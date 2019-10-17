//
//  PhotoPickerViewController.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/17/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

protocol PhotoSelectorDelegate: class {
    func photoSelectorDidSelect(_ photo: UIImage)
}

class PhotoPickerViewController: UIViewController {
    
    
    let imagePicker = UIImagePickerController()
    weak var delegate: PhotoSelectorDelegate?
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {

        let alert = UIAlertController(title: "Add a Photo", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Libaray", style: .default) { (_) in
            self.openGallery()
        }
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        present(alert, animated: true)
    }
}
extension PhotoPickerViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func  openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true)
        } else {
            // add alert controller to alert user that camera is unavailabe
        }
    }
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            delegate?.photoSelectorDidSelect(pickedImage)
            photoImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
