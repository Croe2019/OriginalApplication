//
//  EditViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/10/04.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Photos

class EditViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var editTitleTextField: UITextField!
    @IBOutlet weak var editMemoBodyView: UITextView!
    @IBOutlet weak var editImageView: UIImageView!
    
    var memoTextTitleString = String()
    var memoTextBodyString = String()
    var editMemoImageString = String()
    var editMemoImageData = Data()
    
    var indexNumber = Int()
    // autoID格納配列
    var autoIDArray = [String]()
    
    let editSendToDB = EditSendToDB()
    var testArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.requestAuthorization { (status) in
            
            switch(status){
                
            case .authorized:
                print("許可されています")
            case .denied:
                print("拒否")
            case .notDetermined:
                print("notDetermined")
            case .restricted:
                print("restricted")
            case .limited:
                print("limited")
            @unknown default:
                return
            }
        }

        editTitleTextField.text = memoTextTitleString
        editMemoBodyView.text = memoTextBodyString
        editImageView.sd_setImage(with: URL(string: editMemoImageString), completed: nil)
        
        editTitleTextField.delegate = self
        editMemoBodyView.delegate = self
        
        storingToArray()

    }
    
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
    
    // 保存処理をする
    @IBAction func EditSave(_ sender: Any) {
        
        upDate()
        
        // 画面遷移 ホーム画面へ戻る
        let index = navigationController!.viewControllers.count - 3
        navigationController?.popToViewController(navigationController!.viewControllers[index], animated: true)
    }
    
    // テキスト、画像の編集処理
    // クラスで処理を記述した方が良いが、現在メモのIDをController側で保持している為Controllerで処理を記述する
    func upDate(){

        let textMemo = Memo(textTitle: editTitleTextField.text!, textMemoData: editMemoBodyView.text!)
        
        let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid)
        
        for autoID in autoIDArray{
            
            testArray.append(autoID)
            
        }
        
        let storage = Storage.storage().reference(forURL: "gs://originalapplication-f9c27.appspot.com")
        let imageKey = storage.child("MemoImage")
        let imageRef = storage.child("MemoImage").child("\(String(describing: imageKey)).jpeg")
        editMemoImageData = editImageView.image?.jpegData(compressionQuality: 0.01) as! Data
        
        imageRef.putData(editMemoImageData, metadata: nil){metadata, error in
            
            if(error != nil){
                print(error)
                return
            }
            
            imageRef.downloadURL { (url, error) in
                
                if(url != nil){
                    
                    ref.child(self.testArray[self.indexNumber]).setValue(["memoTitle": textMemo.GetTextTitle(), "memoBody": textMemo.GetTextMemoData(), "memoImage": url?.absoluteString])
                }
            }
            
        }
    }
    
    @IBAction func doCamera(_ sender: Any) {
        showAlert()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        editTitleTextField.resignFirstResponder()
        editMemoBodyView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        editTitleTextField.resignFirstResponder()
        editMemoBodyView.resignFirstResponder()
        return true
    }
    
    // カメラ立ち上げ
    func doCamera(){
        
        let sourceType:UIImagePickerController.SourceType = .camera
        
        // カメラが利用可能かをチェック
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
            
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func doAlbum(){
        
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        
        // カメラが利用可能かをチェック
        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func showAlert(){
        
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (alert) in
            
            self.doCamera()
        }
        
        let albumAction = UIAlertAction(title: "アルバム", style: .default) { (alert) in
            
            self.doAlbum()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 撮影が完了した時に呼ばれる (アルバムから画像が選択された時に呼ばれる)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedimage = info[.editedImage] as? UIImage{
            
            editImageView.image = pickedimage
            
            // 写真の保存
            UIImageWriteToSavedPhotosAlbum(pickedimage, self, nil, nil)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}
