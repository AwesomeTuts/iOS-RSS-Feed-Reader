//
//  CoreDataStack.swift
//  RSSReader
//
//  Created by Fahir on 2/8/15.
//  Copyright (c) 2015 Fahir. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

    let context: NSManagedObjectContext;
    let psc: NSPersistentStoreCoordinator;
    let model: NSManagedObjectModel;
    let store: NSPersistentStore?;
    
    
    init() {
        
        let bundle = NSBundle.mainBundle();
        
        let modelURL = bundle.URLForResource("FeedData", withExtension: "momd")!;
        
        model = NSManagedObjectModel(contentsOfURL: modelURL)!;
        
        psc = NSPersistentStoreCoordinator(managedObjectModel: model);
        
        context = NSManagedObjectContext();
        context.persistentStoreCoordinator = psc;
        
        let applicationDirectory = applicationDocumentsDirectory();
        
        let storeURl = applicationDirectory.URLByAppendingPathComponent("Data");
        
        let option = [NSMigratePersistentStoresAutomaticallyOption: true];
        
        var err: NSError?;
        store = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURl, options: option, error: &err);
        
        if store == nil {
            println("Could not create store: \(err)");
            abort();
        }
        
        
    }
    
    func saveContext() {
        var err: NSError?;
        if context.hasChanges && !context.save(&err) {
            println("Could not save data: \(err)");
        }
    }
    
    
    func applicationDocumentsDirectory() -> NSURL {
        
        let fileManager = NSFileManager.defaultManager();
        
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL];
        
        return urls[0];
        
    }
    
    
}

