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

//
//
class AddEditSafeZOneController: UIViewController, CLLocationManagerDelegate, AddEditSafeZoneView {
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    var slider: UISlider?
    var sliderLabel: UILabel?
    

    let icons = ["buildings-dark-1x", "fountain-dark-1x", "girl-and-boy-dark-1x" , "home-dark-1x", "palm-tree-shape-dark-1x", "park-dark-1x"]
    var selectedIcon: Int!
    
    fileprivate var opened:CGFloat = 360.0, closed:CGFloat = 600
    fileprivate var shape:Shape = Shape.circle
    fileprivate var changingRegion = false
    fileprivate var focused = true
    fileprivate var fence:Fence!
    fileprivate let fenceSide: Double = 100.0 //meters
    fileprivate var fenceDistance:Int = 100 //meters
    fileprivate var  manager = CLLocationManager()

    fileprivate let presenter = AddEditSafeZonePresenter()
    fileprivate var petLocation:MKLocation? = nil
    fileprivate var updatingPetLocation = false


    var safezone: SafeZone?
    var petId: Int!
    var isOwner: Bool!
    var ZBdropDownViews: [UIView]?
    var yNDropDownMenu: YNDropDownMenu?
    
    
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Add Safe zone"
        
        presenter.attachView(self, safezone: safezone)
        map.showsUserLocation = true
        map.showsScale = false
        map.showsCompass = false
        map.mapType = .hybrid
        map.delegate = self
    
        manager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined { manager.requestWhenInUseAuthorization() }
        
      


        
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "")
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
            
                self.yNDropDownMenu = YNDropDownMenu(frame: CGRect(x: 0, y: 89, width: UIScreen.main.bounds.size.width, height: 38),
                                                     dropDownViews: _ZBdropDownViews, dropDownViewTitles: ["Show SafeZone Settings"])
            } else {
                self.yNDropDownMenu = YNDropDownMenu(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: 38),
                                                     dropDownViews: _ZBdropDownViews, dropDownViewTitles: ["Show SafeZone Settings"])
            }
            
 
            
            
                
            
            
            
            
            self.yNDropDownMenu?.setImageWhen(normal: UIImage(named: "arrow-show-1x"), selected: UIImage(named: "arrow-show-1x"), disabled: UIImage(named: "arrow-show-1x"))
            self.yNDropDownMenu?.bottomLine.backgroundColor = UIColor.black
            self.yNDropDownMenu?.bottomLine.isHidden = false
            
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
    
    
    override func viewDidLayoutSubviews() {

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
            
           
            let sonhugoCoordinate = CLLocationCoordinate2D(latitude: 39.592217, longitude: 2.662322)
            
            self.map.centerOn(sonhugoCoordinate, with: 50, animated: false)
            self.map.load(with: sonhugoCoordinate, shape: shape, into: _view, callback: { (fence) in
                self.fence = fence
                self.updateFenceDistance()
            })
        }
    }
    
    deinit {
        presenter.deteachView()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if updatingPetLocation {
            presenter.stopPetGPSUpdates(of: petId)
        }
    }
    

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
            fence.isIdle = fenceDistanceIsIdle()
            self.distanceLabel.text = fenceDistance < 1000 ? "\(fenceDistance) m" : "\(Double(fenceDistance)/1000.0) km"
        }
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
        
    }

    @IBAction func saveBtnPressed(_ sender: Any) {
        if let petId = petId {
            if fence.isIdle {
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
                
            }else{
                alert(title: "", msg: "The area is too small. Please, zoom out.", type: .red)
            }
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
    
    func petLocationFailed(){
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if fence != nil {
            updateFenceDistance()
            if !fenceDistanceIsIdle() && !changingRegion {
                changingRegion = true
                updateFenceDistance()
                changingRegion = false
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return mapView.getRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapView.getAnnotationView(annotation: annotation)
    }

}


