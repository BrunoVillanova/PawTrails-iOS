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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        let _id:Int16 = 25
        NotificationManager.Instance.getPetGPSUpdates { (id, data) in
            if id == _id {
                
                if data.movementAlarm {
                    self.alert(title: "HEY", msg: "MOVEMENT!!", type: .red)
                }else{
                    self.data.append((data.serverDate,data.source))
                    self.data.sort(by: { (element1, element2) -> Bool in
                        return element1.0 > element2.0
                    })
                    self.tableView.reloadData()
                }
            }
        }
        SocketIOManager.Instance.startGPSUpdates(for: [_id])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationManager.Instance.removePetGPSUpdates()
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class testSocketCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

}
