//
//  SingleResultViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 06/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit

class SingleResultViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var avargeSpeed: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var totalDistnceLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    
    
    var polyine = MKPolyline()
    
    fileprivate var annotations = [MKLocationId:[PTAnnotation]]()
    fileprivate var overlays = [MKLocationId:MKOverlay]()


    override func viewDidLoad() {
        super.viewDidLoad()
        let point1 = MKPointAnnotation()
        let point2 = MKPointAnnotation()
        let point9 = MKPointAnnotation()
        let point3 = MKPointAnnotation()
        let point4 = MKPointAnnotation()
        let point5 = MKPointAnnotation()
        let point6 = MKPointAnnotation()
        let point7 = MKPointAnnotation()
        let point8 = MKPointAnnotation()

        point1.coordinate = CLLocationCoordinate2DMake(51.891100, -8.757692)
        point2.coordinate = CLLocationCoordinate2DMake(51.890815, -8.760530)
        point3.coordinate = CLLocationCoordinate2DMake(51.890216, -8.764649)
        point4.coordinate = CLLocationCoordinate2DMake(51.891715, -8.768538)
        point5.coordinate = CLLocationCoordinate2DMake(51.891429, -8.772827)
        point6.coordinate = CLLocationCoordinate2DMake(51.891687, -8.775744)
        point7.coordinate = CLLocationCoordinate2DMake(51.892891, -8.783382)
        point8.coordinate = CLLocationCoordinate2DMake(51.892843, -8.786255)
        point9.coordinate = CLLocationCoordinate2DMake(51.892430, -8.791236)
        
        mapView.addAnnotation(point9)

        let coords = [point1.coordinate, point2.coordinate, point3.coordinate, point4.coordinate, point5.coordinate,point6.coordinate,point7.coordinate, point8.coordinate,point9.coordinate]
        self.polyine = MKPolyline(coordinates: coords, count: coords.count)
        
        let center = CLLocationCoordinate2D(latitude: 51.891100, longitude: -8.757692)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        mapView.showsPointsOfInterest = false
        
      
        
        
        
        mapView.add(polyine)

        
        
        mapView.delegate = self
        
        totalDistnceLbl.text = "8.23 Km"
        totalTimeLbl.text = "00:43:27"
        speed.text = "15 km/h"
        avargeSpeed.text = "5.7 Km/h"
        shareBtn.backgroundColor = UIColor.primary
        shareBtn.layer.cornerRadius = 20
        shareBtn.clipsToBounds = true
        shareBtn.setTitle("Share to social media", for: .normal)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay:polyine)
            polylineRenderer.strokeColor = UIColor.primary
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKPolylineRenderer()
    }
    
  
}


extension SingleResultViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PTBasicAnnotationView.identifier) as? PTBasicAnnotationView
        if annotationView == nil {
            annotationView = PTBasicAnnotationView(annotation: annotation, reuseIdentifier: PTBasicAnnotationView.identifier)
            annotationView?.canShowCallout = false
        }
        
        if !(annotation is MKUserLocation) {
            annotationView!.pictureImageView?.image = UIImage(named: "max")
        }
        
        return annotationView
}
}
