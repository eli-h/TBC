//
//  MenuItemData+CoreDataProperties.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-18.
//
//

import Foundation
import CoreData


extension MenuItemData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MenuItemData> {
        return NSFetchRequest<MenuItemData>(entityName: "MenuItemData")
    }

    @NSManaged public var imageName: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Float
    @NSManaged public var id: String?
    @NSManaged public var menuItemToMenuGroup: MenuGroupData?

}

extension MenuItemData : Identifiable {

}
