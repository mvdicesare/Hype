//
//  HypePhotoViewController.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/17/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class HypePhotoViewController: UIViewController {
    
    var image: UIImage?
    @IBOutlet weak var hypeBodyTextField: UITextField!
    @IBOutlet weak var photoContainerVIew: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let desinationVC = segue.destination as? PhotoPickerViewController
            desinationVC?.delegate = self
        }
       
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissView()
    }
    
    @IBAction func confirmedButtonTapped(_ sender: Any) {
        guard let text = hypeBodyTextField.text, !text.isEmpty,
            let image = image
            else { return }
        
        HypeController.shared.saveHype(with: text, photo: image) { (success) in
            if success {
                self.dismissView()
            }
        }
        
    }
    
    
    
    
    // MARK: - Helper func
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension HypePhotoViewController: PhotoSelectorDelegate {
    func photoSelectorDidSelect(_ photo: UIImage) {
        self.image = photo
    }
}
