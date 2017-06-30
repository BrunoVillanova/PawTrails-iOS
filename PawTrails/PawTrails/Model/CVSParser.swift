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
    fileprivate let lineSplit = "\r\n"
    fileprivate let rowSplit = ";"
    
    func loadCountryCodes() {
        
        let name = "countrycodes"
        
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                
                for line in content.components(separatedBy: lineSplit) {
                    
                    let row = line.components(separatedBy: rowSplit)
                    
                    if let cc = CountryCode(row) {
                        if cc.isNotNil {
                            CDRepository.instance.upsert(cc)
                        }else{
                            debugPrint("Error \(row)")
                        }
                    }else{
                        debugPrint("Error \(row)")
                    }
                }
                
            } catch {
                debugPrint(error)
            }
        }
    }
}
