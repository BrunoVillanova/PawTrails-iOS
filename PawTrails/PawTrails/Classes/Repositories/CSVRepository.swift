//
//  CVSParser.swift
//  PawTrails
//
//  Created by Marc Perello on 13/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation


class CSVRepository {
    
    /// Shared Instance
    static let instance = CSVRepository()
    
    fileprivate let ext = "csv"
    fileprivate let lineSplit = "\r\n"
    fileprivate let rowSplit = ";"
    
    func loadCountryCodes(callback: @escaping ()->Void) {
        
        let name = "countrycodes"
        
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            var row = [String]()
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                
                let group = DispatchGroup()
                
                for line in content.components(separatedBy: lineSplit) {
                    
                    row = line.components(separatedBy: rowSplit)
                    
                    if let cc = CountryCode(row) {
                        if cc.isNotNil {
                            group.enter()
                            CDRepository.instance.upsert(cc, callback: { 
                                group.leave()
                            })
                        }else{
                            Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "CSVParser", code: 0, userInfo: ["row" : row]))
                        }
                    }else{
                        Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "CSVParser", code: 1, userInfo: ["row" : row]))
                    }
                }
                
                group.notify(queue: .main, execute: { 
                    callback()
                })
                
            } catch {
                Reporter.send(file: "\(#file)", function: "\(#function)", error, ["url": url, "row": row])
            }
        }else{
            Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "CSVRepository - load country codes", code: -1, userInfo: ["reason": "Url of country codes could not been created"]))
        }
    }
}
