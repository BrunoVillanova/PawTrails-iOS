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
//
//
class AddEditSafeZOneController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    var slider: UISlider?
    var sliderLabel: UILabel?


    
    var safezone: SafeZone?
    var petId: Int!
    var isOwner: Bool!
    
    fileprivate var opened:CGFloat = 360.0, closed:CGFloat = 600
    fileprivate var shape:Shape = Shape.circle
    fileprivate var changingRegion = false
    fileprivate var focused = true
    fileprivate var fence:Fence!
    fileprivate let fenceSide: Double = 50.0 //meters
    fileprivate var fenceDistance:Int = 50 //meters
    fileprivate var  manager = CLLocationManager()

    fileprivate let presenter = AddEditSafeZonePresenter()
    fileprivate var petLocation:MKLocation? = nil
    fileprivate var updatingPetLocation = false


    
//
    override func viewDidLoad() {
        super.viewDidLoad()
//        presenter.attachView(self, safezone: safezone)
        
    
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
        
       
        let ZBdropDownViews = Bundle.main.loadNibNamed("SettingsView", owner: nil, options: nil) as? [UIView]
        
        
        
        if let vieww = ZBdropDownViews?.first as? SettingsViews {
            vieww.circleBtn.addTarget(self, action: #selector(handlePressed), for: .touchUpInside)
            
            if let safezone = safezone {
                navigationController?.title = "SafeZone"
                vieww.nameTextField.text = safezone.name
                shape = safezone.shape

                if !isOwner {
                   view.isHidden = true
                }

                
            }
            
        }
        
        if let _ZBdropDownViews = ZBdropDownViews {
            let view = YNDropDownMenu(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: 38),
                            dropDownViews: _ZBdropDownViews, dropDownViewTitles: ["Show SafeZone Settings"])
            view.setImageWhen(normal: UIImage(named: "arrow"), selected: UIImage(named: "arrow_sel"), disabled: UIImage(named: "arrow"))
            view.setLabelColorWhen(normal: .black, selected: .black, disabled: .black)
            view.setImageWhen(normal: UIImage(named: "arrow"), selectedTintColor: .clear, disabledTintColor: .black)
            view.bottomLine.backgroundColor = UIColor.black
            view.bottomLine.isHidden = false
            
            if let vieww = ZBdropDownViews?.first as? SettingsViews {
                vieww.nameTextField.placeholder = "Name of the safezone?"
                vieww.nameTextField.title = "Your safeZone name"
//                vieww.nameTextField.titleFont = UIFont(name: "system", size: 20)!
                vieww.nameTextField.titleColor = UIColor(red: 155/255, green: 153/255, blue: 169/255, alpha: 1)
//                vieww.nameTextField.delegate = self
                
                vieww.circleBtn.tintColor = shape == .circle ? UIColor.primary : UIColor.darkGray
                vieww.squareBtn.tintColor = shape == .circle ?  UIColor.darkGray : UIColor.primary

                
                vieww.circleBtn.addTarget(self, action: #selector(handlePressed), for: .touchUpInside)
                 slider = vieww.slider
                
                slider?.setThumbImage(UIImage(named: "SliderBtn"), for: .normal)

                
                
                
                
                
                
                
                slider?.addTarget(self, action: #selector(handleSliderSlided), for: .valueChanged)
                
                
                if let safezone = safezone {
                    navigationController?.title = "SafeZone"
                    vieww.nameTextField.text = safezone.name
                    shape = safezone.shape
                    
                
                    
                    if !isOwner {
                        view.isHidden = true
                    } else {
                        navigationItem.title = "SafeZone"
                    }
                    
                    
                }
                
            }

            view.alwaysSelected(at: 0)

            self.view.addSubview(view)
            
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

    
    func handleSliderSlided() {
        if let sliderr = self.slider {
            let miles = Double(sliderr.value)
            let delta = miles / 69.0
            var currentRegion = self.map.region
            currentRegion.span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            self.map.region = currentRegion

        }

    
    }
    
    func handlePressed() {
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    func updateFenceDistance() {
        if let fence = fence {
            let x0y0 = map.convert(CGPoint(x: fence.x0, y: fence.y0), toCoordinateFrom: view)
            let xfy0 = map.convert(CGPoint(x: fence.xf, y: fence.y0), toCoordinateFrom: view)
            fenceDistance = Int(round(x0y0.location.distance(from: xfy0.location)))
            fence.isIdle = fenceDistanceIsIdle()
            self.distanceLabel.text = fenceDistance < 1000 ? "\(fenceDistance) m" : "\(Double(fenceDistance)/1000.0) km"
            slider?.value = Float(fenceDistance)
        }
    }
    
    
    func fenceDistanceIsIdle() -> Bool {
        return fenceDistance >= Int(fenceSide)
    }

}
