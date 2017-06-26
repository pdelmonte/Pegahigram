//
//  UserTableViewCell.swift
//  Pegahigram
//
//  Created by Pedro Delmonte on 01/06/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate: class {
    func userCellFollowButtonPressed(sender: UserTableViewCell)
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    weak var delegate: UserTableViewCellDelegate?
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.userCellFollowButtonPressed(sender: self)
        }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
