//
//  NotificationListViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/05/29.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // 完了していない通知を一覧で格納する配列
    var notificationRequests = [UNNotificationRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // まだ完了していない通知を取得
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            
            DispatchQueue.main.async {
                
                print(requests)
                self.notificationRequests = requests
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func Back(_ sender: Any) {
        
        // 画面遷移 ホーム画面へ戻る
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルの位置に対応する通知のリクエストを取得
        let request = notificationRequests[indexPath.row]
        // セルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = request.content.title
        let trigger = request.trigger as! UNCalendarNotificationTrigger
        let nextDate = trigger.nextTriggerDate()
        if(nextDate == nil){
            return cell!
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        cell?.detailTextLabel?.text = dateFormatter.string(from: nextDate!)
        return cell!
    }
    
    // セルを編集できるかを決める
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // セルがどのように編集されたかをif文で確認する
        if editingStyle == .delete {
            // MARK: セルがスワイプによって削除された場合
            // プッシュ通知を削除する
            // プッシュ通知のIDを取得
            let id: String = notificationRequests[indexPath.row].identifier
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            // 配列のデータを削除する
            notificationRequests.remove(at: indexPath.row)
            // テーブルビューをリロードする
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationRequests.count
    }
    
}
