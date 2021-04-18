//
//  MenuItem.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-18.
//

import UIKit

struct MenuItem {
    var id: String
    var image: UIImage
    var name: String
    var price: Float
    
    func getItemPrice() -> String {
        return "$\(price)"
    }
    
    mutating func updateItem(newImage: UIImage? = nil, newName: String? = nil, newPrice: Float? = nil) {
        if let updatedImage = newImage {
            image = updatedImage
        }
        
        if let updatedName = newName {
            name = updatedName
        }
        
        if let updatedPrice = newPrice {
            price = updatedPrice
        }
    }
}
