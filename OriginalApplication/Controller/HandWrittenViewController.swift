//
//  HandWrittenViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/02/15.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import UIKit
import NXDrawKit
import RSKImageCropper
import AVFoundation
import MobileCoreServices

// 手書きでメモを作成するコントローラー
class HandWrittenViewController: UIViewController, CanvasDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, PaletteDelegate{
    
    weak var canvasView: Canvas?
    weak var paletteView: Palette?
    weak var toolBar: ToolBar?
    weak var bottomView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
    private func initialize() {
        self.setupCanvas()
        self.setupPalette()
        self.setupToolBar()
    }
    
    override func viewWillLayoutSubviews() {
        let topMargin = UIApplication.shared.topSafeAreaMargin() + 50
        let leftMargin = UIApplication.shared.leftSafeAreaMargin() + 20
        let rightMargin = UIApplication.shared.rightSafeAreaMargin() + 20
        let bottomMargin = UIApplication.shared.bottomSafeAreaMargin()
        let width = view.frame.width
        let height = view.frame.height
        
        self.canvasView?.frame = CGRect(x: leftMargin,
                                        y: topMargin,
                                        width: width - (leftMargin + rightMargin),
                                        height: width - (leftMargin + rightMargin))
        
        guard let paletteView = self.paletteView else {
            return
        }
        
        let paletteHeight = paletteView.paletteHeight()
        paletteView.frame = CGRect(x: 0,
                                   y: height - (paletteHeight + bottomMargin),
                                   width: width,
                                   height: paletteHeight)
        
        
        let toolBarHeight = paletteHeight * 0.25
        let startY = paletteView.frame.minY - toolBarHeight
        self.toolBar?.frame = CGRect(x: 0, y: startY, width: width, height: toolBarHeight)
        
        self.bottomView?.frame = CGRect(x: 0, y: paletteView.frame.maxY, width: width, height: bottomMargin)
    }
    
    private func setupPalette() {
        self.view.backgroundColor = UIColor.white
        
        let paletteView = Palette()
        paletteView.delegate = self
        paletteView.setup()
        self.view.addSubview(paletteView)
        self.paletteView = paletteView
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.21, alpha: 1.0)
        self.view.addSubview(bottomView)
        self.bottomView = bottomView
    }
    
    private func setupToolBar() {
        let toolBar = ToolBar()
        toolBar.undoButton?.addTarget(self, action: #selector(HandWrittenViewController.onClickUndoButton), for: .touchUpInside)
        toolBar.redoButton?.addTarget(self, action: #selector(HandWrittenViewController.onClickRedoButton), for: .touchUpInside)
        toolBar.loadButton?.addTarget(self, action: #selector(HandWrittenViewController.onClickLoadButton), for: .touchUpInside)
        toolBar.saveButton?.addTarget(self, action: #selector(HandWrittenViewController.onClickSaveButton), for: .touchUpInside)
        toolBar.saveButton?.setTitle("share", for: UIControl.State())   // default title is "Save"
        toolBar.clearButton?.addTarget(self, action: #selector(HandWrittenViewController.onClickClearButton), for: .touchUpInside)
        toolBar.loadButton?.isEnabled = true
        self.view.addSubview(toolBar)
        self.toolBar = toolBar
    }
    
    private func setupCanvas() {
        let canvasView = Canvas()
        canvasView.delegate = self
        canvasView.layer.borderColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 0.8).cgColor
        canvasView.layer.borderWidth = 2.0
        canvasView.layer.cornerRadius = 5.0
        canvasView.clipsToBounds = true
        self.view.addSubview(canvasView)
        self.canvasView = canvasView
    }
    
    private func updateToolBarButtonStatus(_ canvas: Canvas) {
        self.toolBar?.undoButton?.isEnabled = canvas.canUndo()
        self.toolBar?.redoButton?.isEnabled = canvas.canRedo()
        self.toolBar?.saveButton?.isEnabled = canvas.canSave()
        self.toolBar?.clearButton?.isEnabled = canvas.canClear()
    }
    
    @objc func onClickUndoButton() {
        self.canvasView?.undo()
    }
    
    @objc func onClickRedoButton() {
        self.canvasView?.redo()
    }
    
    @objc func onClickLoadButton() {
        self.showActionSheetForPhotoSelection()
    }
    
    @objc func onClickSaveButton() {
        self.canvasView?.save()
    }
    
    @objc func onClickClearButton() {
        self.canvasView?.clear()
    }
    
    // 写真選択
    private func showActionSheetForPhotoSelection() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Photo from Album", "Take a Photo")
        actionSheet.show(in: self.view)
    }
    
    private func showPhotoLibrary () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [String(kUTTypeImage)]
        
        self.present(picker, animated: true, completion: nil)
    }
    
    private func showCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch (status) {
        case .notDetermined:
            self.presentImagePickerController()
        case .restricted, .denied:
            self.showAlertForImagePickerPermission()
        case .authorized:
            self.presentImagePickerController()
        default:
            return
        }
    }
    
    private func showAlertForImagePickerPermission() {
            let message = "If you want to use camera, you should allow app to use.\nPlease check your permission"
            let alert = UIAlertView(title: "", message: message, delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Allow")
            alert.show()
        }
        
        private func openSettings() {
            let url = URL(string: UIApplication.openSettingsURLString)
            UIApplication.shared.openURL(url!)
        }
        
        private func presentImagePickerController() {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .camera
                picker.mediaTypes = [String(kUTTypeImage)]
                self.present(picker, animated: true, completion: nil)
            } else {
                let message = "This device doesn't support a camera"
                let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
                alert.show()
            }
        }
    
    func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo:UnsafeRawPointer)       {
        if didFinishSavingWithError != nil {
            let message = "Saving failed"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        } else {
            let message = "Saved successfuly"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        }
    }
    
    func brush() -> Brush? {
        return self.paletteView?.currentBrush()
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
        self.updateToolBarButtonStatus(canvas)
    }
    
    func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?) {
        
        if let pngImage = image?.asPNGImage() {
            let activityViewController = UIActivityViewController(activityItems: [pngImage], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    // User canceled
                    return
                }
                
                if activityType == UIActivity.ActivityType.saveToCameraRoll {
                    let alert = UIAlertController(title: nil, message: "Image is saved successfully", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let type = info[UIImagePickerController.InfoKey.mediaType]
        if type as? String != String(kUTTypeImage) {
            return
        }
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }

        picker.dismiss(animated: true, completion: { [weak self] in
            let cropper = RSKImageCropViewController(image:selectedImage, cropMode:.square)
            cropper.delegate = self as! RSKImageCropViewControllerDelegate
            self?.present(cropper, animated: true, completion: nil)
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.canvasView?.update(croppedImage)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if (actionSheet.cancelButtonIndex == buttonIndex) {
            return
        }
        
        if buttonIndex == 1 {
            self.showPhotoLibrary()
        } else if buttonIndex == 2 {
            self.showCamera()
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            return
        } else {
            self.openSettings()
        }
    }
    
    func colorWithTag(_ tag: NSInteger) -> UIColor? {
        if tag == 4 {
            // if you return clearColor, it will be eraser
            return UIColor.clear
        }
        return nil
    }
}


// MARK: - SafeArea Extension
extension UIApplication {
    public func topSafeAreaMargin() -> CGFloat {
        var topMargin: CGFloat = 0
        if #available(iOS 11.0, *), let topInset = keyWindow?.safeAreaInsets.top {
            topMargin = topInset
        }
        
        return topMargin
    }
    
    public func bottomSafeAreaMargin() -> CGFloat {
        var bottomMargin: CGFloat = 0
        if #available(iOS 11.0, *), let bottomInset = keyWindow?.safeAreaInsets.bottom {
            bottomMargin = bottomInset
        }
        
        return bottomMargin
    }
    
    public func leftSafeAreaMargin() -> CGFloat {
        var leftMargin: CGFloat = 0
        if #available(iOS 11.0, *), let leftInset = keyWindow?.safeAreaInsets.left {
            leftMargin = leftInset
        }
        
        return leftMargin
    }
    
    public func rightSafeAreaMargin() -> CGFloat {
        var rightMargin: CGFloat = 0
        if #available(iOS 11.0, *), let rightInset = keyWindow?.safeAreaInsets.right {
            rightMargin = rightInset
        }
        
        return rightMargin
    }
    
    public func safeAreaSideMargin() -> CGFloat {
        return leftSafeAreaMargin() + rightSafeAreaMargin()
    }
}

