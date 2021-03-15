//
//  NetVIdeoDetailCollectionView.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/4.
//  Copyright © 2020 qykj. All rights reserved.
//  视频详情collection

import UIKit
import Kingfisher

class NetVideoDetailCollectionView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var model:VideoModel?{
        didSet{
            self.reloadData()
        }
    }
    
    var cellItemSelected:((_ indexPath:IndexPath)->())?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = .systemBackground
        self.register(UINib.init(nibName: "VideoListCollectionViewCell", bundle:Bundle.main), forCellWithReuseIdentifier: "videoCell")
        self.register(UINib.init(nibName: "VideoCategoryCollectionViewCell", bundle:Bundle.main), forCellWithReuseIdentifier: "serialCell")
        self.register(UINib.init(nibName: "VideoInfoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "infoCell")
        self.register(UINib.init(nibName: "HeaderTitleCollectionReusableView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        self.delegate = self
        self.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return (self.model?.serialArr!.count)!
        }else {
            return (self.model?.videoArr!.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 三种样式，一种是剧集介绍
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "infoCell", for: indexPath) as! VideoInfoCollectionViewCell
            cell.videoImg.kf.setImage(with: URL.init(string: (self.model?.picUrl)!))
            cell.videoNameLab.text = self.model?.name
            cell.label1.text = model?.getTag(tagArr: (model?.tagArr![0])!)
            cell.label2.text = model?.getTag(tagArr: (model?.tagArr![1])!)
            cell.label3.text = model?.getTag(tagArr: (model?.tagArr![2])!)
            cell.label4.text = model?.getTag(tagArr: (model?.tagArr![3])!)
            return cell
        }else if indexPath.section == 1{
            //            剧集列表
            let serialModel = self.model?.serialArr![indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serialCell", for: indexPath) as! VideoCategoryCollectionViewCell
            cell.titleLab.text = serialModel!.name
            if serialModel!.ischoose == true {
                cell.layer.borderColor = UIColor.red.cgColor
                cell.titleLab.textColor = UIColor.red
            }else{
                cell.layer.borderColor = UIColor.init(.dm, light: UIColor.colorWithHexString(hexString: "333333"), dark: .white).cgColor
                cell.titleLab.textColor = UIColor.init(.dm, light: UIColor.colorWithHexString(hexString: "333333"), dark: .white)
            }
            return cell
        }else{
            //            推荐列表
            let videoModel = self.model?.videoArr![indexPath.row]
            let cell:VideoListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoListCollectionViewCell
            cell.titleLab.text = videoModel!.name
            cell.picImage.kf.setImage(with: URL.init(string: videoModel!.picUrl))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            //            图片比例加上下空格
            return CGSize(width: screenW, height: 90*379/270+20)
        }else if indexPath.section == 1{
            let serialModel = self.model?.serialArr![indexPath.row]
            // 根据字体大小计算
            let size = serialModel!.name?.getStringSize(font: UIFont.systemFont(ofSize: 15), size: CGSize(width: Double(MAXFLOAT), height: 15.0))
            return CGSize(width: size!.width+20.0, height: 20.0)
        }else{
            let width:CGFloat = screenW/2-15
            let height = (width-20)*379/270+50
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            return CGSize(width: screenW, height: 0)
        }else {
            return CGSize(width: screenW, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header:HeaderTitleCollectionReusableView
        if kind == UICollectionView.elementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! HeaderTitleCollectionReusableView
            let titleArr = ["","播放线路","猜你喜欢"]
            header.titleLab.text = titleArr[indexPath.section]
            header.rightBtn.isHidden = true
        }else{
            header = HeaderTitleCollectionReusableView.init()
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1{
            // 剧集点击，修改为选中状态
            let model:SerialModel = (self.model?.serialArr![indexPath.row])!
            model.ischoose = !model.ischoose!
        }
        if self.cellItemSelected != nil {
            self.cellItemSelected!(indexPath)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
