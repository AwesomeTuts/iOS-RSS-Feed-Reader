//
//  Feed.swift
//  RSSReader
//
//  Created by Fahir on 2/8/15.
//  Copyright (c) 2015 Fahir. All rights reserved.
//

import Foundation
import CoreData

@objc(Feed)
class Feed: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var url: String

}
