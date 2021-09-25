//
//  Entity+CoreDataProperties.swift
//  coreDataDemo0
//
//  Created by Blacour on 2021/8/30.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var name: String?
    @NSManaged public var tag: Int32

}

extension Entity : Identifiable {

}
