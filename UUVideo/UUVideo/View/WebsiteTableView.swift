//
//  WebsiteTableView.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class WebsiteTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    var listArr: [(title: String, list: [IndexModel])] = [] {
        didSet {
            reloadData()
        }
    }
    var cellItemDidSelect: ((_ indexPath: IndexPath) -> ())?
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        delegate = self
        dataSource = self
        estimatedRowHeight = 0
        estimatedSectionFooterHeight = 0
        estimatedSectionHeaderHeight = 0
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        listArr.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listArr[section].list.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = listArr[indexPath.section].list[indexPath.row].title
        cell.textLabel?.font = .systemFont(ofSize: 15)
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        listArr[section].title
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellItemDidSelect != nil {
            cellItemDidSelect!(indexPath)
        }
    }
}
