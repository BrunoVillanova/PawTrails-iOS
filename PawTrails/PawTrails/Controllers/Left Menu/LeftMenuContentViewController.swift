//
//  LeftMenuContentViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 09/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift
import SideMenu
import SDWebImage

class LeftMenuContentViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    fileprivate final let menuItems = [
        MenuItem("Live Tracking",
                 imageName: "LiveTrackingMenuIcon",
                 viewController: ViewController.liveTracking),
        MenuItem("My Pets",
                 imageName: "MyPetsMenuIcon",
                 viewController: ViewController.petList),
        MenuItem("My Profile",
                 imageName: "MyProfileMenuIcon",
                 viewController: ViewController.myProfile),
        MenuItem("Vet Recommendations",
                 imageName: "VetRecommendationsMenuIcon",
                 viewController: ViewController.BCSInitial),
        MenuItem("Device Finder",
                 imageName: "DeviceFinderMenuIcon",
                 action: {sender in
                    if let sender = sender as? LeftMenuContentViewController {
                        sender.showComingSoonAlert("Device finder")
                    }
                 }),
        MenuItem("Settings",
                 imageName: "SettingsMenuIcon",
                 viewController: ViewController.settings),
        MenuItem("Support",
                 imageName: "SupportMenuIcon",
                 viewController: ViewController.support)
        ]
    
    fileprivate final let disposeBag = DisposeBag()
    fileprivate var selectedMenuItem: Variable<MenuItem?> = Variable(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
        configureNavigatonBar()
        
        Observable.combineLatest(Observable.just(menuItems), selectedMenuItem.asObservable())
            .map({ (menuItems, selectedMenuItem) -> [MenuItem] in
                return menuItems
            })
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: MenuItemCell.self)) { (_, element, cell) in
                cell.selectionStyle = .none
                cell.configure(element)
            }.disposed(by: disposeBag)
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(MenuItem.self))
            .bind { [unowned self] indexPath, item in
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.selectedMenuItem.value = item
                
                if let viewController = item.viewController {
                    self.appDelegate.setRootController(viewController)
                    self.dismiss(animated: true, completion: {
                        
                    })
                } else if let action = item.action {
                    action(self)
                }
                
            }
            .disposed(by: disposeBag)
        
        
        if let menuHeaderView = self.tableView.tableHeaderView, let imageView = menuHeaderView.viewWithTag(200) as? UIImageView {
            imageView.layer.cornerRadius = imageView.frame.size.width/2.0
            imageView.clipsToBounds = true
            imageView.image = UIImage(named: "menu-me-1x-png")
        }
        
        DataManager.instance.getUser { (error, user) in
            if let user = user {
                self.configureMenuHeader(user.name, email: user.email, imageUrl: user.imageURL)
            }
        }
    }
    
    func showComingSoonAlert(_ functionTitle: String) {
    
        self.dismiss(animated: true) {
            let title = "Coming Soon"
            let infoText = "\(functionTitle) function is currently under construction. We are working hard on the new feature, please check back later."

            let alertView = PTAlertViewController(title, infoText: infoText, buttonTypes: [AlertButtontType.ok], titleBarStyle: .yellow, alertResult: {alert, result in
                alert.dismiss(animated: true, completion: nil)
            })

            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                rootViewController.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func configureMenuHeader(_ name: String?, email: String?, imageUrl: String?) {
        
        if let menuHeaderView = self.tableView.tableHeaderView {
            
            let imageView = menuHeaderView.viewWithTag(200) as? UIImageView
            let titleLabel = menuHeaderView.viewWithTag(201) as? UILabel
            let subtitleLabel = menuHeaderView.viewWithTag(202) as? UILabel
            
            if let imageUrl = imageUrl {
                let imageUrl = URL(string: imageUrl)
                imageView?.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "menu-me-1x-png"), options: .highPriority, completed: { (image, error, cscheType, url) in
                    imageView!.layer.cornerRadius = imageView!.frame.size.width/2.0
                    imageView?.clipsToBounds = true
                })
            }
            
            titleLabel?.text = name
            subtitleLabel?.text = email
        }
    }
    
    fileprivate func configureNavigatonBar() {
        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.backItem?.title = " "
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }

}

class MenuItemCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    
    func configure(_ menuItem: MenuItem) {
        
        if let imageName = menuItem.imageName, let iconImage = UIImage(named: imageName) {
            iconImageView.image = iconImage
        }
        
        if let title = menuItem.title {
            itemTitleLabel.text = title
        }
    }
}

typealias ActionCallback = (_ sender: Any) -> Void

struct MenuItem {
    var title: String?
    var imageName: String?
    var viewController: ViewController?
    var isModal: Bool?
    var action: ActionCallback?
}

extension MenuItem {
    init(_ title: String?, imageName: String?, viewController: ViewController? = nil, isModal: Bool? = false, action: ActionCallback? = nil) {
        self.title = title
        self.imageName = imageName
        self.viewController = viewController
        self.isModal = isModal
        self.action = action
    }
}

class PTMenuBackgroundView: UIView {
    
    var backgroundImage: UIImage?
    let backgroundLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    fileprivate func setupView() {
        self.layer.insertSublayer(backgroundLayer, at: 0)
        
        var imageName: String?
        
        switch UIDevice.current.screenType {
            case .iPhone4_4S:
                imageName = "MenuBackgroundImage-iPhone4S"
            case .iPhones_5_5s_5c_SE:
                imageName = "MenuBackgroundImage-iPhoneSE"
            case .iPhones_6_6s_7_8:
                imageName = "MenuBackgroundImage-iPhone8"
            case .iPhones_6Plus_6sPlus_7Plus_8Plus:
                imageName = "MenuBackgroundImage-iPhone8Plus"
            case .iPhoneX:
                imageName = "MenuBackgroundImage-iPhoneX"
            default:
                break
        }
        
        if let imageName = imageName, let image = UIImage(named: imageName) {
            backgroundImage = image
            backgroundLayer.contents = backgroundImage?.cgImage
            SideMenuManager.default.menuWidth = image.size.width/UIScreen.main.scale
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = self.bounds
    }
}
