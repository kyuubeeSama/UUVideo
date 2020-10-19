//
//  VideoCategoryCollectionViewCell.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/15.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class VideoCategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
    }
}
