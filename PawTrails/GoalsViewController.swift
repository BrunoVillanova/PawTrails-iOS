//
//  GoalsViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 02/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import XLPagerTabStrip


class GoalsViewController: UIViewController, IndicatorInfoProvider {

    var pet: Pet!
    override func viewDidLoad() {
        super.viewDidLoad()
        
      view.backgroundColor = UIColor.brown
    }


    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Activity")
    }
}
