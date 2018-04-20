//
//  ViewControllerUtilities.swift
//  PawTrails
//
//  Created by Bruno Villanova on 20/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import Foundation
import RxSwift

class PTViewController: UIViewController {
    let disposeBag = DisposeBag()
}

extension PTViewController {
    
    func showSelectPetAlert(_  title: String?, selectedAction: @escaping ((_ alert: PTAlertViewController, _ selectedPet: Pet) -> Void)) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let alertView = PTAlertViewController(title, buttonTypes: nil, titleBarStyle: .green)
        
        //// TableView setup
        let contentX:CGFloat = 24
        let contentY:CGFloat = 16
        let contentHeight:CGFloat = 46
        let rowHeight:CGFloat = 82
        let minTableViewSize:CGFloat = 1*rowHeight
        let maxTableViewSize:CGFloat = 3*rowHeight
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: minTableViewSize), style: .plain)
        let cellIdentifier = "cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = rowHeight
        tableView.separatorStyle = .none
        
        let pets = DataManager.instance.pets()

        pets
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier,
                                         cellType: UITableViewCell.self)) {row, element, cell in
                                            
                                            let _ = cell.contentView.subviews.map { $0.removeFromSuperview() }
                                            
                                            cell.selectionStyle = .none
                                            
                                            // Main View
                                            let mainView = PTCircleImageTitleView(frame:  CGRect(x: contentX, y: contentY, width: cell.contentView.bounds.width, height: contentHeight))
                                            
                                            if let petImageURLString = element.imageURL {
                                                mainView.imageView.sd_setImage(with: URL(string: petImageURLString), completed: nil)
                                            }
                                            
                                            mainView.titleLabel.text = element.name
                                            cell.contentView.addSubview(mainView)
                                            
                                            // Separator
                                            let separatorView = UIView(frame: CGRect(x: 0, y: cell.contentView.bounds.height-1, width: cell.contentView.bounds.width, height: 1))
                                            separatorView.backgroundColor = PTConstants.colors.newLightGray
                                            separatorView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
                                            cell.contentView.addSubview(separatorView)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Pet.self)
            .asObservable()
            .subscribe(onNext: { (pet) in
                selectedAction(alertView, pet)
            })
            .disposed(by: disposeBag)
        
        
        alertView.contentView.addSubview(tableView)
        alertView.alertWillAppear = {alert in
            let bottomOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height)
            tableView.setContentOffset(bottomOffset, animated: false)
        }
        
        // Footer View
        let footerViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: rowHeight))
        let footerView = PTCircleImageTitleView(frame:  CGRect(x: contentX, y: contentY, width: footerViewContainer.bounds.size.width-contentX, height: contentHeight))
        footerView.imageView.image = UIImage(named: "CirclePlusIcon")
        footerView.titleLabel.text = "Add Pet"
        footerViewContainer.addTapGestureRecognizer {
            alertView.dismiss(animated: true, completion: {
                appDelegate.presentViewController(ViewController.petWizard)
            })
        }
        footerViewContainer.addSubview(footerView)
        tableView.tableFooterView = footerViewContainer
        
        pets
            .subscribe(onNext: { (pets) in
                let newSize = minTableViewSize + CGFloat(pets.count)*rowHeight
                let theHeight = newSize < maxTableViewSize ? newSize : maxTableViewSize
                
                alertView.setContentViewHeightAnimated(theHeight, afterHeightChanged: {
                    let bottomOffset = CGPoint(x: 0, y: 0)
                    tableView.setContentOffset(bottomOffset, animated: false)
                })
            })
            .disposed(by: disposeBag)
        
        // Present
        self.present(alertView, animated: true, completion: nil)
    }
}
