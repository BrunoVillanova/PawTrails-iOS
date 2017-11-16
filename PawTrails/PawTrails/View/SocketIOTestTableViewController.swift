//
//  SocketIOTestTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 12/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SocketIOTestTableViewController: UITableViewController {
    
    var data = [(Date,String)]()
    let id:Int = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
//      SocketIOManager.instance.startGettingGpsUpdates(for: [96])
//        SocketIOManager.instance.connectToPetChannel()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        SocketIOManager.instance.startGettingGpsUpdates(for: [96])
//        SocketIOManager.instance.startGPSUpdates(for: [96])

    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        NotificationManager.instance.removePetGPSUpdates(of: id)
        
   
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! testSocketCell
        let elementIndex = data[indexPath.row]
        cell.titleLabel.text = elementIndex.0.toString()
        cell.textView.text = elementIndex.1
        return cell
    }
    
    
}

class testSocketCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

}
