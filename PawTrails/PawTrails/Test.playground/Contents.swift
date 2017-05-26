//: Playground - noun: a place where people can play

import UIKit

//var str = "Hello, playground"
//
//for i in 1...10 {
//    round((Double(i))/10)
//}
//
//
//var data = [String:[String]]()
//
//let list = "🗺 🗿 🗽 ⛲️ 🗼 🏰 🏯 🏟 🎡 🎢 🎠 ⛱ 🏖 🏝 ⛰ 🏔 🗻 🌋 🏜 🏕 ⛺️ 🛤 🛣 🏗 🏭 🏠 🏡 🏘 🏚 🏢 🏬 🏣 🏤 🏥 🏦 🏨 🏪 🏫 🏩 💒 🏛 ⛪️ 🕌 🕍 🕋 ⛩"
//
//
//for emoji in list.components(separatedBy: " ") {
//    
//    if var result = emoji.applyingTransform( kCFStringTransformToUnicodeName as StringTransform, reverse: false) {
//        if let i0 = result.range(of: "{"),  let i1 = result.range(of: "}") {
//            
//            let cleanList = result[i0.upperBound..<i1.lowerBound].lowercased().components(separatedBy: " ")
//
//            for key in cleanList {
//                if data[key] == nil {
//                    data[key] = [String]()
//                }
//                data[key]!.append(emoji)
//            }
//        }
//    }
//}
//
//data["castle"]
//
//print(data)

//import Foundation
//
//let headers = [
//    "content-type": "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW",
//    "token": "sICQaPLYvjwl3VyeHQVwVO3lCg5mcRDFzgvK5gIBAfWEbvSTlNpgBsCeJIAWzeB9u7UznDaYT7C4CvXXimeUPQ9yyKv8Y6isdc2BQdzJkcNXHLU089VXZ4wy1494764115O1HN7ZglciW2wvLQIzNqkIqtRlrRqXqeZ7277iskBpn7V8YDIM33vuwmPXefVFuUMx2UPverUByPKxtsjxwP12bQ0q6V5BQS8SMYo1piDY8owBRQ8nF9pR0p",
//    "cache-control": "no-cache",
//    "postman-token": "069eec91-9c87-de92-1753-28f8eea5b673"
//]
//let parameters = [
//    [
//        "name": "path",
//        "value": "user"
//    ],
//    [
//        "name": "userid",
//        "value": "2"
//    ],
//    [
//        "name": "picture",
//        "fileName": "/Users/iosdeveloper/Downloads/IMG_2335.JPG"
//    ]
//]
//
//let boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
//
//var body = ""
//
//for param in parameters {
//    let paramName = param["name"]!
//    body += "--\(boundary)\r\n"
//    body += "Content-Disposition:form-data; name=\"\(paramName)\""
//    if let filename = param["fileName"] {
//        do {
////            let contentType = param["content-type"]!
//
//            let fileContent = try String(contentsOfFile: filename, encoding: String.Encoding.utf8)
//            body += "; filename=\"\(filename)\"\r\n"
////            body += "Content-Type: \(contentType)\r\n\r\n"
//            body += fileContent
//
//        } catch {
//            
//            
//        }
//    } else if let paramValue = param["value"] {
//        body += "\r\n\r\n\(paramValue)"
//    }
//}
//
//print(body)


for i in 0...10 {
    
    let c = Double(arc4random() % 10000)/1000000.0
    print(c)
    
}












