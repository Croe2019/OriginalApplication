//
//  FetchData.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/08/27.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import Foundation
import Firebase

class FetchData{
    
    var memoArray = [Memo]()
    
    // UIDを取得し、ログインしているユーザーごとの作成したメモを表示する
    func FetchMemoData(){
        
        let ref = Database.database().reference().child("Textmemo").child(Auth.auth().currentUser!.uid).queryLimited(toLast: 100).observe(.value) { (snapShot) in
            
            
             if let snapShot = snapShot.children.allObjects as? [DataSnapshot]
             {
                               
                for snap in snapShot
                {
                    
                    if let memoData = snap.value as? [String:Any]
                    {
                        
                        let memoTitle = memoData["memoTitle"] as? String
                        let memoTextData = memoData["memoTextData"] as? String
                        
                        self.memoArray.append(Memo(textTitle: memoTitle!, textMemoData: memoTextData!))
                    }
                }
                               
            }
            
            }
            
        }
    
}
