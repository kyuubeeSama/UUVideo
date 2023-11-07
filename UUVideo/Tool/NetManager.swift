//
// 文件名:NetManager.swift 

// Created by Galaxy  on 2022/6/16
// Copyright © 2022 qykj All rights reserved.
import Alamofire
import HandyJSON
import Foundation
import SwiftyJSON
import MBProgressHUD

struct NetStatusModel:HandyJSON{
    var msg = ""
    var status = 200
    var code = 0 //1成功  2失败  3包含敏感词
    var data:[String:Any] = [:]
}

enum NetWorkError: Error {
    case responseJsonSerializationError(code:Int,message:String,response:Any) // 序列化 返回非自字典格式数据
    case responseDataError(code: Int,data: Any)// 请求数据状态错误 status 2错误
    case systemError(msg: String)
}

class NetFileModel {
    enum UplodeType{
        case file
        case data
    }
    var fileName:String = ""
    var filePath:String = ""
    var fileData:Data
    var fileMimeType:String = ""
    var upLaodType:UplodeType
    
    init() {
        upLaodType = .file
        fileData = Data()
    }
}
class NetElement {
    var url:String
    var host = ""
    var method:HTTPMethod
    var parameters:[String: Any]
    var encoding:ParameterEncoding
    var upLaodArray:[NetFileModel]
    var downModel:NetFileModel
    var headers: HTTPHeaders {
        get {
            let head: HTTPHeaders = [
                "contentType":"application/json",
           ]
            return head
        }
    }
    init() {
        url = ""
        method = HTTPMethod.post
        parameters = [:]
        encoding = URLEncoding.default
        upLaodArray = [NetFileModel]()
        downModel = NetFileModel()
    }
}
class NetToast {
    var show:Bool
    var loadString:String = ""
    var errorString:String = "请求失败"
    init() {
        show = false
    }
}

class NetManager {
    private static let msgNetError = "网络错误，请联网后点击重试"
    private static let msgDataError = "获取网络数据失败"
    
    private static let manager = NetworkReachabilityManager()
    private var  element:NetElement = NetElement()
    private var  toast:NetToast = NetToast()
    private var  point_sec:((_ res:String) -> Void)?
    private var  point_fail:((_ fail:AFError) -> Void)?
    // 基本参数
    public  func element(element :@escaping (_ element:NetElement) -> Void)->Self{
        self.element = NetElement()
        element(self.element)
        return self
    }
    // Toast
    public  func toast(toast :@escaping (_ toast:NetToast) -> Void)->Self{
        self.toast = NetToast()
        toast(self.toast)
        return self
    }
    private func showHUD(str:String){
        if let _ = UIApplication.shared.keyWindow {
            MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            MBProgressHUD.forView(UIApplication.shared.keyWindow!)?.label.text = str
        }
    }
    private func hideHUD(){
        if let _ = UIApplication.shared.keyWindow {
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: false)
        }
    }
    public func request(_ success:@escaping (_ success:String) -> Void , fail:@escaping(_ fail:AFError)->Void){

        if self.element.url.count == 0{
            if self.point_fail != nil{
                self.point_fail!(AFError.invalidURL(url: URL(string: self.element.host + self.element.url)!))
            }
            return
        }
        if self.toast.show {
            self.showHUD(str: self.toast.loadString)
        }
        AF.request(self.element.host + self.element.url, method: self.element.method, parameters: self.element.parameters, encoding: self.element.encoding, headers: self.element.headers, interceptor: nil, requestModifier: nil).validate().responseString { response in
            if let rep = response.response {
                self.dealResponseHeadersWithHeaders(headers: rep.allHeaderFields, url: response.response!.url!)
            }
            self.hideHUD()
#if DEBUG
            self.markLogs(url: response.request!.url!)
#endif
            switch response.result{
            case .failure(let error):
                print(error.localizedDescription)
                fail(error);
            case .success(let succ):
                guard NetStatusModel.deserialize(from: succ) != nil else {
                    fail(AFError.responseValidationFailed(reason: AFError.ResponseValidationFailureReason.customValidationFailed(error: NetWorkError.responseDataError(code:-100 ,data: succ))))
                    print("👉FailData:👉\(JSON.init(parseJSON: succ))")
                    return
                }
                print("👉succ:👉\(JSON.init(parseJSON: succ))")

                success(succ)
            }
            self.hideHUD()
        }
    }
    public func requestWithDic(_ success:@escaping (_ success:Dictionary<String,Any>) -> Void , fail:@escaping(_ fail:AFError)->Void){

        if self.element.url.count == 0{
            if self.point_fail != nil{
                self.point_fail!(AFError.invalidURL(url: URL(string: self.element.host + self.element.url)!))
            }
            return
        }
        if self.toast.show {
            self .showHUD(str: self.toast.loadString)
        }
        AF.request(self.element.host + self.element.url, method: self.element.method, parameters: self.element.parameters, encoding: self.element.encoding, headers: self.element.headers, interceptor: nil, requestModifier: nil).validate().responseData { response in
            self.hideHUD()
            if let rep = response.response {
                self.dealResponseHeadersWithHeaders(headers: rep.allHeaderFields, url: response.response!.url!)
            }

#if DEBUG
            self.markLogs(url: response.request!.url!)
#endif
            switch response.result{
            case .failure(let error):
                print(error.localizedDescription)
                fail(error);
            case .success(let succ):
                
                do {
                    let js = try! JSONSerialization.jsonObject(with: succ)
                    if let dic:Dictionary<String,Any> = js as? Dictionary<String, Any> {
                        guard NetStatusModel.deserialize(from: dic) != nil else {
                            fail(AFError.responseValidationFailed(reason: AFError.ResponseValidationFailureReason.customValidationFailed(error: NetWorkError.responseDataError(code:-100 ,data: succ))))
                            print("👉FailData:👉\(JSON.init(dic))")
                            return
                        }
                        success(dic)
                    }else{
                        print("👉FailData:👉\(js)")
                    }
                }
            }
        }
    }
    
    public func request() -> Self{
        if self.element.url.count == 0{
            if self.point_fail != nil{
                self.point_fail!(AFError.invalidURL(url: URL(string: self.element.host + self.element.url)!))
            }
            return self
        }
        if self.toast.show {
            self .showHUD(str: self.toast.loadString)
        }
        AF.request(self.element.host + self.element.url, method: self.element.method, parameters: self.element.parameters, encoding: self.element.encoding, headers: self.element.headers, interceptor: nil, requestModifier: nil).validate().responseString { response in
            if let rep = response.response {
                self.dealResponseHeadersWithHeaders(headers: rep.allHeaderFields, url: response.response!.url!)
            }

#if DEBUG
            self.markLogs(url: response.request!.url!)
#endif
            self.hideHUD()
            switch response.result{
            case .failure(let error):
                print(error.localizedDescription)
                if self.point_fail != nil{
                    self.point_fail!(error)
                }
            case .success(let succ):
                guard NetStatusModel.deserialize(from: succ) != nil else {
                    if self.point_fail != nil{
                        self.point_fail!(AFError.responseValidationFailed(reason: AFError.ResponseValidationFailureReason.customValidationFailed(error: NetWorkError.responseDataError(code:-100 ,data: succ))))
                    }
                    print("👉FailData:👉\(JSON.init(parseJSON: succ))")
                    return
                }
                if self.point_sec != nil{
                    self.point_sec!(succ)
                }
            }
        }
        return self
    }
    // 成功
    public func dealSucc(_ success:@escaping (_ resStr:String) -> Void) -> Self {
        self.point_sec = success
        return self
    }
    public func makeEnd(){}
    // 失败
    public func dealFail(_ fail:@escaping (_ fail:AFError) -> Void) {
        self.point_fail = fail
    }
    
    public func upLoad()->Self{
        self .showHUD(str: self.toast.loadString)
        AF.upload(multipartFormData: { MultipartFormData in
            for item in self.element.upLaodArray {
                switch item.upLaodType{
                case .file:
                    item.filePath = item.filePath.addingPercentEncoding(withAllowedCharacters: CharacterSet.afURLQueryAllowed)!
                    MultipartFormData.append(URL(fileURLWithPath:item.filePath), withName: item.fileName, fileName: item.fileName, mimeType: item.fileMimeType)
                case .data:
                    MultipartFormData.append(item.fileData, withName: item.fileName, fileName: item.fileName, mimeType: item.fileMimeType)
                }
            }
            
        }, to: self.element.host + self.element.url).responseString { response in
            self.hideHUD()
            if let rep = response.response {
                self.dealResponseHeadersWithHeaders(headers: rep.allHeaderFields, url: response.response!.url!)
            }

#if DEBUG
            self.markLogs(url: response.request!.url!)
#endif
            switch response.result{
            case .failure(let error):
                print(error.localizedDescription)
                if self.point_fail != nil{
                    self.point_fail!(error)
                }
            case .success(let succ):
                guard NetStatusModel.deserialize(from: succ) != nil else {
                    if self.point_fail != nil{
                        self.point_fail!(AFError.responseValidationFailed(reason: AFError.ResponseValidationFailureReason.customValidationFailed(error: NetWorkError.responseDataError(code:-100 ,data: succ))))
                    }
                    print("👉FailData:👉\(JSON.init(parseJSON: succ))")
                    return
                }
                if self.point_sec != nil{
                    self.point_sec!(succ)
                }
            }
        }
        return self
    }
    
    public func upLoad(_ success:@escaping (_ success:String) -> Void , fail:@escaping(_ fail:AFError)->Void){
        self .showHUD(str: self.toast.loadString)
        AF.upload(multipartFormData: { MultipartFormData in
            for item in self.element.upLaodArray {
                switch item.upLaodType{
                case .file:
                    item.filePath = item.filePath.addingPercentEncoding(withAllowedCharacters: CharacterSet.afURLQueryAllowed)!
                    MultipartFormData.append(URL.init(fileURLWithPath: item.filePath), withName: item.fileName, fileName: item.fileName, mimeType: item.fileMimeType)
                case .data:
                    MultipartFormData.append(item.fileData, withName: item.fileName, fileName: item.fileName, mimeType: item.fileMimeType)
                }
            }
            
        }, to: self.element.host + self.element.url).responseString { response in
            self.hideHUD()
            if let rep = response.response {
                self.dealResponseHeadersWithHeaders(headers: rep.allHeaderFields, url: response.response!.url!)
            }

#if DEBUG
            self.markLogs(url: response.request!.url!)
#endif
            switch response.result{
            case .failure(let error):
                print(error.localizedDescription)
                fail(error);
            case .success(let succ):
                success(succ)
            }
        }
    }
    
    func downLoad(_ progress: @escaping (Progress) -> Void,success:@escaping (_ success:String) -> Void , fail:@escaping(_ fail:AFError)->Void){
        AF.download(self.element.host + self.element.url, interceptor: nil, to:  { temporaryURL, response in
            return (URL(fileURLWithPath: self.element.downModel.filePath),[.removePreviousFile, .createIntermediateDirectories])
        }).downloadProgress { Progress in
            progress(Progress)
        }.responseString { response in
            self.dealResponseHeadersWithHeaders(headers: response.response!.allHeaderFields, url: response.response!.url!)

#if DEBUG
            self.markLogs(url: response.request!.url!)
#endif
            switch response.result{
            case .failure(let error):
                print(error.localizedDescription)
                fail(error);
            case .success(let succ):
                success(succ)
            }
        }
    }
    func markLogs(url:URL){
        let urlComponents = NSURLComponents(string: "\(url)")!
        urlComponents.queryItems = self.element.parameters.map { (key: String, value: Any) in
            URLQueryItem(name: key, value: "\(value)")
        }
        print("👉url:\(String(describing: urlComponents.url!))👈")
    }
    func dealResponseHeadersWithHeaders(headers:Dictionary<AnyHashable,Any>, url:URL){
        if let code = headers["code"] as? Int{
            if (code == 401 || code == 402){
            }else if(code == 403 ){
            }
        }
    }
}
