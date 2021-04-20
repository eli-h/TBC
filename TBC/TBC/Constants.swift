//
//  Constants.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-18.
//

import Foundation

struct K {
    //MARK: - Identifiers
    static let menuGroupViewController = "MenuGroupViewController"
    static let menuItemViewController = "MenuItemViewController"
    static let addMenuGroupViewController = "AddMenuGroupViewController"
    static let addMenuItemViewController = "AddMenuItemViewController"
    static let menuGroupCell = "MenuGroupCell"
    static let MenuItemCell = "MenuItemCell"
    
    //MARK: - Segues
    static let menuGroupToMenuItems = "menuGroupToMenuItem"
    static let menuGroupToAddMenuGroup = "menuGroupToAddMenuGroup"
    static let menuItemToAddMenuItem = "menuItemToAddMenuItem"
    
    //MARK: - Database
    static let menuGroupDataEntityName = "MenuGroupData"
    static let menuItemDataEntityName = "MenuItemData"
    static let idKey = "id"
    static let imageNameKey = "imageName"
    static let nameKey = "name"
    static let priceKey = "price"
    static let persistentContainerName = "TBC"
}
