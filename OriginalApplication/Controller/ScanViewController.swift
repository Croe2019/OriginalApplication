//
//  ScanViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/02/25.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import UIKit
import Firebase

class ScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var recognizedTextView: UITextView!
    @IBOutlet weak var scanImage: UIImageView!
    @IBOutlet weak var scanMenu: UITabBar!
    
    private var scanImageData = Data()
    // 画像名を格納する変数
    var memoImageString:String = String()
    var recording = false
    let sendToDB = SendToDB()
    let soundRecord = SoundRecord()
    var sendText = TextAndImageSend()
    var imageAndMemoBody = ScanImageAndMemoBodySend()

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        scanMenu.delegate = self
    }
    
    @IBAction func back(_ sender: Any) {
        // 画面遷移 ホーム画面へ戻る
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // キーボードが表示された時
    @objc private func keyboardWillShow(sender: NSNotification) {
        if recognizedTextView.isFirstResponder {
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
    
    // カメラ立ち上げ
    func doCamera(){

        let sourceType:UIImagePickerController.SourceType = .camera

        // カメラが利用可能かをチェック
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){

            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = .camera
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }

    func doAlbum(){

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else{
            return
        }
        
        scanImage.image = image
        self.recognizeTextInCloud(in: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // テキスト認識 このコントローラーのみでの記述(他のControllerで使用しない為)
    private func recognizeTextInCloud(in image: UIImage){
        
        let metadata = VisionImageMetadata()
        metadata.orientation = .rightTop
        
        // 撮影した写真のデータを入れる
        let visionImage = VisionImage(image: image)
        visionImage.metadata = metadata
        
        let options = VisionCloudTextRecognizerOptions()
        // 日本語と英語を読み込む
        options.languageHints = ["ja", "en"]
        
        // クラウドベースでテキスト認識するためのインスタンスを生成
        let cloudTextRecognizer = Vision.vision().cloudTextRecognizer(options: options)
        
        // 生成したインスタンスで画像から文字認識を行う
        cloudTextRecognizer.process(visionImage) { text, error in
            guard error == nil, let text = text else {
                print("Text recognizer failed with error: " + "\(error?.localizedDescription ?? "No Results")")
                return
            }
            
            self.recognizedTextView.text = text.text
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        titleTextField.resignFirstResponder()
        recognizedTextView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        titleTextField.resignFirstResponder()
        recognizedTextView.resignFirstResponder()
        return true
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
         
            if(titleTextField.text != "" && recognizedTextView.text != "" && scanImage.image != nil && recording == true){
                
                self.scanImageData = self.scanImage.image?.jpegData(compressionQuality: 0.01) as! Data
                self.sendToDB.Send(memoTitle: titleTextField.text!, memoTextData: recognizedTextView.text!, memoImageString: memoImageString, memoImageData: scanImageData, localFile: self.soundRecord.getURL())
                // 画面遷移 ホーム画面へ戻る
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }else if(titleTextField.text != "" && recognizedTextView.text != "" && scanImage.image != nil && recording == false){
                
                scanImageData = scanImage.image?.jpegData(compressionQuality: 0.01) as! Data
                sendText.Send(memoTitle: titleTextField.text!, memoTextData: recognizedTextView.text!, memoImageString: memoImageString, memoImageData: scanImageData)
                // 画面遷移 ホーム画面へ戻る
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            else if(titleTextField.text == "" && recognizedTextView.text != "" && scanImage.image != nil && recording == false){
                
                scanImageData = scanImage.image?.jpegData(compressionQuality: 0.01) as! Data
                imageAndMemoBody.Send(memoTextData: recognizedTextView.text!, memoImageString: memoImageString, memoImageData: scanImageData)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            else if(scanImage.image == nil){
                
                //アラート生成
                //UIAlertControllerのスタイルがalert
                let alert: UIAlertController = UIAlertController(title: "解析するデータがありません", message:  "解析したい写真を撮影、選択してください", preferredStyle:  UIAlertController.Style.alert)
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
    }
}
