//
//  HomeViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    fileprivate let presenter = HomePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
//        self.presenter.checkSignInStatus()
        SocketIOManager.sharedInstance.connectToServerWithNickname("try") { (data) in
                if data != nil {
                    print(data!)
                }
            SocketIOManager.sharedInstance.socket.emit("", "")
        }
    }
    
    @IBAction func signOutAction(_ sender: UIBarButtonItem) {
//        self.presenter.signOut()
        let randomNum:UInt32 = arc4random_uniform(100)
        SocketIOManager.sharedInstance.sendMessage("msg \(randomNum)", withNickname: "\(UIDevice.current.description)")
    }
    
}

extension HomeViewController: HomeView{
    
    func errorMessage(_ error: String) {
        self.alert(title: "Error", msg: error)
    }
    
    func userNotSignedIn() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
