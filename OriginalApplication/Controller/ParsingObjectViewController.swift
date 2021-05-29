//
//  ParsingObjectViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/05/23.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Firebase

class ParsingObjectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var menuBar: UITabBar!
    
    var recording = false
    let sendToDB = SendToDB()
    let soundRecord = SoundRecord()
    var sendText = TextAndImageSend()
    var imageAndMemoBody = ScanImageAndMemoBodySend()
    // 画像名を格納する変数
    var memoImageString:String = String()
    private var scanImageData = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menuBar.delegate = self
        
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
    }
    
    // キーボードが表示された時
    @objc private func keyboardWillShow(sender: NSNotification) {
        if textView.isFirstResponder {
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
        
        imageView.image = image
        // 画像からオブジェクトを検出し、出力
        detectImageObject(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // 英語を翻訳するメソッド
    func translator(){
        
        // 対象となる言語と、翻訳先言語を指定し、Translatorオブジェクトを作成
        let options = TranslatorOptions(sourceLanguage: .en, targetLanguage: .ja)
        let translator = NaturalLanguage.naturalLanguage().translator(options: options)
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: true, allowsBackgroundDownloading: true
        )
        
        // モデルがローカルのなければダウンロード
        translator.downloadModelIfNeeded(with: conditions) { error in
            //guard let sSelf = self else { return }
            if let error = error{
                
                print(error)
                return
            }
            
            // Modelがダウンロード済みであれば翻訳
            translator.translate(self.titleTextField.text!) { translatedText, error in
                
                guard error == nil, let translatedText = translatedText else{
                    print(error)
                    return
                }
                self.titleTextField.text! = translatedText
            }
        }
    }
    
    // 画像からオブジェクトを検出、結果を出力
    func detectImageObject(image: UIImage){
        
        // 使用するモデルを入れる
        guard let ciImage = CIImage(image: image), let model = try? VNCoreMLModel(for: MobileNetV2().model) else{
            return
        }
        
        // CoreMLモデルを使用して画像を処理する画像解析リクエスト
        let request = VNCoreMLRequest(model: model){ (request, error) in
            
            // 解析結果を分類情報として保存
            guard let results = request.results as? [VNClassificationObservation] else{
                return
            }
            
            // 画像内の一番割合が大きいオブジェクトを出力する
            if let firstResult = results.first{
                
                let objectArray = firstResult.identifier.components(separatedBy: ",")
                // 検出結果をtitleTextFieldに入れる
                if(objectArray.count == 1){
                    self.translator()
                    self.titleTextField.text! = firstResult.identifier
                }else{
                    self.translator()
                    self.titleTextField.text! = objectArray.first!
                }
            }
        }
        
        // 画像解析をリクエスト
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        // リクエストを実行
        do{
            try handler.perform([request])
        }
        catch{
            print(error)
        }
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
         
            if(titleTextField.text != "" && textView.text != "" && imageView.image != nil && recording == true){
                
                self.scanImageData = self.imageView.image?.jpegData(compressionQuality: 0.01) as! Data
                self.sendToDB.Send(memoTitle: titleTextField.text!, memoTextData: textView.text!, memoImageString: memoImageString, memoImageData: scanImageData, localFile: self.soundRecord.getURL())
                // 画面遷移 ホーム画面へ戻る
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }else if(titleTextField.text != "" && textView.text != "" && imageView.image != nil && recording == false){
                
                scanImageData = imageView.image?.jpegData(compressionQuality: 0.01) as! Data
                sendText.Send(memoTitle: titleTextField.text!, memoTextData: textView.text!, memoImageString: memoImageString, memoImageData: scanImageData)
                // 画面遷移 ホーム画面へ戻る
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            else if(titleTextField.text == "" && textView.text != "" && imageView.image != nil && recording == false){
                
                scanImageData = imageView.image?.jpegData(compressionQuality: 0.01) as! Data
                imageAndMemoBody.Send(memoTextData: textView.text!, memoImageString: memoImageString, memoImageData: scanImageData)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            else if(imageView.image == nil){
                
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        titleTextField.resignFirstResponder()
        textView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        titleTextField.resignFirstResponder()
        textView.resignFirstResponder()
        return true
    }
    
    @IBAction func Back(_ sender: Any) {
        // 画面遷移 ホーム画面へ戻る
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
