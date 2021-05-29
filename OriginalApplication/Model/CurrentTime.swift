//
//  CurrentTime.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/05/28.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import Foundation

// 現在の時刻の取得、表示するクラス
class CurrentTime{
    
    var timer: Timer?
    var currentTime: String?
    var dateFormatter = DateFormatter()
    weak var delegate: CreateController?
    
    init() {
        
        if(timer == nil){
            
            // タイマーをセット、一秒ごとにupdateCurrentTimeを呼ぶ
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func updateCurrentTime(){
        // フォーマットの指定
        dateFormatter.dateFormat = "HH:mm"
        // 時刻をUNIXから端末のタイムゾーンにする
        dateFormatter.timeZone = TimeZone.current
        // 現在の時刻をフォーマットに従って文字列下を行う
        let timeZoneDate = dateFormatter.string(from: Date())
        currentTime = timeZoneDate
        delegate?.UpdateTime(currentTime!)
    }
}
