//
//  VideoListCollectionView.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import Kingfisher
class VideoListCollectionView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var listArr:[[String:Any]]?{
        didSet{
            self.reloadData()
        }
    }
    
    var cellItemSelected:((_ indexPath:IndexPath)->())?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = .systemBackground
        self.register(UINib.init(nibName: "VideoListCollectionViewCell", bundle:Bundle.main), forCellWithReuseIdentifier: "cell")
        self.register(UINib.init(nibName: "VideoTableCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "tableCell")
        self.register(UINib.init(nibName: "VideoListHeaderCollectionReusableView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.listArr!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dictionary = self.listArr![section]
        let list:[VideoModel] = dictionary["list"] as! [VideoModel]
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dic = self.listArr![indexPath.section]
        let listArr:[VideoModel] = dic["list"] as! [VideoModel]
        let model:VideoModel = listArr[indexPath.row]
        if model.type == 4{
            // 番剧类似tableview的样式
            let cell:VideoTableCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "tableCell", for: indexPath) as! VideoTableCollectionViewCell
            cell.titleLab.text = model.name
            cell.titleLab.sizeToFit()
            cell.leftImg.kf.setImage(with: URL.init(string: model.picUrl!))
            cell.numLab.text = model.num
            return cell
        }else {
            // 本地和相册,线上模式
            let cell:VideoListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VideoListCollectionViewCell
            cell.titleLab.text = model.name
            cell.picImage.image = model.pic
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dic = self.listArr![indexPath.section]
        let listArr:[VideoModel] = dic["list"] as! [VideoModel]
        let model:VideoModel = listArr[indexPath.row]
        if Tool.isPad() {
//            340,230
            if model.type == 4 {
                return CGSize(width: 250, height: 100)
            }else{
                return CGSize(width: 170, height: 115)
            }
        }else{
            if model.type == 4 {
                return CGSize(width: screenW, height: 100)
            }else{
                // 一行2个
                let width:CGFloat = screenW/2-15
                let height = (width-20)*9/16+50
                return CGSize(width: width, height: height)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header:VideoListHeaderCollectionReusableView
        if kind == UICollectionView.elementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! VideoListHeaderCollectionReusableView
            let dic = self.listArr![indexPath.section]
            let titleStr:String = dic["title"] as! String
            header.titleLab.text = titleStr
        }else{
            header = VideoListHeaderCollectionReusableView.init()
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let dic = self.listArr![section]
        let title:String = dic["title"] as! String
        if (String.myStringIsNULL(string: title)){
            return CGSize(width: screenW, height: 0)
        }else {
            return CGSize(width: screenW, height: 60)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: screenW, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.cellItemSelected != nil {
            self.cellItemSelected!(indexPath)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
