//
//  SignInViewController.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/16/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//


// TODO - FetchUser, If it exists prsent the tableview
//TODO - implement our create user method when that fires and completes successlly present the table view


import UIKit

class SignInViewController: UIViewController {
    var image: UIImage?
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUser()
    }
    

    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text,
            !username.isEmpty else {return}
        UserController.shared.createUserWith(username: username, profilePhoto: image) { (success) in
            if success {
                self.showHypeListViewController()
            }
        }
    }
    // MARK: -  Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
    
    // MARK: - Class methods
    func fetchUser(){
        UserController.shared.fetchUser { (success) in
            if success {
                self.showHypeListViewController()
            }
        }
    }
    func showHypeListViewController() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let vc = storyboard.instantiateInitialViewController()
                else { return }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
}

extension SignInViewController: PhotoSelectorDelegate {
    func photoSelectorDidSelect(_ photo: UIImage) {
        image = photo
    }
    

}
