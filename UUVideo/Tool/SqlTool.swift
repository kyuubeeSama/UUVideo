//
//  SqlTool.swift
//  UUVideo
//
//  Created by Galaxy on 2021/3/22.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit
import GRDB

class SqlTool: NSObject {
    let databasePath = FileTool.init().getDocumentPath() + "/.database.db"

    // 创建数据库
    func createTable() {
        let result = FileTool.init().createFile(document: "/.database.db", fileData: Data.init())
        if result {
            let dbQueue = try? DatabaseQueue(path: databasePath)
            try? dbQueue?.write({ (db) in
//                创建浏览历史表
                try? db.execute(sql: """
                                     CREATE TABLE IF NOT EXISTS history(
                                     id INTEGER PRIMARY KEY AUTOINCREMENT,
                                     name TEXT NOT NULL,
                                     url TEXT NOT NULL UNIQUE,
                                     serialName TEXT NOT NULL,
                                     picurl TEXT NOT NULL,
                                     add_time INTEGER,
                                     webtype INTEGER NOT NULL,
                                     serialIndex INTEGER NOT NULL,
                                     progress FLOAT NOT NULL,
                                     serialNum INTEGER DEFAULT (1),
                                     circuitIndex INTEGER DEFAULT (0)
                                      )
                                     """)
//                创建收藏表
                try? db.execute(sql: """
                                     CREATE TABLE IF NOT EXISTS collect(
                                     id INTEGER PRIMARY KEY AUTOINCREMENT,
                                     name TEXT NOT NULL,
                                     url TEXT NOT NULL UNIQUE,
                                     video_id INTEGER DEFAULT(0),
                                     updateinfo TEXT NOT NULL,
                                     picurl TEXT NOT NULL,
                                     add_time INTEGER,
                                     webtype INTEGER NOT NULL
                                     )
                                     """)
                //TODO:创建追番表，保存追番的视频
            })
            
        }
    }

    // 判断某个字段是否存在
    func findCoumExist(table:String,column:String) -> Bool{
        do {
            let dbQueue = try DatabaseQueue(path: databasePath)
            let row = try dbQueue.read({ db in
                try Row.fetchOne(db, sql: "select * from sqlite_master where name = '\(table)' and sql like '%\(column)%'")
            })
            if row != nil {
                return true
            }
        }catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    // 在表中添加某字段
    func addColum(table:String,column:String,type:Database.ColumnType,defalut:DatabaseValueConvertible){
        do{
            let dbQueue = try DatabaseQueue(path: databasePath)
            try dbQueue.write({ db in
                try db.alter(table: table, body: { t in
                    t.add(column: column, type).defaults(to: defalut)
                })
            })
        }catch {
            print(error.localizedDescription)
        }
    }
    
    // 在表中删除某个字段
    func deleteColum(table:String,column:String){
        
    }
    
    // 保存历史浏览记录
    func saveHistory(model: VideoModel) {
        do {
            let dbQueue = try DatabaseQueue(path: databasePath)
            try dbQueue.write { db in
                try db.execute(sql: """
                                        REPLACE INTO history ('name','url','serialName','picurl',add_time,webtype,serialIndex,progress,serialNum,circuitIndex) VALUES(:name,:url,:serialName,:picurl,:add_time,:webtype,:serialIndex,:progress,:serialNum,:circuitIndex)
                                    """, arguments: [model.name, model.serialDetailUrl, model.serialName, model.picUrl, Date.getCurrentTimeInterval(), model.webType, model.serialIndex, model.progress,model.serialNum,model.circuitIndex])
            }
        } catch {
            print(error.localizedDescription)
        }

    }

    // 获取浏览记录
    func getHistory() -> ListModel {
        let model = ListModel.init()
        model.more = false
        model.list = []
        do {
            let dbQueue = try DatabaseQueue(path: databasePath)
            let rows = try dbQueue.read({ db in
                try Row.fetchAll(db, sql: "select * from history where 1=1 order by add_time desc")
            })
            for items in rows {
                var videoModel = VideoModel.init()
                videoModel.type = 5
                videoModel.name = items[Column("name")]
                videoModel.serialDetailUrl = items[Column("url")]
//                videoModel.num = items[Column("updateinfo")]
                videoModel.serialName = items[Column("serialName")]
                videoModel.picUrl = items[Column("picurl")]
                videoModel.webType = items[Column("webtype")]
                videoModel.progress = items[Column("progress")]
                videoModel.serialNum = items[Column("serialNum")]
                videoModel.circuitIndex = items[Column("circuitIndex")]
                videoModel.serialIndex = items[Column("serialIndex")]
                model.list.append(videoModel)
            }
        } catch {
            print(error.localizedDescription)
        }
        return model
    }
    // 清空浏览记录
    func cleanHistory() -> Bool {
        do {
            let dbQueue = try DatabaseQueue(path: databasePath)
            try dbQueue.write { db in
                try db.execute(sql: "delete from history where 1=1")
            }
        } catch {
            print(error.localizedDescription)
        }
        return true
    }

    // 保存收藏记录
    func saveCollect(model: VideoModel) -> Bool {
        do {
            let dbQueue = try DatabaseQueue(path: databasePath)
            try dbQueue.write { db in
                try db.execute(sql: """
                                        REPLACE INTO collect ('name','url','updateinfo','picurl',add_time,webtype) VALUES(:name,:url,:update,:picurl,:add_time,:webtype)
                                    """, arguments: [model.name, model.detailUrl, model.num, model.picUrl, Date.getCurrentTimeInterval(), model.webType])
            }
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    // 删除指定收藏记录
    func deleteCollect(model: VideoModel) -> Bool {
        do {
            let dbQueue = try DatabaseQueue(path: databasePath)
            try dbQueue.write { db in
                try db.execute(sql: """
                                             delete from collect where url = :url
                                    """, arguments: [model.detailUrl])
            }
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func isCollect(model: VideoModel) -> Bool {
        do {
            let dbQueue = try DatabaseQueue(path: databasePath)
            let rows = try dbQueue.read({ db in
                try Row.fetchOne(db, sql: "select * from collect where url = :url", arguments: [model.detailUrl])
            })
            if (rows != nil) {
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    // 获取收藏数据
    func getCollect() -> ListModel {
        let model = ListModel.init()
        model.more = false
        model.list = []
        do {
            let dbQueue = try DatabaseQueue(path: databasePath)
            let rows = try dbQueue.read({ db in
                try Row.fetchAll(db, sql: "select * from collect where 1=1 order by add_time desc")
            })
            for item in rows {
                var videoModel = VideoModel.init()
                videoModel.type = 4
                videoModel.name = item[Column("name")]
                videoModel.detailUrl = item[Column("url")]
                videoModel.num = item[Column("updateinfo")]
                videoModel.picUrl = item[Column("picurl")]
                videoModel.webType = item[Column("webtype")]
                model.list.append(videoModel)
            }
        } catch {
            print(error.localizedDescription)
        }
        return model
    }

}
