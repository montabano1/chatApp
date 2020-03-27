//
//  ProfileViewTableViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/19/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit

class ProfileViewTableViewController: UITableViewController {

    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var messageButtonOutlet: UIButton!
    
    @IBOutlet weak var callButtonOutlet: UIButton!
    
    @IBOutlet weak var blockButtonOutlet: UIButton!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var user: FUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction func callButtonPressed(_ sender: Any) {
        print("call user \(user!.fullname)")
    }
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        print("chat with user \(user!.fullname)")
    }
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        if currentBlockedIds.contains(user!.objectId) {
            let index = currentBlockedIds.firstIndex(of: user!.objectId)
            currentBlockedIds.remove(at: index!)
        } else {
            currentBlockedIds.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIds]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            self.updateBlockStatus()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return 30
    }
    
    func setupUI() {
        if user != nil {
            self.title = "Profile"
            fullNameLabel.text = user!.fullname
            phoneNumberLabel.text = user!.phoneNumber
            
            updateBlockStatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    func updateBlockStatus() {
        if user!.objectId != FUser.currentId() {
            blockButtonOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
            callButtonOutlet.isHidden = false
        } else {
            blockButtonOutlet.isHidden = true
            messageButtonOutlet.isHidden = true
            callButtonOutlet.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockButtonOutlet.setTitle("Unblock User", for: .normal)
        } else {
            blockButtonOutlet.setTitle("Block User", for: .normal)
        }
    }
}
