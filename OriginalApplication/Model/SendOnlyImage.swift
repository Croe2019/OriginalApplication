//
//  SendOnlyImage.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/03/04.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

// 画像のみ送信
class SendOnlyImage{
    
    // 画像形式メモを送信
    func SendImage(memoImageData:Data, memoImageString:String){
        
        // DBのchildを決める 現在はテキスト形式のみ あとで追加する
        let memoDB = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).childByAutoId()
        
        // 送信先のStorageURL
        let storage = Storage.storage().reference(forURL: "gs://originalapplication-f9c27.appspot.com")
        
        let imageKey = memoDB.child("MemoImage").childByAutoId().key
        
        let imageRef = storage.child("MemoImage").child("\(String(describing: imageKey!)).jpeg")
        
        // アップロードタスク putFileの方が良ければそちらに変更
        print(memoImageData.debugDescription)
        let uploadTask = imageRef.putData(memoImageData, metadata: nil){
            (metadata, error) in

            if(error != nil){

                print(error)
                return
            }

            imageRef.downloadURL { (url, error) in

                if(url != nil){

                    // 送信するものを指定する
                    // 画像だけ送信する場合は、デフォルトでタイトルと本文を文字列で送信する
                    // この場合は、後で検索機能実装の為と表示で分かりやすくする為
                    let memoInfo = ["memoTitle":"タイトル" as Any, "memoBody":"本文です" as Any,"memoImage":url?.absoluteString as Any]
                    memoDB.updateChildValues(memoInfo)
                }

            }
        }

        uploadTask.resume()
        

    }
}
