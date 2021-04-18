//
//  MenuGroupTableViewCell.swift
//  TBC
//
//  Created by Eli Heineman on 2021-04-18.
//

import UIKit

class MenuGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(image: UIImage, name: String) {
        groupImageView.image = image
        groupNameLabel.text = name
    }
}
