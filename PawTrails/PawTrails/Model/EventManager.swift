//
//  EventManager.swift
//  PawTrails
//
//  Created by Marc Perello on 22/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class EventManager {
    
    static let instance = EventManager()
    
    
    func handle(event: Event, for viewController: UIViewController?) {
        
        switch(event.type){
            
        case .petRemoved: handlePetRemoved(with: event, for: viewController)
            
        case .guestAdded: handleGuestAdded(with: event, for: viewController)

        case .guestRemoved, .guestLeft: handleGuestRemoved(with: event, for: viewController)

        default: break
        }

    }
    
    private func handlePetRemoved(with event: Event, for viewController: UIViewController?){

        guard let pet = event.pet else { return }
        guard let petName = pet.name else { return }
        
        DataManager.instance.removePetDB(by: pet.id) { (error) in
            if error == nil {
                self.updatePetListUI(for: pet.id, isRemove: true, in: viewController)
                var vc: UIViewController? {
                    return viewController?.navigationController?.visibleViewController ?? viewController
                }
                vc?.alert(title: "", msg: "\(petName) has been removed!", type: .blue)
            }
        }
    }
    
    private func handleGuestAdded(with event: Event, for viewController: UIViewController?){
        
        guard let pet = event.pet else { return }
        guard let petName = pet.name else { return }
        
        guard let guest = event.guest else { return }
        guard let guestName = guest.name else { return }
        
        if SharedPreferences.get(.id) == "\(guest.id)" {
            
            DataManager.instance.set(pet, callback: { (error, _) in
                if error == nil {
                    self.updatePetListUI(for: pet.id, in: viewController)
                    var vc: UIViewController? {
                        return viewController?.navigationController?.visibleViewController ?? viewController
                    }
                    vc?.alert(title: "", msg: "\(petName) has been added!", type: .blue)
                }
            })
            
        }else{
            
            DataManager.instance.addDB(guest, to: pet.id, callback: { (error, _) in
                if error == nil {
                    self.updateSharedUsersUI(for: pet.id, in: viewController)
                    var vc: UIViewController? {
                        return viewController?.navigationController?.visibleViewController ?? viewController
                    }
                    vc?.alert(title: "", msg: "\(guestName) has been added to \(petName)!", type: .blue)
                }
            })
        }
    }
    
    private func handleGuestRemoved(with event: Event, for viewController: UIViewController?){
        
        let didLeft = event.type == .guestLeft
        
        guard let pet = event.pet else { return }
        guard let petName = pet.name else { return }
        
        guard let guest = event.guest else { return }
        guard let guestName = guest.name else { return }
        
        
        if SharedPreferences.get(.id) == "\(guest.id)" {
            
            handlePetRemoved(with: event, for: viewController)
            
        }else{
            
            DataManager.instance.removeSharedUserDB(id: guest.id, from: pet.id, callback: { (error) in
                if error == nil {
                    self.updateSharedUsersUI(for: pet.id, in: viewController)
                    var vc: UIViewController? {
                        return viewController?.navigationController?.visibleViewController ?? viewController
                    }
                    let msg = didLeft ? "\(guestName) left from \(petName)!" : "\(guestName) has been removed from \(petName)!"
                    vc?.alert(title: "", msg: msg, type: .blue)
                }
            })
        }
    }
    
    private func updateSharedUsersUI(for petId: Int, in viewController: UIViewController?){
        if let petProfile = viewController?.navigationController?.viewControllers.first(where: { $0 is PetProfileTableViewController }) as? PetProfileTableViewController, petProfile.pet.id == petId {
            DispatchQueue.main.async {
                petProfile.reloadUsers()
            }
        }
    }
    
    private func updatePetListUI(for petId: Int, isRemove: Bool = false, in viewController: UIViewController?){
        DispatchQueue.main.async {
            if let navigationController = viewController?.navigationController {
                
                if let petList = navigationController.viewControllers.first(where: { $0 is PetsViewController }) as? PetsViewController {
                    
                    if isRemove, let petProfile = navigationController.viewControllers.first(where: { $0 is PetProfileTableViewController }) as? PetProfileTableViewController, petProfile.pet.id == petId {
                        navigationController.popToRootViewController(animated: true)
                    }
                    petList.reloadPets()
                }
                
            }else if let homeVC = viewController as? HomeViewController {
                homeVC.reloadPets()
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
