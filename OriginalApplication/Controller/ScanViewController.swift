//
//  ScanViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/02/25.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DoneCatchProtocol {
    
    
    
    @IBOutlet weak var scanImag: UIImageView!
    @IBOutlet weak var scanText: UILabel!
    
    private var scanImageData = Data()
    // 最後にapiKeyを入れる
    let apiKey = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectScan(_ sender: Any) {
        
        showAlert()
        
    }
    
    
    @IBAction func analytics(_ sender: Any) {
        
        // 通信を行う
        if(scanImag.image != nil){
            
            scanImageData = scanImag.image?.jpegData(compressionQuality: 0.01) as! Data
            var googleURL = "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"
            let analytics = Analysis(imageData: scanImageData, scanTextString: scanText.text!, urlString: googleURL)
            analytics.doneCatchProtocol = self
            analytics.setData()
        }
    }
    
    func catchData(scanTextString: String) {
        
        scanText.text = scanTextString
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
        
        if let pickedimage = info[.originalImage] as? UIImage{

            scanImag.image = pickedimage

            // 写真の保存
            UIImageWriteToSavedPhotosAlbum(pickedimage, self, nil, nil)
            picker.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
