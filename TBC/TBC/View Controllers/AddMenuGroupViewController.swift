//
//  AddMenuGroupViewController.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-19.
//

import UIKit

protocol AddMenuGroupViewControllerDelegate {
    func didAddNewMenuGroup(_ newMenuGroup: MenuGroup)
}

class AddMenuGroupViewController: UIViewController {

    @IBOutlet weak var menuGroupImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var menuNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var addMenuButton: UIButton!
    
    var delegate: AddMenuGroupViewControllerDelegate?
    var menuGroupImage: UIImage?
    var imagePicker = UIImagePickerController()
    let databaseManager = DatabaseManager()
    var imageIsValid: Bool {
        get {
            return menuGroupImage != nil
        }
    }
    var nameIsValid: Bool {
        get {
            return (menuNameTextField.text?.count ?? 0) > 0
        }
    }
    var priceIsValid: Bool {
        get {
            return (priceTextField.text?.count ?? 0) > 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        menuNameTextField.delegate = self
        priceTextField.delegate = self
    }
    
    @IBAction func addImageButtonTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func addMenuButtonTapped(_ sender: Any) {
        if imageIsValid && nameIsValid {
            let newMenuGroup = MenuGroup(
                id: UUID().uuidString,
                image: menuGroupImage!,
                name: menuNameTextField.text!
            )
            
            delegate?.didAddNewMenuGroup(newMenuGroup)
            databaseManager.saveNewMenuGroup(newMenuGroup)
            self.dismiss(animated: true, completion: nil)
        } else {
            //TODO: Throw error
        }
    }
}

extension AddMenuGroupViewController: UITextFieldDelegate {
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

extension AddMenuGroupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        menuGroupImage = image
        menuGroupImageView.image = menuGroupImage
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
