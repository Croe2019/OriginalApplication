//
//  SendToTrashBox.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/03/05.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class SendToTrashBox{
    
    // テストコード
    var indexNumber = Int()
    // autoID表示用配列
    var autoIDArray = [String]()
    var testArray = [String]()
    
    // ゴミ箱に送りたいデータを格納
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
    
    // ゴミ箱に送る
    func TrashSend(editMemoTitle:String, editMemoBody:String, editMemoImageString:String, editMemoImageData:Data, indexNumber:String){
        
        // refの中身が間違っているのか？
        let ref = Database.database().reference().child("TrashBox").child(Auth.auth().currentUser!.uid)
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
