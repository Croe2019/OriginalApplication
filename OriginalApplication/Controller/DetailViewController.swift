//
//  DetailViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/08/30.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoTextBody: UILabel!
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var memoImageCollection: UICollectionView!
    
    var memoTextTitleString = String()
    var memoTextBodyString = String()
    var memoImageString = String()
    var memoImageData = Data()
    // テストコード データのautoIDの番号を取得する変数
    var indexNumber = Int()
    var memoArray = [Memo]()
   // let dataDelete = DataDelete()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memoImageCollection.dataSource = self
        memoImageCollection.delegate = self
        memoTitle.text = memoTextTitleString
        memoTextBody.text = memoTextBodyString
        memoImageView.sd_setImage(with: URL(string:memoImageString), completed: nil)
        // テスト
        print("indexNumber", indexNumber)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // 要素数を入れる
        return memoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // ストーリーボードで設定したID
        let cell = memoImageCollection.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        // タグ番号を使ってImageViewのインスタンスを生成
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
    
        // UIImageをUIImageViewのimageとして設定
        // 後で複数表示したいので画像を複数DBに保存できる機能を実装したら配列化
        imageView.sd_setImage(with: URL(string: memoArray[indexNumber].GetImageString()), completed: nil)
        print("画像の値", memoArray[indexNumber].GetImageString())
        
        return cell
    }
    
//    func sendTrashBox(){
//
//        let textMemo = Memo(textTitle: memoTitle.text!, textMemoData: memoTextBody.text!)
//        // DBのchildを決める 現在はテキスト形式のみ あとで追加する
//        let memoDB = Database.database().reference().child("TrashBox").child(Auth.auth().currentUser!.uid).childByAutoId()
//
//        // 送信先のStorageURL
//        let storage = Storage.storage().reference(forURL: "gs://originalapplication-f9c27.appspot.com")
//
//        let imageKey = memoDB.child("MemoImage").childByAutoId().key
//
//        let imageRef = storage.child("MemoImage").child("\(String(describing: imageKey!)).jpeg")
//        memoImageData = memoImageView.image?.jpegData(compressionQuality: 0.01) as! Data
//
//        // アップロードタスク putFileの方が良ければそちらに変更
//        let uploadTask = imageRef.putData(memoImageData, metadata: nil){
//            (metadata, error) in
//
//            if(error != nil){
//
//                print(error)
//                return
//            }
//
//            imageRef.downloadURL { (url, error) in
//
//                if(url != nil){
//
//                    // 送信するものを指定する
//                    // 画像だけ送信する場合は、デフォルトでタイトルと本文を文字列で送信する
//                    // この場合は、後で検索機能実装の為と表示で分かりやすくする為
//                    let memoInfo = ["memoTitle":textMemo.GetTextTitle() as Any, "memoBody":textMemo.GetTextMemoData() as Any,"memoImage":url?.absoluteString as Any]
//                    memoDB.updateChildValues(memoInfo)
//                }
//            }
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 複数の画面遷移をする為、エラー防止
        if(segue.identifier == "Edit"){
            
            let editVC = segue.destination as! EditViewController
            editVC.memoTextTitleString = memoTextTitleString
            editVC.memoTextBodyString = memoTextBodyString
            // テストコード
            editVC.indexNumber = indexNumber
            // 画像の値を渡す
            editVC.editMemoImageString = memoImageString
            // 編集画面へ遷移する際も配列で値を渡す
        }
    }
    
}
