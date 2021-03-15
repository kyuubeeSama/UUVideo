//
//  VideoListCollectionViewCell.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class VideoListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var picImage: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLab.textColor = UIColor.init(.dm, light: .black, dark: .white)
    }

}
