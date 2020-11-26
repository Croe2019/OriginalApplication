//
//  SearchViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/11/26.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit
import Firebase

// 検索機能のコントローラー ※後でクラス化するかを検討する
class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    
    // テストです
    var memoArray = [Memo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // 入力したメモのタイトルと、DBにあるメモのタイトルと一致すれば検索結果を表示し画面遷移
    @IBAction func search(_ sender: Any) {
        
        let ref = Database.database().reference().child("Record/memoTitle").child(Auth.auth().currentUser!.uid).queryOrdered(byChild: "memoTitle").observe(.value) { (snapShot) in
            
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapShot{
                    
                    if let memoData = snap.value as? [String:Any]{
                        
                        let memoTitle = memoData["memoTitle"] as? String
                        let memoTextData = memoData["memoBody"] as? String
                        let memoImageString = memoData["memoImage"] as? String
                        
                        if(self.searchTextField.text == memoTitle){
                            
                            // 検索キーワードと一致するメモがあれば画面遷移をし、結果画面に表示する
                            self.memoArray.append(Memo.init(textTitle: memoTitle!, textMemoData: memoTextData!, memoImageString: memoImageString!))
                            
                        }
                    }
                }
                
            }
        }
            
        
        performSegue(withIdentifier: "Result", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let resutlVC = segue.description as! SearchResultViewController
        resutlVC.searchMemoTitleString = searchTextField.text!
    }
}
