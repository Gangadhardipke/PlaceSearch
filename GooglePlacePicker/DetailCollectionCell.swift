//
//  DetailCollectionCell.swift
//  GooglePlacePicker
//
//  Created by king on 8/5/18.
//  Copyright © 2018 gangadhar. All rights reserved.
//

import UIKit

class DetailCollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        self.clipsToBounds = true
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = UIColor.blue
    }
}
