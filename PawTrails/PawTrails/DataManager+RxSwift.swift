//
//  DataManager+RxSwift.swift
//  PawTrails
//
//  Created by Bruno Villanova on 10/11/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import RxSwift

extension DataManager {
    
//    static var authorized: Observable<Bool> {
//        return Observable.create { observer in
//
//            DispatchQueue.main.async {
//                if self.instance.isAuthenticated() {
//                    observer.onNext(true)
//                    observer.onCompleted()
//                } else {
//                    observer.onNext(false)
//                    observer.onCompleted()
//                    requestAuthorization { newStatus in
//                        observer.onNext(newStatus == .authorized)
//                        observer.onCompleted()
//                    }
//                } }
//
//            return Disposables.create()
//        }
//    }
    
    /// Try to load pets from API then if error, get pets from storage
    ///
    /// - Returns: bool value to verify the operation was complete successfully.
    func pets() -> Observable<[Pet]> {
        
        //TODO: add pets from socketIO
        return Observable.create({ observer in
            
            self.loadPets { (apiError, apiPets) in
                
                // Error loading pets from API, try to get from storage
                if apiError != nil {
                    self.getPets { (storageError, storagePets) in
                        if let error = storageError as DataManagerError! {
                            observer.onError(error)
                        } else {
                            observer.onNext(storagePets!)
                            observer.onCompleted()
                        }
                    }
                } else {
                    observer.onNext(apiPets!)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        })
    }
    
    func retrieveRunningTrips() {
        APIRepository.instance.getTripList([0,1]) { (error, trips) in
            if error == nil {
                self.runningTrips.value = trips!
            }
        }
    }
    
    func getApiTrips() -> Observable<[Trip]> {
        
        return Observable.create({observer in
            APIRepository.instance.getTripList([]) { (error, trips) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(trips!)
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        })
    }
    
    func getActivePetTrips() -> Observable<[Trip]> {
        return allTrips()
            .map({ (trips) -> [Trip] in
                return trips.filter({ (trip) -> Bool in
                    return trip.status < 2
                })
            }).ifEmpty(default: [Trip]())
    }
    
    func allTrips() -> Observable<[Trip]> {
        let apiTrips = getApiTrips()
        let socketTrips = SocketIOManager.instance.trips()
        
        let allTrips = Observable.combineLatest(apiTrips, socketTrips) { (tripsFromApi, tripsFromSocket) -> [Trip] in
            
            var finalTrips = tripsFromApi.map{$0}

            for socketTrip in tripsFromSocket {
                var theTripOnApi = finalTrips.first(where: { (trip) -> Bool in
                    return trip.id == socketTrip.id
                })
                
                if theTripOnApi != nil {
                    theTripOnApi!.status = socketTrip.status
                } else {
                    finalTrips.append(socketTrip)
                }
            }

            return finalTrips
        }
        
        return allTrips
    }
    
    
    func allPetDeviceData() -> Observable<[PetDeviceData]> {

        let pets = self.pets()

        return pets.flatMap { (petList) -> Observable<[PetDeviceData]> in
            
            let petIDs = petList.map({ (pet) -> Int in
                pet.id
            })
            let liveGpsUpdates = SocketIOManager.instance.gpsUpdates(petIDs)
            return liveGpsUpdates
        }
    }
    
    func lastPetDeviceData(_ pet: Pet) -> Observable<PetDeviceData?> {
        return allPetDeviceData().map({ (petDeviceDataList) -> PetDeviceData? in
            
            let filtered = petDeviceDataList.filter({ (element) -> Bool in
                return element.pet.id == pet.id
            })
            
            if filtered.count > 0 {
                let sorted = filtered.sorted(by: { (elem1, elem2) -> Bool in
                    return elem1.deviceData.deviceTime > elem2.deviceData.deviceTime
                })
                return sorted.first
            }
            
            return nil
        })
    }
}
