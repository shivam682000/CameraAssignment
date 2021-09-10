//
//  ViewController.swift
//  CameraAssignment
//
//  Created by shivam kumar on 06/09/21.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController {
    
    @IBOutlet var image1 : UIImageView!
    @IBOutlet var button1 : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button1.backgroundColor = .blue
        
        image1.layer.cornerRadius = 20
        button1.layer.cornerRadius = 20
        button1.setTitleColor(.white, for: .normal)
    }
    
    func savedImage() {
        
        if (image1.image == nil) {
            let alert = UIAlertController(title: SELECT_IMAGE, message: SELECT_IMAGE, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: OK, style: .default, handler: nil)
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let imageData = image1.image!.pngData()
            let compressedImage = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
            let alert = UIAlertController(title: SAVED, message: YOUR_IMAGE_HAS_BEEN_SAVED, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: OK, style: .default, handler: nil)
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
@IBAction func checkPhotoLibraryPermission() {
    
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
        self.savedImage()
        break
    case .denied, .restricted :
        presentCameraSettings()
        break
    case .notDetermined:
        PHPhotoLibrary.requestAuthorization { status in
                        switch status {
                        case .authorized:
                            DispatchQueue.main.async {
                                self.savedImage()
                            }
                            break
                        
                        case .denied, .restricted:
                            self.presentCameraSettings()
                            break
                        case .notDetermined:
                            break
                        
                        default:
                            break
                        }
                    }
        break
    default:
        break
    }
}

func callCamera() {
    let picker = UIImagePickerController()
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
}

func presentCameraSettings() {
    let alert = UIAlertController(title: ERROR, message: ACESS_DENIED, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: CANCEL, style: .default))
    alert.addAction(UIAlertAction(title: SETTING, style: .cancel) { _ in
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: {
                _ in
            })
        }
    })
    self.present(alert, animated: true, completion: nil)
}

func checkCameraPermission() {
    let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
    switch authStatus {
    case .denied:
        self.presentCameraSettings()
        break
    case .restricted:
       break
    case .authorized:
        self.callCamera()
        break
    case .notDetermined:
        
        AVCaptureDevice.requestAccess(for: .video) { (success) in
            if success{
                DispatchQueue.main.async {
                    self.callCamera()
                }
            }else{
                print(GRANTED)
            }
        }
        break
    default:
        break
    }
}

@IBAction func didTapButton() {
    self.checkCameraPermission()
    }

}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image2 = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        image1.image = image2
    }
}

