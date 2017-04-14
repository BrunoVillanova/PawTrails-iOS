//
//  EmojiiManager.swift
//  PawTrails
//
//  Created by Marc Perello on 08/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class EmojiManager {
    
    static var Instance = EmojiManager()
    
    private var data = [String:[String]]()
    private let list = "🗺 🗿 🗽 ⛲️ 🗼 🏰 🏯 🏟 🎡 🎢 🎠 ⛱ 🏖 🏝 ⛰ 🏔 🗻 🌋 🏜 🏕 ⛺️ 🛤 🏭 🏠 🏡 🏘 🏚 🏢 🏬 🏣 🏤 🏥 🏦 🏨 🏪 🏫 🏩 💒 🏛 ⛪️ 🕌 🕍 🕋 ⛩"
    
    init() {
        
        for emoji in list.components(separatedBy: " ") {
            
            if let result = emoji.applyingTransform( kCFStringTransformToUnicodeName as StringTransform, reverse: false) {
                if let i0 = result.range(of: "{"),  let i1 = result.range(of: "}") {
                    
                    let cleanList = result[i0.upperBound..<i1.lowerBound].lowercased().components(separatedBy: " ")
                    
                    for key in cleanList {
                        if data[key] == nil {
                            data[key] = [String]()
                        }
                        data[key]!.append(emoji)
                    }
                }
            }
        }
    }
    
    public func getEmojis(from text: String) -> [String]? {
        for part in text.components(separatedBy: " ").reversed() {
            if data[part] != nil {
                return data[part]
            }
        }
        return nil
    }
    
}
