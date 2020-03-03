//
//  SightEntity+CoreDataProperties.swift
//  assignment1
//
//  Created by Yujie Wu on 2/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//
//

import Foundation
import CoreData


extension SightEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SightEntity> {
        return NSFetchRequest<SightEntity>(entityName: "SightEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var icon: String?
    @NSManaged public var long: String?
    @NSManaged public var lat: String?
    @NSManaged public var image: String?

}
