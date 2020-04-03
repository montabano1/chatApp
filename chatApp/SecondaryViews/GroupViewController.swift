//
//  GroupViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/1/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD

class GroupViewController: UIViewController {

    
    @IBOutlet weak var cameraButtonOutlet: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet var cameraTapGestureRecognizer: UITapGestureRecognizer!
    
    var group: NSDictionary!
    var groupIcon: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButtonOutlet.isUserInteractionEnabled = true
        cameraButtonOutlet.addGestureRecognizer(cameraTapGestureRecognizer)
        
        setupUI()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Invite Users", style: .plain, target: self, action: #selector(self.inviteUsers))]
        
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        var withValues : [String:Any]!
        
        if groupNameTextField.text != "" {
            withValues = [kNAME : groupNameTextField.text!]
        } else {
            ProgressHUD.showError("Subject is required")
        }
        let avatarData = cameraButtonOutlet.image?.jpegData(compressionQuality: 0.7)
        let avatarString = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        withValues = [kNAME : groupNameTextField.text!, kAVATAR : avatarString!]
        
        Group.updateGroup(groupId: group[kGROUPID] as! String, withValues: withValues)
        
        withValues = [kWITHUSERFULLNAME: groupNameTextField.text!, kAVATAR : avatarString]
        
        updateExistingRecentWithNewValues(chatroomId: group[kGROUPID] as! String, members: group[kMEMBERS] as! [String], withValues: withValues)
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func editButtonPressed(_ sender: Any) {
        showIconOptions()
    }
    @IBAction func iconTapGesture(_ sender: Any) {
        showIconOptions()
    }
    
    @objc func inviteUsers() {
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "inviteUsers") as! InviteUserTableViewController
        
        userVC.group = group
        self.navigationController?.pushViewController(userVC, animated: true)
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
                self.cameraButtonOutlet.image   = UIImage(named: "cameraIcon")
                self.editButtonOutlet.isHidden = true
            }
            optionMenu.addAction(resetAction)
        }
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let currentPopoverpresentationcontroller = optionMenu.popoverPresentationController {
                currentPopoverpresentationcontroller.sourceView = editButtonOutlet
                currentPopoverpresentationcontroller.sourceRect = editButtonOutlet.bounds
                
                currentPopoverpresentationcontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
        
    }
    
    func setupUI() {
        self.title = "Group"
        groupNameTextField.text = group[kNAME] as? String
        
        imageFromData(pictureData: group[kAVATAR] as! String) { (avatarImage) in
            if avatarImage != nil {
                self.cameraButtonOutlet.image = avatarImage!.circleMasked
            }
        }
    }
}




