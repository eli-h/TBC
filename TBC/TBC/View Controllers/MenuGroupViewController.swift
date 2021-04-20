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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuGroups = dummyMenuGroups()
        
        menuGroupTableView.delegate = self
        menuGroupTableView.dataSource = self
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMenuGroup(sender:)))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //databaseManager.fetchAllMenuGroups() ?? []
        reloadTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.menuGroupToAddMenuGroup {
            let vc = segue.destination as? AddMenuGroupViewController
            vc?.delegate = self
        }
    }
    
    @objc func addMenuGroup(sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.menuGroupToAddMenuGroup, sender: self)
    }
    
    func dummyMenuGroups() -> [MenuGroup] {
        var dummyMenuGroups: [MenuGroup] = []
        
        let menuGroup1 = MenuGroup(id: "1", image: #imageLiteral(resourceName: "elijahMemoji"), name: "Pancakes", items: [])
        let menuGroup2 = MenuGroup(id: "2", image: #imageLiteral(resourceName: "elijahMemoji"), name: "Burgers", items: [])
        let menuGroup3 = MenuGroup(id: "3", image: #imageLiteral(resourceName: "elijahMemoji"), name: "Ice Cream", items: [])
        
        dummyMenuGroups.append(menuGroup1)
        dummyMenuGroups.append(menuGroup2)
        dummyMenuGroups.append(menuGroup3)
        
        return dummyMenuGroups
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.menuGroups.remove(at: indexPath.row)
            self.reloadTableView()
        }

        let share = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            // share item at indexPath
        }

        share.backgroundColor = UIColor.blue

        return [delete, share]
    }
}

extension MenuGroupViewController: AddMenuGroupViewControllerDelegate {
    func didAddNewMenuGroup(_ newMenuGroup: MenuGroup) {
        menuGroups.append(newMenuGroup)
        reloadTableView()
    }
}
