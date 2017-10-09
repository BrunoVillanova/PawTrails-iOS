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
class AddEditSafeZOneController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    
    var safezone: SafeZone?
    var petId: Int!
    var isOwner: Bool!
    
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "")
        self.view.backgroundColor = UIColor.white
        
        if let view1 = Bundle.main.loadNibNamed("SettingsView", owner: nil, options: nil)?.first as? SettingsViews {
            view1.circleBtn.circle()
        }
        
        let ZBdropDownViews = Bundle.main.loadNibNamed("SettingsView", owner: nil, options: nil) as? [UIView]
        
        if let _ZBdropDownViews = ZBdropDownViews {
            let view = YNDropDownMenu(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: 38),
                            dropDownViews: _ZBdropDownViews, dropDownViewTitles: ["Show SafeZone Settings"])
            view.setImageWhen(normal: UIImage(named: "arrow"), selected: UIImage(named: "arrow_sel"), disabled: UIImage(named: "arrow"))
            view.setLabelColorWhen(normal: .black, selected: .black, disabled: .black)
            view.setImageWhen(normal: UIImage(named: "arrow"), selectedTintColor: .clear, disabledTintColor: .black)
            view.bottomLine.backgroundColor = UIColor.black
            view.bottomLine.isHidden = false
            
            

            let backgroundView = UIView()
            backgroundView.backgroundColor = .black
            view.blurEffectView = backgroundView
            view.blurEffectViewAlpha = 0.7
            view.alwaysSelected(at: 0)

            self.view.addSubview(view)
        }
        


    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
//
//
//        
//        let ZBdropDownViews = Bundle.main.loadNibNamed("DropDownViews", owner: nil, options: nil) as? [UIView]
//        let FFA409 = UIColor(colorLiteralRed: 255/255, green: 164/255, blue: 9/255, alpha: 1.0)
//        
//        if let _ZBdropDownViews = ZBdropDownViews {
//            // Inherit YNDropDownView if you want to hideMenu in your dropDownViews
//            let view = YNDropDownMenu(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: 38), dropDownViews: _ZBdropDownViews, dropDownViewTitles: ["Apple", "Banana", "Kiwi", "Pear"])
//            
//            view.setImageWhen(normal: UIImage(named: "arrow_nor"), selected: UIImage(named: "arrow_sel"), disabled: UIImage(named: "arrow_dim"))
//            //view.setImageWhen(normal: UIImage(named: "arrow_nor"), selectedTintColor: FFA409, disabledTintColor: FFA409)
//            //view.setImageWhen(normal: UIImage(named: "arrow_nor"), selectedTintColorRGB: "FFA409", disabledTintColorRGB: "FFA409")
//            
//            view.setLabelColorWhen(normal: .black, selected: FFA409, disabled: .gray)
//            //            view.setLabelColorWhen(normalRGB: "000000", selectedRGB: "FFA409", disabledRGB: "FFA409")
//            
//            view.setLabelFontWhen(normal: .systemFont(ofSize: 12), selected: .boldSystemFont(ofSize: 12), disabled: .systemFont(ofSize: 12))
//            //            view.setLabel(font: .systemFont(ofSize: 12))
//            
//            view.backgroundBlurEnabled = true
//            //            view.bottomLine.backgroundColor = UIColor.black
//            view.bottomLine.isHidden = false
//            // Add custom blurEffectView
//            let backgroundView = UIView()
//            backgroundView.backgroundColor = .black
//            view.blurEffectView = backgroundView
//            view.blurEffectViewAlpha = 0.7
//            
//            // Open and Hide Menu
//            view.alwaysSelected(at: 0)
//            //            view.disabledMenuAt(index: 2)
//            //view.showAndHideMenuAt(index: 3)
//            
//            view.setBackgroundColor(color: UIColor.white)
//            
//            self.view.addSubview(view)
//        }
//
//    }
//
}
