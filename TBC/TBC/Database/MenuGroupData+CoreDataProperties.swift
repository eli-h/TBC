//
//  MenuGroupData+CoreDataProperties.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-18.
//
//

import Foundation
import CoreData


extension MenuGroupData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MenuGroupData> {
        return NSFetchRequest<MenuGroupData>(entityName: "MenuGroupData")
    }

    @NSManaged public var name: String?
    @NSManaged public var imageName: String?
    @NSManaged public var id: String?
    @NSManaged public var menuGroupToMenuItems: NSSet?

}

// MARK: Generated accessors for menuGroupToMenuItems
extension MenuGroupData {

    @objc(addMenuGroupToMenuItemsObject:)
    @NSManaged public func addToMenuGroupToMenuItems(_ value: MenuItemData)

    @objc(removeMenuGroupToMenuItemsObject:)
    @NSManaged public func removeFromMenuGroupToMenuItems(_ value: MenuItemData)

    @objc(addMenuGroupToMenuItems:)
    @NSManaged public func addToMenuGroupToMenuItems(_ values: NSSet)

    @objc(removeMenuGroupToMenuItems:)
    @NSManaged public func removeFromMenuGroupToMenuItems(_ values: NSSet)

}

extension MenuGroupData : Identifiable {

}
