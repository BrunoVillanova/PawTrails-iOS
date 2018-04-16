//
//  AddEditSafeZOneController.swift
//  PawTrails
//
//  Created by Marc Perello on 06/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import YNDropDownMenu
import MapKit
import SkyFloatingLabelTextField
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

class AddEditSafeZOneController: UIViewController, CLLocationManagerDelegate, AddEditSafeZoneView {
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var map: PTMapView!
    @IBOutlet weak var focusPetButton: UIButton!
    var slider: UISlider?
    var sliderLabel: UILabel?
    fileprivate var petsCollectionView: UICollectionView?
    fileprivate var selectedPet: Variable<Pet?> = Variable(nil)
    
    
    let icons = ["buildings-dark-1x", "fountain-dark-1x", "girl-and-boy-dark-1x" , "home-dark-1x", "palm-tree-shape-dark-1x", "park-dark-1x"]
    var selectedIcon: Int!
    
    fileprivate var opened:CGFloat = 360.0, closed:CGFloat = 600
    fileprivate var shape:Shape = Shape.circle
    fileprivate var changingRegion = false
    fileprivate var focused = true
    fileprivate var fence:Fence!
    fileprivate let fenceSide: Double = 100.0 //meters
    fileprivate var fenceDistance:Int = 100 //meters
    fileprivate var manager = CLLocationManager()
    fileprivate let presenter = AddEditSafeZonePresenter()
    fileprivate var petLocation:MKLocation? = nil
    fileprivate var updatingPetLocation = false
    fileprivate final let disposeBag = DisposeBag()
    
    var safezone: SafeZone?
    var petId: Int!
    var isOwner: Bool!
    var ZBdropDownViews: [UIView]?
    var yNDropDownMenu: YNDropDownMenu?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
        self.navigationItem.title = "Add Safe zone"
        
        presenter.attachView(self, safezone: safezone)
        map.showsUserLocation = true
        map.showsScale = false
        map.showsCompass = false
        map.mapType = .hybrid

        
        manager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined { manager.requestWhenInUseAuthorization() }
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor.white
        
        
        ZBdropDownViews = Bundle.main.loadNibNamed("SettingsView", owner: nil, options: nil) as? [UIView]
        if let vieww = ZBdropDownViews?.first as? SettingsViews {
            if let safezone = safezone {
                
                self.navigationItem.title = "Edit SafeZone"
                
                vieww.nameTextField.text = safezone.name
                shape = safezone.shape
                
                if !isOwner {
                    self.saveBtn.isEnabled = false
                    view.isHidden = true
                }
            }
        }
        
        if let _ZBdropDownViews = ZBdropDownViews {
            
            if UIScreen.main.nativeBounds.height == 2436 {
                
                self.yNDropDownMenu = YNDropDownMenu(frame: CGRect(x: 0, y: 88, width: UIScreen.main.bounds.size.width, height: 38),
                                                     dropDownViews: _ZBdropDownViews, dropDownViewTitles: ["Show SafeZone Settings"])
            } else {
                self.yNDropDownMenu = YNDropDownMenu(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: 38),
                                                     dropDownViews: _ZBdropDownViews, dropDownViewTitles: ["Show SafeZone Settings"])
            }
            
            
            self.yNDropDownMenu?.setImageWhen(normal: UIImage(named: "arrow-show-1x"), selected: UIImage(named: "arrow-show-1x"), disabled: UIImage(named: "arrow-show-1x"))
            self.yNDropDownMenu?.setLabelFontWhen(normal: UIFont(name: "Montserrat-Regular", size: 14)!, selected: UIFont(name: "Montserrat-Regular", size: 14)!, disabled: UIFont(name: "Montserrat-Regular", size: 14)!)
            self.yNDropDownMenu?.setLabelColorWhen(normal: PTConstants.colors.darkGray, selected: PTConstants.colors.darkGray, disabled: PTConstants.colors.darkGray)


            self.yNDropDownMenu?.bottomLine.backgroundColor = PTConstants.colors.darkGray
            self.yNDropDownMenu?.bottomLine.isHidden = false
            self.yNDropDownMenu?.blurEffectStyle = .light
            
            if let settingsView = ZBdropDownViews?.first as? SettingsViews {
                settingsView.nameTextField.placeholder = "Name of the safezone?"
                settingsView.nameTextField.title = "Your safeZone name"
                settingsView.nameTextField.titleColor = UIColor(red: 155/255, green: 153/255, blue: 169/255, alpha: 1)
                
                
                settingsView.collectionView.delegate = self
                settingsView.collectionView.dataSource = self
                settingsView.collectionView.allowsMultipleSelection = false
                
                settingsView.collectionView.contentInset = UIEdgeInsetsMake(0, 2, 0, 16)
                let nib = UINib(nibName: "IconCell", bundle: nil)
                settingsView.collectionView?.register(nib, forCellWithReuseIdentifier: "myCell")
                settingsView.collectionView.showsHorizontalScrollIndicator = false
                settingsView.collectionView.showsVerticalScrollIndicator = false
                
                
                settingsView.circleBtn.shadow()
                settingsView.squareBtn.shadow()
                settingsView.circleBtn.addTarget(self, action: #selector(handlePressed(sender:)), for: .touchUpInside)
                settingsView.squareBtn.addTarget(self, action: #selector(handleSquaredBtnPressed(sender:)), for: .touchUpInside)
                
                slider = settingsView.slider
                if let slider = slider {
                    slider.addTarget(self, action: #selector(handleSliderSlided(sender:)), for: .valueChanged)
                }
                
                
                if let safezone = safezone {
                    self.navigationItem.title = "Edit SafeZone"
                    settingsView.nameTextField.text = safezone.name
                    shape = safezone.shape
                    
                    if !isOwner {
                        view.isHidden = true
                        self.navigationItem.title = "SafeZone"
                    }
                }
                
            }
            
            self.yNDropDownMenu?.alwaysSelected(at: 0)
            
            if let view = self.yNDropDownMenu {
                self.view.addSubview(view)
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let _view = UIView(frame: UIScreen.main.bounds)
        
        if let safezone = safezone {
            guard let center = safezone.point1?.coordinates else { return }
            guard let topCenter = safezone.point2?.coordinates else { return }
            
            self.map.load(with: center, topCenter: topCenter, shape: self.shape, into: _view, callback: { (fence) in
                if let fence = fence {
                    self.fence = fence
                    self.updateFenceDistance()
                }
            })
            
        }else{
            
            self.map.showAnnotations([self.map.userLocation], animated: false)
            let topLeftCoordinate = map.coordinate(from: self.map.userLocation.coordinate, distance: 20)
            self.map.load(with: self.map.userLocation.coordinate, topCenter: topLeftCoordinate, shape: self.shape, into: _view, callback: { (fence) in
                if let fence = fence {
                    self.fence = fence
                    self.updateFenceDistance()
                }
            })
            
//            self.map.load(with: self.map.userLocation.coordinate, shape: shape, into: _view, callback: { (fence) in
//                self.fence = fence
//                self.updateFenceDistance()
//            })
        }
    }
    
    deinit {
        presenter.deteachView()
        NotificationCenter.default.removeObserver(self)
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    fileprivate func initialize() {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        configureNavigationBar()
        
        map.showGpsUpdates()
        
        let layout = UICollectionViewFlowLayout()
        // Now setup the flowLayout required for drawing the cells
        let space = 5.0 as CGFloat
        layout.itemSize = CGSize(width:60, height:60)
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        
        petsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        petsCollectionView!.register(PetCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        DataManager.instance.pets().bind(to: petsCollectionView!.rx.items(cellIdentifier: "cell", cellType: PetCollectionViewCell.self)) { (row, pet, cell) in
                cell.configure(pet)

        }.disposed(by: disposeBag)
        
        petsCollectionView!.rx.modelSelected(Pet.self)
            .bind(to: self.selectedPet)
            .disposed(by: disposeBag)
        
        
        petsCollectionView!.isHidden = true
        petsCollectionView!.backgroundColor = .clear
        petsCollectionView!.semanticContentAttribute = .forceRightToLeft
        
        self.view.insertSubview(petsCollectionView!, belowSubview: focusPetButton)
        
        petsCollectionView!.snp.makeConstraints { (make) in
            make.top.equalTo(focusPetButton)
            make.trailing.equalTo(focusPetButton.snp.leading).offset(-16)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        selectedPet.asObservable().subscribe(onNext: { (pet) in
            if let pet = pet {
                self.map.focusOnPet(pet)
            }
        }).disposed(by: disposeBag)
        
        map.regionDidChange = {map, animated in
            if self.fence != nil {
                self.updateFenceDistance()
                if !self.fenceDistanceIsIdle() && !self.changingRegion {
                    self.changingRegion = true
                    self.updateFenceDistance()
                    self.changingRegion = false
                }
            }
            
        }
    }
    
    fileprivate func configureNavigationBar() {
        self.navigationController?.navigationBar.tintColor = PTConstants.colors.newRed
        
//        let button = UIButton.init(type: .custom)
//        button.setImage(UIImage.init(named:""), for: .normal)
//        let leftBarButton = UIBarButtonItem.init(customView: button)
//        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func geoCodeFence() -> (Point,Point) {
        let point1 = Point(coordinates: map.convert(fence.center, toCoordinateFrom: view))
        let point2 = Point(coordinates: map.convert(fence.topCenter, toCoordinateFrom: view))
        return (point1, point2)
    }
    
    
    func handleSliderSlided(sender: UISlider) {
        let miles = Double(sender.value)
        let delta = miles / 69.0
        var currentRegion = self.map.region
        currentRegion.span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let (lat, long) = (currentRegion.center.latitude, currentRegion.center.longitude)
        let coordinate =  CLLocationCoordinate2D(latitude: lat, longitude: long)
        map.centerOn(coordinate, with: miles, animated: true)
    }
    
    func updateFenceDistance() {
        if let fence = fence {
            let x0y0 = map.convert(CGPoint(x: fence.x0, y: fence.y0), toCoordinateFrom: view)
            let xfy0 = map.convert(CGPoint(x: fence.xf, y: fence.y0), toCoordinateFrom: view)
            
            fenceDistance = Int(round(x0y0.location.distance(from: xfy0.location)))
            
            var radius = fenceDistance/2
            
            if radius < 20 {
                radius = 20
                fenceDistance = 40
            }
            
            fence.isIdle = fenceDistanceIsIdle()
            
            self.distanceLabel.text = fenceDistance < 1000 ? "\(radius) m" : "\(Double(radius)/1000.0) km"
            
            print("\(map.getZoom())")
        }
    }
    
    fileprivate func showAlertMinimumFence() {
        let title = "Fence Minimum Distance"
        let infoText = "The fence minimum distance is 20m"
        
        let alertView = PTAlertViewController(title, infoText: infoText, buttonTypes: [AlertButtontType.ok], titleBarStyle: .yellow, alertResult: {alert, result in
            alert.dismiss(animated: true, completion: nil)
        })
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    func fenceDistanceIsIdle() -> Bool {
        return fenceDistance >= Int(fenceSide)
    }
    
    @IBAction func userLocationBtnPressed(_ sender: Any) {
        
        focused = false
        
        if !map.userLocation.coordinate.isDefaultZero {
            map.centerOn(map.userLocation.coordinate, with: 51, animated: true)
        }else{
            let status = CLLocationManager.authorizationStatus()
            if status == .notDetermined {
                manager.requestWhenInUseAuthorization()
            }else if status == .denied {
                popUpUserLocationDenied()
            }else {
                //                beginLoadingLocation()
                manager.requestLocation()
            }
        }
        
    }
    
    @IBAction func startTripBtnPressed(_ sender: Any) {
        if let petsCollectionView = petsCollectionView {
            if (!petsCollectionView.isHidden) {
                petsCollectionView.slideInAffect(direction: kCATransitionFromLeft)
                petsCollectionView.isHidden = true
            } else {
                petsCollectionView.slideInAffect(direction: kCATransitionFromRight)
                petsCollectionView.isHidden = false
            }
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        if let petId = petId {
            let id = safezone?.id ?? 0
            if let settingsView = ZBdropDownViews?.first as? SettingsViews {
                if selectedIcon != nil {
                    presenter.addEditSafeZone(safezoneId: id, name: settingsView.nameTextField.text, shape: shape, active: true, points: geoCodeFence(), imageId: selectedIcon, into: petId)
                } else if let number = safezone?.image {
                    presenter.addEditSafeZone(safezoneId: id, name: settingsView.nameTextField.text, shape: shape, active: true, points: geoCodeFence(), imageId:Int(number) , into: petId)
                } else {
                    presenter.addEditSafeZone(safezoneId: id, name: settingsView.nameTextField.text, shape: shape, active: true, points: geoCodeFence(), imageId: 0 , into: petId)
                }
                
            }
            
//            if fence.isIdle {
//                let id = safezone?.id ?? 0
//                if let settingsView = ZBdropDownViews?.first as? SettingsViews {
//                    if selectedIcon != nil {
//                        presenter.addEditSafeZone(safezoneId: id, name: settingsView.nameTextField.text, shape: shape, active: true, points: geoCodeFence(), imageId: selectedIcon, into: petId)
//                    } else if let number = safezone?.image {
//                        presenter.addEditSafeZone(safezoneId: id, name: settingsView.nameTextField.text, shape: shape, active: true, points: geoCodeFence(), imageId:Int(number) , into: petId)
//                    } else {
//                        presenter.addEditSafeZone(safezoneId: id, name: settingsView.nameTextField.text, shape: shape, active: true, points: geoCodeFence(), imageId: 0 , into: petId)
//                    }
//
//                }
//
//            }else{
//                alert(title: "", msg: "The area is too small. Please, zoom out.", type: .red)
//            }
        }
        
    }
    
    
    func handlePressed(sender: UIButton) {
        
        if let settingsView = ZBdropDownViews?.first as? SettingsViews {
            settingsView.circleBtn.backgroundColor = UIColor.darkGray
            settingsView.circleBtn.setTitleColor(.white, for: .normal)
            
            settingsView.squareBtn.backgroundColor = UIColor(red: 233/255, green: 234/255, blue: 236/255, alpha: 1)
            settingsView.squareBtn.setTitleColor(.black, for: .normal)
        }
        
        fence.shape = .circle
        shape = .circle
    }
    
    
    func handleSquaredBtnPressed(sender: UIButton) {
        if let settingsView = ZBdropDownViews?.first as? SettingsViews {
            settingsView.squareBtn.backgroundColor = UIColor.darkGray
            settingsView.squareBtn.setTitleColor(.white, for: .normal)
            
            settingsView.circleBtn.backgroundColor = UIColor(red: 233/255, green: 234/255, blue: 236/255, alpha: 1)
            settingsView.circleBtn.setTitleColor(.black, for: .normal)
        }
        fence.shape = .square
        shape = .square
    }
    
    //MARK: - AddEditSafeZoneView
    func errorMessage(_ error: ErrorMsg) {
        alert(title: "", msg: error.msg)
    }
    
    func success() {
        self.navigationController?.popViewController(animated: true)
        self.petId = nil
        self.safezone = nil
        self.isOwner = nil
        self.popUp(title: "Success", msg: "Safezone has been successfully added/Edited ")
    }
    
    func missingName() {
        
        if let vieww = ZBdropDownViews?.first as? SettingsViews {
            vieww.nameTextField.becomeFirstResponder()
            vieww.nameTextField.shake()
            self.alert(title: "", msg: "Please enter a safe zone name", type: .red, disableTime: 3, handler: nil)
            
            if let view = self.yNDropDownMenu {
                view.showAndHideMenu(at: 0)
            }
        }
    }
    
    func beginLoadingContent() {
        showLoadingView()
    }
    
    func endLoadingContent() {
        hideLoadingView()
    }
    
    func petLocationFailed() {
        updatingPetLocation = false
        endLoadingLocation()
        alert(title: "", msg: "Couldn't locate the pet", type: .red)
    }
    
    func endLoadingLocation() {
        
    }
}


extension AddEditSafeZOneController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! IconCell
        cell.imageView.image = UIImage(named: icons[indexPath.item])
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIcon = self.icons.index(of: self.icons[indexPath.item])
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.backgroundColor = UIColor.groupTableViewBackground
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.backgroundColor = UIColor.clear
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
}

extension AddEditSafeZOneController: MKMapViewDelegate {
    // MARK: - MKMapViewDelegate
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        return mapView.getRenderer(overlay: overlay)
//    }
//    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        return mapView.getAnnotationView(annotation: annotation)
//    }
}

