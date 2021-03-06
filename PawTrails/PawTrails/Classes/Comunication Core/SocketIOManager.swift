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

enum GPSTimeIntervalMode: Int {
    case smart, live
    
    var string: String {
        switch self {
        case .smart: return "smart"
        case .live: return "live"
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
                    self.disconnect()
                    self.userNotSigned()
                } else {
                    self.triedToReconnectOnUnauthorized = true
                    self.reconnect()
                }
                
            } else if status == .accountNeedsVerification {
                self.disconnect()
            }
            else if (status != .waiting) {
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
            
            if let petDeviceData = PetDeviceData.fromJson(data.first) {
                for newPetDeviceData in petDeviceData {
                    if !self.petGpsUpdates.value.contains(newPetDeviceData) {  // if there is a name in the new list also in the old list
                        Reporter.debugPrint("SocketIO -> Setting petGpsUpdates.value")
                        self.petGpsUpdates.value = petDeviceData
                        return
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
        
//        DataManager.instance.userToken.asObservable().subscribe(onNext: { (authentication) in
//            if authentication != nil {
//                self.connect()
//            } else {
//                self.socket.disconnect()
//            }
//        }).disposed(by: disposeBag)
        
        self.socket.onAny { (socketAnyEvent) in
            
            if let items = socketAnyEvent.items, items.contains(where: { (event) -> Bool in
                if let event = event as? SocketIOClientStatus {
                    let isEventDisconnected = event == SocketIOClientStatus.disconnected
                    
                    if isEventDisconnected {
                        self.isConnected = false
                    }
                    
                    return isEventDisconnected
                }
                return false
                
            }) {
                
                if self.shouldReconnect {
                    self.connect()
                }
                
            }
        }
    }
    
    
    func userNotSigned() {
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController, !(rootViewController is InitialViewController) else {
            self.disconnect()
            return
        }
        
        let title: String = "Authorization Needed"
        let subTitle: String = "Please, you need to login."
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: true
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Login") {
        
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, !rootViewController.isKind(of: InitialViewController.self) {


                let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
                if let vc = loginStoryboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
                    let navController = UINavigationController(rootViewController: vc)
                    UIApplication.shared.keyWindow?.rootViewController?.present(navController, animated: true, completion: {
                        //TEMP self.tabBarController?.selectedIndex = 0
                    })
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
        self.connect()
        return isReady().filter({ (value) -> Bool in
            return value == true
        }).flatMap({ (isReady) -> Observable<[Pet]> in
            self.socket.emit(channel.pets.name)
            return self.pets.asObservable()
        })
    }
    
    func gpsUpdates(_ petIDs: [Int], gpsMode: GPSTimeIntervalMode) -> Observable<[PetDeviceData]> {
        self.connect()
        return isReady()
            .filter({ (isReady) -> Bool in
            return isReady
        }).flatMap({ (isReady) -> Observable<[PetDeviceData]> in
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Emitting GPS updates for Pets IDs: \(petIDs.map{ $0 }) - Mode: \(gpsMode.string.uppercased())")
            self.socket.emit("gpsPets", ["ids": petIDs, "noLastPos": false, "gpsTimeInterval": gpsMode.string])
            return self.petGpsUpdates.asObservable()
                .map({ (petDeviceDataList) -> [PetDeviceData] in
                    return petDeviceDataList.filter { petIDs.contains($0.pet.id) }
                })
        })
    }
    
    func trips() -> Observable<[Trip]> {
        self.connect()
        return isReady()
                .filter ({ (value) -> Bool in
                    Reporter.debugPrint("SocketIOManager -> trips() -> filter -> \(value)")
                    return value == true
                })
                .flatMapLatest ({ (isReady) -> Observable<[Trip]> in
                    Reporter.debugPrint("SocketIOManager -> trips() -> flatMap")
                    self.socket.emit(channel.trips.name)
                    return self.petTrips.asObservable()
                })
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
        self.shouldReconnect = false
        self.socket.disconnect()
    }
    
    
    // MARK: establish connection with PetsList channel.
    func connectToPetChannel() {
        self.socket.emit("getPetList", false)
        self.socket.on("pets", callback: { (data, ack) in
            Reporter.debugPrint("SocketIO pets")
        })
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
    case AccountNeedsVerification = 417
    
    var description: String {
        switch self {
        case .Timeout:
            return "Timeout on trying to authenticate with live channel."
        case .NotAuth:
            return "Live channel authentication error, please try login again."
        case .AccountNeedsVerification:
            return "Your account is not verified, please check your email to verify your account"
        }
    }
}
