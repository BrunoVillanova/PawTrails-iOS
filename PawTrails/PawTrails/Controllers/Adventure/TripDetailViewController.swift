//
//  TripDetailViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 19/02/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

protocol TripDetailViewControllerDelegate {
    func closed(viewController: TripDetailViewController)
}

class TripDetailViewController: UIViewController {

    var trips: [Trip]?
    let mapView = PTMapView(frame: CGRect.zero)
    let infoViewContainer = UIView(frame: .zero)
    var delegate: TripDetailViewControllerDelegate?
    var collectionView: UICollectionView?
    var pageControl: UIPageControl?
    var scrollViewPageIndex :Int {
        set {
            let contentX = collectionView!.frame.size.width * CGFloat(newValue)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: { [weak self] _ in
                    self?.collectionView!.contentOffset = CGPoint.init(x: contentX, y: 0)
                })
            }
        }
        get {
            if let collectionView = collectionView, collectionView.contentOffset.x != 0, collectionView.frame.size.width != 0 {
                return Int(collectionView.contentOffset.x / collectionView.frame.size.width)
            }
            
            return 0
        }
    }
    var selectedPageIndex = Variable(Int())
    final let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
        configureLayout()
        configureData()
        configureNavigationBar()
    }
    
    func closeButtonTapped() {
        self.dismiss(animated: true, completion: {
            self.delegate?.closed(viewController: self)
        })
    }
    
    fileprivate func configureNavigationBar() {
        if self.navigationController != nil && self.presentingViewController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close-1x-png"), style: .plain, target: self, action: #selector(closeButtonTapped))
            self.navigationItem.leftBarButtonItem?.tintColor = .darkGray
        }
        
        self.navigationItem.title = "Adventure Result"
    }
    
    fileprivate func configureLayout() {
        self.extendedLayoutIncludesOpaqueBars = false
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(mapView)
        
        infoViewContainer.backgroundColor = .white
        self.view.addSubview(infoViewContainer)

        let infoViewContainerSize: CGFloat = 200
        
        infoViewContainer.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottomMargin)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(infoViewContainerSize)
        }
        
        var collectionViewLayoutHeight = infoViewContainerSize
        
        if let trips = trips, trips.count > 1 {
            pageControl = UIPageControl()
            infoViewContainer.addSubview(pageControl!)
            pageControl!.numberOfPages = trips.count
            pageControl!.pageIndicatorTintColor = .lightGray
            pageControl!.currentPageIndicatorTintColor = .darkGray
            pageControl!.snp.makeConstraints({ (maker) in
                maker.height.equalTo(16)
                maker.centerX.equalToSuperview()
                maker.bottom.equalToSuperview()
            })
            collectionViewLayoutHeight = infoViewContainerSize - 30
        }

        // CollectionView
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: collectionViewLayoutHeight)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.register(TripInfoCollectionViewCell.self, forCellWithReuseIdentifier: TripInfoCollectionViewCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        self.collectionView = collectionView
        
        infoViewContainer.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            if let pageControl = pageControl {
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalTo(pageControl.snp.top)
            } else {
                make.edges.equalToSuperview()
            }
        }
        
        selectedPageIndex.asObservable().bind(to: pageControl!.rx.currentPage).disposed(by: disposeBag)
        
        collectionView.rx.contentOffset.bind { [weak self] (point) in
            guard let _ = self?.collectionView!.frame.size.width else {
                return
            }
            
            if let _ = self?.collectionView {
                
                if let scrollViewPageIndex = self?.scrollViewPageIndex {
                    self?.selectedPageIndex.value = scrollViewPageIndex
                }
            
            }
            
            }.disposed(by: disposeBag)
        
        mapView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(infoViewContainer.snp.top)
        }
    }
    
    override func viewDidLayoutSubviews() {
        infoViewContainer.dropShadow(color: .black, opacity: 0.1, offSet: CGSize(width: 0, height: -2), radius: 1, scale: true)
    }
    
    fileprivate func configureData() {
        
        mapView.allowUserInteraction(true)
        
        trips?.forEach({ (trip) in
            mapView.setStaticTripView(trip)
            if let petName = trip.pet.name {
                self.navigationItem.title = "\(petName)'s Adventure"
            }
        })
    }
}

extension TripDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let trips = self.trips {
            return trips.count
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripInfoCollectionViewCell.identifier, for: indexPath) as! TripInfoCollectionViewCell
        
        if let trips = self.trips {
            let trip = trips[indexPath.row]
            cell.configureWithTrip(trip)
        }
        
        return cell

    }
}

