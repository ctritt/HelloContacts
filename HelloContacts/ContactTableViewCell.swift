//
//  ContactTableViewCell.swift
//  HelloContacts
//
//  Created by TQL Mobile  on 12/8/17.
//  Copyright © 2017 University of Cincinnati. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var contactImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contactImage.image = nil
    }

}
