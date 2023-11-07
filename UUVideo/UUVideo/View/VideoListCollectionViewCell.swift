//
//  VideoListCollectionViewCell.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import Kingfisher
class VideoListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var picImage: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    public var model:VideoModel = VideoModel.init(){
        didSet{
            titleLab.text = model.name.deleteOtherChar()
            if model.type == 3 {
                print(model.picUrl)
                let modifier = AnyModifier { request in
                    var r = request
                    r.setValue(websiteModelArr[self.model.webType].webUrlStr, forHTTPHeaderField: "Referer")
                    return r
                }
                picImage.kf.setImage(with: URL.init(string: model.picUrl), options: [.requestModifier(modifier)], completionHandler: nil)
            } else {
                picImage.image = model.pic
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLab.textColor = UIColor.init(.dm, light: .black, dark: .white)
    }

}
