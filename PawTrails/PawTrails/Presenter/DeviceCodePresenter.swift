//
//  DeviceCodePresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 26/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol DeviceCodeView: NSObjectProtocol, View, ConnectionView {
    func idle(_ code: String)
    func wrongCode()
    func codeFormat()
}

class DeviceCodePresenter {
    
    weak fileprivate var view: DeviceCodeView?
    private var reachability: Reachbility!
    
    
    func attachView(_ view: DeviceCodeView){
        self.view = view
        self.reachability = Reachbility(view)
    }
    
    func deteachView() {
        self.view = nil
    }

    func check(_ code: String?){
        
        if code == nil || (code != nil && code == "") {
            view?.codeFormat()
        }else if let code = code {
            DataManager.Instance.check(code, callback: { (idle) in
                DispatchQueue.main.async {
                    if idle {
                        self.view?.idle(code)
                    }else{
                        self.view?.wrongCode()
                    }
                }
            })
        }
    }
}
