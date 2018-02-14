//
//  CacheManager.swift
//  PawTrails
//
//  Created by Bruno Villanova on 13/02/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import Cache

class CacheManager {
    static let sharedInstance = CacheManager()
    
    
    static  let diskConfig = DiskConfig(
        // The name of disk storage, this will be used as folder name within directory
        name: "AppCache",
        // Expiry date that will be applied by default for every added object
        // if it's not overridden in the `setObject(forKey:expiry:)` method
        expiry: .date(Date().addingTimeInterval(2*3600)),
        // Maximum size of the disk cache storage (in bytes)
        maxSize: 10000,
        // Where to store the disk cache. If nil, it is placed in `cachesDirectory` directory.
        directory: try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                appropriateFor: nil, create: true).appendingPathComponent("MyPreferences"),
        // Data protection is used to store files in an encrypted format on disk and to decrypt them on demand
        protectionType: .complete
    )
    
    static let memoryConfig = MemoryConfig(
        // Expiry date that will be applied by default for every added object
        // if it's not overridden in the `setObject(forKey:expiry:)` method
        expiry: .date(Date().addingTimeInterval(2*60)),
        /// The maximum number of objects in memory the cache should hold
        countLimit: 50,
        /// The maximum total cost that the cache can hold before it starts evicting objects
        totalCostLimit: 0
    )
    
    open var storage = try! Storage(diskConfig: CacheManager.diskConfig, memoryConfig: CacheManager.memoryConfig)
}
