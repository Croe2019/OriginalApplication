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
        
    }
    
    // JSON解析を行う
    public func setData(){
        
        
    }
    
}
