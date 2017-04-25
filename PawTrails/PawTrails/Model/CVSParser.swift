//
//  CVSParser.swift
//  PawTrails
//
//  Created by Marc Perello on 13/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation


class CSVParser {
    
    static let Instance = CSVParser()
    
    fileprivate let ext = "csv"
    fileprivate let lineSplit = "\n"
    fileprivate let rowSplit = ","
    
    func loadCountryCodes() {
        
        let name = "countrycodes"
        
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                
                
                for line in content.components(separatedBy: lineSplit) {
                    
                    let row = line.components(separatedBy: rowSplit)
                    
                    if row.count == 3 {
                        var element = [String:Any]()
                        element["name"] = row[0]
                        element["shortname"] = row[1]
                        element["code"] = row[2]
                        _ = try CoreDataManager.Instance.upsert("CountryCode", with: element, withId: "code")
                    }
                }
                
            } catch {
                debugPrint(error)
            }
        }
    }
    
//    func getBreeds(for type: Type) -> [String]? {
//        
//        guard let typeName = type.name else { return nil }
//        
//        let name = "\(typeName.lowercased())breeds"
//        
//        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
//            
//            do {
//                let content = try String(contentsOf: url, encoding: .utf8)
//                
//                var breeds = [String]()
//                
//                for line in content.components(separatedBy: "\n") {
//                    
//                    let row = line.components(separatedBy: rowSplit)
//                    
//                    if row.count == 1 {
//                        breeds.append(row[0])
//                    }
//                }
//                
//                return breeds
//                
//            } catch {
//                debugPrint(error)
//            }
//        }
//        return nil
//    }
    
}
