//
//  PetCollectionViewCell.swift
//  PawTrails
//
//  Created by Bruno Villanova on 04/13/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SDWebImage

class PetCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: PTBalloonImageView!
    
    final let placeholderImage = UIImage(named: "PetPlaceholderImage")
    var mainView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    fileprivate func setupView() {
        
        if let viewFromNib = Bundle.main.loadNibNamed("PetCollectionViewCell", owner: self, options: nil)?.first as? UIView {
            viewFromNib.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewFromNib.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            mainView = viewFromNib
            self.addSubview(viewFromNib)
        }
        imageView.image = placeholderImage
    }
    
    func configure(_ pet: Pet) {
        imageView.imageUrl = pet.imageURL
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
    }
}
