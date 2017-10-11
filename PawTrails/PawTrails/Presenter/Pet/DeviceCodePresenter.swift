//
//  DeviceCodePresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 26/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol DeviceCodeView: NSObjectProtocol, View {
    func idle(_ code: String)
    func wrongCode()
    func codeFormat()
    func codeChanged()
}

class DeviceCodePresenter {
    
    weak fileprivate var view: DeviceCodeView?
    
    func attachView(_ view: DeviceCodeView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func check(_ code: String?){
        
        if code == nil || (code != nil && (code == "" || !code!.isValidCode)) {
            view?.codeFormat()
        }else if let code = code {
            DataManager.instance.check(code, callback: { (idle) in
                if idle {
                    self.view?.idle(code)
                }else{
                    self.view?.wrongCode()
                }
            })
        }
    }
    
    func change(_ code:String, to petId: Int){
        
        DataManager.instance.change(code, of: petId) { (error) in
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.codeChanged()
            }
        }
    }
}
