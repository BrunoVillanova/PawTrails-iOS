 //
 //  PetsViewController.swift
 //  PawTrails
 //
 //  Copyright © 2017 AttitudeTech. All rights reserved.
 //
 
 import UIKit
 import RxSwift
 import SDWebImage
 import RxCocoa
 import RxDataSources
 import Differentiator
 
 class PetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPetsFound: UIView!
    @IBOutlet weak var addMyFirstPetButton: UIButton!
    
    fileprivate var pets = [Int:IndexPath]()
    fileprivate var petIdss = [Int]()
    fileprivate var petDeviceData: [PetDeviceData]?
    fileprivate let disposeBag = DisposeBag()
    fileprivate var iphoneX = false
    
    fileprivate let dataSource = RxTableViewSectionedReloadDataSource<PetSection>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidLayoutSubviews() {
        
        if #available(iOS 11.0, *) {
            if ((UIApplication.shared.keyWindow?.safeAreaInsets.top)! > CGFloat(0.0)) {
                iphoneX = true
                Reporter.debugPrint("iphone x")
            } else {
                self.tabBarController?.tabBar.invalidateIntrinsicContentSize()
                self.tabBarController?.tabBar.isHidden = false
            }
        }
    }
    
    @IBAction func addMyFirstPetButtonTapped(_ sender: Any) {
        self.goToAddDevice()
    }
    
    @IBAction func addDeviceButtonTapped(_ sender: Any) {
        self.goToAddDevice()
    }
    
    func reloadPets() {
        DataManager.instance.pets()
            .map({ (pets) -> [PetSection] in
                let owned = pets.filter({ $0.isOwner == true })
                let shared = pets.filter({ $0.isOwner == false })
                let sections = [
                    PetSection(header: "Owned", items: owned),
                    PetSection(header: "Shared", items: shared)
                ]
                
                self.noPetsFound.isHidden = pets.count > 0;
                return sections
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    fileprivate func initialize() {
        
        noPetsFound.isHidden = true
        tableView.tableFooterView = UIView()
        
        let notificationIdentifier: String = "petAdded"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPets), name: NSNotification.Name(rawValue: notificationIdentifier), object: nil)
        
        addMyFirstPetButton.backgroundColor = UIColor.primary
        addMyFirstPetButton.round()
        

        dataSource.configureCell = { dataSource, tableView, indexPath, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PetCell
            cell.configure(element)
            return cell
        }

        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        DataManager.instance.pets()
            .map({ (pets) -> [PetSection] in
                let owned = pets.filter({ $0.isOwner == true })
                let shared = pets.filter({ $0.isOwner == false })
                let sections = [
                    PetSection(header: "Owned", items: owned),
                    PetSection(header: "Shared", items: shared)
                ]
                
                self.noPetsFound.isHidden = pets.count > 0;
                return sections
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(PetSection.Item.self))
            .bind { [unowned self] indexPath, item in
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.goToPetDetails(item)
            }
            .disposed(by: disposeBag)
    }
    
    fileprivate func goToPetDetails(_ pet: Pet) {
        if let petDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetDetails") as? TabPageViewController {
            petDetailsViewController.pet = pet
            
            self.navigationController?.pushViewController(petDetailsViewController, animated: true)
        }
    }
    
    
    fileprivate func addButton(){
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "StopTripButton-1x-png"), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        button.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -2).isActive = true
        if let tabbarhieght = self.tabBarController?.tabBar.frame.size.height {
            button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(tabbarhieght + 5)).isActive = true
        }
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    
    fileprivate func goToAddDevice() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "StepOneViewController") as? StepOneViewController {
            
            let navigationController = UINavigationController.init(rootViewController: vc)
            // Transparent navigation bar
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.isTranslucent = true
            navigationController.navigationBar.backgroundColor = UIColor.clear
            navigationController.navigationBar.tintColor = UIColor.white
            navigationController.navigationBar.topItem?.title = " "
            navigationController.navigationBar.backItem?.title = " "
            
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    
    @objc fileprivate func buttonAction(sender: UIButton!) {
        Reporter.debugPrint("Button tapped")
    }
 }
 
 extension PetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
 }
 
 
 struct PetSection {
    var header: String
    var items: [Item]
 }
 
 extension PetSection: SectionModelType {
    typealias Item = Pet
    
    init(original: PetSection, items: [Item]) {
        self = original
        self.items = items
    }
 }
 
 class PetCell: UITableViewCell {
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deviceStatusView: PTDeviceStatusView!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    var currentPet: Pet?
    var disposable: Disposable?
    
    fileprivate let disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposable?.dispose()
        currentPet = nil
        titleLabel.text = nil
        petImageView.image = nil
        subtitleLabel.text = ""
        deviceStatusView.resetAllSubviews()
    }
    
    func configure(_ pet: Pet) {
        DispatchQueue.main.async {
            self.currentPet = pet
            self.titleLabel.text = pet.name
            
            if let imageUrl = pet.imageURL {
                self.petImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: #imageLiteral(resourceName: "PetPlaceholderImage"), options: [.continueInBackground])
            } else {
                self.petImageView.image = nil
            }
            
            self.subtitleLabel.text = "Bring your device outdoor to get location.."
            
            self.disposable = DataManager.instance.lastPetDeviceData(pet).subscribe(onNext: {[weak self] (petDeviceData) in
                if let petDeviceData = petDeviceData, let pet = self?.currentPet, petDeviceData.pet.id == pet.id {
                    self?.deviceStatusView.configure(petDeviceData, animated: true)
                    petDeviceData.deviceData.point.getFullFormatedAddress(handler: {[weak self] (address) in
                        self?.subtitleLabel.text = address
                    })
                }
            })
        }
    }
 }
