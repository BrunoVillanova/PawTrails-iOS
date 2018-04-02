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

class PetBreedSelectViewController: PetWizardStepViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let dataSource = RxTableViewSectionedReloadDataSource<PetBreedSection>()
    final let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPets()
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
    
        tableView.tableFooterView = UIView()
        
        dataSource.configureCell = { dataSource, tableView, indexPath, breed in
            let cell = tableView.dequeueReusableCell(withIdentifier: PTSimpleTableViewCell.reuseIdentifier, for: indexPath) as! PTSimpleTableViewCell
            let checked = false
            cell.configure(title: breed.name, checked: checked)
            return cell
        }
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(PetBreedSection.Item.self))
            .bind { [unowned self] indexPath, item in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    
    fileprivate func retrieveBreeds() -> Observable<[PetBreedSection]>? {
        if let petType = self.pet!.type, let type = petType.type {
            return DataManager.instance.breeds(for: type)
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
        }

        return nil
    }
    
    fileprivate func reloadPets() {
        retrieveBreeds()?
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
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
