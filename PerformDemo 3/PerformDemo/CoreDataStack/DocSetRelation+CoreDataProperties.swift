//
//  DocSetRelation+CoreDataProperties.swift
//  PerformDemo
//
//  Created by mac on 18/11/21.
//
//

import Foundation
import CoreData


extension DocSetRelation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocSetRelation> {
        return NSFetchRequest<DocSetRelation>(entityName: "DocSetRelation")
    }

    @NSManaged public var index: Int32
    @NSManaged public var document: Document?
    @NSManaged public var setlist: Setlist?

}

extension DocSetRelation : Identifiable {

}
