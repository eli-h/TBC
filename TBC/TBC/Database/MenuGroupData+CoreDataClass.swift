//
//  MenuGroupData+CoreDataClass.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-18.
//
//

import Foundation
import CoreData

@objc(MenuGroupData)
public class MenuGroupData: NSManagedObject {
    func addMenuItemData(_ menuItemData: MenuItemData) {
        menuItemData.menuItemToMenuGroup = self
    }
}
