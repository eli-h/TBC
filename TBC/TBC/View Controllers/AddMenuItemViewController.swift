//
//  AddMenuItemViewController.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-20.
//

import UIKit

protocol AddMenuItemViewControllerDelegate {
    func didAddNewMenuItem(_ newMenuItem: MenuItem)
    func didUpdateMenuItem(_ updatedMenuItem: MenuItem)
}

class AddMenuItemViewController: UIViewController {

    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    @IBOutlet weak var addItemButton: UIButton!
    
    var delegate: AddMenuItemViewControllerDelegate?
    var menuItemToEdit: MenuItem?
    var parentMenuGroupId: String?
    var editMenuItem = false
    var itemImage: UIImage?
    var imagePicker = UIImagePickerController()
    let databaseManager = DatabaseManager()
    var imageIsValid: Bool {
        get {
            return itemImage != nil
        }
    }
    var nameIsValid: Bool {
        get {
            return (itemNameTextField.text?.count ?? 0) > 0
        }
    }
    var priceIsValid: Bool {
        get {
            return (Float(itemPriceTextField.text!) != nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        itemNameTextField.delegate = self
        itemPriceTextField.delegate = self
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let menuItem = menuItemToEdit, editMenuItem == true {
            fillInEditInfo(for: menuItem)
        }
    }
    
    @IBAction func addImageButtonTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func addItemButtonTapped(_ sender: Any) {
        if imageIsValid && nameIsValid && priceIsValid {
            
            if !editMenuItem {
                let newMenuItem = MenuItem(
                    id: UUID().uuidString,
                    image: itemImage!,
                    name: itemNameTextField.text!,
                    price: Float(itemPriceTextField.text!)!
                )
                
                delegate?.didAddNewMenuItem(newMenuItem)
                databaseManager.saveNewMenuItem(newMenuItem, toMenuGroupWithId: parentMenuGroupId!)
            } else {
                menuItemToEdit!.image = itemImage!
                menuItemToEdit!.name = itemNameTextField.text!
                menuItemToEdit!.price = Float(itemPriceTextField.text!)!
                
                delegate?.didUpdateMenuItem(menuItemToEdit!)
                databaseManager.deleteMenuItem(withId: menuItemToEdit!.id, fromMenuGroupWithId: parentMenuGroupId!)
                databaseManager.saveNewMenuItem(menuItemToEdit!, toMenuGroupWithId: parentMenuGroupId!)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func fillInEditInfo(for menuItem: MenuItem) {
        itemImage = menuItem.image
        menuItemImageView.image = itemImage
        itemNameTextField.text = menuItem.name
        itemPriceTextField.text = String(menuItem.price)
    }
}

extension AddMenuItemViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let charSet = textField.tag == 0 ? CharacterSet.alphanumerics : CharacterSet.decimalDigits
        
        if string.count > 0 {
            let unwantedStr = string.trimmingCharacters(in: charSet)
            return unwantedStr.count == 0
        }

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddMenuItemViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        itemImage = image
        menuItemImageView.image = itemImage
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
