//
//  Alarm.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/05/28.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import Foundation
import AVKit
import UIKit

class Alarm{
    
    var selectedWakeUPTime:Date?
    var audioPlayer:AVAudioPlayer!
    var sleepTimer:Timer?
    var seconds = 0
    
    // アラーム、タイマーを開始
    func RunTime(){
        
        seconds = CalculateIntarval(userAwakeTime: selectedWakeUPTime!)
        
        if(sleepTimer == nil){
            
            sleepTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func UpdateTimer(){
        
        if(seconds != 0){
            // secondsから-1する
            seconds -= 1
        }else{
            //タイマーを止める
            sleepTimer?.invalidate()
            //タイマーにnil代入
            sleepTimer = nil
            //音源のパス
            let soundFilePath = Bundle.main.path(forResource: "", ofType: "")!
            //パスのURL
            let sound:URL = URL(fileURLWithPath: soundFilePath)
            do {
                //AVAudioPlayerを作成
                audioPlayer = try AVAudioPlayer(contentsOf: sound, fileTypeHint:nil)
                // バックグラウンドでもオーディオ再生可能にする
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Could not load file")
            }
            //再生
            audioPlayer.play()
        }
    }
    
    private func CalculateIntarval(userAwakeTime:Date)-> Int{
        
        var interval = Int(userAwakeTime.timeIntervalSinceNow)
        
        if(interval < 0){
            
            interval = 86400 - (0 - interval)
        }
        
        let calendar = Calendar.current
        let seconds = calendar.component(.second, from: userAwakeTime)
        return interval - seconds
    }
    
    func stopTimer(){
        //sleepTimerがnilじゃない場合
        if sleepTimer != nil {
            //タイマーを止める
            sleepTimer?.invalidate()
            //タイマーにnil代入
            sleepTimer = nil
        }else{
            //タイマーを止める
            audioPlayer.stop()
        }
    }
}
