//
//  ModelController.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-18.
//

import UIKit
import CoreData

struct DatabaseManager {
    
    func saveNewMenuGroup(_ newMenuGroup: MenuGroup) {
        let dbPersistence = DatabasePersistence.sharedInstance
        let context = dbPersistence.persistentContainer.viewContext as NSManagedObjectContext
        
        let newMenuGroupData = createMenuGroupData(from: newMenuGroup, using: context)
        
        save(context)
        print("Saved new menu group with Id: \(String(describing: newMenuGroupData.id))")
    }
    
    func deleteMenuGroup(withId menuGroupId: String) {
        let dbPersistence = DatabasePersistence.sharedInstance
        let context = dbPersistence.persistentContainer.viewContext as NSManagedObjectContext
        
        let menuGroup = fetchMenuGroupData(withId: menuGroupId)
        
        if let menuGroupToDelete = menuGroup {
            
            ImageController.shared.deleteImage(imageName: menuGroupToDelete.imageName!)

            context.delete(menuGroupToDelete)
            save(context)
            print("Deleted menu group with Id: \(menuGroupId)")
        } else {
            print("Could not find menu group with Id: \(menuGroupId)")

        }
    }
    
    func createMenuGroupData(from newMenuGroup: MenuGroup, using context: NSManagedObjectContext) -> MenuGroupData {
        let menuGroupDataEntityDescription = NSEntityDescription.entity(forEntityName: K.menuGroupDataEntityName, in: context)
        let menuGroupData = MenuGroupData(entity: menuGroupDataEntityDescription!, insertInto: context)
        
        let imageName = ImageController.shared.saveImage(image: newMenuGroup.image)
        
        menuGroupData.setValue(newMenuGroup.id, forKey: K.idKey)
        menuGroupData.setValue(imageName, forKey: K.imageNameKey)
        menuGroupData.setValue(newMenuGroup.name, forKey: K.nameKey)
        
        for item in newMenuGroup.items {
            let itemData = createMenuItemData(from: item, using: context)
            menuGroupData.addMenuItemData(itemData)
        }
        
        return menuGroupData
    }
    
    func saveNewMenuItem(_ newMenuItem: MenuItem, toMenuGroupWithId menuGroupId: String) {
        let dbPersistence = DatabasePersistence.sharedInstance
        let context = dbPersistence.persistentContainer.viewContext as NSManagedObjectContext
        
        let menuGroupData = fetchMenuGroupData(withId: menuGroupId)
        
        if let menuGroupToAddMenuItemTo = menuGroupData {
            
            let newMenuItemData = createMenuItemData(from: newMenuItem, using: context)
            menuGroupToAddMenuItemTo.addMenuItemData(newMenuItemData)
            save(context)
            print("Menu item with id: \(String(describing: newMenuItemData.id)) saved to site with Id: \(menuGroupId)")
        } else {
            print("Could not find menu group with id: \(menuGroupId)")
        }
    }
    
    func deleteMenuItem(withId menuItemId: String, fromMenuGroupWithId menuGroupId: String) {
        let dbPersistence = DatabasePersistence.sharedInstance
        let context = dbPersistence.persistentContainer.viewContext as NSManagedObjectContext
        
        let menuItem = fetchMenuItemData(withId: menuItemId, fromMenuGroupWithId: menuGroupId)
        
        if let menuItemToDelete = menuItem {
            
            ImageController.shared.deleteImage(imageName: menuItemToDelete.imageName!)

            context.delete(menuItemToDelete)
            save(context)
            print("Deleted menu group with Id: \(menuGroupId)")
        } else {
            print("Could not find menu group with Id: \(menuGroupId)")

        }
    }
    
    func fetchMenuItemData(withId menuItemId: String, fromMenuGroupWithId menuGroupId: String) -> MenuItemData? {

        guard let menuGroupData = fetchMenuGroupData(withId: menuGroupId) else {
            print("Could not find menu group with Id: \(menuGroupId)")
            return nil
        }
        
        guard let menuItems = menuGroupData.menuGroupToMenuItems?.allObjects as? [MenuItemData] else {
            print("Could not find menu item in menu group with Id: \(menuGroupId)")
            return nil
        }
        
        for menuItem in menuItems {
            if menuItem.id == menuItemId {
                return menuItem
            }
        }
        
        return nil
    }
    
    func createMenuItemData(from newMenuItem: MenuItem, using context: NSManagedObjectContext) -> MenuItemData {
        let menuItemDataEntityDescription = NSEntityDescription.entity(forEntityName: K.menuItemDataEntityName, in: context)
        let menuItemData = MenuItemData(entity: menuItemDataEntityDescription!, insertInto: context)
        
        let imageName = ImageController.shared.saveImage(image: newMenuItem.image)
        
        menuItemData.setValue(newMenuItem.id, forKey: K.idKey)
        menuItemData.setValue(imageName, forKey: K.imageNameKey)
        menuItemData.setValue(newMenuItem.name, forKey: K.nameKey)
        menuItemData.setValue(newMenuItem.price, forKey: K.priceKey)
        
        return menuItemData
    }

    func fetchAllMenuGroups() -> [MenuGroup]? {
        let dbPersistence = DatabasePersistence.sharedInstance
        let context = dbPersistence.persistentContainer.viewContext as NSManagedObjectContext
        
        var menuGroups: [MenuGroup] = []
        let imageObjectsRequest = NSFetchRequest<NSManagedObject>(entityName: K.menuGroupDataEntityName)
        
        do {
            let menuGroupObjects = try context.fetch(imageObjectsRequest)
            
            for menuGroupObject in menuGroupObjects {
                let savedMenuGroupObject = menuGroupObject as! MenuGroupData
                let menuGroup = convertMenuGroupDataToMenuGroup(savedMenuGroupObject)
                menuGroups.append(menuGroup)
            }
        } catch let error as NSError {
            print("Could not return image objects: \(error)")
        }
        
        return menuGroups
    }
    
    func fetchMenuGroupData(withId menuGroupId: String) -> MenuGroupData? {
        let dbPersistence = DatabasePersistence.sharedInstance
        let context = dbPersistence.persistentContainer.viewContext as NSManagedObjectContext
        
        let entityDescription = NSEntityDescription.entity(forEntityName: K.menuGroupDataEntityName, in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let predicate = NSPredicate(format: "id == %@", menuGroupId)
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = predicate
        
        var resultArray: [MenuGroupData] = []
        
        do {
            let result = try context.fetch(fetchRequest) as? [MenuGroupData]
            
            if result!.count > 0 {
                resultArray = result!
            } else {
                return nil
            }
        } catch let error as NSError {
            print("Could not fetch menu group: \(error) - \(error.userInfo)")
        }
        
        return resultArray[0]
    }
    
    func convertMenuGroupDataToMenuGroup(_ menuGroupData: MenuGroupData) -> MenuGroup {
        let storedImage = ImageController.shared.fetchImage(imageName: menuGroupData.imageName!)
        
        var menuItems: [MenuItem] = []
        
        for menuItemData in menuGroupData.menuGroupToMenuItems?.allObjects as! [MenuItemData] {
            let menuItem = convertMenuItemDataToMenuItem(menuItemData)
            menuItems.append(menuItem)
        }
        
        let menuGroup = MenuGroup(
            id: menuGroupData.id!,
            image: storedImage!,
            name: menuGroupData.name!,
            items: menuItems
        )
        
        return menuGroup
    }
    
    func convertMenuItemDataToMenuItem(_ menuItemData: MenuItemData) -> MenuItem {
        let storedImage = ImageController.shared.fetchImage(imageName: menuItemData.imageName!)
        
        let menuItem = MenuItem(
            id: menuItemData.id!,
            image: storedImage!,
            name: menuItemData.name!,
            price: menuItemData.price
        )
        
        return menuItem
    }
    
    func save(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save context: \(error) - \(error.userInfo)")
        }
    }
}
