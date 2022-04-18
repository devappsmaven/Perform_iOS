//
//  Setlist+CoreDataProperties.swift
//  PerformDemo
//
//  Created by mac on 18/11/21.
//
//

import Foundation
import CoreData


extension Setlist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Setlist> {
        return NSFetchRequest<Setlist>(entityName: "Setlist")
    }

    @NSManaged public var setName: String?
    @NSManaged public var docSetRel: NSSet?

}

// MARK: Generated accessors for docSetRel
extension Setlist {

    @objc(addDocSetRelObject:)
    @NSManaged public func addToDocSetRel(_ value: DocSetRelation)

    @objc(removeDocSetRelObject:)
    @NSManaged public func removeFromDocSetRel(_ value: DocSetRelation)

    @objc(addDocSetRel:)
    @NSManaged public func addToDocSetRel(_ values: NSSet)

    @objc(removeDocSetRel:)
    @NSManaged public func removeFromDocSetRel(_ values: NSSet)

}

extension Setlist : Identifiable {

}
