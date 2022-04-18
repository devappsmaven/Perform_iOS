//
//  Document+CoreDataProperties.swift
//  
//
//  Created by Vineet Sharma on 31/01/22.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var docData: Data?
    @NSManaged public var docName: String?
    @NSManaged public var docPromptSize: Int16
    @NSManaged public var docPromptSpeed: Int16
    @NSManaged public var docSetRel: NSSet?
    @NSManaged public var recordings: NSSet?
    @NSManaged public var docId: Int64

}

// MARK: Generated accessors for docSetRel
extension Document {

    @objc(addDocSetRelObject:)
    @NSManaged public func addToDocSetRel(_ value: DocSetRelation)

    @objc(removeDocSetRelObject:)
    @NSManaged public func removeFromDocSetRel(_ value: DocSetRelation)

    @objc(addDocSetRel:)
    @NSManaged public func addToDocSetRel(_ values: NSSet)

    @objc(removeDocSetRel:)
    @NSManaged public func removeFromDocSetRel(_ values: NSSet)

}

// MARK: Generated accessors for recordings
extension Document {

    @objc(addRecordingsObject:)
    @NSManaged public func addToRecordings(_ value: Recording)

    @objc(removeRecordingsObject:)
    @NSManaged public func removeFromRecordings(_ value: Recording)

    @objc(addRecordings:)
    @NSManaged public func addToRecordings(_ values: NSSet)

    @objc(removeRecordings:)
    @NSManaged public func removeFromRecordings(_ values: NSSet)

}
