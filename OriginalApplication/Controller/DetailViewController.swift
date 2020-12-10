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

class DetailViewController: UIViewController, FSPagerViewDelegate, FSPagerViewDataSource {
    
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoTextBody: UILabel!
    @IBOutlet weak var memoImageView: UIImageView!
    
    var memoTextTitleString = String()
    var memoTextBodyString = String()
    var memoImageString = String()
    // テストコード データのautoIDの番号を取得する変数
    var indexNumber = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memoTitle.text = memoTextTitleString
        memoTextBody.text = memoTextBodyString
        // pagerView生成
        let pagerView = FSPagerView()
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(pagerView)
        let pageControl = FSPageControl()
        self.view.addSubview(pageControl)
//        memoImageView.sd_setImage(with: URL(string:memoImageString), completed: nil)
        
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
    
    // ここにメモごとに保存してある画像の数を返せば良いでしょうか？
    // その際はメモの配列を作る必要があるでしょうか？
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        
        return numberOfItems(in: pagerView)
    }
    
    // 画像を表示するときはcellを使う必要があるのでしょうか？
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        // メモの画像を入れる
        cell.imageView?.image = memoImageView.image
        
        return cell
    }
}
