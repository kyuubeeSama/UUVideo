//
//  NetVideoPlayerCollectionView.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/20.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class NetVideoPlayerCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // 标题
    // 剧集
    // 下面放推荐视频
    var model: VideoModel? {
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
        self.register(UINib.init(nibName: "VideoListCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "videoCell")
        self.register(UINib.init(nibName: "VideoCategoryCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "serialCell")
        self.register(UINib.init(nibName: "HeaderTitleCollectionReusableView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return (model?.serialArr.count)!
        } else {
            return (model?.videoArr.count)!
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 三种样式，一种是剧集介绍
        if indexPath.section == 0 {
            //            剧集列表
            let serialModel = model?.serialArr[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serialCell", for: indexPath) as! VideoCategoryCollectionViewCell
            cell.titleLab.text = serialModel!.name
            if model?.serialIndex == indexPath.row {
                serialModel?.ischoose = true
            }else{
                serialModel?.ischoose = false
            }
            if serialModel!.ischoose == true {
                cell.layer.borderColor = UIColor.red.cgColor
                cell.titleLab.textColor = UIColor.red
            } else {
                cell.layer.borderColor = UIColor.init(.dm, light: UIColor.colorWithHexString(hexString: "333333"), dark: .white).cgColor
                cell.titleLab.textColor = UIColor.init(.dm, light: UIColor.colorWithHexString(hexString: "333333"), dark: .white)
            }
            return cell
        } else {
            //            推荐列表
            let videoModel = model?.videoArr[indexPath.row]
            let cell: VideoListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoListCollectionViewCell
            cell.titleLab.text = videoModel!.name
            cell.picImage.kf.setImage(with: URL.init(string: videoModel!.picUrl))
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let serialModel = model?.serialArr[indexPath.row]
            // 根据字体大小计算
            let size = serialModel!.name.getStringSize(font: UIFont.systemFont(ofSize: 15), size: CGSize(width: Double(MAXFLOAT), height: 15.0))
            var width = size.width + 30
            if width < 50 {
                width = 50
            }
            return CGSize(width: width, height: 30.0)
        } else {
            let width: CGFloat = screenW / 2 - 15
            let height = (width - 20) * 379 / 270 + 70
            return CGSize(width: width, height: height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: screenW, height: 60)
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
        if kind == UICollectionView.elementKindSectionHeader {
            let titleArr = [ "播放线路", "猜你喜欢"]
            header.titleLab.text = titleArr[indexPath.section]
            header.rightBtn.isHidden = true
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
