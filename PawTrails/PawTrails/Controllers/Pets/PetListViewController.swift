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
    @IBOutlet weak var noPetsView: UIView!
    
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
                
                self.noPetsView.isHidden = pets.count > 0;
                return sections
            })
    }
    
    fileprivate func bindData() {
        noPetsView.isHidden = true
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(companyLogoImageView)
        
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
            let numberOfRows = dataSource.tableView(tableView, numberOfRowsInSection: indexPath.section)
            let isFirstRow:Bool = indexPath.row == 0
            let isLastRow:Bool = indexPath.row == numberOfRows-1
            cell.isFirstRow = isFirstRow
            cell.isLastRow = isLastRow
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
    
    @IBAction func addFirstPetAction(_ sender: Any) {
        self.addPetButtonAction(sender)
    }
}

extension PetListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = section == 0 ? "My Own Pets" : "Shared with Me"
        return PTTableViewHeader(title)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 48
        }
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
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var statusTimeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusView: PTDeviceStatusView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    var currentPet: Pet?
    var disposable: Disposable?
    var isFirstRow: Bool = true {
        didSet {
            updateLayout()
        }
    }
    var isLastRow: Bool = true {
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

        let shadowRadius:CGFloat = 4
        var corners: UIRectCorner = []
        
        if isFirstRow && isLastRow {
            corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            topLayoutConstraint.constant = 16
            bottomLayoutConstraint.constant = 16
            separatorView.isHidden = true
        } else if isFirstRow {
            corners = [.topLeft, .topRight]
            topLayoutConstraint.constant = 16
            bottomLayoutConstraint.constant = 0
            separatorView.isHidden = false
        } else if isLastRow {
            corners = [.bottomLeft, .bottomRight]
            topLayoutConstraint.constant = 0
            bottomLayoutConstraint.constant = 16
            separatorView.isHidden = true
        } else {
            topLayoutConstraint.constant = 0
            bottomLayoutConstraint.constant = 0
            separatorView.isHidden = false
        }
        
        mainView.roundCorners(corners: corners, radius: 4)

        petImageView.layer.masksToBounds = true
        petImageView.layer.cornerRadius = petImageView.frame.size.height/2.0

        shadowView.clipsToBounds = false
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOffset = CGSize(width: -2, height: -2)
        shadowView.layer.shadowRadius = shadowRadius
        shadowView.layer.shadowColor = PTConstants.colors.darkGray.cgColor
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: mainView.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 4, height: 4)).cgPath
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    func configure(_ pet: Pet) {
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

