//
//  EditSendToDB.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/10/08.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import UIKit

// 編集したメモを送信するクラス ※一旦保留 編集したいメモのIDがController側で保持しているため
class EditSendToDB{
    
    // テストコード
    var indexNumber = Int()
    // autoID表示用配列
    var autoIDArray = [String]()
    var testArray = [String]()
    
    // データを格納
    func storingToArray(){
        
        let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).queryLimited(toLast: 100).observe(.value) { (snapShot) in
            
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapShot{
                    
                    // autoIDを追加
                    self.autoIDArray.append(snap.key)
                }
        
            }
            
        }
    }
    
    // テキスト形式のメモを送信
    func EditSend(editMemoTitle:String, editMemoBody:String, editMemoImageString:String, editMemoImageData:Data){
        
        // refの中身が間違っているのか？
        let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid)
        // 条件が間違っているのか？
        
        for autoID in autoIDArray{
            
            testArray.append(autoID)
            
        }
        
        let storage = Storage.storage().reference(forURL: "gs://originalapplication-f9c27.appspot.com")
        let imageKey = storage.child("MemoImage")
        let imageRef = storage.child("MemoImage").child("\(String(describing: imageKey)).jpeg")
        
        imageRef.putData(editMemoImageData, metadata: nil){metadata, error in
            
            if(error != nil){
                print(error)
                return
            }
            
            imageRef.downloadURL { (url, error) in
                
                if(url != nil){
                    
                    //editMemoImageData = editImageView.image?.jpegData(compressionQuality: 0.01) as! Data
                    ref.child(self.testArray[self.indexNumber]).setValue(["memoTitle": editMemoTitle, "memoBody": editMemoBody, "memoImage": url?.absoluteString])
                }
            }
            
        }
    }
    
    
}
