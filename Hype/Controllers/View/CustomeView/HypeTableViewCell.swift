//
//  HypeTableViewCell.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/17/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class HypeTableViewCell: UITableViewCell {
    
    
    var hype: Hype? {
        didSet {
            updateViews()
        }
    }
    
    
    
    @IBOutlet weak var hypeImageVIew: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var hypeBodyLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpViews()
        // Initialization code
    }
    func updateViews() {
        guard let hype = hype else {return}
        updateUser(for: hype)
        setImageView(for: hype)
        hypeBodyLabel.text = hype.body
        timestampLabel.text = hype.timestamp.formatDate()
    }
    func setUpViews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.contentMode = .scaleAspectFit
        hypeImageVIew.layer.cornerRadius = hypeImageVIew.frame.height / 10
        hypeImageVIew.contentMode = .scaleAspectFit
    }
    
    func updateUser(for hype: Hype) {
        if hype.user == nil {
            UserController.shared.fetchUserFor(hype) {
                (user) in
                guard let user = user else { return }
                hype.user = user
                self.setUserInfo(for: user)
            }
        } else {
            setUserInfo(for: hype.user!)
        }
    }
    func setUserInfo(for user: User) {
        DispatchQueue.main.async {
            self.profileImageView.image = user.profilePhoto
            self.usernameLabel.text = user.username
        }
    }
    func setImageView(for hype: Hype) {
        if let hypeImage = hype.hypePhoto {
            hypeImageVIew.image = hypeImage
            hypeImageVIew.isHidden = false
        } else {
            hypeImageVIew.isHidden = true
        }
    }
    
}
