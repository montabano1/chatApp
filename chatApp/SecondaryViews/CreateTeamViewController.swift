//
//  CreateTeamViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/5/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD

class CreateTeamViewController: UIViewController {
    
    var orgName = ""
    var orgId = ""
    
    var allTeams = [String]()
    
    var width = CGFloat(0)
    
    var startOrgStuff = [UIView]()
    var sOrgTitle = UILabel()
    var sOrgNameLabel = UILabel()
    var sOrgName = UITextField()
    var sPrivateLabel = UILabel()
    var sPrivateSwitch = UISwitch()
    var sPasswordLabel = UILabel()
    var sPassword = UITextField()
    var sConfirmPasswordLabel = UILabel()
    var sConfirmPassword = UITextField()
    var sConfirmStatus = UILabel()
    var sNameOK = UILabel()
    var sCancelButton = UIButton()
    var sCreateButton = UIButton()
    var nameOK = false
    var pwOK = true
    var passwordTime = false
    var sNeedOrgLabel = UILabel()
    var sNeedOrg = UISwitch()
    
    var teamId = ""
    var admins = [String]()
    var members = [String]()
    var name = ""
    var privateValue = ""
    var password = ""
    var needOrg = ""
    
    override func viewWillAppear(_ animated: Bool) {
        reference(.Organization).document(orgId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            if let teams = snapshot.data()!["Teams"] as? [String] {
                self.allTeams = teams
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        width = view.bounds.width
        
        sOrgTitle.frame = CGRect(x: 20, y: topbarHeight + 10, width: 500, height: 50)
        sOrgTitle.text = "\(orgName)"
        sOrgTitle.font = UIFont.systemFont(ofSize: 40)
        sOrgTitle.sizeToFit()
        sOrgTitle.center.x = view.center.x
        view.addSubview(sOrgTitle)
        
        sOrgNameLabel.frame = CGRect(x: 20, y: sOrgTitle.frame.maxY + 40, width: 500, height: 30)
        sOrgNameLabel.text = "Team Name:"
        sOrgNameLabel.font = UIFont.systemFont(ofSize: 25)
        sOrgNameLabel.sizeToFit()
        view.addSubview(sOrgNameLabel)
        sOrgName.frame = CGRect(x: sOrgNameLabel.frame.maxX + 10, y: 1, width: view.frame.width - sOrgNameLabel.frame.maxX - 20, height: 40)
        sOrgName.center.y = sOrgNameLabel.center.y
        sOrgName.layer.borderWidth = 2
        sOrgName.layer.cornerRadius = 5
        sOrgName.setLeftPaddingPoints(10)
        sOrgName.placeholder = "Enter Team Name"
        sOrgName.tag = 55
        sOrgName.autocapitalizationType = .allCharacters
        sOrgName.autocorrectionType = .no
        sOrgName.addTarget(self, action: #selector(checkName), for: .allEditingEvents)
        view.addSubview(sOrgName)
        
        sNameOK.frame = CGRect(x: sOrgName.frame.minX + 10, y: sOrgName.frame.maxY + 5, width: 500, height: 30)
        sNameOK.text = ""
        sNameOK.textColor = .red
        sNameOK.alpha = 0
        view.addSubview(sNameOK)
        
        sNeedOrgLabel.frame = CGRect(x: 20, y: sNameOK.frame.maxY + 10, width: 500, height: 60)
        sNeedOrgLabel.text = "Require membership to \n\(orgName)?"
        sNeedOrgLabel.numberOfLines = 2
        sNeedOrgLabel.font = UIFont.systemFont(ofSize: 25)
        sNeedOrgLabel.sizeToFit()
        sNeedOrgLabel.textAlignment = .center
        view.addSubview(sNeedOrgLabel)
        sNeedOrg.frame = CGRect(x: sNeedOrg.frame.maxX + 10, y: 1, width: 90, height: 40)
        sNeedOrg.center.y = sNeedOrgLabel.center.y
        view.addSubview(sNeedOrg)
        
        sPrivateLabel.frame = CGRect(x: 20, y: sNeedOrgLabel.frame.maxY + 10, width: 500, height: 30)
        sPrivateLabel.text = "Require password to join?"
        sPrivateLabel.font = UIFont.systemFont(ofSize: 25)
        sPrivateLabel.sizeToFit()
        view.addSubview(sPrivateLabel)
        sPrivateSwitch.frame = CGRect(x: sPrivateLabel.frame.maxX + 10, y: 1, width: 90, height: 40)
        sPrivateSwitch.center.y = sPrivateLabel.center.y
        sPrivateSwitch.addTarget(self, action: #selector(togglePW), for: .touchUpInside)
        view.addSubview(sPrivateSwitch)
        
        sPasswordLabel.frame = CGRect(x: 20, y: sPrivateSwitch.frame.maxY + 30, width: 500, height: 30)
        sPasswordLabel.text = "Password: "
        sPasswordLabel.font = UIFont.systemFont(ofSize: 25)
        sPasswordLabel.sizeToFit()
        sPasswordLabel.alpha = 0
        view.addSubview(sPasswordLabel)
        sPassword.frame = CGRect(x: sPasswordLabel.frame.maxX + 10, y: 1, width: view.frame.width - sPasswordLabel.frame.maxX - 20, height: 40)
        sPassword.center.y = sPasswordLabel.center.y
        sPassword.layer.borderWidth = 2
        sPassword.layer.cornerRadius = 5
        sPassword.setLeftPaddingPoints(10)
        sPassword.placeholder = "Case sensitive"
        sPassword.autocapitalizationType = .allCharacters
        sPassword.autocorrectionType = .no
        sPassword.alpha = 0
        sPassword.isSecureTextEntry = true
        sPassword.addTarget(self, action: #selector(checkPW), for: .allEditingEvents)
        view.addSubview(sPassword)
        
        sConfirmPasswordLabel.frame = CGRect(x: 20, y: sPassword.frame.maxY + 20, width: 500, height: 30)
        sConfirmPasswordLabel.text = "Confirm: "
        sConfirmPasswordLabel.font = UIFont.systemFont(ofSize: 25)
        sConfirmPasswordLabel.sizeToFit()
        sConfirmPasswordLabel.alpha = 0
        view.addSubview(sConfirmPasswordLabel)
        sConfirmPassword.frame = CGRect(x: sPassword.frame.minX, y: 1, width: sPassword.frame.width, height: 40)
        sConfirmPassword.center.y = sConfirmPasswordLabel.center.y
        sConfirmPassword.layer.borderWidth = 2
        sConfirmPassword.layer.cornerRadius = 5
        sConfirmPassword.setLeftPaddingPoints(10)
        sConfirmPassword.placeholder = "Confirm Password"
        sConfirmPassword.autocapitalizationType = .allCharacters
        sConfirmPassword.autocorrectionType = .no
        sConfirmPassword.alpha = 0
        sConfirmPassword.isSecureTextEntry = true
        sConfirmPassword.addTarget(self, action: #selector(checkPW), for: .allEditingEvents)
        view.addSubview(sConfirmPassword)
        
        sConfirmStatus.frame = CGRect(x: 1, y: sConfirmPassword.frame.maxY + 5, width: 500, height: 30)
        sConfirmStatus.text = "Passwords don't match"
        sConfirmStatus.sizeToFit()
        sConfirmStatus.center.x = sConfirmPassword.center.x
        sConfirmStatus.textColor = .red
        sConfirmStatus.alpha = 0
        view.addSubview(sConfirmStatus)
        
        sCreateButton.frame = CGRect(x: 0, y: sConfirmStatus.frame.maxY + 20, width: width * 0.8, height: 50)
        sCreateButton.setTitle("Create \(orgName)-", for: [])
        sCreateButton.addTarget(self, action: #selector(createTeam), for: .touchUpInside)
        sCreateButton.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        sCreateButton.setTitleColor(.black, for: [])
        sCreateButton.layer.cornerRadius = 5
        sCreateButton.center.x = view.center.x
        createNOTOK()
        view.addSubview(sCreateButton)
    }
    
    @objc func viewTapped() {
        self.view.endEditing(true)
    }
    
    @objc func checkPW() {
        if sConfirmPassword.text!.count > 0 && sPassword.alpha == 1 {
            sConfirmStatus.alpha = 1
            if sPassword.text == sConfirmPassword.text {
                sConfirmStatus.text = "Passwords match"
                sConfirmStatus.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                pwOK = true
                createOK()
            } else {
                pwOK = false
                sConfirmStatus.text = "Passwords don't match"
                sConfirmStatus.textColor = .red
                createNOTOK()
            }
        } else {
            sConfirmStatus.alpha = 0
        }
    }
    
    @objc func togglePW() {
        if sPassword.alpha == 0 {
            UIView.animate(withDuration: 0.5) {
                self.sPassword.alpha = 1
                self.sPassword.text = ""
                self.sConfirmPassword.text = ""
                self.sPasswordLabel.alpha = 1
                self.sConfirmPassword.alpha = 1
                self.sConfirmPasswordLabel.alpha = 1
                self.pwOK = false
                self.createNOTOK()
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.sPassword.alpha = 0
                self.sPasswordLabel.alpha = 0
                self.sConfirmPassword.alpha = 0
                self.sConfirmPasswordLabel.alpha = 0
                self.sConfirmStatus.alpha = 0
                self.pwOK = true
                if self.sOrgName.text!.count > 0 {
                    self.createOK()
                }
            }
        }
    }
    
    @objc func checkName() {
        sNameOK.alpha = 1
        if sOrgName.text!.count > 0 {
            if allTeams.contains(orgName + "-" + sOrgName.text!) {
                sNameOK.text = "Name already taken"
                sNameOK.textColor = .red
                nameOK = false
                createNOTOK()
            } else {
                sNameOK.text = "Name available!"
                sNameOK.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                nameOK = true
                createOK()
            }
        } else {
            sNameOK.text = "Name must not be blank"
            nameOK = false
            sNameOK.textColor = .red
            createNOTOK()
        }
        sCreateButton.setTitle("Create \(orgName)-\(sOrgName.text!)", for: [])
    }
    
    func createOK() {
        if nameOK && pwOK {
            self.sCreateButton.backgroundColor = #colorLiteral(red: 0.5282745361, green: 0.9657374024, blue: 0.7535668612, alpha: 1)
            self.sCreateButton.isEnabled = true
        }
    }
    
    func createNOTOK() {
        self.sCreateButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.sCreateButton.isEnabled = false
    }
    
    @objc func createTeam() {
        view.endEditing(true)
        ProgressHUD.show("Creating \(orgName + "-" + sOrgName.text!)")
        let localreference = reference(.Team).document()
        teamId = localreference.documentID
        admins = [FUser.currentId()]
        members = [FUser.currentId()]
        name = orgName + "-" + sOrgName.text!
        if sNeedOrg.isOn {
            needOrg = "Yes"
        } else {
            needOrg = "No"
        }
        if sPassword.text!.count > 0 {
            privateValue = "Yes"
            let encryptedPW = Encryption.encryptText(chatRoomId: teamId, message: sPassword.text!)
            password = encryptedPW
        } else {
            privateValue = "No"
            password = ""
        }
        
        
        localreference.setData(["Admins":admins, "Members":members, "Name":name, "TeamId":teamId, "Password":password, "Private":privateValue, "OrgId":orgId, "OrgName":orgName, "NeedOrg":needOrg]) { (error) in
            if error != nil {
                ProgressHUD.showError("There was an error creating your team")
            } else {
                var myTeams = FUser.currentUser()?.teams
                myTeams?.append(self.name)
                var myAdminTeams = FUser.currentUser()?.adminTeams
                myAdminTeams!.append(self.teamId)
                updateCurrentUserInFirestore(withValues: [kTEAMS:myTeams, kADMINTEAMS:myAdminTeams]) { (error) in
                    if error != nil {
                        ProgressHUD.showError("There was an error adding your team to your profile")
                    } else {
                        reference(.Organization).document(self.orgId).getDocument { (snapshot, error) in
                            if error != nil {
                                ProgressHUD.showError("There was an error finding \(self.orgName)")
                            } else {
                                guard let snapshot = snapshot else {return}
                                var tempOrg = snapshot.data()
                                var orgTeams = [String]()
                                if let tempOrgTeams = tempOrg!["Teams"] as? [String] {
                                    orgTeams = tempOrgTeams
                                }
                                orgTeams.append(self.name)
                                tempOrg!["Teams"] = orgTeams
                                reference(.Organization).document(self.orgId).setData(tempOrg!) { (error) in
                                    if error != nil {
                                        ProgressHUD.showError("There was an error updating \(self.orgName)")
                                    } else {
                                        ProgressHUD.showSuccess()
                                        UserDefaults.standard.set("Created Team Successfully!", forKey: "initialSMessage")
                                        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "tabBar") as! UITabBarController
                                        
                                        let window = self.view.window
                                        window?.rootViewController = mainView
                                        UIView.transition(with: window!,
                                                          duration: 0.3,
                                                          options: .transitionCrossDissolve,
                                                          animations: nil,
                                                          completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}
