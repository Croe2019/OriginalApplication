//
//  HomeController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/07/19.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var memoTableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    
    var memoArray = [Memo]()
    // 検索結果を格納する配列
    var searchResult = [Memo]()
    
    var memoTitle = String()
    var memoTextBody = String()
    // 画像のURLの値を渡す
    var memoImageString = String()
    // テストコード indexNumberにtableViewにあるメモのautoID番号を入れる Int型にしているのは数字で判別する為
    // String型の方が良い場合はString型へ変更
    var indexNumber = Int()
    
    // autoID表示用配列
    var autoIDArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memoTableView.delegate = self
        memoTableView.dataSource = self
        searchField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.memoArray.removeAll()
        self.memoTableView.reloadData()
        // テストコード 処理順を変更 最初にログインしたユーザーを確認後データを読み込む
        let authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if let user = user?.uid{
                
                let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).queryLimited(toLast: 100).observe(.value) { (snapShot) in
                    
                    if let snapShot = snapShot.children.allObjects as? [DataSnapshot]{
                        
                        for snap in snapShot{
                            
                            if let memoData = snap.value as? [String:Any]{
                                
                                let memoTitle = memoData["memoTitle"] as? String
                                let memoTextData = memoData["memoBody"] as? String
                                let memoImageData = memoData["memoImage"] as? String
                                
                                if(memoImageData != "" && memoTitle != "" && memoTextData != ""){
                                    
                                    self.FeachData()
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        searchBar.showsCancelButton = true
        
        let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).observe(.value) { (snapShot) in
            
            self.searchResult.removeAll()
            self.memoArray.removeAll()
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapShot{
                    
                    if let memoData = snap.value as? [String:Any]{
                        
                        let memoTitle = memoData["memoTitle"] as? String
                        let memoTextData = memoData["memoBody"] as? String
                        let memoImageString = memoData["memoImage"] as? String
                        
                        // タイトルを入力して一致するものがあれば表示
                        if(self.searchField.text! == memoTitle){
                            
                            self.searchResult.append(Memo.init(textTitle: memoTitle!, textMemoData: memoTextData!, memoImageString: memoImageString!))
                        }
                        else if(self.searchField.text!.prefix(3) == memoTitle!.prefix(3)){
                            
                            // 先頭3文字が一致しているメモがあればある分表示
                            self.searchResult.append(Memo.init(textTitle: memoTitle!, textMemoData: memoTextData!, memoImageString: memoImageString!))
                        }
                        else{
                            
                            // 検索ワードが無ければ、全てのメモを表示
                            self.memoArray.append(Memo.init(textTitle: memoTitle!, textMemoData: memoTextData!, memoImageString: memoImageString!))
                        }
                        
                    }
                }
                
            }
            
            self.memoTableView.reloadData()
        }
        
    }
    
    // キャンセルボタン処理
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        searchBar.text = ""
        memoTableView.reloadData()
    }
    
    // キャンセルボタンを表示
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.showsCancelButton = true
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 検索しない時はDBから取得したメモを表示
        if(searchField.text! == ""){
            
            return memoArray.count
        }else{
            
            // テキストが入っているときは検索した方を表示
            return searchResult.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = memoTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if(searchField.text! == ""){
            
            cell.textLabel!.text = memoArray[indexPath.row].GetTextTitle()
        }else{
            
            cell.textLabel!.text = searchResult[indexPath.row].GetTextTitle()
        }
    
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(searchField.text! == ""){
            
            memoTitle = memoArray[indexPath.row].GetTextTitle()
            memoTextBody = memoArray[indexPath.row].GetTextMemoData()
            
            memoImageString = memoArray[indexPath.row].GetImageString()
        }
        else{
            
            memoTitle = searchResult[indexPath.row].GetTextTitle()
            memoTextBody = searchResult[indexPath.row].GetTextMemoData()
            
            memoImageString = searchResult[indexPath.row].GetImageString()
        }
        
        // テストコード 2番号を格納
        indexNumber = indexPath.row
        print("autoID",indexNumber)
        
        performSegue(withIdentifier: "Detail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 複数の画面遷移をする為、エラー防止
        if(segue.identifier == "Detail"){
            
            let detailVC = segue.destination as! DetailViewController
            detailVC.memoTextTitleString = memoTitle
            detailVC.memoTextBodyString = memoTextBody
            // 画像の値を渡す
            detailVC.memoImageString = memoImageString
            // テストコード
            detailVC.memoArray = memoArray
            // テストコード 詳細画面へ値を渡す
            detailVC.indexNumber = indexNumber
            
        }
        
    }
    
    // テキスト、画像の両方を取得
    func FeachData(){
        
        let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).queryLimited(toLast: 100).observe(.value) { (snapShot) in
            
            self.memoArray.removeAll()
            
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapShot{
                    
                    if let memoData = snap.value as? [String:Any]{
                        
                        let memoTitle = memoData["memoTitle"] as? String
                        let memoTextData = memoData["memoBody"] as? String
                        let memoImageString = memoData["memoImage"] as? String
                        
                        self.memoArray.append(Memo.init(textTitle: memoTitle!, textMemoData: memoTextData!, memoImageString: memoImageString!))
                    }
                }
                
            }
            
            self.memoTableView.reloadData()
        }
    }
    
}
