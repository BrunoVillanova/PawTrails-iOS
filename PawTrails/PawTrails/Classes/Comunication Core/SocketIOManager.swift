//
//  SocketIOManagement.swift
//  PawTrails
//
//  Created by Marc Perello on 03/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//
import Foundation
import UIKit
import SocketIO
import SwiftyJSON
import RxSwift
import SCLAlertView

enum TripAction: Int {
    case initial = 0 // INITIAL VALUES
    case started = 2 // "action": 2 => Trip started (notify only to the trip owner) START
    case removed = 3 // "action": 3 => Trip removed (deleted) (notify only to the trip owner)
    case updated = 4 // "action": 4 => Trip updated (notify only to the trip owner) PAUSE / RESUME / STOP
    
    var name: String {
        switch self {
        case .initial: return "initial"
        case .started: return "started"
        case .removed: return "removed"
        case .updated: return "updated"
        }
    }
}


fileprivate enum channel {
    
    case connect, diconnect, auth, trips, pets, gpsUpdates
    
    var name: String {
        switch self {
        case .connect: return "connect"
        case .diconnect: return "diconnect"
        case .trips: return "trips"
        case .auth: return "authCheck"
        case .pets: return "pets"
        case .gpsUpdates: return "gpsUpdates"
        }
    }
    
    static func gpsUpdatesName(for petId: Int) -> String {
        return "gpsUpdates"
    }
    
    // to return pets.
    static func joinRoom(for petIds: [Int]) -> String {
        return "pets"
    }
}


/// Performs communication with Socket IO Platform
class SocketIOManager: NSObject, URLSessionDelegate {
    
    /// Shared Instance
    static let instance = SocketIOManager()
    
    private let urlString = Constants.socketURL
    private let urlStringSSL = Constants.socketURLSSL
    
    private var socket: SocketIOClient!
    private let disposeBag = DisposeBag()
    public var socketReactive: Reactive<SocketIOClient>?
    
    private var onUpdates = [Int:Bool]()
    private var PetsGPSData = NSCache<NSNumber,GPSData>()
    
    public var isConnected = false
    private var isConnecting = false
    private var isAuthenticating = false
    private var isAuthenticated = false
    private var shouldReconnect = false

    var pets: Variable<[Pet]> = Variable([Pet]())
    var petGpsUpdates: Variable<[PetDeviceData]> = Variable([PetDeviceData]())
    var petTrips: Variable<[Trip]> = Variable([Trip]())
    var isReadyForCommunication: Variable<Bool> = Variable(false)
    var triedToReconnectOnUnauthorized = false
    
    fileprivate var openChannels: Set<channel> = Set<channel>()
    
//    var petGpsUpdates: Observable<[PetDeviceData]?> = Observable.from(optional: [PetDeviceData]())
    
    init(SSLEnabled: Bool = true) {
        super.init()
        
        let urlString = SSLEnabled ? self.urlStringSSL : self.urlString
        
    #if DEBUG
        let config : SocketIOClientConfiguration = [
//            .log(true),
            .secure(true),
            .reconnectAttempts(50),
            .reconnectWait(3),
            .forceNew(true)]
    #else
        let config : SocketIOClientConfiguration = [
            .secure(true),
            .reconnectAttempts(50),
            .reconnectWait(3),
            .forceNew(true)]
    #endif
        
        if let url = URL(string: urlString) {
            self.socket = SocketIOClient(socketURL: url, config: config)
        }
        
        // Init SocketIO
        socketReactive = Reactive<SocketIOClient>(socket)
        
        // Define SocketIO event handlers
        socketReactive?.on(channel.connect.name).subscribe(onNext: { (data) in
            Reporter.debugPrint("SocketIO -> Connect \(data)")
            self.isConnected = true
            self.isConnecting = false
            self.socketAuth()
        }){}.disposed(by: disposeBag)
        
        
        socketReactive?.on(channel.auth.name).subscribe(onNext: { (data) in
            
            self.isAuthenticating = false
            let status = self.getStatus(data)
            Reporter.debugPrint("SocketIO -> AuthCheck -> \(status) -> \(data)")
            if (status == .connected) {
                self.isAuthenticated = true
                Reporter.debugPrint("SocketIO -> AuthCheck -> Authenticated and Ready for Communitcation")
                self.isReadyForCommunication.value = true
            } else if (status == .unauthorized) {
                self.disconnect()
                self.userNotSigned()
            } else if (status == .unauthorized2) {
                
                if self.triedToReconnectOnUnauthorized {
                    //TODO: force user to login again
                    self.disconnect()
                    self.userNotSigned()
                } else {
                    self.triedToReconnectOnUnauthorized = true
                    self.reconnect()
                }
                
            } else if (status != .waiting) {
                self.socketAuth()
            }
        }).disposed(by: disposeBag)
        
        
        socketReactive?.on(channel.diconnect.name).subscribe(onNext: { (data) in
            Reporter.debugPrint("SocketIO -> Disconnect")
            self.isConnected = false
            self.isReadyForCommunication.value = false
            
            if self.shouldReconnect {
                self.shouldReconnect = false
                self.connect()
            }
        }){}.disposed(by: disposeBag)
        
        
        socketReactive?.on(channel.pets.name).subscribe(onNext: { (data) in
            Reporter.debugPrint("SocketIO -> Pets")
            self.openChannels.insert(channel.pets)
        }).disposed(by: disposeBag)
        
        
        socketReactive?.on(channel.gpsUpdates.name).subscribe(onNext: { (data) in
            Reporter.debugPrint("SocketIO -> GPS Updates")
            self.openChannels.insert(channel.gpsUpdates)
            
            if let petDeviceData = PetDeviceData.fromJson(data.first) {
                for newPetDeviceData in petDeviceData {
                    if !self.petGpsUpdates.value.contains(newPetDeviceData) {  // if there is a name in the new list also in the old list
                        Reporter.debugPrint("SocketIO -> Setting petGpsUpdates.value")
                        self.petGpsUpdates.value = petDeviceData
                        break
                    }
                }

            }
            
        }).disposed(by: disposeBag)
        
        
        socketReactive?.on(channel.trips.name).subscribe(onNext: { (data) in
            Reporter.debugPrint("SocketIO -> Trips")
            self.openChannels.insert(channel.trips)
            if let json = data.first as? [String:Any] {
                
                if let tripActionValue = json["action"] as? Int, let tripAction = TripAction(rawValue: tripActionValue) {
    
                    Reporter.debugPrint("SocketIO -> Trips -> Action: \(tripAction.name)")
                    
                    if let tripsData = json["trips"] as? [[String:Any]] {
                        
                        var tripList = [Trip]()
                        
                        for tripJson in tripsData {
                            tripList.append(Trip(tripJson))
                            Reporter.debugPrint("SocketIO -> Trips -> Trip!")
                        }
                        
                        self.petTrips.value = tripList
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        DataManager.instance.userToken.asObservable().subscribe(onNext: { (authentication) in
            if authentication != nil {
                self.connect()
            } else {
                self.socket.disconnect()
            }
        }).disposed(by: disposeBag)
        
        self.socket.onAny { (socketAnyEvent) in
            
            if let items = socketAnyEvent.items, items.contains(where: { (event) -> Bool in
                if let event = event as? SocketIOClientStatus {
                    return event == SocketIOClientStatus.disconnected
                }
                return false
                
            }) {
                self.connect()
            }
        }
    }
    
    
    func userNotSigned() {
        //TODO: show alert prompt
        
        let title: String = "Authorization Needed"
        let subTitle: String = "Please, you need to login."
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: true
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Login") {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, let storyboard = rootViewController.storyboard, !rootViewController.isKind(of: InitialViewController.self) {
                
                if let vc = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
                    rootViewController.present(vc, animated: true, completion: nil)
                }
            }
        }
        
        alertView.showTitle(
            title, // Title of view
            subTitle: subTitle, // String of view
            duration: 0.0, // Duration to show before closing automatically, default: 0.0
            completeText: "ok", // Optional button value, default: ""
            style: .notice, // Styles - see below.
            colorStyle: 0xD4143D,
            colorTextButton: 0xFFFFFF
        )
    }
    
    func getPets() -> Observable<[Pet]> {
        return isReady().filter({ (value) -> Bool in
            return value == true
        }).flatMap({ (isReady) -> Observable<[Pet]> in
            self.socket.emit(channel.pets.name)
            return self.pets.asObservable()
        })
    }
    
    func gpsUpdates(_ petIDs: [Int]) -> Observable<[PetDeviceData]> {
        return isReady()
            .filter({ (isReady) -> Bool in
            return isReady
        }).flatMap({ (isReady) -> Observable<[PetDeviceData]> in
            self.socket.emit("gpsPets", ["ids": petIDs, "noLastPos": false])
            return self.petGpsUpdates.asObservable()
                .map({ (petDeviceDataList) -> [PetDeviceData] in
                    return petDeviceDataList.filter { petIDs.contains($0.pet.id) }
                })
        })
    }
    
    func trips() -> Observable<[Trip]> {
        return isReady()
                .filter({ (value) -> Bool in
                    Reporter.debugPrint("SocketIOManager -> trips() -> filter -> \(value)")
                    return value == true
                })
                .flatMapLatest({ (isReady) -> Observable<[Trip]> in
                    Reporter.debugPrint("SocketIOManager -> trips() -> flatMap")
                    self.socket.emit(channel.trips.name)
                    return self.petTrips.asObservable()
                }).share()
    }
    
    func isReady() -> Observable<Bool> {
        return isReadyForCommunication.asObservable()
    }
    
    func socketAuth() {
        guard !isAuthenticating && isConnected else {
            return
        }
        
        let token = SharedPreferences.get(.token)
        if token != "" {
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Connecting")
            isAuthenticating = true
            socket.emit(channel.auth.name, token)
        } else{
            isAuthenticating = false
            Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Socket IO", code: -1, userInfo: ["reason": "missing token"]))
        }
    }
    
    /// Establishes Connection with Socket IO, peforms login driven by token.
    ///
    /// - Parameter callback: returns socket IO connection status
    func connect(_ callback: ((SocketIOStatus)->())? = nil) {
        
        guard !self.isConnecting else {
            return
        }
        
        guard !self.isConnected else {
            return
        }
        
        guard !self.isAuthenticating else {
            return
        }
        
        if DataManager.instance.isAuthenticated() {
            self.isConnecting = true
            socket.connect()
        }
    }
    
    func reconnect() {
        self.shouldReconnect = true
        self.disconnect()
    }
    
    /// Disconnects from Socket I.O.
    func disconnect() {
        self.socket.disconnect()
        self.isConnected = false
    }
    
    
    // MARK: establish connection with PetsList channel.
    func connectToPetChannel() {
        self.socket.emit("getPetList", false)
        self.socket.on("pets", callback: { (data, ack) in
            Reporter.debugPrint("SocketIO pets")
        })
    }

    //MARK:- Pet
    /// Collect GPS Data for pet id
    ///
    /// - Parameter id: pet id
    /// - Returns: returns GPSData if available else *nil*
    func getGPSData(for id: Int) -> GPSData? {
        return PetsGPSData.object(forKey: NSNumber(integerLiteral: Int(id)))
    }
    
    /// Set Location Name
    ///
    /// - Parameters:
    ///   - locationName: location name
    ///   - petId: pet id
    func set(_ locationName: String, for petId: Int){
        if let data = getGPSData(for: petId) {
            data.locationAndTime = "\(locationName) - \(data.distanceTime)"
        }
    }
    
    /// Start pets GPS Updates
    ///
    //    /// - Parameter petIds: pet ids
    func startGPSUpdates(for petIds: [Int]) -> Observable<[PetDeviceData]> {
        Reporter.debugPrint("SocketIO GPS Pets Emited for petIDs \(petIds)")
        return self.gpsUpdates(petIds)
    }
    

    

    
    //Events
    
    private func handleEventUpdated(_ data:[Any]){
        if let dict = data.first as? [String:Any] {
            
            let json = JSON(dict)
            let error = json["errors"].intValue
            
            if error != 0 {
                Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Socket IO Handle Events", code: error, userInfo: dict))
            }else {
                NotificationManager.instance.post(Event(json))
            }
        } else{
            Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Socket IO Handle Events", code: -1, userInfo: ["data":data]))
        }
    }
    
    // helpers
    
    private func getStatus(_ data: [Any]) -> SocketIOStatus {
        if let json = data.first as? [String:Any] {
            if let code = json["errors"] as? Int {
                return SocketIOStatus(rawValue: code) ?? SocketIOStatus.unknown
            }
            if let code = json["status"] as? Int {
                return SocketIOStatus(rawValue: code) ?? SocketIOStatus.unknown
            }
        }
        if let element = ((data as NSArray)[0] as? NSArray)?[0] as? String {
            return element == "unauthorized" ? SocketIOStatus.unauthorized : SocketIOStatus.unknown
        }
        Reporter.debugPrint(file: "\(#file)", function: "\(#function)", data, data.first as? [String:Any] ?? "", data as? [String] ?? "")
        return SocketIOStatus.unknown
    }
}

struct SocketIOManagerError: Error {
    
    enum errorKind {
        case authError
    }
}


enum SocketIOErrorCode: Int {
    
    
    case Timeout = 419
    case NotAuth = 414
    
    var description: String {
        switch self {
        case .Timeout:
            return "Timeout on trying to authenticate with live channel."
        case .NotAuth:
            return "Live channel authentication error, please try login again."
        }
    }
}
