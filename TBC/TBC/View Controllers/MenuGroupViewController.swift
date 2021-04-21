//
//  MenuGroupViewController.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-18.
//

import UIKit

class MenuGroupViewController: UIViewController {

    @IBOutlet weak var menuGroupTableView: UITableView!
    
    let databaseManager = DatabaseManager()
    var menuGroups: [MenuGroup] = []
    var selectedMenuGroup: MenuGroup?
    var goToEdit = false
    var menuGroupToEdit: MenuGroup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //menuGroups = dummyMenuGroups()
        
        menuGroupTableView.delegate = self
        menuGroupTableView.dataSource = self
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMenuGroup(sender:)))
        navigationItem.rightBarButtonItem = rightButton
        
        menuGroups = databaseManager.fetchAllMenuGroups() ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.menuGroupToAddMenuGroup {
            let vc = segue.destination as? AddMenuGroupViewController
            vc?.delegate = self
            vc?.editMenuGroup = goToEdit
            
            if goToEdit, menuGroupToEdit != nil {
                vc?.menuGroupToEdit = menuGroupToEdit
            }
        } else if segue.identifier == K.menuGroupToMenuItems {
            let vc = segue.destination as? MenuItemViewController
            vc?.menuGroup = selectedMenuGroup
        }
    }
    
    @objc func addMenuGroup(sender: UIBarButtonItem) {
        goToEdit = false
        performSegue(withIdentifier: K.menuGroupToAddMenuGroup, sender: self)
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.menuGroupTableView.reloadData()
        }
    }
}

extension MenuGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuGroup = menuGroups[indexPath.row]
        let menuGroupCell = tableView.dequeueReusableCell(withIdentifier: K.menuGroupCell) as! MenuGroupTableViewCell
        menuGroupCell.setCell(image: menuGroup.image, name: menuGroup.name)
        return menuGroupCell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _)  in
            let menuGroupToDelete = self.menuGroups.remove(at: indexPath.row)
            self.databaseManager.deleteMenuGroup(withId: menuGroupToDelete.id)
            self.reloadTableView()
        }

        let edit = UIContextualAction(style: .normal, title: "Edit") { (_, _, _) in
            self.goToEdit = true
            self.menuGroupToEdit = self.menuGroups[indexPath.row]
            self.performSegue(withIdentifier: K.menuGroupToAddMenuGroup, sender: self)
        }

        edit.backgroundColor = UIColor.blue

        let swipeActions = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return swipeActions
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMenuGroup = menuGroups[indexPath.row]
        performSegue(withIdentifier: K.menuGroupToMenuItems, sender: self)
    }
}

extension MenuGroupViewController: AddMenuGroupViewControllerDelegate {
    func didUpdateMenuGroup(_ updatedMenuGroup: MenuGroup) {
        menuGroups.removeAll {
            $0.id == updatedMenuGroup.id
        }
        
        menuGroups.append(updatedMenuGroup)
        reloadTableView()
    }
    
    func didAddNewMenuGroup(_ newMenuGroup: MenuGroup) {
        menuGroups.append(newMenuGroup)
        reloadTableView()
    }
}

extension MenuGroupViewController: MenuItemViewControllerDelegate {
    func didUpdateMenuItem(_ newMenuGroup: MenuGroup) {
        menuGroups.removeAll {
            $0.id == newMenuGroup.id
        }
        
        menuGroups.append(newMenuGroup)
        reloadTableView()
    }
}
