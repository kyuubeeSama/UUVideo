//
//  VideoTableCollectionViewCell.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/18.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class VideoTableCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var leftImg: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var numLab: UILabel!

    public var model:VideoModel = VideoModel.init(){
        didSet{
            titleLab.text = model.name.deleteOtherChar()
            titleLab.alignTop()
            leftImg.kf.setImage(with: URL.init(string: model.picUrl), placeholder: UIImage.init(named: "placeholder.jpg"), options: nil, completionHandler: nil)
            if model.type == 5 {
                numLab.text = "播放到：\(model.serialName as String)"
            } else {
                numLab.text = model.num
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
