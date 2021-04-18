//
//  MenuItemViewController.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-18.
//

import UIKit

class MenuItemViewController: UIViewController {

    @IBOutlet weak var menuItemTableView: UITableView!
    
    var menuGroup: [MenuGroup] = []
    var menuItems: [MenuItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
