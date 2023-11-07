source 'https://gitee.com/mirrors/CocoaPods-Specs.git'
platform :ios,'14.0'

target 'UUVideo' do

  pod 'SJVideoPlayer'
  pod 'SJBaseVideoPlayer'
  # 投屏
  pod 'MRDLNA'
  pod 'Popover.OC'
  pod 'UICollectionViewLeftAlignedLayout'
  pod 'MBProgressHUD'

  use_frameworks!
  #  网络请求
  pod 'Alamofire'
  #  图片缓存
  pod 'Kingfisher'
  #  控件适配
  pod 'SnapKit'
  #  加载样式
  pod 'Toast-Swift'
  #  键盘弹出
  pod 'IQKeyboardManagerSwift'
  # 下拉刷新
  pod 'ESPullToRefresh'
  #  空页面判断
  pod 'EmptyDataSet-Swift'
  #  json解析
  pod 'SwiftyJSON'
  pod 'HandyJSON'
  #  应用内自定义通知
  pod 'NotificationBannerSwift'
  # 侧滑菜单
  pod 'SideMenu'
  # 暗黑模式
  pod 'FluentDarkModeKit'
  # xpath工具
  pod "Ji"
  # sqlite数据库
  pod 'GRDB.swift'
  # 导航栏
  pod 'JXSegmentedView'
  
  pod 'ReactiveCocoa'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
  end
  
end
