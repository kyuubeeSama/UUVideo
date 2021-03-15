//
//  HeaderTitleCollectionReusableView.swift
//  UUVideo
//
//  Created by Galaxy on 2020/9/30.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class HeaderTitleCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var rightBtn: UIButton!
    
    var rightBtnBlock:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    @IBAction func rightBtnClick(_ sender: UIButton) {
        if (rightBtnBlock != nil) {
            self.rightBtnBlock!()
        }
    }    
}
