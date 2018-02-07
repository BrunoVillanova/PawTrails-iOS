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
        }).share()
    }

    
    func getApiTrips(_ status: [Int] = []) -> Observable<[Trip]> {
        return Observable.create({observer in
            APIRepository.instance.getTripList(status) { (error, trips) in
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
    
    func finishedTrips() -> Observable<[Trip]> {
        let apiTrips = getApiTrips([2])
        let socketTrips = SocketIOManager.instance.trips()
        return apiTrips.flatMapLatest({ (apiTripsData) -> Observable<[Trip]> in
            return socketTrips.flatMap({ (socketTripsData) -> Observable<[Trip]> in
                return apiTrips
            })
        })
    }
    
    func getActivePetTrips() -> Observable<[Trip]> {
        let apiTrips = getApiTrips([0,1])
        let socketTrips = SocketIOManager.instance.trips()
        return apiTrips.flatMapLatest({ (apiTripsData) -> Observable<[Trip]> in
            return socketTrips.flatMap({ (socketTripsData) -> Observable<[Trip]> in
                return apiTrips
            })
        })
    }
    
    func allTrips() -> Observable<[Trip]> {
        let apiTrips = getApiTrips()
        let socketTrips = SocketIOManager.instance.trips()
        return apiTrips.flatMapLatest({ (apiTripsData) -> Observable<[Trip]> in
            return socketTrips.flatMap({ (socketTripsData) -> Observable<[Trip]> in
                return apiTrips
            })
        })
    }

    
    func allPetDeviceData() -> Observable<[PetDeviceData]> {

        let pets = self.pets().share()

        return pets.flatMap { (petList) -> Observable<[PetDeviceData]> in
            
            let petIDs = petList.map({ (pet) -> Int in
                pet.id
            })
            let liveGpsUpdates = SocketIOManager.instance.gpsUpdates(petIDs)
            return liveGpsUpdates.share()
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
        }).share()
    }
    
    func startTrips(_ petIDs: [Int]) -> Observable<[Trip]> {
        
        let apiStartTrips = Observable<[Trip]>.create({ observer in
            APIRepository.instance.startTrips(petIDs) { (error, data) in
                if error != nil {
                    observer.onError(error!)
                } else {
                    observer.onNext(data!)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }).flatMap({ (trips) -> Observable<[Trip]> in
            return self.allTrips()
        })
        
        return apiStartTrips
    }
    
    func stopTrips(_ tripIDs: [Int]) -> Observable<[Trip]> {
        
        let finishTripApiObserver = Observable<[Trip]>.create({ observer in
            APIRepository.instance.finishTrip(tripIDs) { (error, data) in
                if error != nil {
                    observer.onError(error!)
                } else {
                    observer.onNext(data!)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        })
        
        return finishTripApiObserver
    }
    
    func finishAdventure() -> Observable<[Trip]> {
        return self.getActivePetTrips()
            .filter({ (trips) -> Bool in
                return trips.count > 0
            })
//            .take(1)
            .flatMap { (trips) -> Observable<[Trip]> in
                let tripIDs = trips.map({Int($0.id)})
                return self.stopTrips(tripIDs)
            }
    }
    
    
    func pauseAdventure() -> Observable<[Trip]> {
        
        return self.getActivePetTrips()
            .filter({ (trips) -> Bool in
                return trips.count > 0
            })
            .flatMap { (trips) -> Observable<[Trip]> in
                
                let tripIDs = trips.map({Int($0.id)})
                let pauseTrips = Observable<[Trip]>.create({ observer in
                    APIRepository.instance.pauseTrip(tripIDs) { (error) in
                        if error != nil {
                            observer.onError(error!)
                        } else {
                            observer.onNext([])
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                })
                .flatMap({ (trip) -> Observable<[Trip]> in
                    return self.getActivePetTrips()
                })
                
                return pauseTrips
        }
    }
    
    func resumeAdventure() -> Observable<[Trip]> {
        
        let resumeTripObservable = self.getActivePetTrips()
            .filter({ (trips) -> Bool in
                let pausedTrips = trips.filter { $0.status == 1}
                return pausedTrips.count > 0
            })
            .take(1)
            .flatMap { (trips) -> Observable<[Trip]> in
                
                let resumeTrips = Observable<[Trip]>.create({ observer in
                    APIRepository.instance.resumeTrip { (error) in
                        if error != nil {
                            observer.onError(error!)
                        } else {
                            observer.onNext([])
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                })
                .flatMap({ (trip) -> Observable<[Trip]> in
                    return self.getActivePetTrips()
                })
                
                return resumeTrips
        }
        
        return resumeTripObservable
    }
}
