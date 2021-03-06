//
//  RecommandationController.swift
//  PawTrails
//
//  Created by Marc Perello on 18/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class RecommandationController: UIViewController {

    @IBOutlet weak var cImage: UIImageView!
    @IBOutlet weak var pImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var videoTurorialBtn: UIButton!
    @IBOutlet weak var startNowBtn: UIButton!
    fileprivate let presenter = PetsPresenter()

    fileprivate var pets = [Int:IndexPath]()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        tableView.tableFooterView = UIView()
        
        startNowBtn.backgroundColor = UIColor.primary
        startNowBtn.round()

        videoTurorialBtn.backgroundColor = UIColor.primary
        videoTurorialBtn.round()
        let notificationName = Notification.Name("BcScore")
        NotificationCenter.default.addObserver(self, selector: #selector(self.getPetsForNotification(_:)), name: notificationName, object: nil)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.title = "Professional Guides"
        
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
    }
    
    @objc func getPetsForNotification(_ sender: Notification) {
        self.presenter.loadPets()
        loadPets()
        
    }
    
    @IBAction func startNowBtn(_ sender: Any) {
    }
    
    
    @IBAction func videoTotBtnPressed(_ sender: Any) {
        self.popUpDestructive(title: "", msg: "You are being redirected to youtube to watch the Tutorial", cancelHandler: nil) { (done) in
            let youtubeId = "C9ng5Dw8kIU"
            if let urlFromStr = URL(string: "youtube://\(youtubeId)") {
                if UIApplication.shared.canOpenURL(urlFromStr) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(urlFromStr, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(urlFromStr)
                    }
                } else if let webURL = URL(string: "https://www.youtube.com/watch?v=C9ng5Dw8kIU") {
                    UIApplication.shared.openURL(webURL)
                }
            }
        }
        
    }
    
    
    func updateUi() {
        var count = [Int]()

        count.removeAll(keepingCapacity: false)
        if presenter.pets.isEmpty != true {
            for pet in presenter.pets {
                if pet.bcScore > 0 {
                    count.append(1)
                } else {
                }
            }
        }

        if count.count > 0 {
            self.tableView.isHidden = false
            self.cImage.isHidden = true
            self.pImage.isHidden = true
            self.scrollView.isHidden = true
            self.navigationItem.rightBarButtonItem = self.addBtn
            self.startNowBtn.isHidden = true
            self.videoTurorialBtn.isHidden = false
        } else {
            self.tableView.isHidden = true
            self.cImage.isHidden = false
            self.pImage.isHidden = false
            self.scrollView.isHidden = false
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = self.addBtn
            self.startNowBtn.isHidden = false
            self.videoTurorialBtn.isHidden = true
        }
    }
    
    
    func hideNotificationn() {
        
        //        if let notificationViews = UIApplication.shared.keyWindow?.subviews.filter({ $0.tag == subviewId.notification.rawValue }) {
        if let notificationViews = UIApplication.shared.keyWindow?.rootViewController?.view.subviews.filter({ $0.tag == subviewId.notification.rawValue }) {
            
            for notificationView in notificationViews {
                DispatchQueue.main.async {
                    notificationView.removeFromSuperview()
                }
            }
        }
    }
    
    @objc func reloadPetsAPI(){
        presenter.loadPets()
    }
    
    deinit {
        presenter.deteachView()
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNotificationn()

        reloadPets()
        loadPets()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            if let destination = segue.destination as? ResultFromListViewController {
                if let inexpatth = tableView.indexPathForSelectedRow {
                    destination.pet = getPet(at: inexpatth)
                }
            }
        }
    }
    
}

extension RecommandationController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = [Int]()
        count.removeAll(keepingCapacity: false)
        if presenter.pets.isEmpty != true {
            
            for pet in presenter.pets {
                if pet.bcScore > 0 {
                    count.append(1)
                } else {
                }
            }
        }
       
        if count.count > 0 {
            return count.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReccomendationCell
        
        if presenter.pets.isEmpty != true {
            let pet = presenter.pets[indexPath.item]
            let usedPet = pet.bcScore > 0
            
            cell.petImage.imageUrl = pet.imageURL
            
            
            if usedPet {
                if let name = pet.name {
                    
                    if pet.bcScore == 1 {
                        cell.nameAndResultLbl.text = "\(name) is very thin"
                    } else if pet.bcScore == 2 {
                        cell.nameAndResultLbl.text = "\(name) is underweight"
                    } else if pet.bcScore == 3 {
                        cell.nameAndResultLbl.text = "\(name) is the ideal weight"
                    } else if pet.bcScore == 4 {
                        cell.nameAndResultLbl.text = "\(name) is overweight"
                        
                    } else if pet.bcScore == 5 {
                        cell.nameAndResultLbl.text = "\(name) is obese"
                    }
                }

            } else {
                if let name = pet.name {
                    cell.nameAndResultLbl.text = "No data for \(name)"
                } else {
                    cell.nameAndResultLbl.text = "No score data for pet"
                }
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showResult", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    

    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
}

extension RecommandationController: PetsView {
    func reloadPets(){
        presenter.getPets()
    }
    
    // Mohamed - PetsView
    func errorMessage(_ error: ErrorMsg) {
//        refreshControl.endRefreshing()
        alert(title: error.title, msg: error.msg)
    }
    
    func loadPets() {
//        refreshControl.endRefreshing()
        self.tableView.reloadData()
        updateUi()
    }
    
    func petsNotFound() {
        self.tableView.reloadData()
        if presenter.pets.count != 0 {
            self.tableView.isHidden = true
            self.cImage.isHidden = false
            self.pImage.isHidden = false
            self.scrollView.isHidden = false
        }
    }
    
    
    func getPet(at indexPath: IndexPath) -> Pet {
        if presenter.pets.count > 0 {
            return presenter.pets[indexPath.item]
        }else if presenter.ownedPets.count > 0 {
            return presenter.ownedPets[indexPath.row]
        }else{
            return presenter.sharedPets[indexPath.row]
        }
    }
}


class ReccomendationCell: UITableViewCell {
    @IBOutlet weak var petImage: PTBalloonImageView!
    @IBOutlet weak var nameAndResultLbl: UILabel!
}
