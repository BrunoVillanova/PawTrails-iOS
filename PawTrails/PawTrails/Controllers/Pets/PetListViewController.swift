//
//  PetListViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 17/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SDWebImage

class PetListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var isFirstTimeViewAppears = true
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate let disposeBag = DisposeBag()
    fileprivate let dataSource = RxTableViewSectionedReloadDataSource<PetListSection>()
    fileprivate let companyLogoImageView = UIImageView(image: UIImage(named: "CompanyLogoColorSmall"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstTimeViewAppears {
            isFirstTimeViewAppears = false
            refreshControl.beginRefreshing()
            refreshControl.sendActions(for: .valueChanged)
        } else {
            reloadPets()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let image = companyLogoImageView.image {
            let originY = tableView.bounds.size.height - (image.size.height+self.bottomSafeAreaHeight)
            companyLogoImageView.frame = CGRect(x: 0, y: originY, width: image.size.width, height: image.size.height)
            var center: CGPoint = companyLogoImageView.center
            center.x = tableView.bounds.size.width/2.0
            companyLogoImageView.center = center
        }
        
        tableView.dropShadow()
    }
    
    fileprivate func initialize() {
        configureNavigationBar()
        bindData()
    }
    
    fileprivate func configureNavigationBar() {
    
        let addPetButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addPetButtonAction))
        navigationItem.rightBarButtonItem = addPetButton
        
        if let navigationController = self.navigationController as? PTNavigationViewController {
            navigationController.showNavigationBarDropShadow = true
        }
        
        self.navigationItem.title = "My Pets"
    }
    
    @objc fileprivate func addPetButtonAction(_ sender: Any) {
        appDelegate.showPetWizardModally(true)
    }
    
    @objc fileprivate func reloadPets() {
        retrievePets()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    fileprivate func retrievePets() -> Observable<[PetListSection]> {
        return DataManager.instance.pets()
            .map({ (pets) -> [PetListSection] in
                var sections = [PetListSection]()
                let ownedPets = pets.filter({ $0.isOwner == true })
                let sharedPets = pets.filter({ $0.isOwner == false })
                
                if ownedPets.count > 0 {
                    sections.append(PetListSection(header: "My Own Pets", items: ownedPets))
                }
                
                if sharedPets.count > 0 {
                    sections.append(PetListSection(header: "Shared with Me", items: sharedPets))
                }
                
//                self.noPetsFound.isHidden = pets.count > 0;
                return sections
            })
    }
    
    fileprivate func bindData() {
//        noPetsFound.isHidden = true
        tableView.tableFooterView = UIView()
        tableView.addSubview(companyLogoImageView)
        tableView.delegate = self
        
        refreshControl.backgroundColor = UIColor.secondary
        refreshControl.tintColor = UIColor.primary
        tableView.addSubview(refreshControl)
        
        
        refreshControl.rx.controlEvent(.valueChanged)
            .flatMap{ [unowned self] _ in
                return self.retrievePets().do(onError: { (error) in
                    self.refreshControl.endRefreshing()
                }, onCompleted: {
                    self.refreshControl.endRefreshing()
                })
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        dataSource.configureCell = { dataSource, tableView, indexPath, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PetListCell
            cell.configure(element)
            return cell
        }
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(PetSection.Item.self))
            .bind { [unowned self] indexPath, item in
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.goToPetDetails(item)
            }
            .disposed(by: disposeBag)
        
        let notificationIdentifier: String = "petAdded"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPets), name: NSNotification.Name(rawValue: notificationIdentifier), object: nil)
    }
    
    fileprivate func goToPetDetails(_ pet: Pet) {
        if let petDetailsViewController = ViewController.petDetail.viewController as? TabPageViewController {
            petDetailsViewController.pet = pet
            self.navigationController?.pushViewController(petDetailsViewController, animated: true)
        }
    }
}

extension PetListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = section == 0 ? "My Own Pets" : "Shared with Me"
        return PTTableViewHeader(title)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
}


fileprivate struct PetListSection {
    var header: String
    var items: [Item]
}

extension PetListSection: SectionModelType {
    typealias Item = Pet
    
    init(original: PetListSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class PetListCell: UITableViewCell {
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var statusTimeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusView: PTDeviceStatusView!
    @IBOutlet weak var mainView: UIView!
    
    var currentPet: Pet?
    var disposable: Disposable?
    var showTopBorder: Bool = true {
        didSet {
            updateLayout()
        }
    }
    var showBottomBorder: Bool = true {
        didSet {
            updateLayout()
        }
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = .none
    }
    
    fileprivate func resetContent() {
        currentPet = nil
        petNameLabel.text = nil
        petImageView.image = nil
        statusTimeLabel.text = nil
        addressLabel.text = nil
    }
    
    fileprivate func updateLayout() {
        
        var corners: UIRectCorner = []
        
        if showTopBorder && showBottomBorder {
            corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        } else if showTopBorder {
            corners = [.topLeft, .topRight]
        } else if showBottomBorder {
            corners = [.bottomLeft, .bottomRight]
        }
        
        mainView.roundCorners(corners: corners, radius: 4)
        
        petImageView.layer.cornerRadius = petImageView.frame.size.height/2.0
//        mainView.dropShadow(color: PTConstants.colors.darkGray, opacity: 0.8, offSet: CGSize(width: 0, height: 10), radius: 10, scale: true)
        
        mainView.clipsToBounds = false
        mainView.layer.masksToBounds = false
        mainView.layer.shadowOffset = CGSize(width: 0, height: 0)
        mainView.layer.shadowRadius = 50
        mainView.layer.shadowColor = PTConstants.colors.newLightGray.cgColor
        mainView.layer.shadowOpacity = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    func configure(_ pet: Pet) {
        
        petImageView.layer.masksToBounds = true
        self.currentPet = pet
        
        DispatchQueue.main.async {
            self.disposable?.dispose()
            
            self.resetContent()
            
            self.petNameLabel.text = pet.name
            
            if let petImageUrlString = pet.imageURL {
                let petImageUrl = URL(string: petImageUrlString)
                self.petImageView.sd_setImage(with: petImageUrl, completed: nil)
            }
            
            self.addressLabel.text = "Bring your device outdoor to get location.."
            
            self.disposable = DataManager.instance.petDeviceData(pet.id, gpsMode: .smart).subscribe(onNext: {[weak self] (petDeviceData) in
                if let petDeviceData = petDeviceData {
                    self?.statusView.configure(petDeviceData, animated: true)
                    
                    if let point = petDeviceData.deviceData.point {
                        self?.addressLabel.text = "Getting Address..."
                        point.getFullFormatedAddress(handler: {[weak self] (address, error) in
                            
                            if error != nil {
                                self?.addressLabel.text = ""
                            } else {
                                self?.addressLabel.text = address
                            }
                            
                        })
                    }
                    
                }
            })
        }
    }
}

