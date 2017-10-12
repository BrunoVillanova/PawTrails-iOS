//
//  ddViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 11/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class ddViewController: UIViewController {
    @IBOutlet weak var circleChart: CircleChart!

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        circleChart.setChart(at: 0.8, color: UIColor.blue)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
