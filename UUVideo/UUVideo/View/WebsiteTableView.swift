//
//  WebsiteTableView.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class WebsiteTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    var listArr: [String]? {
        didSet {
            reloadData()
        }
    }

    var cellItemDidSelect: ((_ indexPath: IndexPath) -> ())?

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        delegate = self
        dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listArr!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = listArr![indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellItemDidSelect != nil {
            cellItemDidSelect!(indexPath)
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
