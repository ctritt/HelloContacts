//
//  ContactTableViewCell.swift
//  HelloContacts
//
//  Created by TQL Mobile  on 12/8/17.
//  Copyright © 2017 University of Cincinnati. All rights reserved.
//

import UIKit

class ContactCollectionViewCell: UICollectionViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var contactImage: UIImageView!
    
    override func awakeFromNib() {
        contactImage.layer.cornerRadius = 25
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contactImage.image = nil
    }

}
