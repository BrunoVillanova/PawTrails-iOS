//
//  PetBreedViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 31/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Differentiator
import Foundation

class PetBreedSelectViewController: PetWizardStepViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    final let disposeBag = DisposeBag()
    fileprivate final let dataSource = RxTableViewSectionedReloadDataSource<PetBreedSection>()
    fileprivate var petBreedSections: Variable<[PetBreedSection]> = Variable([PetBreedSection]())
    fileprivate var selectedBreed: Variable<Breed?> = Variable(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveBreeds()
        if let _ = self.pet?.breeds {
            self.delegate?.stepCompleted(completed: true, pet: self.pet!)
        } else  {
            self.delegate?.stepCompleted(completed: false, pet: self.pet!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func nextButtonVisible() -> Bool {
        return true
    }
    
    fileprivate func initialize() {
        rightBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skipTapped))
        configureSearchTextField()
        configureTableDataSource()
    }
    
    fileprivate func retrieveBreeds() {
        if let pet = self.delegate?.getPet(), let petType = pet.type, let type = petType.type {
            DataManager.instance.breeds(for: type)
                .map({ (breeds) -> [PetBreedSection] in
                    var sections = [PetBreedSection]()
                    
                    for breed in breeds {
                        let breedName = breed.name
                        let headerTitle = "\(breedName[breedName.startIndex])".uppercased()

                        if let existingSectionModel = sections.first(where: { (breedSection) -> Bool in
                            return breedSection.header == headerTitle
                        }) {
                            var theBreeds = Array(existingSectionModel.items)
                            theBreeds.append(breed)
                            if let index = sections.index(where: { (bs) -> Bool in
                                return bs.header == headerTitle
                            }) {
                                sections.remove(at: index)
                            }
                            
                            sections.append(PetBreedSection(header: headerTitle, items: theBreeds))
                        } else {
                            sections.append(PetBreedSection(header: headerTitle, items: [breed]))
                        }
                    }

                    return sections.sorted { $0.header < $1.header}
                })
                .bind(to: self.petBreedSections)
                .disposed(by: disposeBag)
        }
    }
    
    fileprivate func configureSearchTextField() {
        if let searchImage = UIImage(named: "SearchIcon") {
            let frame = CGRect(x: 0, y: 0, width: searchImage.size.width+16, height: searchImage.size.height)
            let searchImageView = UIImageView(frame: frame)
            searchImageView.contentMode = .center
            searchImageView.image = searchImage
            searchImageView.tintColor = PTConstants.colors.darkGray
            searchTextField.leftView = searchImageView
            searchTextField.leftViewMode = .always
            searchTextField.tintColor = PTConstants.colors.darkGray
        }

    }
    
    func skipTapped() {
        self.delegate?.goToNextStep()
    }
    
    @IBAction func crossBreedButtonTapped(_ sender: Any) {
        
        let title = "Cross breed"
        let textFieldTitle = "Type in your pet’s breed"
        
        let alertView = PTAlertViewController(title, textFieldLabelTitle: textFieldTitle,
                                              titleBarStyle: .green, alertResult: {alert, result in
                                                if result == .cancel {
                                                    alert.dismiss()
                                                } else {
                                                    if let text = alert.textField?.text {
                                                        self.pet?.breeds = PetBreeds(first: nil, second: nil, text)
                                                        self.delegate?.updatePet(self.pet)
                                                        self.delegate?.stepCompleted(completed: true, pet: self.pet!)
                                                        self.delegate?.goToNextStep()
                                                    }
                                                    alert.dismiss()
                                                    
                                                }
        })
        if let petBreed = self.pet?.breeds, let description = petBreed.description {
            alertView.textFieldText = description
        }
        self.present(alertView, animated: false, completion: nil)
    }
    
    func configureTableDataSource() {
        
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 52
        
        dataSource.configureCell = { dataSource, tableView, indexPath, breed in
            let cell = tableView.dequeueReusableCell(withIdentifier: PTSimpleTableViewCell.reuseIdentifier, for: indexPath) as! PTSimpleTableViewCell
            
            var checked = false
            
            if let selectedBreed = self.selectedBreed.value, breed.id == selectedBreed.id {
                checked = true
            }
            
            cell.configure(title: breed.name, checked: checked)
            return cell
        }
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        
        let search = searchTextField.rx.text.orEmpty
            .asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
        
        let termAndBreeds = Observable.combineLatest(search.asObservable(), petBreedSections.asObservable())
            .map({ (query, petBreedSections) -> [PetBreedSection] in
                
                if query.count > 0 {
                    var filteredSections = [PetBreedSection]()
                    
                    for breedSection in petBreedSections {
                        let filteredItems = breedSection.items.filter ({ $0.name.hasPrefix(query) })
                        if filteredItems.count > 0 {
                            filteredSections.append(PetBreedSection(header: breedSection.header, items: filteredItems))
                        }
                    }
                    
                    return filteredSections
                } else {
                    return petBreedSections
                }
            })
        
        Observable.combineLatest(termAndBreeds.asObservable(), selectedBreed.asObservable())
            .map({ (petBreedSections, selectedBreed) -> [PetBreedSection] in
                return petBreedSections
            })
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(PetBreedSection.Item.self))
            .bind { [unowned self] indexPath, item in
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.selectedBreed.value = item
                self.pet!.breeds = PetBreeds(first: item, second: nil, nil)
                self.delegate?.stepCompleted(completed: true, pet: self.pet!)
            }
            .disposed(by: disposeBag)
    }
    
}

extension PetBreedSelectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .white
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = PTConstants.colors.darkGray
        header.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 20)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }
}

class PTSimpleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "PTSimpleTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    func configure(title: String?, checked: Bool = false) {
        titleLabel.text = title
        iconImageView.isHidden = !checked
    }
}

fileprivate struct PetBreedSection {
    var header: String
    var items: [Item]
}

extension PetBreedSection: SectionModelType {
    typealias Item = Breed
    
    init(original: PetBreedSection, items: [Item]) {
        self = original
        self.items = items
    }
}
