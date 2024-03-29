//
//  DownloadTableView.swift
//  UUVideo
//
//  Created by Galaxy on 2021/11/1.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit

class DownloadTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    
    var listArr:[Any]=[]{
        didSet{
            reloadData()
        }
    }
    var cellItemClickBlock:((_ indexPath:IndexPath)->())?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        delegate = self
        self.register(UINib.init(nibName: "DownloadTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DownloadTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellItemClickBlock != nil{
            cellItemClickBlock!(indexPath)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
