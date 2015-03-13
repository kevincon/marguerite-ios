//
//  GTFSDatabase.swift
//  A convenience struct for accessing the GTFS sqlite3 database.
//
//  Created by Kevin Conley on 3/1/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import Foundation

struct GTFSDatabase {
    
    // MARK: - Access
    
    static func open() -> FMDatabase? {
        let databasePath = GTFSDatabase.resourceDatabasePath()
        let db = FMDatabase(path: databasePath)
        if !db.open() {
            return nil
        } else {
            return db
        }
    }

    // MARK: - Paths
    
    static func resourceDatabasePath() -> String {
        return NSBundle.mainBundle().pathForResource("gtfs", ofType: "db")!
    }
}
