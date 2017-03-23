//
//  Notifier.swift
//  Snout
//
//  Created by Marc Perello on 15/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit


public class Notifier {

    private enum notificationType {
        
        case red, blue, green
        
        var color: UIColor {
            switch self {
            case .red: return UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.8)
            case .green: return UIColor(red: 0, green: 0.5, blue: 0.2, alpha: 0.8)
            default: return UIColor(red: 0, green: 0.478431, blue: 1, alpha: 0.8)
            }
        }
    }
    
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
        self.view.addSubview(self.notification(title: Message.Instance.connectionError(type: .NoConnection), type: .red))
    }

    let viewHeight:CGFloat = 64, labelHeight: CGFloat = 24
    
    private func notification(title:String, type:notificationType = .blue) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: viewHeight))
        view.backgroundColor = type.color
        
        let label = UILabel(frame: CGRect(x: 0, y: labelHeight, width: self.view.bounds.width, height: 40))
        label.text = title
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        
        view.addSubview(label)
        return view
    }


}
