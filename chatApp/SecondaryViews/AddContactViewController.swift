//
//  AddContactViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/4/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import FirebaseFirestore
import ProgressHUD

class AddContactViewController: UIViewController {

    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var userAvatar = UIImageView()
    var userFullName = UILabel()
    var plusButton = UIButton()
    var addStatus = UILabel()
    
    var userToAdd: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inviteButton = UIBarButtonItem(title: "Invite", style: .plain, target: self, action: #selector(inviteUser))
        self.navigationItem.rightBarButtonItems = [inviteButton]
        segmentedControl.frame = CGRect(x: 1, y: segmentedControl.frame.minY, width: view.bounds.width * 0.9, height: segmentedControl.frame.height)
        segmentedControl.center.x = view.center.x
        searchLabel.center.x = view.center.x
        searchField.center.x = view.center.x
        searchButton.center.x = view.center.x
        
        userAvatar.frame = CGRect(x: 1, y: searchButton.frame.maxY + 15, width: 200, height: 200)
        userAvatar.image = UIImage(named: "avatarPlaceholder")
        userAvatar.center.x = view.center.x
        view.addSubview(userAvatar)
        userFullName.frame = CGRect(x: 1, y: userAvatar.frame.maxY + 5, width: userAvatar.frame.width, height: 50)
        userFullName.layer.cornerRadius = 5
        userFullName.textAlignment = .center
        userFullName.numberOfLines = 2
        //userFullName.isHidden
        userFullName.text = "AJKSFHHKJ \ndsajkfhaskdjf"
        userFullName.font = UIFont.systemFont(ofSize: 22)
        userFullName.sizeToFit()
        userFullName.center.x = view.center.x
        userFullName.isHidden = true
        view.addSubview(userFullName)
        plusButton.frame = CGRect(x: userAvatar.frame.maxX - 20, y: userAvatar.frame.minY - 20, width: 40, height: 40)
        plusButton.layer.cornerRadius = 20
        plusButton.setImage(UIImage(named: "plus"), for: [])
        plusButton.isHidden = true
        plusButton.addTarget(self, action: #selector(addUserToContacts), for: .touchUpInside)
        view.addSubview(plusButton)
        addStatus.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        addStatus.text = "Added!"
        addStatus.textColor = .green
        addStatus.font = UIFont.systemFont(ofSize: 25)
        addStatus.sizeToFit()
        addStatus.center = plusButton.center
        addStatus.isHidden = true
        view.addSubview(addStatus)
    }
    
    @objc func inviteUser() {
        let text = "Hey! Lets chat on monTalk \(kAPPURL)"
        let objectsToShare : [Any] = [text]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.setValue("Lets Chat on monTalk", forKey: "subject")
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func changeSearch(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            searchLabel.text = "Search by phone number"
            searchLabel.sizeToFit()
            searchLabel.center.x = view.center.x
            searchField.placeholder = "Please enter 10-digit phone number"
        } else if segmentedControl.selectedSegmentIndex == 1 {
            searchLabel.text = "Search by email"
            searchLabel.sizeToFit()
            searchLabel.center.x = view.center.x
            searchField.placeholder = "Please enter email"
        }
    }
    
    @objc func addUserToContacts() {
        
        if  !(FUser.currentUser()?.contacts.contains(userToAdd!))! {
            var contacts = FUser.currentUser()?.contacts
            contacts?.append(userToAdd!)
            updateCurrentUserInFirestore(withValues: [kCONTACT : contacts as! [String]]) { (completion) in
            }
        } else {
            addStatus.text = "Added!"
            addStatus.sizeToFit()
        }
        plusButton.isHidden = true
        addStatus.isHidden = false
    }
    
    @IBAction func searchForUser(_ sender: Any) {
        ProgressHUD.show("Searching...")
        addStatus.isHidden = true
        self.view.endEditing(true)
        if segmentedControl.selectedSegmentIndex == 0 {
            reference(.User).whereField(kPHONE, isEqualTo: searchField.text!).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                if !snapshot.isEmpty {
                    for user in snapshot.documents {
                        let userDictionary = user.data() as NSDictionary
                        let fUser = FUser(_dictionary: userDictionary)
                        self.userToAdd = fUser.objectId
                        imageFromData(pictureData: fUser.avatar) { (avatarImage) in
                            if avatarImage != nil {
                                self.userAvatar.image = avatarImage!.circleMasked
                            }
                        }
                        self.userFullName.text = "\(fUser.firstname)\n\(fUser.lastname)"
                        self.userFullName.isHidden = false
                        if (FUser.currentUser()?.contacts.contains(fUser.objectId))! {
                            self.addStatus.sizeToFit()
                            self.addStatus.isHidden = false
                        } else {
                            self.addStatus.sizeToFit()
                            self.plusButton.isHidden = false
                        }
                        ProgressHUD.dismiss()
                    }
                } else {
                    self.userFullName.isHidden = true
                    self.userAvatar.image = UIImage(named: "avatarPlaceholder")
                    ProgressHUD.showError("User not found!")
                }
                
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            reference(.User).whereField(kEMAIL, isEqualTo: searchField.text!).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                if !snapshot.isEmpty {
                    for user in snapshot.documents {
                        let userDictionary = user.data() as NSDictionary
                        let fUser = FUser(_dictionary: userDictionary)
                        imageFromData(pictureData: fUser.avatar) { (avatarImage) in
                            if avatarImage != nil {
                                self.userAvatar.image = avatarImage!.circleMasked
                            }
                        }
                        self.userFullName.text = "\(fUser.firstname)\n\(fUser.lastname)"
                        self.userFullName.isHidden = false
                        ProgressHUD.dismiss()
                    }
                } else {
                    ProgressHUD.showError("User not found!")
                    self.userAvatar.image = UIImage(named: "avatarPlaceholder")
                    self.userFullName.isHidden = true
                }
            }
        }
    }
}
