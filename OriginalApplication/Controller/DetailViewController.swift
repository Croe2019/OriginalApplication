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
    // テストコード データのautoIDの番号を取得する変数
    var indexNumber = Int()
    var memoArray = [Memo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memoImageCollection.dataSource = self
        memoImageCollection.delegate = self
        memoTitle.text = memoTextTitleString
        memoTextBody.text = memoTextBodyString
        memoImageView.sd_setImage(with: URL(string:memoImageString), completed: nil)
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
