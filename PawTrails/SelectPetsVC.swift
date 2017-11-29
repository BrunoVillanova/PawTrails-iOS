//
//  SelectPetsVC.swift
//  PawTrails
//
//  Created by Marc Perello on 04/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift

enum selectPetsAction {
    case startAdventure, joinAdventure
}

class SelectPetsVC: UIViewController, PetsView, SelectPetView {
    
    @IBOutlet weak var petsCollectionView: UICollectionView!
    @IBOutlet weak var startAdventureBtn: UIButton!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    var refreshControl = UIRefreshControl()
    
    fileprivate let presenter = PetsPresenter()
    fileprivate let presenter2 = SelectedPetView()
    
    var runningTripArray = [TripList]()
    
    fileprivate var pets = [Int:IndexPath]()
    fileprivate let disposeBag = DisposeBag()
    fileprivate var petIDsOnTrip = [Int64]()
    fileprivate var petIDsToStartTrip : Variable<Set<Int>> = Variable(Set<Int>())
    
    
    var tripListArray = [Int]()
    var action: selectPetsAction? {
        didSet {
            if action != oldValue {
                updateControlsForAction(action)
            }
        }
    }
    
    fileprivate func updateControlsForAction(_ action: selectPetsAction?) {
        
        guard action != nil else {
            return
        }
        
        var headerImage = #imageLiteral(resourceName: "startAdventure")
        var navBarTitle = "Start Adventure"
        var titleText = "Select Pets to Start Adventure"
        var buttonTitle = "START ADVENTURE"
        
        if action == .joinAdventure {
            headerImage = #imageLiteral(resourceName: "JoinAdventure-1x-png")
            navBarTitle = "Join Adventure"
            titleText = "Select Pets to Join Adventure"
            buttonTitle = "JOIN ADVENTURE"
        }
        
        headerImageView?.image = headerImage
        headerTitleLabel?.text = titleText
        startAdventureBtn?.setTitle(buttonTitle, for: UIControlState.normal)
        self.title = navBarTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    fileprivate func initialize() {
        
        if action == nil {
            action = .startAdventure
        }
        
        updateControlsForAction(action)
        
        startAdventureBtn.isEnabled = false
        startAdventureBtn.fullyroundedCorner()
        startAdventureBtn.backgroundColor = UIColor.primary
        
        refreshControl.backgroundColor = UIColor.secondary
        refreshControl.tintColor = UIColor.primary
        refreshControl.addTarget(self, action: #selector(reloadPetsAPI), for: .valueChanged)
        petsCollectionView.addSubview(refreshControl)
        
        presenter.attachView(self)
        presenter2.attatchView(self)
        
        petsCollectionView.delegate = self
        petsCollectionView.dataSource = self
        petsCollectionView.allowsMultipleSelection = true
        
        DataManager.instance.getActivePetTrips().subscribe(onNext: { (data) in
            self.petIDsOnTrip = data.map({$0.petId})
            self.petsCollectionView.reloadData()
        }).addDisposableTo(disposeBag)
        
        petIDsToStartTrip.asObservable().subscribe(onNext: { (data) in
            self.startAdventureBtn.isEnabled = data.count > 0
            self.petsCollectionView.reloadData()
        }).addDisposableTo(disposeBag)
    }
    
    func clearOnAppearance() {
        for indexPath in petsCollectionView.indexPathsForSelectedItems ?? [] {
            petsCollectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    @objc func reloadPetsAPI(){
        presenter.loadPets()
    }
    
    deinit {
        presenter.deteachView()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        clearOnAppearance()
        self.tabBarController?.tabBar.isHidden = true
        reloadPets()
    }

    
    private func updateItem(by id: Int){
        Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Update Pet \(id)")
        if let index = self.pets[id] {
            self.petsCollectionView.reloadItems(at: [index])
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        presenter2.tripList.removeAll()
        
        if var selectedItem = petsCollectionView.indexPathsForSelectedItems {
            selectedItem.removeAll()
        } else {
            print("No index were found")
        }

    }
    
    
    func reloadPets(){
        presenter.getPets()
    }
    
    
    // Mohamed - PetsView
    func errorMessage(_ error: ErrorMsg) {
        refreshControl.endRefreshing()
        alert(title: error.title, msg: error.msg)
    }

    func loadPets() {
        refreshControl.endRefreshing()
        petsCollectionView.reloadData()
    }

    func petsNotFound() {
        refreshControl.endRefreshing()
        petsCollectionView.reloadData()
    }
    
    func getPet(at indexPath: IndexPath) -> Pet {
        if presenter.pets.count > 0 {
            return presenter.pets[indexPath.item]
        }else if presenter.ownedPets.count > 0 {
            return presenter.ownedPets[indexPath.row]
        }else{
            return presenter.sharedPets[indexPath.row]
        }
    }
    
    @IBAction func selectAllPressed(_ sender: Any) {
        petIDsToStartTrip.value = Set(presenter.pets.map({$0.id}).filter { !petIDsOnTrip.contains(Int64($0)) })
        petsCollectionView.reloadData()
    }
    
    @IBAction func StartAdventureBtnPressed(_ sender: Any) {
        showLoadingView()
        
        DataManager.instance.startTrips(petIDsToStartTrip.value.map({$0}))
            .take(1)
            .subscribe(onNext: { (startedTrips) in
                print("Started Trips! \(startedTrips)")
                self.hideLoadingView()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TripScreenViewController")
                
                self.dismiss(animated: true, completion: {
                    self.navigationController?.present(vc!, animated: false, completion: nil)
                })
                
            }, onError: { (error) in
                self.hideLoadingView()
                self.petIDsToStartTrip.value.removeAll()
                let error = error as! APIManagerError
                print("Error \(error.errorCode!)!")
            }).addDisposableTo(disposeBag)
    }

    @IBAction func closebtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue"  {
            dismiss(animated: true, completion: nil)
            if let navigationController = segue.destination as? UINavigationController {
                _ = navigationController.topViewController as? TripScreenViewController
            }
        }
    }
}


extension SelectPetsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let pet = presenter.pets[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath)
        cell!.isSelected = false
        
        if petIDsToStartTrip.value.contains(pet.id) {
            petIDsToStartTrip.value.remove(pet.id)
        } else {
            petIDsToStartTrip.value.insert(pet.id)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}


extension SelectPetsVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.pets.count
    }
    
    // CollectionVIew Method
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let pet = presenter.pets[indexPath.row]
        let petIsOnTrip = petIDsOnTrip.contains(Int64(pet.id))
        let checked = petIsOnTrip || petIDsToStartTrip.value.contains(pet.id)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelectPetsCell
        cell.configureWithPet(pet)
        cell.checkMarkView.setOn(checked, animated: true)
        cell.isUserInteractionEnabled = !petIsOnTrip
        
        return cell
    }
}
