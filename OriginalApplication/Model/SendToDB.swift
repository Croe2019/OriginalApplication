//
//  SendToDB.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/08/06.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import UIKit

class SendToDB
{
    private var memoImageStringArray = [String]()
    
    // データベースに送信する
    func Send(memoTitle:String, memoTextData:String, memoImageString:String, memoImageDataArray:[Data])
    {
        // 引数に外部から入力されたものを格納する
        // DBのchildを決める 現在はテキスト形式のみ あとで追加する
        let memoDB = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).childByAutoId()
        // 送信先のStorageURL
        let storage = Storage.storage().reference(forURL: "gs://originalapplication-f9c27.appspot.com")

        // フォルダを作る(フォルダの中に各形式のメモが入る TextMemoにはテキスト形式で入れる)
        let textKey = memoDB.child("TextMemo").childByAutoId().key
        let imageKey = memoDB.child("MemoImage").childByAutoId().key
        
        let textRef = storage.child("TextMemo").child("\(String(describing: textKey!))")
        let imageRef = storage.child("MemoImage").child("\(String(describing: imageKey!)).jpeg")
        
        
        // for文の前にindexNumberArrayに選択した画像の要素数を入れたい
        // アップロードタスク putFileの方が良ければそちらに変更
        for i in 0...memoImageDataArray.count - 1{
            
            print("Sendのiの値", i)
            let uploadTask = imageRef.putData(memoImageDataArray[i], metadata: nil){
                (metadata, error) in
                
                if(error != nil){
                    
                    print(error)
                    return
                }
                
                imageRef.downloadURL { (url, error) in
                    
                    if(url != nil){
                        
                        self.memoImageStringArray.append(url!.absoluteString)
                        print("memoImageStringArrayの値1", self.memoImageStringArray.count)
                    }
                    
                }
                
            }
            print("memoImageStringArrayの値2", self.memoImageStringArray.count)
            let memoInfo = ["memoTitle":memoTitle as Any, "memoBody":memoTextData as Any, "memoImage":self.memoImageStringArray as Any]
            memoDB.updateChildValues(memoInfo)
           // uploadTask.resume()
        }
        
    }
   
}
