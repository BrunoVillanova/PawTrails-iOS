//
//  ProfileCell.swift
//  PawTrails
//
//  Created by Marc Perello on 07/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class ProfileCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.green
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    
    override func setupViews() {
        self.backgroundColor = UIColor.red
        
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        let collectionview = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return collectionview
        

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    
    
    
    
}
