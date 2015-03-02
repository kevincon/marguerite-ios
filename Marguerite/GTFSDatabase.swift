//
//  GTFSDatabase.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/1/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import Foundation

extension NSFileManager {
    class func documentsDirectory() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDirectory() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) as [String]
        return paths[0]
    }
}

class GTFSDatabase {
    
    // MARK: - Access
    
    class func open() -> FMDatabase? {
        var databasePath = GTFSDatabase.resourceDatabasePath()
        if GTFSDatabase.autoUpdateBuildExists() {
            databasePath = GTFSDatabase.autoUpdateDatabasePath()
        }
        let db = FMDatabase(path: databasePath)
        if !db.open() {
            return nil
        } else {
            return db
        }
    }
    
    // MARK: - Paths
    
    class func resourceDatabasePath() -> String {
        return NSBundle.mainBundle().pathForResource("gtfs", ofType: "db")!
    }
    
    class func autoUpdateDatabasePath() -> String {
        return NSFileManager.cachesDirectory().stringByAppendingPathComponent("gtfs.db")
    }
    
    class func autoUpdateBuildExists() -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(autoUpdateDatabasePath())
    }
    
}
