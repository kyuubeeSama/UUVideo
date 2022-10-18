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
    
    var listArr:[ListModel] = []{
        didSet{
            reloadData()
        }
    }
    // 删除数据
    var deleteItemBlock:((_ indexPath:IndexPath)->())?
    
    // 是否是收藏
    var is_collect = false
    
    var cellItemSelected:((_ indexPath:IndexPath)->())?
    var headerRightClicked:((_ indexPath:IndexPath)->())?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        backgroundColor = .systemBackground
        self.register(UINib.init(nibName: "VideoListCollectionViewCell", bundle:Bundle.main), forCellWithReuseIdentifier: "cell")
        self.register(UINib.init(nibName: "VideoTableCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "tableCell")
        self.register(UINib.init(nibName: "HeaderTitleCollectionReusableView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        listArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let listModel = listArr[section]
        return listModel.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let listModel = listArr[indexPath.section]
        let model = listModel.list[indexPath.row]
        // 5的类型为
        if model.type == 4 || model.type == 5{
            // 番剧类似tableview的样式
            let cell:VideoTableCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "tableCell", for: indexPath) as! VideoTableCollectionViewCell
            cell.titleLab.text = model.name
            cell.titleLab.alignTop()
            cell.leftImg.kf.setImage(with: URL.init(string: model.picUrl), placeholder: UIImage.init(named: "placeholder.jpg"), options: nil, completionHandler: nil)
            if model.type == 5 {
                cell.numLab.text = "播放到：\(model.serialName as String)"
            }else{
                cell.numLab.text = model.num
            }
            if is_collect {
                let longTap = UILongPressGestureRecognizer.init()
                cell.addGestureRecognizer(longTap)
                longTap.reactive.stateChanged.take(until: cell.reactive.prepareForReuse).observeValues { tap in
                    // 删除
                    if self.deleteItemBlock != nil {
                        self.deleteItemBlock!(indexPath)
                    }
                }
            }
            return cell
        }else {
            // 本地和相册,线上模式
            let cell:VideoListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VideoListCollectionViewCell
            cell.titleLab.text = model.name
            if model.type == 3 {
                print(model.picUrl)
                let modifier = AnyModifier { request in
                    var r = request
                    r.setValue(urlArr[model.webType], forHTTPHeaderField: "Referer")
                    return r
                }
                cell.picImage.kf.setImage(with: URL.init(string: model.picUrl), options: [.requestModifier(modifier)], completionHandler: nil)
            }else{
                cell.picImage.image = model.pic
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let listModel = listArr[indexPath.section]
        let model = listModel.list[indexPath.row]
        if Tool.isPhone() {
            if model.type == 4 || model.type == 5{
                return CGSize(width: screenW, height: 100)
            }else if model.type == 3{
                let width:CGFloat = screenW/2-15
                let height = (width-20)*379/270+50
                return CGSize(width: width, height: height)
            }else{
                // 一行2个
                let width:CGFloat = screenW/2-15
                let height = (width-20)*9/16+50
                return CGSize(width: width, height: height)
            }
        }else{
            //            340,230
            if model.type == 4 || model.type == 5{
                return CGSize(width: 250, height: 100)
            }else if model.type == 3{
                let width:CGFloat = 170
                let height = (width-20)*379/270+70
                return CGSize(width: width, height: height)
            }else{
                return CGSize(width: 170, height: 135)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header:HeaderTitleCollectionReusableView
        if kind == UICollectionView.elementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! HeaderTitleCollectionReusableView
            let listModel = listArr[indexPath.section]
            header.titleLab.text = listModel.title
            if listModel.more! {
                header.rightBtn.isHidden = false
            }else{
                header.rightBtn.isHidden = true
            }
            header.rightBtnBlock = {
                if self.headerRightClicked != nil {
                    self.headerRightClicked!(indexPath)
                }
            }
        }else{
            header = HeaderTitleCollectionReusableView.init()
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let listModel = listArr[section]
        if (String.myStringIsNULL(string: listModel.title)){
            return CGSize(width: screenW, height: 0)
        }else {
            return CGSize(width: screenW, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: screenW, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cellItemSelected != nil {
            cellItemSelected!(indexPath)
        }
    }

    
}
