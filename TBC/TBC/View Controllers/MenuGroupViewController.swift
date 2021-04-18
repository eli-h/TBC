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
        menuGroupTableView.delegate = self
        menuGroupTableView.dataSource = self
        let rightButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showEditing(sender:)))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        menuGroups = dummyMenuGroups()//databaseManager.fetchAllMenuGroups() ?? []
    }
    
    @objc func showEditing(sender: UIBarButtonItem) {
        if menuGroupTableView.isEditing {
            menuGroupTableView.isEditing = false
        } else {
            menuGroupTableView.isEditing = true
        }
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
}
