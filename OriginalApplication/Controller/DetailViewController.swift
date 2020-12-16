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

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoTextBody: UILabel!
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var memoScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var memoTextTitleString = String()
    var memoTextBodyString = String()
    var memoImageString = String()
    // テストコード データのautoIDの番号を取得する変数
    var indexNumber = Int()
    var memoArray = [Memo]()
    
    // ページ数
    var pegeCount:Int!
    // ScrollScreenの高さ
    var scrollScreenHeight:CGFloat!
    // ScrollScreenの幅
    var scrollScreenWidth:CGFloat!
    
    var imageWidth:CGFloat!
    var imageHeight:CGFloat!
    var screenSize:CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memoTitle.text = memoTextTitleString
        memoTextBody.text = memoTextBodyString
        memoImageView.sd_setImage(with: URL(string:memoImageString), completed: nil)
        
        
        screenSize = UIScreen.main.bounds
        // ページスクロールとするためにページ幅を合わせる
        scrollScreenWidth = screenSize.width
        let imageTop:UIImage = UIImage(named: memoImageString)!
        pegeCount = memoArray.count
        
        imageWidth = imageTop.size.width
        imageHeight = imageTop.size.height
        scrollScreenHeight = scrollScreenWidth * imageHeight/imageWidth
        
        for i in 0 ..< pegeCount {
            // UIImageViewのインスタンス
            let image:UIImage = UIImage(named:memoArray[i].GetImageString())!
            let imageView = UIImageView(image:image)
                    
            var rect:CGRect = imageView.frame
            rect.size.height = scrollScreenHeight
            rect.size.width = scrollScreenWidth
         
            imageView.frame = rect
            imageView.tag = i + 1
                    
            // UIScrollViewのインスタンスに画像を貼付ける
            self.memoScrollView.addSubview(imageView)
                    
        }
        setupScrollImages()
    }
    
    func setupScrollImages(){
           
           // DBにある画像表示 ※現在は画像が1枚しかない状態なので、後で配列にする
           let image:UIImage = UIImage(named:memoImageString)!
           var imgView = UIImageView(image:image)
           var subviews:Array = memoScrollView.subviews
           
           // 描画開始の x,y 位置
           var px:CGFloat = 0.0
           let py:CGFloat = (screenSize.height - scrollScreenHeight)/2
           
           // verticalScrollIndicatorとhorizontalScrollIndicatorが
           // デフォルトで入っているので2から始める
           for i in 2 ..< subviews.count {
               imgView = subviews[i] as! UIImageView
               if (imgView.isKind(of: UIImageView.self) && imgView.tag > 0){
                   
                   var viewFrame:CGRect = imgView.frame
                   viewFrame.origin = CGPoint(x: px, y: py)
                   imgView.frame = viewFrame
                   
                   px += (scrollScreenWidth)
                   
               }
           }
           // UIScrollViewのコンテンツサイズを画像のtotalサイズに合わせる
           let nWidth:CGFloat = scrollScreenWidth * CGFloat(pegeCount)
           memoScrollView.contentSize = CGSize(width: nWidth, height: scrollScreenHeight)
           
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
