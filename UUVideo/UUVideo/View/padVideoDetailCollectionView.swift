//
//  padVideoDetailCollectionView.swift
//  UUVideo
//
//  Created by Galaxy on 2021/10/13.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit

class padVideoDetailCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // 标题
    // 剧集
    // 下面放推荐视频
    var model: VideoModel = VideoModel.init() {
        didSet {
            reloadData()
        }
    }

    var cellItemSelected: ((_ indexPath: IndexPath) -> ())?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        backgroundColor = UIColor.systemBackground
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "infoCell")
        self.register(UINib.init(nibName: "VideoCategoryCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "serialCell")
        self.register(UINib.init(nibName: "HeaderTitleCollectionReusableView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        model.circuitArr.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return model.circuitArr[section-1].serialArr.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 三种样式，一种是剧集介绍
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "infoCell", for: indexPath)
            let titleLab = UILabel.init()
            cell.contentView.addSubview(titleLab)
            titleLab.center = cell.contentView.center
            titleLab.bounds = CGRect(x: 10, y: 0, width: cell.contentView.bounds.width, height: cell.contentView.bounds.height)
            titleLab.text = model.name
            titleLab.font = UIFont.systemFont(ofSize: 15)
            return cell
        } else {
            //            剧集列表
            let circuitModel = model.circuitArr[indexPath.section]
            let serialModel = circuitModel.serialArr[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serialCell", for: indexPath) as! VideoCategoryCollectionViewCell
            cell.titleLab.text = serialModel.name
            serialModel.ischoose = (model.serialIndex == indexPath.row && model.circuitIndex == indexPath.section)
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
            return CGSize(width: bounds.width, height: 40)
        } else {
            let circuitModel = model.circuitArr[indexPath.section]
            let serialModel = circuitModel.serialArr[indexPath.row]
            // 根据字体大小计算
            let size = serialModel.name.getStringSize(font: UIFont.systemFont(ofSize: 15), size: CGSize(width: Double(MAXFLOAT), height: 15.0))
            var width = size.width + 30
            if width < 50 {
                width = 50
            }
            return CGSize(width: width, height: 30.0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: bounds.width, height: section == 0 ? 0 : 60)
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
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! HeaderTitleCollectionReusableView
        header.rightBtn.isHidden = true
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section != 1{
            let circuitModel = model.circuitArr[indexPath.section]
            header.titleLab.text = "播放线路："+circuitModel.name
        }else{
            header.titleLab.text = ""
        }
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cellItemSelected != nil {
            cellItemSelected!(indexPath)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
