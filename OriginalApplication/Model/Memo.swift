//
//  TextMemo.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/08/06.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import Foundation

// 記録の管理をするクラス
class Memo
{
    private var textTitle:String = ""
    private var textMemoData:String = ""
    private var memoImageString:String = ""
    //private var imageData:Data = Data()
    
    init(textTitle:String, textMemoData:String, memoImageString:String){
        
        self.textTitle = textTitle
        self.textMemoData = textMemoData
        self.memoImageString = memoImageString
    }
    
    // 外部から入力された値を入れる
    init(textTitle:String, textMemoData:String) {
        
        self.textTitle = textTitle
        self.textMemoData = textMemoData
    }
    
    init(memoImageString:String) {
    
        self.memoImageString = memoImageString
    }
    
    // メモのタイトルを取得
    public func GetTextTitle() -> String{
        
        return self.textTitle
    }
    
    // メモの文章を取得
    public func GetTextMemoData() -> String{
        
        return self.textMemoData
    }
    
    // 画像のURLを取得
    public func GetImageString() -> String{
        
        return self.memoImageString
    }
    
}
