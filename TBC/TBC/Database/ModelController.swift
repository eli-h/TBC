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
    
    func createMenuGroupData(from newMenuGroup: MenuGroup, using context: NSManagedObjectContext) -> MenuGroupData {
        let menuGroupDataEntityDescription = NSEntityDescription.entity(forEntityName: K.menuGroupDataEntityName, in: context)
        let menuGroupData = MenuGroupData(entity: menuGroupDataEntityDescription!, insertInto: context)
        
        let imageName = ImageController.shared.saveImage(image: newMenuGroup.image)
        
        menuGroupData.setValue(newMenuGroup.id, forKey: K.idKey)
        menuGroupData.setValue(imageName, forKey: K.imageNameKey)
        menuGroupData.setValue(newMenuGroup.name, forKey: K.nameKey)
        
        return menuGroupData
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
