//
//  Recording+CoreDataProperties.swift
//  
//
//  Created by Vineet Sharma on 31/01/22.
//
//

import Foundation
import CoreData


extension Recording {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recording> {
        return NSFetchRequest<Recording>(entityName: "Recording")
    }

    @NSManaged public var recData: Data?
    @NSManaged public var recStr: String?
    @NSManaged public var document: Document?

}
