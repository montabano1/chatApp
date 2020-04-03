//
//  NewGroupViewController.swift
//  monTalk
//
//  Created by michael montalbano on 3/31/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD

class NewGroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GroupMemberCollectionViewDelegate {

    @IBOutlet weak var editAvatarButton: UIButton!
    @IBOutlet weak var groupIconImageView: UIImageView!
    @IBOutlet weak var groupSubject: UITextField!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var subGroupSubject: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var tapper: UITapGestureRecognizer!
    
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    var groupIcon: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        groupIconImageView.isUserInteractionEnabled = true
        groupIconImageView.addGestureRecognizer(tapper)
        
        updateParticipantsLabel()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GroupMemberCollectionViewCell
        cell.delegate = self
        cell.generateCell(user: allMembers[indexPath.row], indexPath: indexPath)
        
        return cell
    }
    
    @objc func createButtonPressed(_ sender: Any) {
        if groupSubject.text != "" {
            memberIds.append(FUser.currentId())
            let avatarData = UIImage(named: "groupIcon")!.jpegData(compressionQuality: 0.7)!
            var avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            if groupIcon != nil {
                let avatarData = groupIcon!.jpegData(compressionQuality: 0.7)!
                avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
            
            let groupId = UUID().uuidString
            
            let group = Group(groupId: groupId, subject: groupSubject.text!, ownerId: FUser.currentId(), members: memberIds, avatar: avatar)
            
            group.saveGroup()
            
            startGroupChat(group: group)
            
            let chatVC = ChatViewController()
            chatVC.titleName = group.groupDictionary[kNAME] as? String
            chatVC.memberIds = group.groupDictionary[kMEMBERS] as? [String]
            chatVC.membersToPush = group.groupDictionary[kMEMBERS] as? [String]
            
            chatVC.chatroomId = groupId
            chatVC.isGroup = true
            chatVC.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(chatVC, animated: true)
            
        } else {
            ProgressHUD.showError("Subject is required")
        }
    }
    
    @IBAction func groupAvatarPressed(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func editIconTapped(_ sender: Any) {
        showIconOptions()
    }
    
    func showIconOptions() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take/Choose Photo", style: .default) { (alert) in
            print("camera")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        if groupIcon != nil {
            let resetAction = UIAlertAction(title: "Reset", style: .default) { (alert) in
                self.groupIcon = nil
                self.groupIconImageView.image   = UIImage(named: "cameraIcon")
                self.editAvatarButton.isHidden = true
            }
            optionMenu.addAction(resetAction)
        }
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let currentPopoverpresentationcontroller = optionMenu.popoverPresentationController {
                currentPopoverpresentationcontroller.sourceView = editAvatarButton
                currentPopoverpresentationcontroller.sourceRect = editAvatarButton.bounds
                
                currentPopoverpresentationcontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
        
    }
    func didClickDeleteButton(indexPath: IndexPath) {
        allMembers.remove(at: indexPath.row)
        memberIds.remove(at: indexPath.row)
        
        collectionView.reloadData()
        updateParticipantsLabel()
    }
    
    func updateParticipantsLabel() {
        participantsLabel.text = "PARTICIPANTS: \(allMembers.count)"
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(self.createButtonPressed))]
    
        self.navigationItem.rightBarButtonItem?.isEnabled = allMembers.count > 0
    }
    
    

}
