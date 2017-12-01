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
            .flatMapLatest({ (trips) -> Observable<[Trip]> in
                print("func getActivePetTrips \(trips.count)")
                //TODO: add pets from socketIO
                return Observable.create({ observer in
                    let onlyActiveTrips = trips.filter({ (trip) -> Bool in
                        return trip.status < 2
                    })
                    
                    print("onlyActiveTrips \(onlyActiveTrips.count)")
                    observer.onNext(onlyActiveTrips)
                    observer.onCompleted()
                    return Disposables.create()
                })
            }).ifEmpty(default: [Trip]())
    }
    
    func allTrips() -> Observable<[Trip]> {
        let apiTrips = getApiTrips()
        let socketTrips = SocketIOManager.instance.trips()
        print("DataManager -> allTrips")
        
        let allTrips = Observable.combineLatest(apiTrips, socketTrips) { (tripsFromApi, tripsFromSocket) -> [Trip] in
            
            var finalTrips = tripsFromApi.map{$0}

            for socketTrip in tripsFromSocket {
                var theTripOnApi = finalTrips.first { $0.id == socketTrip.id }
                
                if theTripOnApi != nil {
                    theTripOnApi!.status = socketTrip.status
                    finalTrips.remove(at: finalTrips.index(where: { (trip) -> Bool in
                        return trip.id == theTripOnApi?.id
                    })!)
                    finalTrips.append(theTripOnApi!)
                } else {
                    finalTrips.append(socketTrip)
                }
            }
            
        
            print("DataManager -> allTrips -> active tripsFromApi = \(tripsFromApi.filter{$0.status < 2}.count)")
            print("DataManager -> allTrips -> active tripsFromSocket = \(tripsFromSocket.filter{$0.status < 2}.count)")
            print("DataManager -> allTrips -> active finalTrips = \(finalTrips.filter{$0.status < 2}.count)")

            return finalTrips
        }.ifEmpty(default: [Trip]())
        
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
            .take(1)
            .flatMap { (trips) -> Observable<[Trip]> in
                let tripIDs = trips.map({Int($0.id)})
                return self.stopTrips(tripIDs)
        }
    }
    
    
    func pauseAdventure() -> Observable<[Trip]> {
        
        return self.getActivePetTrips()
            .filter({ (trips) -> Bool in
                return trips.count > 0
            }).take(1)
            .flatMap { (trips) -> Observable<[Trip]> in
                let tripIDs = trips.map({Int($0.id)})
                
                return Observable.create({ observer in
                    APIRepository.instance.pauseTrip(tripIDs) { (error) in
                        if error != nil {
                            observer.onError(error!)
                        } else {
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                })
        }
    }
    
    func resumeAdventure() -> Observable<[Trip]> {
        
        return self.getActivePetTrips()
            .filter({ (trips) -> Bool in
                let pausedTrips = trips.filter { $0.status == 1}
                return pausedTrips.count > 0
            })
            .take(1)
            .flatMap { (trips) -> Observable<[Trip]> in

                return Observable.create({ observer in
                    APIRepository.instance.resumeTrip { (error) in
                        if error != nil {
                            observer.onError(error!)
                        } else {
                            //                            self.retrieveRunningTrips()
                            //                            observer.onNext(data!)
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                })
        }
    }
}
