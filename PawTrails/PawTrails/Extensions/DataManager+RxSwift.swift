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

    
    func allPetDeviceData(_ gpsMode: GPSTimeIntervalMode) -> Observable<[PetDeviceData]> {

        let pets = self.pets()

        return pets.flatMapLatest { (petList) -> Observable<[PetDeviceData]> in
            let petIDs = petList.map{ $0.id }
            let liveGpsUpdates = SocketIOManager.instance.gpsUpdates(petIDs, gpsMode: gpsMode)
            return liveGpsUpdates.share()
        }
    }
    
    func petDeviceData(_ petID: Int, gpsMode: GPSTimeIntervalMode) -> Observable<PetDeviceData?> {
        return SocketIOManager.instance.gpsUpdates([petID], gpsMode: gpsMode)
            .map({ (petDeviceDataList) -> PetDeviceData? in
                return petDeviceDataList.first
            })
    }
    
    func lastPetDeviceData(_ pet: Pet, gpsMode: GPSTimeIntervalMode) -> Observable<PetDeviceData?> {
        return allPetDeviceData(gpsMode).map({ (petDeviceDataList) -> PetDeviceData? in
            
            let filtered = petDeviceDataList.filter({ (element) -> Bool in
                return element.pet.id == pet.id
            })
            
            if filtered.count > 0 {
                let sorted = filtered.sorted(by: { (elem1, elem2) -> Bool in
                    if let deviceTime1 = elem1.deviceData.deviceTime, let deviceTime2 = elem2.deviceData.deviceTime {
                        return deviceTime1 > deviceTime2
                    } else {
                        return elem1.deviceData.id > elem2.deviceData.id
                    }
                })
                return sorted.first
            }
            
            return nil
        }).share()
    }
    
    func lastPetDeviceData(_ pet: Pet) -> Observable<PetDeviceData?> {
        return allPetDeviceData(.smart).map({ (petDeviceDataList) -> PetDeviceData? in
            
            let filtered = petDeviceDataList.filter({ (element) -> Bool in
                return element.pet.id == pet.id
            })
            
            if filtered.count > 0 {
                let sorted = filtered.sorted(by: { (elem1, elem2) -> Bool in
                    if let deviceTime1 = elem1.deviceData.deviceTime, let deviceTime2 = elem2.deviceData.deviceTime {
                        return deviceTime1 > deviceTime2
                    } else {
                        return elem1.deviceData.id > elem2.deviceData.id
                    }
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
        }).flatMapLatest({ (trips) -> Observable<[Trip]> in
            return self.allTrips()
        })
        
        return apiStartTrips
    }
    
    func stopTrips(_ tripIDs: [Int]) -> Observable<[Trip]> {
        
        let finishTripApiObserver = Observable<[Trip]>.create({ observer in
            APIRepository.instance.finishTrip(tripIDs) { (error, data) in
                if let error = error {
                    observer.onError(error)
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
            .take(1)
            .flatMapLatest { (trips) -> Observable<[Trip]> in
                let tripIDs = trips.map({Int($0.id)})
                return self.stopTrips(tripIDs)
            }
    }
    
    
    func pauseAdventure() -> Observable<[Trip]> {
        
        return self.getActivePetTrips()
            .filter({ (trips) -> Bool in
                return trips.count > 0
            })
            .take(1)
            .flatMapLatest { (trips) -> Observable<[Trip]> in
                let tripIDs = trips.map({Int($0.id)})
                return self.pauseTrips(tripIDs)
        }
    }
    
    func pauseTrips(_ tripIDs: [Int]) -> Observable<[Trip]>{
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
        .flatMapLatest({ (trip) -> Observable<[Trip]> in
            return self.getActivePetTrips()
        })
        
        return pauseTrips
    }
    
    func resumeAdventure() -> Observable<[Trip]> {
        
        let resumeTripObservable = self.getActivePetTrips()
            .filter({ (trips) -> Bool in
                let pausedTrips = trips.filter { $0.status == 1}
                return pausedTrips.count > 0
            })
            .take(1)
            .flatMapLatest { (trips) -> Observable<[Trip]> in
                
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
                .flatMapLatest({ (trip) -> Observable<[Trip]> in
                    return self.getActivePetTrips()
                })
                
                return resumeTrips
        }
        
        return resumeTripObservable
    }
    
    func getImmediateLocation(_ petIDs: [Int]) -> Observable<Void> {
        return Observable.create({ observer in
            APIRepository.instance.getImmediateLocation(petIDs, callback: { (error) in
                if error != nil {
                    observer.onError(error!)
                } else {
                    observer.onNext()
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }).take(1)
    }
}
