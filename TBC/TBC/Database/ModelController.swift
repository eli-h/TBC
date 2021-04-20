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
    
//    func updateMenuGroup(withId menuGroupId: String, with newImage: UIImage, and newName: String) {
//        let dbPersistence = DatabasePersistence.sharedInstance
//        let context = dbPersistence.persistentContainer.viewContext as NSManagedObjectContext
//        
//        let oldMenuGroupData = fetchMenuGroup(withId: menuGroupId)
//        
//        if let menuGroupToUpdate = oldMenuGroupData {
//            
//            ImageController.shared.deleteImage(imageName: menuGroupToUpdate.imageName!)
//            
//            let imageName = ImageController.shared.saveImage(image: newImage)
//            
//            menuGroupToUpdate.imageName = imageName
//            menuGroupToUpdate.name = newName
//
//            save(context)
//            print("Updated menu group name to: \(String(describing: menuGroupToUpdate.name))")
//            print("Updated menu group image name to: \(String(describing: menuGroupToUpdate.imageName))")
//        } else {
//            print("Could not find menu group with Id: \(menuGroupId)")
//        }
//    }
    
    func deleteMenuGroup(withId menuGroupId: String) {
        let dbPersistence = DatabasePersistence.sharedInstance
        let context = dbPersistence.persistentContainer.viewContext as NSManagedObjectContext
        
        let menuGroup = fetchMenuGroup(withId: menuGroupId)
        
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
        
        return menuGroupData
    }
    
    func saveNewMenuItem(_ newMenuItem: MenuItem, toMenuGroupWithId menuGroupId: String) {
        let dbPersistence = DatabasePersistence.sharedInstance
        let context = dbPersistence.persistentContainer.viewContext as NSManagedObjectContext
        
        let menuGroupData = fetchMenuGroup(withId: menuGroupId)
        
        if let menuGroupToAddMenuItemTo = menuGroupData {
            
            let newMenuItemData = createMenuItemData(from: newMenuItem, using: context)
            menuGroupToAddMenuItemTo.addMenuItemData(newMenuItemData)
            save(context)
            print("Menu item with id: \(String(describing: newMenuItemData.id)) saved to site with Id: \(menuGroupId)")
        } else {
            print("Could not find menu group with id: \(menuGroupId)")
        }
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
    
    func fetchMenuGroup(withId menuGroupId: String) -> MenuGroupData? {
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

//class ModelController {
//    static let shared = ModelController()
//
//    let entityName = "MenuGroupData"
//
//    private var savedObjects = [NSManagedObject]()
//    private var images = [UIImage]()
//    private var managedContext: NSManagedObjectContext!
//
//    private init() {
//        //guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        managedContext = DatabasePersistence.sharedInstance.context
//
//        fetchImageObjects()
//    }
//
//    func fetchImageObjects() {
//        let imageObjectsRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//
//        do {
//            savedObjects = try managedContext.fetch(imageObjectsRequest)
//            images.removeAll()
//            for imageObject in savedObjects {
//                let savedImageObject = imageObject as! MenuGroupData
//                guard savedImageObject.imageName != nil else { return }
//                let storedImage = ImageController.shared.fetchImage(imageName: savedImageObject.imageName!)
//
//                if let storedImage = storedImage {
//                    images.append(storedImage)
//                }
//            }
//        } catch let error as NSError {
//            print("Could not return image objects: \(error)")
//        }
//    }
//
//    func saveImageObject(image: UIImage) {
//        let imageName = ImageController.shared.saveImage(image: image)
//
//        if let imageName = imageName {
//            let coreDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)
//            let newImageEntity = NSManagedObject(entity: coreDataEntity!, insertInto: managedContext) as! MenuGroupData
//
//            newImageEntity.imageName = imageName
//
//            do {
//                try managedContext.save()
//                images.append(image)
//                print("\(imageName) was saved in new object")
//            } catch let error as NSError {
//                print("Could not save new image object: \(error)")
//            }
//        }
//    }
//
//    func deleteImageObject(imageIndex: Int) {
//        guard images.indices.contains(imageIndex) && savedObjects.indices.contains(imageIndex) else { return }
//
//        let imageObjectToDelete = savedObjects[imageIndex] as! MenuGroupData
//        let imageName = imageObjectToDelete.imageName
//
//        do {
//            managedContext.delete(imageObjectToDelete)
//            try managedContext.save()
//
//            if let imageName = imageName {
//                ImageController.shared.deleteImage(imageName: imageName)
//            }
//
//            savedObjects.remove(at: imageIndex)
//            images.remove(at: imageIndex)
//
//            print("Image object was deleted")
//        } catch let error as NSError {
//            print("Could not delete image object: \(error)")
//        }
//    }
//}
