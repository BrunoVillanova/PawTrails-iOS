//
//  SupportViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 10/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class SupportViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let companyLogoImageView = UIImageView(image: UIImage(named: "CompanyLogoColorSmall"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let image = companyLogoImageView.image {
            let originY = tableView.bounds.size.height - (image.size.height+self.bottomSafeAreaHeight)
            companyLogoImageView.frame = CGRect(x: 0, y: originY, width: image.size.width, height: image.size.height)
            var center: CGPoint = companyLogoImageView.center
            center.x = tableView.bounds.size.width/2.0
            companyLogoImageView.center = center
        }
        
    }
    
    fileprivate func initialize() {
        configureNavigationBar()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = nil
        tableView.addSubview(companyLogoImageView)
    }
    
    fileprivate func configureNavigationBar() {
        
        if let navigationController = self.navigationController as? PTNavigationViewController {
            navigationController.showNavigationBarDropShadow = true
        }
        
        self.navigationItem.title = "Support"
    }
}

extension SupportViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PTSupportCell
        
        var text: String?
        var iconImageName: String?
        
        if indexPath.section == 0 {
            text = "info@pawtrails.com\nWe will be in contact with you shortly"
            iconImageName = "EmailSupportIcon"
        } else {
            text = "Ireland\n+353 (21) 432 1699\nWorking Hours:\n9:00am-5:00pm Monday to Friday\nExcluding Public Holidays"
            iconImageName = "PhoneSupportIcon"
        }
        
        cell.configure(text, iconImageName: iconImageName)
        
        return cell
    }
}

extension SupportViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = "Email Support"
        
        if section == 1 {
            title = "Give us a call"
        }
        
        
        return PTTableViewHeader(title)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 48
        }
        
        return 16
    }
}

import SnapKit

class PTTableViewHeader: UIView {
    
    let titleLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    convenience init(_ title: String?) {
        self.init(frame: .zero)
        configure(title)
    }
    
    fileprivate func setupView() {
        self.backgroundColor = .clear
        self.addSubview(titleLabel)
        titleLabel.font = UIFont(name: "Montserrat-Regular", size: 20)
        titleLabel.textColor = PTConstants.colors.darkGray
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview()
            make.trailing.greaterThanOrEqualToSuperview().offset(16)
        }
    }
    
    func configure(_ title: String?) {
        titleLabel.text = title
    }
}


class PTSupportCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    func configure(_ text: String?, iconImageName: String?) {
        if let text = text {
            let attributedString = NSMutableAttributedString(string: text, attributes: [
                NSFontAttributeName : UIFont(name: "Montserrat-Regular", size: 14)!,
                NSForegroundColorAttributeName: PTConstants.colors.darkGray
                ])
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = 12
            attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            titleLabel.attributedText = attributedString
        }
        
        if let iconImageName = iconImageName, let iconImage = UIImage(named: iconImageName) {
            iconImageView.image = iconImage
        }
    }
}

class PTShadowView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    fileprivate func setupView() {
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 5
        self.layer.shadowColor = PTConstants.colors.newLightGray.cgColor
        self.layer.shadowOpacity = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
}
