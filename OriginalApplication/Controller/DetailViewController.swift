//
//  DetailViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/08/30.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit
import Firebase
import FSPagerView

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoTextBody: UILabel!
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var memoTextTitleString = String()
    var memoTextBodyString = String()
    var memoImageString = String()
    // テストコード データのautoIDの番号を取得する変数
    var indexNumber = Int()
    var memoArray = [Memo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memoTitle.text = memoTextTitleString
        memoTextBody.text = memoTextBodyString
        print("画像の値", memoImageString)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        // タグ番号を使ってImageViewのインスタンスヲッ生成
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        // 要素の名前を画像のUIImageとする 後で配列化する
        let cellImage = UIImage(named: memoImageString)
        // UIImageをUIImageViewのimageとして設定
        imageView.image = cellImage
        
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
        }
    }
    
}
