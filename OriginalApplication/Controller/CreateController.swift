//
//  CreateController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/08/01.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit
import Photos
import SDWebImage
import Firebase
import DKImagePickerController

class CreateController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var memoCollectionView: UICollectionView!
    
    // テストコード
    let dkImagePickerController = DKImagePickerController()
    let sendToDB = SendToDB()
    // 画像名を格納する変数
    var memoImageString:String = String()
    // 画像データを格納する変数
    var memoImageData = Data()
    
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
        

        // 枠線の色を指定
        memoTextView.layer.borderColor = UIColor.link.cgColor
        // 横幅
        memoTextView.layer.borderWidth = 2.0
        
        // 角丸を設定
        memoTextView.layer.cornerRadius = 20.0
        memoTextView.layer.masksToBounds = true
        
        titleTextField.delegate = self
        memoCollectionView.delegate = self
        memoCollectionView.dataSource = self
    }

    
    @IBAction func PostAction(_ sender: Any) {
        
        let textMemo = Memo(textTitle: titleTextField.text!, textMemoData: memoTextView.text!)

        // テキスト、画像の両方を送信
        if(titleTextField.text != "" && memoTextView.text != "" && memoImageView.image != nil){

            memoImageData = memoImageView.image?.jpegData(compressionQuality: 0.01) as! Data
            sendToDB.Send(memoTitle: textMemo.GetTextTitle(), memoTextData: textMemo.GetTextMemoData(), memoImageString: memoImageString, memoImageData: memoImageData)
        }
        // テキストのみ送信
        else if(titleTextField.text != "" || memoTextView.text != ""){

            sendToDB.SendText(memoTitle: textMemo.GetTextTitle(), memoTextData: textMemo.GetTextMemoData())
        }
        // 画像のみ送信 画像を圧縮
        else if(memoImageView.image != nil){

            memoImageData = memoImageView.image?.jpegData(compressionQuality: 0.01) as! Data
            sendToDB.SendImage(memoImageData: memoImageData, memoImageString: memoImageString)
        }
    
        // 画面遷移
        dismiss(animated: true, completion: nil)
        // 画面遷移 ホーム画面へ戻る
//        let index = navigationController!.viewControllers.count - 2
//        navigationController?.popToViewController(navigationController!.viewControllers[index], animated: true)
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        titleTextField.resignFirstResponder()
        memoTextView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        titleTextField.resignFirstResponder()
        memoTextView.resignFirstResponder()
        return true
    }
    
    
    @IBAction func cameraAction(_ sender: Any) {
        
        // カメラ or アクションシート
        //showAlert()
        // 選択できる写真の最大数
        self.dkImagePickerController.maxSelectableCount = 5
        
        // カメラモード、写真モードの選択
        self.dkImagePickerController.sourceType = .photo
        
        // キャンセルボタンの有効か
        self.dkImagePickerController.showsCancelButton = true
        self.dkImagePickerController.didSelectAssets = {
            [unowned self] (assets: [DKAsset]) in
             
            //選択された画像はassetsに入れて返却されますのでfetchして取り出すとよいでしょう
            for asset in assets {
                    asset.fetchFullScreenImage(true, completeBlock: { (image, info) in
                        self.memoImageView.image = image
                })
            }
        }
        self.present(dkImagePickerController, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // 要素数を入れる
        return self.dkImagePickerController.maxSelectableCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // ストーリーボードで設定したID
        let cell = memoCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        // ここでCollectionViewに画像を入れれば良いか？
        
        return cell
    }
    
    // カメラ立ち上げ
//    func doCamera(){
//
//        let sourceType:UIImagePickerController.SourceType = .camera
//
//        // カメラが利用可能かをチェック
//        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
//
//            let cameraPicker = UIImagePickerController()
//            cameraPicker.allowsEditing = true
//            cameraPicker.sourceType = sourceType
//            cameraPicker.delegate = self
//            self.present(cameraPicker, animated: true, completion: nil)
//        }
//    }
//
//    func doAlbum(){
//
//        let sourceType:UIImagePickerController.SourceType = .photoLibrary
//
//        // カメラが利用可能かをチェック
//        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
//
//            let cameraPicker = UIImagePickerController()
//            cameraPicker.allowsEditing = true
//            cameraPicker.sourceType = sourceType
//            cameraPicker.delegate = self
//            self.present(cameraPicker, animated: true, completion: nil)
//        }
//    }
//
//    func showAlert(){
//
//        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか", preferredStyle: .actionSheet)
//
//        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (alert) in
//
//            self.doCamera()
//        }
//
//        let albumAction = UIAlertAction(title: "アルバム", style: .default) { (alert) in
//
//            self.doAlbum()
//        }
//
//        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
//
//        alertController.addAction(cameraAction)
//        alertController.addAction(albumAction)
//        alertController.addAction(cancelAction)
//        self.present(alertController, animated: true, completion: nil)
//    }
//
//    // 撮影が完了した時に呼ばれる (アルバムから画像が選択された時に呼ばれる)
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        if let pickedimage = info[.editedImage] as? UIImage{
//
//            memoImageView.image = pickedimage
//
//            // 写真の保存
//            UIImageWriteToSavedPhotosAlbum(pickedimage, self, nil, nil)
//            picker.dismiss(animated: true, completion: nil)
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//
//        picker.dismiss(animated: true, completion: nil)
//    }
    
    
    @IBAction func backHome(_ sender: Any) {
        
        // 画面遷移 ホーム画面へ戻る
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
