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
import AVFoundation
import DKImagePickerController
import FanMenu
import Macaw

class CreateController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  AVAudioRecorderDelegate, UITabBarDelegate{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var createMenu: UITabBar!
    
    var recording = false
    // テストコード
    let dkImagePickerController = DKImagePickerController()
    let sendToDB = SendToDB()
    let textAndImageSend = TextAndImageSend()
    let sendOnlyText = SendOnlyText()
    let sendOnlyImage = SendOnlyImage()
    let sendOnlySound = SendOnlySound()
    
    let sendOnlyTitle = SendOnlyTitle()
    let sendOnlyMemoBody = SendOnlyMemoBody()
    let titleAndImageSend = TitleAndImageSend()
    let titleAndSoundSend = TitleAndSoundSend()
    let memoBodyAndImageSend = MemoBodyAndImage()
    let memoBodyAndSoundSend = MemoBodyAndSound()
    let imageAndSoundSend = ImageAndSoundSend()
   
    let soundRecord = SoundRecord()
    // 画像名を格納する変数
    var memoImageString:String = String()
    // 画像データを格納する変数
    var memoImageDataArray = [Data]()
    
    // テストコード
    var memoImageData = Data()
    var soundData = Data()
    
    // テストコード 画像を保存する配列
    var selectImageArray = [UIImage]()
    var indexNumberArray = [Int]()
    
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(sender:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(sender:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
        // 枠線の色を指定
        memoTextView.layer.borderColor = UIColor.link.cgColor
        // 横幅
        memoTextView.layer.borderWidth = 2.0
        
        // 角丸を設定
        memoTextView.layer.cornerRadius = 20.0
        memoTextView.layer.masksToBounds = true
        
        titleTextField.delegate = self
        createMenu.delegate = self
    }
    
    // キーボードが表示された時
    @objc private func keyboardWillShow(sender: NSNotification) {
        if memoTextView.isFirstResponder {
            guard let userInfo = sender.userInfo else { return }
            let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
            UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
                let transform = CGAffineTransform(translationX: 0, y: -150)
                self.view.transform = transform
            })
        }
    }

    // キーボードが閉じられた時
    @objc private func keyboardWillHide(sender: NSNotification) {
        guard let userInfo = sender.userInfo else { return }
        let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity
        })
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

        // 選択できる写真の最大数
        self.dkImagePickerController.maxSelectableCount = 1
        
        // カメラモード、写真モードの選択
        self.dkImagePickerController.sourceType = .photo
        
        // キャンセルボタンの有効か
        self.dkImagePickerController.showsCancelButton = true
        self.dkImagePickerController.didSelectAssets = {
            [unowned self] (assets: [DKAsset]) in
             
            //選択された画像はassetsに入れて返却されるのでfetchして取り出す
            for asset in assets {
                    asset.fetchFullScreenImage(true, completeBlock: { (image, info) in
                        guard let appendImage = image else{
                            return
                        }
                       // self.selectImageArray.append(appendImage)
                        // テスト用
                        memoImageView.image = appendImage
                        //memoCollectionView.reloadData()
                })
                
            }
            
        }
        self.present(dkImagePickerController, animated: true, completion: nil)
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

            memoImageView.image = pickedimage

            // 写真の保存
            UIImageWriteToSavedPhotosAlbum(pickedimage, self, nil, nil)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    // アラート
    func imagePickerControllerDidReachMaxLimit(_ imagePickerController: DKImagePickerController) {
            let alert = UIAlertController.init(title: "注意", message: "これ以上選択できません!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okAction)
            imagePickerController.present(alert, animated: true, completion: nil)
        }

    @IBAction func backHome(_ sender: Any) {
        
        // 画面遷移 ホーム画面へ戻る
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if(item.tag == 0){
            // カメラ、アルバムを選択する
            self.showAlert()
        }else if(item.tag == 1){
            
            // 音声を収録
            recording = true
            self.soundRecord.setUpAudioRecorder()
        }else if(item.tag == 2){
            
            // 送信処理を呼ぶ
            let textMemo = Memo(textTitle: titleTextField.text!, textMemoData: memoTextView.text!)
            
            // メモの各データが全てからの場合アラートを出す
            if(titleTextField.text!.isEmpty && memoTextView.text!.isEmpty && memoImageView.image == nil && recording == false){
                
                sendAlert()
            }
            
            if(titleTextField.text != "" && memoTextView.text != "" && memoImageView.image != nil && recording == true){
                
                self.memoImageData = self.memoImageView.image?.jpegData(compressionQuality: 0.01) as! Data
                self.sendToDB.Send(memoTitle: textMemo.GetTextTitle(), memoTextData: textMemo.GetTextMemoData(), memoImageString: self.memoImageString, memoImageData: self.memoImageData, localFile: self.soundRecord.getURL())
     
                // 画面遷移 ホーム画面へ戻る
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            else if(titleTextField.text != "" && memoTextView.text != "" && memoImageView.image != nil && recording == false){
                
                memoImageData = memoImageView.image?.jpegData(compressionQuality: 0.01) as! Data
                textAndImageSend.Send(memoTitle: textMemo.GetTextTitle(), memoTextData: textMemo.GetTextMemoData(), memoImageString: memoImageString, memoImageData: memoImageData)
                // 画面遷移 ホーム画面へ戻る
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            // テキストのみ送信
            else if(titleTextField.text != "" && memoTextView.text != "" && memoImageView.image == nil && recording == false){

                sendOnlyText.SendText(memoTitle: titleTextField.text!, memoTextData: memoTextView.text!)
                // 画面遷移 ホーム画面へ戻る
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            // 画像のみ送信 画像を圧縮
            else if(titleTextField.text == "" && memoTextView.text == "" && recording == false && memoImageView.image != nil){

                // テスト用
                memoImageData = memoImageView.image?.jpegData(compressionQuality: 0.01) as! Data
                sendOnlyImage.SendImage(memoImageData: memoImageData, memoImageString: memoImageString)
                // 画面遷移 ホーム画面へ戻る
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            else if(titleTextField.text == "" && memoTextView.text == "" && memoImageView.image == nil && recording == true){

                sendOnlySound.uploadSound(localFile: soundRecord.getURL())
                // 画面遷移 ホーム画面へ戻る
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            // タイトルのみ送信
            else if(titleTextField.text != "" && memoTextView.text == "" && memoImageView.image == nil && recording == false){
                
                sendOnlyTitle.SendText(memoTitle: titleTextField.text!)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            // メモの本文のみ送信
            else if(titleTextField.text == "" && memoTextView.text != "" && memoImageView.image == nil && recording == false){
                
                sendOnlyMemoBody.SendText(memoBody: memoTextView.text!)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            // タイトル、画像のみ送信
            else if(titleTextField.text != "" && memoTextView.text == "" && memoImageView.image != nil && recording == false){
                
                memoImageData = memoImageView.image?.jpegData(compressionQuality: 0.01) as! Data
                titleAndImageSend.Send(memoTitle: titleTextField.text!, memoImageString: memoImageString, memoImageData: memoImageData)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            // タイトル、音声のみ送信
            else if(titleTextField.text != "" && memoTextView.text == "" && memoImageView.image == nil && recording == true){
                
                titleAndSoundSend.uploadSound(memoTitle: titleTextField.text!, localFile: soundRecord.getURL())
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            // メモの本文、画像のみ送信
            else if(titleTextField.text == "" && memoTextView.text != "" && memoImageView.image != nil && recording == false){
                
                memoImageData = memoImageView.image?.jpegData(compressionQuality: 0.01) as! Data
                memoBodyAndImageSend.Send(memoBody: memoTextView.text!, memoImageString: memoImageString, memoImageData: memoImageData)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            // 本文、音声のみ送信
            else if(titleTextField.text == "" && memoTextView.text != "" && memoImageView.image == nil && recording == true){
                
                memoBodyAndSoundSend.uploadSound(memoBody: memoTextView.text!, localFile: soundRecord.getURL())
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            // 画像、音声のみ送信
            else if(titleTextField.text == "" && memoTextView.text == "" && memoImageView.image != nil && recording == true){
                
                memoImageData = memoImageView.image?.jpegData(compressionQuality: 0.01) as! Data
                imageAndSoundSend.Send(memoImageString: memoImageString, memoImageData: memoImageData, localFile: soundRecord.getURL())
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func sendAlert(){
        
        //アラート生成
        //UIAlertControllerのスタイルがalert
        let alert: UIAlertController = UIAlertController(title: "メモのデータがありません", message:  "最低でもタイトルを入れてください", preferredStyle:  UIAlertController.Style.alert)
        // 確定ボタンの処理
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // 確定ボタンが押された時の処理をクロージャ実装する
            (action: UIAlertAction!) -> Void in
            //実際の処理
            print("OK")
        })
        // キャンセルボタンの処理
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // キャンセルボタンが押された時の処理をクロージャ実装する
            (action: UIAlertAction!) -> Void in
            //実際の処理
            print("キャンセル")
        })

        //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        //実際にAlertを表示する
        present(alert, animated: true, completion: nil)
    }
}
