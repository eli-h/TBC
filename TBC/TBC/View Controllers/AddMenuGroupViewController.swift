//
//  AddMenuGroupViewController.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-19.
//

import UIKit

protocol AddMenuGroupViewControllerDelegate {
    func didAddNewMenuGroup(_ newMenuGroup: MenuGroup)
    func didUpdateMenuGroup(_ updatedMenuGroup: MenuGroup)
}

class AddMenuGroupViewController: UIViewController {

    @IBOutlet weak var menuGroupImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var menuNameTextField: UITextField!
    @IBOutlet weak var addMenuButton: UIButton!
    
    var delegate: AddMenuGroupViewControllerDelegate?
    var menuGroupToEdit: MenuGroup?
    var editMenuGroup = false
    var menuImage: UIImage?
    var imagePicker = UIImagePickerController()
    let databaseManager = DatabaseManager()
    var imageIsValid: Bool {
        get {
            return menuImage != nil
        }
    }
    var nameIsValid: Bool {
        get {
            return (menuNameTextField.text?.count ?? 0) > 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        menuNameTextField.delegate = self
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let menuGroup = menuGroupToEdit, editMenuGroup == true {
            fillInEditInfo(for: menuGroup)
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
    
    @IBAction func addMenuButtonTapped(_ sender: Any) {
        if imageIsValid && nameIsValid {
            
            if !editMenuGroup {
                let newMenuGroup = MenuGroup(
                    id: UUID().uuidString,
                    image: menuImage!,
                    name: menuNameTextField.text!
                )
                
                delegate?.didAddNewMenuGroup(newMenuGroup)
                databaseManager.saveNewMenuGroup(newMenuGroup)
            } else {
                menuGroupToEdit!.image = menuImage!
                menuGroupToEdit!.name = menuNameTextField.text!
                
                delegate?.didUpdateMenuGroup(menuGroupToEdit!)
                databaseManager.deleteMenuGroup(withId: menuGroupToEdit!.id)
                databaseManager.saveNewMenuGroup(menuGroupToEdit!)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func fillInEditInfo(for menuGroup: MenuGroup) {
        menuImage = menuGroup.image
        menuGroupImageView.image = menuImage
        menuNameTextField.text = menuGroup.name
    }
}

extension AddMenuGroupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string.count > 0 {
            let unwantedStr = string.trimmingCharacters(in: CharacterSet.alphanumerics)
            return unwantedStr.count == 0
        }

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddMenuGroupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        menuImage = image
        menuGroupImageView.image = menuImage
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
