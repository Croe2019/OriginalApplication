//
//  Analysis.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/02/27.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol DoneCatchProtocol {
    
    // 規則を決める
    func catchData(scanTextString:String)
}

class Analysis{
    
    // 外部から渡ってくる画像の値
    private var imageData:Data?
    private var scanTextString:String?
    private var urlString:String?
    var doneCatchProtocol:DoneCatchProtocol?
    
    init(imageData:Data, scanTextString:String, urlString:String){
        
        self.imageData = imageData
        self.scanTextString = scanTextString
        self.urlString = urlString
    }
    
    // JSON解析を行う
    public func setData(){
        
        // urlエンコーディング
        let encordURLString:String = scanTextString!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        AF.request(encordURLString, method: .post, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            
            print("responseの値", response.debugDescription)
            
            switch response.result{
            
            case .success:
                do{
                    let json:JSON = try JSON(data: response.data!)
                    
                    let scanData = ScanData(imageData: json["requests"]["image"]["content"].string, scanTextString: json["requests"]["features"]["type"]["DOCUMENT_TEXT_DETECT"].string)
                    
                    self.doneCatchProtocol?.catchData(scanTextString: self.scanTextString!)
                }catch{
                    print("エラーです")
                }
                break
            case .failure:
                break
            }
        }
    }
    
    // その値をControllerに渡す
}
