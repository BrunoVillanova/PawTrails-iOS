//
//  EventManager.swift
//  PawTrails
//
//  Created by Marc Perello on 22/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class EventManager {
    
    static let Instance = EventManager()
    
    
    func handle(event: Event, for viewController: UIViewController?) {
        
        switch(event.type){
            
        case .petRemoved: handlePetRemoved(with: event.info, for: viewController)
            
        case .guestAdded: handleGuestAdded(with: event.info, for: viewController)

        case .guestRemoved, .guestLeft: handleGuestRemoved(with: event.info, for: viewController)
//
//        case .unknown:
//            
//            debugPrint("Unknown Event Type!", event.info)
//            
//            break
        default: break
        }

    }
    
    private func handlePetRemoved(with data: [String:Any], for viewController: UIViewController?){
        
        
        guard let petData = data["pet"] as? [String:Any] else { return }
        guard let petId = petData["id"] as? Int else { return }
        guard let petName = petData["name"] as? String else { return }
        
        UpdateManager.Instance.removePet(by: petId, {

            self.updatePetListUI(for: petId, isRemove: true, in: viewController)
            var vc: UIViewController? {
                return viewController?.navigationController?.visibleViewController ?? viewController
            }
            vc?.alert(title: "", msg: "\(petName) has been removed!", type: .blue)
        })
    }
    
    private func handleGuestAdded(with data: [String:Any], for viewController: UIViewController?){
        
        guard let petData = data["pet"] as? [String:Any] else { return }
        guard let petId = petData["id"] as? Int else { return }
        guard let petName = petData["name"] as? String else { return }
        
        guard let guestData = data["guest"] as? [String:Any] else { return }
        guard let guestId = guestData["id"] as? Int else { return }
        guard let guestName = guestData["name"] as? String else { return }
        
        if SharedPreferences.get(.id) == "\(guestId)" {
            
            UpdateManager.Instance.addPet(petData, callback: { 
                self.updatePetListUI(for: petId, in: viewController)
                var vc: UIViewController? {
                    return viewController?.navigationController?.visibleViewController ?? viewController
                }
                vc?.alert(title: "", msg: "\(petName) has been added!", type: .blue)

            })
            
        }else{
            UpdateManager.Instance.addSharedUser(with: guestData, for: petId) {
                
                self.updateSharedUsersUI(for: petId, in: viewController)
                var vc: UIViewController? {
                    return viewController?.navigationController?.visibleViewController ?? viewController
                }
                vc?.alert(title: "", msg: "\(guestName) has been added to \(petName)!", type: .blue)
            }
        }
    }
    
    private func handleGuestRemoved(with data: [String:Any], for viewController: UIViewController?){
        
        guard let petData = data["pet"] as? [String:Any] else { return }
        guard let petId = petData["id"] as? Int else { return }
        guard let petName = petData["name"] as? String else { return }
        
        guard let guestData = data["guest"] as? [String:Any] else { return }
        guard let guestId = guestData["id"] as? Int else { return }
        guard let guestName = guestData["name"] as? String else { return }
        
        
        if SharedPreferences.get(.id) == "\(guestId)" {
            
            handlePetRemoved(with: data, for: viewController)
            
        }else{
            UpdateManager.Instance.removeSharedUser(with: guestId, from: petId) {

                self.updateSharedUsersUI(for: petId, in: viewController)
                var vc: UIViewController? {
                    return viewController?.navigationController?.visibleViewController ?? viewController
                }
                vc?.alert(title: "", msg: "\(guestName) has been removed from \(petName)!", type: .blue)
            }
        }
    }
    
    private func updateSharedUsersUI(for petId: Int, in viewController: UIViewController?){
        if let petProfile = viewController?.navigationController?.viewControllers.first(where: { $0 is PetProfileTableViewController }) as? PetProfileTableViewController, petProfile.pet.id == Int16(petId) {
            DispatchQueue.main.async {
                petProfile.reloadUsers()
            }
        }
    }
    
    private func updatePetListUI(for petId: Int, isRemove: Bool = false, in viewController: UIViewController?){
        DispatchQueue.main.async {
            if let navigationController = viewController?.navigationController {
                
                if let petList = navigationController.viewControllers.first(where: { $0 is PetsViewController }) as? PetsViewController {
                    
                    if isRemove, let petProfile = navigationController.viewControllers.first(where: { $0 is PetProfileTableViewController }) as? PetProfileTableViewController, petProfile.pet.id == Int16(petId) {
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
