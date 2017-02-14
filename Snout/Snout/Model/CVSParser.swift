//
//  CVSParser.swift
//  Snout
//
//  Created by Marc Perello on 13/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation


class CSVParser {
    
    static let Instance = CSVParser()
    
    fileprivate let name = "countrycodes"
    fileprivate let ext = "csv"
    fileprivate let split = "\r\n"
    
    func loadCountryCodes() {
        
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                
                
                for line in content.components(separatedBy: split) {
                    
                    let row = line.components(separatedBy: ",")
                    
                    var element = [String:Any]()
                    element["name"] = row[0]
                    element["shortname"] = row[1]
                    element["code"] = row[2]
                    _ = try CoreDataManager.Instance.store(entity: "CountryCode", withData: element)
                }
                
            } catch {
                debugPrint(error)
            }
        }
    }
}
