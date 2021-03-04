//
//  SendOnlyText.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/03/04.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

// テキストのみ送信
class SendOnlyText{
    
    // テキスト形式のメモを送信
    func SendText(memoTitle:String, memoTextData:String){
        
        let textMemo = Memo(textTitle: memoTitle, textMemoData: memoTextData)
        
        // DBのchildを決める 現在はテキスト形式のみ あとで追加する
        let memoDB = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).childByAutoId()
        // 送信先のStorageURL
        let storage = Storage.storage().reference(forURL: "gs://originalapplication-f9c27.appspot.com")

        // フォルダを作る(フォルダの中に各形式のメモが入る TextMemoにはテキスト形式で入れる)
        let textKey = memoDB.child("TextMemo").childByAutoId().key
        let textRef = storage.child("TextMemo").child("\(String(describing: textKey!))")
        
        // 送信するものを指定する
        let memoInfo = ["memoTitle":textMemo.GetTextTitle() as Any, "memoBody":textMemo.GetTextMemoData() as Any, "memoImage": "" as Any]
        memoDB.updateChildValues(memoInfo)
    }
}
