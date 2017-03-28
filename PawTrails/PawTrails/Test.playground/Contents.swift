//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

for i in 1...10 {
    round((Double(i))/10)
}


var data = [String:[String]]()

let list = "🗺 🗿 🗽 ⛲️ 🗼 🏰 🏯 🏟 🎡 🎢 🎠 ⛱ 🏖 🏝 ⛰ 🏔 🗻 🌋 🏜 🏕 ⛺️ 🛤 🛣 🏗 🏭 🏠 🏡 🏘 🏚 🏢 🏬 🏣 🏤 🏥 🏦 🏨 🏪 🏫 🏩 💒 🏛 ⛪️ 🕌 🕍 🕋 ⛩"


for emoji in list.components(separatedBy: " ") {
    
    if var result = emoji.applyingTransform( kCFStringTransformToUnicodeName as StringTransform, reverse: false) {
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

data["castle"]

print(data)

