//
//  ProfileViewTableViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/19/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD

class ProfileViewTableViewController: UITableViewController {

    @IBOutlet weak var orgCell: UITableViewCell!
    @IBOutlet weak var orgView: UIView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var messageButtonOutlet: UIButton!
    
    @IBOutlet weak var callButtonOutlet: UIButton!
    
    @IBOutlet weak var blockUserButton: UIButton!
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var orgNameLabel: UILabel!
    
    var user: FUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Got here!")
        setupUI()
    }

    @IBAction func callButtonPressed(_ sender: Any) {
        let currentUser = FUser.currentUser()!
        let call = CallClass(_callerId: currentUser.objectId, _withUserId: user!.objectId, _callerFullName: currentUser.fullname, _withUserFullName: user!.fullname)
        call.saveCallInBackground()
        callButtonOutlet.isEnabled = false
        let busPhone = phoneNumberLabel.text!
        if let url = URL(string: "tel://\(busPhone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        if !checkBlockedStatus(withUser: user!) {
            let chatVC = ChatViewController()
            chatVC.titleName = user!.firstname
            chatVC.membersToPush = [FUser.currentId(), user!.objectId]
            chatVC.memberIds = [FUser.currentId(), user!.objectId]
            chatVC.chatroomId = startPrivateChat(user1: FUser.currentUser()!, user2: user!)
            chatVC.isGroup = false
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
        } else {
            ProgressHUD.showError("This user is not available for chat")
        }
        
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
        
        blockUser(userToBlock: user!)
    }
    
    @IBAction func reportUserButtonPressed(_ sender: Any) {
        reference(.Reporteduser).document(user!.objectId).setData(["reporter": FUser.currentId(), "userId": user!.objectId, "reason" : "reason", "date" : dateFormatter().string(from: Date())])
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return 3
        }
        return 2
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
            orgNameLabel.text = ""
            teamNameLabel.text = ""
            for org in user!.organizations {
                orgNameLabel.text! += "\(org)\n"
            }
            for team in user!.teams {
                teamNameLabel.text! += "\(team)\n"
            }
            if teamNameLabel.text == "" {
                teamNameLabel.text = "None"
            }
            if orgNameLabel.text == "" {
                orgNameLabel.text = "None"
            }
            orgNameLabel.numberOfLines = 0
            orgNameLabel.sizeToFit()
            teamNameLabel.numberOfLines = 0
            teamNameLabel.sizeToFit()
            orgNameLabel.center.y = orgView.center.y
            updateBlockStatus()
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            return max(CGFloat((user?.organizations.count)! * 40),60)
        }
        if indexPath.section == 1 && indexPath.row == 2 {
            return max(60,CGFloat((user?.teams.count)! * 40))
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            return 75
        }
        return 45
        
    }
    
    func updateBlockStatus() {
        if user!.objectId != FUser.currentId() {
            blockUserButton.isHidden = false
            messageButtonOutlet.isHidden = false
            callButtonOutlet.isHidden = false
        } else {
            blockUserButton.isHidden = true
            messageButtonOutlet.isHidden = true
            callButtonOutlet.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockUserButton.setTitle("Unblock User", for: .normal)
        } else {
            blockUserButton.setTitle("Block User", for: .normal)
        }
    }
}
