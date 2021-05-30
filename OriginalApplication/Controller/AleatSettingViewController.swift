//
//  AleatSettingViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/05/29.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import UIKit
import UserNotifications

class AleatSettingViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notificationDatePicker: UIDatePicker!
    @IBOutlet weak var addNotificationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationDatePicker.preferredDatePickerStyle = .wheels
        addNotificationButton.layer.cornerRadius = 8
        addNotificationButton.layer.borderWidth = 1
        addNotificationButton.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    // 通知を追加
    @IBAction func addNotification(_ sender: Any) {
        // DatePickerから日付を取得
        let notificationDate = notificationDatePicker.date
        // テキストフィールドからテキストを取得
        let notificationTitle = titleTextField.text!
        // カレンダークラスを作成 ここで、UIDatePickerの表示をデフォルトにしたい(main.storyBoardの形式にしたい)
        let calendar: Calendar = Calendar.current
        let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate), repeats: false)
        // 通知の中身を設定
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.sound = UNNotificationSound.default
        content.badge = 1
        // 通知のリクエストを作成
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // 通知のリクエストを登録する
        UNUserNotificationCenter.current().add(request) { (error) in
            // エラーが存在しているかを確認
            if(error != nil){
                print(error)
            }else{
                
                DispatchQueue.main.async {
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        titleTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        titleTextField.resignFirstResponder()
        return true
    }
}
