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
    
    class func fileExists(path: String) -> Bool {
        return self.defaultManager().fileExistsAtPath(path)
    }
}

protocol GTFSDatabaseCreationProgressDelegate {
    func updatingStepNumber(currentStep: Int, outOfTotalSteps totalSteps: Int, currentStepLabel stepDesc:String)
}

struct GTFSDatabaseBuildStatus {
    static var inProgress = false
}

@objc class GTFSDatabase {
    
    // MARK: - Access
    
    class func open() -> FMDatabase? {
        var databasePath = GTFSDatabase.resourceDatabasePath()
        if NSFileManager.fileExists(autoUpdateDatabasePath()) {
            databasePath = GTFSDatabase.autoUpdateDatabasePath()
        }
        let db = FMDatabase(path: databasePath)
        if !db.open() {
            return nil
        } else {
            return db
        }
    }
    
    // MARK: - Creation
    
    class func activateNewAutoUpdateBuildIfAvailable() -> Bool {
        if !GTFSDatabaseBuildStatus.inProgress && NSFileManager.fileExists(GTFSDatabase.newAutoUpdateDatabasePath()) {
            return GTFSDatabase.copyNewAutoUpdateDatabaseBuild() && GTFSDatabase.deleteDatabase(GTFSDatabase.newAutoUpdateDatabasePath())
        }
        return true
    }
    
    /*
    Uses GTFS text files to create an sqlite3 database in the Caches directory.
    Returns YES if gtfs.db exists in Caches directory afterwards, NO otherwise.
    */
    class func create<T: GTFSDatabaseCreationProgressDelegate>(creationProgressDelegate: T) -> Bool {
        if !GTFSDatabase.deleteDatabase(GTFSDatabase.newAutoUpdateDatabasePath()) {
            return false
        }
        
        GTFSDatabaseBuildStatus.inProgress = true
        
        let importer = GTFSImporter()
        
        print("Importing Agency...")
        creationProgressDelegate.updatingStepNumber(1, outOfTotalSteps: 12, currentStepLabel: "Importing Agency...")
        importer.addAgency()
        
        print("Importing Calendar Dates...")
        creationProgressDelegate.updatingStepNumber(2, outOfTotalSteps: 12, currentStepLabel: "Importing Calendar Dates...")
        importer.addCalendarDate()
        
        print("Importing Routes...")
        creationProgressDelegate.updatingStepNumber(3, outOfTotalSteps: 12, currentStepLabel: "Importing Routes...")
        importer.addRoute()
        
        print("Importing Shapes...")
        creationProgressDelegate.updatingStepNumber(4, outOfTotalSteps: 12, currentStepLabel: "Importing Shapes...")
        importer.addShape()
        
        print("Importing Stops...")
        creationProgressDelegate.updatingStepNumber(5, outOfTotalSteps: 12, currentStepLabel: "Importing Stops...")
        importer.addStop()
        
        print("Importing Trips...")
        creationProgressDelegate.updatingStepNumber(6, outOfTotalSteps: 12, currentStepLabel: "Importing Trips...")
        importer.addTrip()
        
        print("Importing StopTime...")
        creationProgressDelegate.updatingStepNumber(7, outOfTotalSteps: 12, currentStepLabel: "Importing StopTime...")
        importer.addStopTime()
        
        print("Vacuuming...")
        creationProgressDelegate.updatingStepNumber(8, outOfTotalSteps: 12, currentStepLabel: "Vacuuming...")
        importer.vacuum()
        
        print("Reindexing...")
        creationProgressDelegate.updatingStepNumber(9, outOfTotalSteps: 12, currentStepLabel: "Reindexing...")
        importer.reindex()
        
        //For convenience. This will add an extra column 'routes' which will contain comma seperated route numbers passing through each stop
        print("Adding routes to stops...")
        creationProgressDelegate.updatingStepNumber(10, outOfTotalSteps: 12, currentStepLabel: "Adding routes to stops...")
        importer.addStopRoutes()
        
        print("Vacuuming...")
        creationProgressDelegate.updatingStepNumber(11, outOfTotalSteps: 12, currentStepLabel: "Vacuuming...")
        importer.vacuum()
        
        print("Reindexing...")
        creationProgressDelegate.updatingStepNumber(12, outOfTotalSteps: 12, currentStepLabel: "Reindexing...")
        importer.reindex()
        
        GTFSDatabaseBuildStatus.inProgress = false
        
        print("GTFS import complete!")
        
        let databaseExists = NSFileManager.fileExists(GTFSDatabase.newAutoUpdateDatabasePath())
        if databaseExists {
            print("DB file exists: true")
        } else {
            print("DB file exists: false")
        }
        
        return databaseExists
    }
    
    // MARK: - Deletion
    
    class func deleteDatabase(path: String) -> Bool {
        var error: NSErrorPointer = nil
        
        if NSFileManager.fileExists(path) {
            SwiftTryCatch.try({
                NSFileManager.defaultManager().removeItemAtPath(path, error: error)
                return
            }, catch: { (error) in
                println("deleteDatabase(): \(error.reason)")
            }, finally: {})
            if error != nil {
                return false
            }
        }
        return true
    }
    
    // MARK: - Copying
    
    class func copyNewAutoUpdateDatabaseBuild() -> Bool {
        let dest = GTFSDatabase.autoUpdateDatabasePath()
        let src = GTFSDatabase.newAutoUpdateDatabasePath()
        
        if !NSFileManager.fileExists(GTFSDatabase.newAutoUpdateDatabasePath()) {
            print("copyNewAutoUpdateDatabaseBuild(): GTFS auto update database not available.")
            return false
        }
        
        GTFSDatabase.deleteDatabase(GTFSDatabase.autoUpdateDatabasePath())
        
        var error: NSErrorPointer = nil
        
        SwiftTryCatch.try({
            NSFileManager.defaultManager().copyItemAtPath(src, toPath: dest, error: error)
            return
        }, catch: { (error) in
            println("copyNewAutoUpdateDatabaseBuild(): \(error.reason)")
        }, finally: {})
        
        if error != nil {
            return false
        }
        
        return true
    }
    
    // MARK: - Paths
    
    class func resourceDatabasePath() -> String {
        return NSBundle.mainBundle().pathForResource("gtfs", ofType: "db")!
    }
    
    class func newAutoUpdateDatabasePath() -> String {
        return NSFileManager.cachesDirectory().stringByAppendingPathComponent("gtfs_auto_update_build_db")
    }
    
    class func autoUpdateDatabasePath() -> String {
        return NSFileManager.cachesDirectory().stringByAppendingPathComponent("gtfs.db")
    }
    
}
