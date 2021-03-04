//
//  MenuViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/07/24.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    
    var menuList = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ホーム、ゴミ箱はデフォルトで表示する
        // メニューの機能実装時には変更する
        menuList = ["新規作成", "ホーム", "検索", "手書き", "画像を解析" ,"ゴミ箱"]
        menuTableView.delegate = self
        menuTableView.dataSource = self
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // メニューの位置を取得する
        let menuPosition = self.menuView.layer.position
        // 初期位置の画面の外側にする為、メニューの幅の文だけマイナスする
        self.menuView.layer.position.x = -self.menuView.frame.width
        // 表示時のアニメーションを作成する
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.menuView.layer.position.x = menuPosition.x
        },
                       completion: {
                        bool in
        })
    }
    
    // メニューエリア以外タップ時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        for touch in touches{
            
            if(touch.view?.tag == 1)
            {
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: .curveEaseIn,
                               animations: {
                                self.menuView.layer.position.x = -self.menuView.frame.width
                },
                               completion: {bool in
                                self.dismiss(animated: true, completion: nil)
                }
                )
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "create", sender: nil)
        case 1:
            self.dismiss(animated: true, completion: nil)
        case 2: performSegue(withIdentifier: "Search", sender: nil)
        case 3: performSegue(withIdentifier: "HandWritten", sender: nil)
        case 4: performSegue(withIdentifier: "Scan", sender: nil)
        case 5: return // ゴミ箱機能が現在ないため
        
        default:
            return
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel!.text = menuList[indexPath.row]
        
        return cell
    }
    
    func viewDidAppear(){
        
        menuTableView.reloadData()
    }

}
