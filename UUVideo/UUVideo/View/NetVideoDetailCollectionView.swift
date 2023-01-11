//
//  NetVIdeoDetailCollectionView.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/4.
//  Copyright © 2020 qykj. All rights reserved.
//  视频详情collection

import UIKit
import Kingfisher

class NetVideoDetailCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var model: VideoModel = VideoModel.init() {
        didSet {
            reloadData()
        }
    }

    var cellItemSelected: ((_ indexPath: IndexPath) -> ())?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = .systemBackground
        self.register(UINib.init(nibName: "VideoListCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "videoCell")
        self.register(UINib.init(nibName: "VideoCategoryCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "serialCell")
        self.register(UINib.init(nibName: "VideoInfoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "infoCell")
        self.register(UINib.init(nibName: "HeaderTitleCollectionReusableView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        delegate = self
        dataSource = self
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        model.circuitArr.count+2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == model.circuitArr.count+1 {
            return model.videoArr.count
        }else{
            let circuitModel = model.circuitArr[section-1]
            return circuitModel.serialArr.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 三种样式，一种是剧集介绍
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "infoCell", for: indexPath) as! VideoInfoCollectionViewCell
            cell.videoImg.kf.setImage(with: URL.init(string: (model.picUrl)))
            cell.videoNameLab.text = model.name
            if (model.tagArr.count) > 0 {
                cell.label1.text = model.getTag(tagArr: (model.tagArr[0]))
                cell.label2.text = model.getTag(tagArr: (model.tagArr[1]))
                cell.label3.text = model.getTag(tagArr: (model.tagArr[2]))
                cell.label4.text = model.getTag(tagArr: (model.tagArr[3]))
            } else {
                cell.label1.text = ""
                cell.label2.text = ""
                cell.label3.text = ""
                cell.label4.text = ""
            }
            return cell
        } else if indexPath.section == model.circuitArr.count+1 {
            //            推荐列表
            let videoModel = model.videoArr[indexPath.row]
            let cell: VideoListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoListCollectionViewCell
            cell.titleLab.text = videoModel.name
            cell.titleLab.alignTop()
            cell.picImage.kf.setImage(with: URL.init(string: videoModel.picUrl))
            return cell
        } else {
            //            剧集列表
            let circuitModel = model.circuitArr[indexPath.section-1]
            let serialModel = circuitModel.serialArr[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serialCell", for: indexPath) as! VideoCategoryCollectionViewCell
            cell.titleLab.text = serialModel.name
            if serialModel.ischoose == true {
                cell.layer.borderColor = UIColor.red.cgColor
                cell.titleLab.textColor = UIColor.red
            } else {
                cell.layer.borderColor = UIColor.init(.dm, light: UIColor.colorWithHexString(hexString: "333333"), dark: .white).cgColor
                cell.titleLab.textColor = UIColor.init(.dm, light: UIColor.colorWithHexString(hexString: "333333"), dark: .white)
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            //            图片比例加上下空格
            return CGSize(width: screenW, height: 90 * 379 / 270 + 20)
        } else if indexPath.section == model.circuitArr.count + 1 {
            if Tool.isPhone() {
                let width: CGFloat = screenW / 2 - 15
                let height = (width - 20) * 379 / 270 + 70
                return CGSize(width: width, height: height)
            }else{
                let width: CGFloat = 170
                let height = (width - 20) * 379 / 270 + 70
                return CGSize(width: width, height: height)
            }
        } else {
            let circuitModel = model.circuitArr[indexPath.section-1]
            let serialModel = circuitModel.serialArr[indexPath.row]
            // 根据字体大小计算
            let size = serialModel.name.getStringSize(font: UIFont.systemFont(ofSize: 15), size: CGSize(width: Double(MAXFLOAT), height: 15.0))
            var width = size.width+30
            if width < 50 {
                width = 50
            }
            return CGSize(width: width, height: 30.0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: screenW, height: 0)
        } else {
            return CGSize(width: screenW, height: 60)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: HeaderTitleCollectionReusableView
        if kind == UICollectionView.elementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! HeaderTitleCollectionReusableView
            if indexPath.section == model.circuitArr.count+1{
                header.titleLab.text = "猜你喜欢"
            }else if indexPath.section != 0{
                let circuitModel = model.circuitArr[indexPath.section-1]
                header.titleLab.text = "播放线路："+circuitModel.name
            }
            header.rightBtn.isHidden = true
        } else {
            header = HeaderTitleCollectionReusableView.init()
        }
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section > 0 && indexPath.section <= model.circuitArr.count {
            // 剧集点击，修改为选中状态
            let circuitModel = model.circuitArr[indexPath.section-1]
            let model: SerialModel = circuitModel.serialArr[indexPath.row]
            model.ischoose = !model.ischoose!
            reloadData()
        }
        if cellItemSelected != nil {
            cellItemSelected!(indexPath)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
