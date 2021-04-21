//
//  MenuItemViewController.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-18.
//

import UIKit

protocol MenuItemViewControllerDelegate {
    func didUpdateMenuItem(_ newMenuGroup: MenuGroup)
}

class MenuItemViewController: UIViewController {

    @IBOutlet weak var menuItemTableView: UITableView!
    
    var delegate: MenuItemViewControllerDelegate?
    let databaseManager = DatabaseManager()
    var menuGroup: MenuGroup!
    var goToEdit = false
    var menuItemToEdit: MenuItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuItemTableView.delegate = self
        menuItemTableView.dataSource = self
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMenuItem(sender:)))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.menuItemToAddMenuItem {
            let vc = segue.destination as? AddMenuItemViewController
            vc?.delegate = self
            vc?.editMenuItem = goToEdit
            vc?.parentMenuGroupId = menuGroup!.id
            
            if goToEdit, menuItemToEdit != nil {
                vc?.menuItemToEdit = menuItemToEdit
            }
        }
    }
    
    @objc func addMenuItem(sender: UIBarButtonItem) {
        goToEdit = false
        performSegue(withIdentifier: K.menuItemToAddMenuItem, sender: self)
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.menuItemTableView.reloadData()
        }
    }
}

extension MenuItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuGroup.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItem = menuGroup.items[indexPath.row]
        let menuItemCell = tableView.dequeueReusableCell(withIdentifier: K.MenuItemCell) as! MenuItemTableViewCell
        menuItemCell.setCell(image: menuItem.image, name: menuItem.name, price: menuItem.price)
        return menuItemCell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let menuItemToDelete = self.menuGroup.items.remove(at: indexPath.row)
            self.databaseManager.deleteMenuItem(withId: menuItemToDelete.id, fromMenuGroupWithId: self.menuGroup.id)
            
            self.delegate?.didUpdateMenuItem(self.menuGroup!)
            
            self.reloadTableView()
        }

        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            self.goToEdit = true
            self.menuItemToEdit = self.menuGroup.items[indexPath.row]
            self.performSegue(withIdentifier: K.menuItemToAddMenuItem, sender: self)
        }

        edit.backgroundColor = UIColor.blue

        return [delete, edit]
    }
}

extension MenuItemViewController: AddMenuItemViewControllerDelegate {
    func didUpdateMenuItem(_ updatedMenuItem: MenuItem) {
        menuGroup.items.removeAll {
            $0.id == updatedMenuItem.id
        }
        
        menuGroup.items.append(updatedMenuItem)
        delegate?.didUpdateMenuItem(menuGroup)
        reloadTableView()
    }
    
    func didAddNewMenuItem(_ newMenuItem: MenuItem) {
        menuGroup.items.append(newMenuItem)
        delegate?.didUpdateMenuItem(menuGroup)
        reloadTableView()
    }
}
