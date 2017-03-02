//
//  Notifier.swift
//  Snout
//
//  Created by Marc Perello on 15/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

public class Notifier {

    private let view: UIView!
    private var label:UILabel!

    init(with view:UIView) {
        self.view = view
    }

    //MARK: - Connection
    
    func connectedToNetwork() {
        self.label.removeFromSuperview()
    }

    func notConnectedToNetwork() {
        self.label = self.notification(title: Message.Instance.connectionError(type: .NoConnection), type: .red)
        self.label.layer.zPosition = 1
        self.view.addSubview(self.label)
    }

    private func notification(title:String, type:notificationType = .blue) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20))
        label.text = title
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        switch type {
        case .red: label.backgroundColor = UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.8)
            break
        case .green: label.backgroundColor = UIColor(red: 0, green: 0.5, blue: 0.2, alpha: 0.8)
            break
        default: label.backgroundColor = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 0.8)
        }
        label.textAlignment = .center
        return label
    }


}
