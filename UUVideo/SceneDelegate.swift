//
//  SceneDelegate.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import GRDB

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
        // 创建数据库文件。
        SqlTool.init().createTable()
        if !(SqlTool.init().findCoumExist(table: "history", column: "serialNum")) {
            SqlTool.init().addColum(table: "history", column: "serialNum", type: .integer, defalut: "1")
        }
        print(FileTool.init().getDocumentPath())
        let windowScene = scene as! UIWindowScene
        window = UIWindow.init(windowScene: windowScene)
        window?.backgroundColor = .systemBackground
        var index = BaseViewController.init()
        if Tool.isPhone() {
            index = PhoneIndexViewController.init()
        }else{
            index = PadIndexViewController.init()
        }
        let nav = UINavigationController.init(rootViewController: index)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // 文件转入提醒
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        print("音乐文件只是\(url.absoluteString)")
        let fileName = url.lastPathComponent
        var path = url.absoluteString
        if path.contains("file://") {
            print("\(path)")
            path = path.replacingOccurrences(of: "file:///private", with: "")
//            path = path.replacingOccurrences(of: "%20", with: " ")
            let localPath = FileTool.init().getDocumentPath() + "/video/" + fileName
            print("目标保存位置是:\(localPath)")
            let dic = ["fileName": fileName, "filePath": path]
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: localPath) {
                // 文件不存在，重新拷贝
                print("文件已存在")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FileExistsNotification"), object: nil, userInfo: dic)
            } else {
                // 文件已存在
                print("本地没有该文件，文件原始位置是\(path),目标位置是\(localPath)")
                do {
                    try fileManager.copyItem(atPath: path, toPath: localPath)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FileSaveSuccessNotification"), object: nil, userInfo: dic)
                } catch let error {
                    print("外部文件本地保存失败，\(error)");
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FileSaveFieldFileNotification"), object: nil, userInfo: dic)
                }
            }
        }
    }

}

