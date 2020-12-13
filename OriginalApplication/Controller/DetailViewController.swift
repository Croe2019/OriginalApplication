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
    
    var memoArray = [Memo]()
    
    @IBOutlet weak var pagerView: FSPagerView!{
        didSet{
            
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
                        self.pagerView.itemSize = FSPagerView.automaticSize
        }
    }
    
    
    @IBOutlet weak var pageControl: FSPageControl!{
        
        didSet{
            
            self.pageControl.numberOfPages = self.memoArray.count
                        self.pageControl.contentHorizontalAlignment = .right
                        self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memoTitle.text = memoTextTitleString
        memoTextBody.text = memoTextBodyString
        // pagerView生成
//        let pagerView = FSPagerView()
//        pagerView.frame = CGRect(x: 46, y: 120, width: 100, height: 100)
//        pagerView.delegate = self
//        pagerView.dataSource = self
//        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
//        self.view.addSubview(pagerView)
//        let pageControl = FSPageControl()
//        pageControl.frame = CGRect(x: 46, y: 120, width: 100, height: 100)
//        self.view.addSubview(pageControl)
        memoImageView.sd_setImage(with: URL(string:memoImageString), completed: nil)
        
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
    // FSPagerView DataSource
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        
        return memoArray.count
    }
    
    // 画像を表示するときはcellを使う必要があるのでしょうか？
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        // メモの画像を入れる
        cell.imageView?.image = UIImage(named: memoImageString)
        
        return cell
    }
    
    // FSPagerView Delegate
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        
        self.pageControl.currentPage = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        
        self.pageControl.currentPage = pagerView.currentIndex
    }
}
