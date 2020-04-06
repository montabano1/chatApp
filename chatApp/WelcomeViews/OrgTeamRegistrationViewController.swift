//
//  OrgTeamRegistrationViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/3/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import SearchTextField
import ProgressHUD
import FirebaseFirestore

class OrgTeamRegistrationViewController: UIViewController, UITextFieldDelegate {

    var joinOrgButton = UIButton()
    var joinOrgLabel = UILabel()
    var startOrgButton = UIButton()
    var startOrgLabel = UILabel()
    var joinTeamButton = UIButton()
    var joinTeamLabel = UILabel()
    var startTeamButton = UIButton()
    var startTeamLabel = UILabel()
    var fourButtons = [UIButton]()
    var fourLabels = [UILabel]()
    var searchField = SearchTextField()
    var backButton = UIButton()
    var searchLabel = UILabel()
    var joinButton = UIButton()
    var allOrgsFound = false
    var allOrgs = [String]()
    var allTeamsFound = false
    var allTeams = [String]()
    var passwordTime = false
    var joinType = "Org"
    var orgId = ""
    var admins = [String]()
    var members = [String]()
    var name = ""
    var privateValue = ""
    var password = ""
    var width: CGFloat = 0
    var height: CGFloat = 0
    var orgs = [String]()
    var initialOptionStuff = [UIView]()
    var joinPWField = UITextField()
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = view.bounds.width
        let tapGestureRegognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRegognizer)
        
        
        
        fourButtons = [joinOrgButton, startOrgButton, joinTeamButton, startTeamButton ]
        fourLabels = [joinOrgLabel, startOrgLabel, startTeamLabel, joinTeamLabel]
        var i = 1
        for button in fourButtons {
            button.layer.borderWidth = 1
            button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            button.layer.cornerRadius = 10
            button.tag = i
            //button.alpha = 0
            i += 1
        }
        for label in fourLabels {
            //label.alpha = 0
        }
        
        initialOptionStuff = [joinOrgButton, startOrgButton, joinTeamButton, startTeamButton, joinOrgLabel, startOrgLabel, startTeamLabel, joinTeamLabel]
        
        startOrgStuff = [sOrgTitle, sOrgName, sOrgNameLabel, sPrivateLabel, sPrivateSwitch, sPasswordLabel, sPassword, sConfirmPassword, sConfirmStatus, sConfirmPasswordLabel, sNameOK, sCancelButton, sCreateButton]
        for thing in startOrgStuff {
            thing.alpha = 0
        }
        
        
        joinOrgButton.frame = CGRect(x: width/6, y: 1, width: width/4, height: width/4)
        joinOrgButton.setImage(UIImage(named: "joinTeam")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        joinOrgButton.imageView?.contentMode = .center
        joinOrgButton.center.y = view.center.y / 2
        joinOrgButton.addTarget(self, action: #selector(joinOrganization), for: .touchUpInside)
        view.addSubview(joinOrgButton)
        joinOrgLabel.frame = CGRect(x: joinOrgButton.frame.minX, y: joinOrgButton.frame.maxY + 5, width: width/4, height: 30)
        joinOrgLabel.text = "Join an \n organization"
        joinOrgLabel.numberOfLines = 2
        joinOrgLabel.textAlignment = .center
        joinOrgLabel.font = UIFont.systemFont(ofSize: 17.5)
        joinOrgLabel.sizeToFit()
        joinOrgLabel.center.x = joinOrgButton.center.x
        view.addSubview(joinOrgLabel)
        
        startOrgButton.frame = CGRect(x: 7*width/12, y: 1, width: width/4, height: width/4)
        startOrgButton.setImage(UIImage(named: "createTeam")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        startOrgButton.imageView?.contentMode = .center
        startOrgButton.center.y = view.center.y / 2
        startOrgButton.addTarget(self, action: #selector(startOrganization), for: .touchUpInside)
        view.addSubview(startOrgButton)
        startOrgLabel.frame = CGRect(x: startOrgButton.frame.minX, y: startOrgButton.frame.maxY + 5, width: width/4, height: 30)
        startOrgLabel.text = "Create an \n organization"
        startOrgLabel.numberOfLines = 2
        startOrgLabel.textAlignment = .center
        startOrgLabel.font = UIFont.systemFont(ofSize: 17.5)
        startOrgLabel.sizeToFit()
        startOrgLabel.center.x = startOrgButton.center.x
        view.addSubview(startOrgLabel)
        
        joinTeamButton.frame = CGRect(x: width/6, y: 1, width: width/4, height: width/4)
        joinTeamButton.setImage(UIImage(named: "joinTeam")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        joinTeamButton.imageView?.contentMode = .center
        joinTeamButton.center.y = view.center.y
        joinTeamButton.addTarget(self, action: #selector(joinTeam), for: .touchUpInside)
        view.addSubview(joinTeamButton)
        joinTeamLabel.frame = CGRect(x: joinTeamButton.frame.minX, y: joinTeamButton.frame.maxY + 5, width: width/4, height: 30)
        joinTeamLabel.text = "Join a \n team"
        joinTeamLabel.numberOfLines = 2
        joinTeamLabel.textAlignment = .center
        joinTeamLabel.font = UIFont.systemFont(ofSize: 17.5)
        joinTeamLabel.sizeToFit()
        joinTeamLabel.center.x = joinTeamButton.center.x
        view.addSubview(joinTeamLabel)
        
        startTeamButton.frame = CGRect(x: 7*width/12, y: 1, width: width/4, height: width/4)
        if FUser.currentUser()?.adminOrgs.count == 0 {
            startTeamButton.setImage(UIImage(named: "createTeam")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)).noir, for: [])
        } else {
            startTeamButton.setImage(UIImage(named: "createTeam")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        }
        startTeamButton.imageView?.contentMode = .center
        startTeamButton.center.y = view.center.y
        startTeamButton.addTarget(self, action: #selector(startTeam), for: .touchUpInside)
        view.addSubview(startTeamButton)
        startTeamLabel.frame = CGRect(x: startTeamButton.frame.minX, y: startTeamButton.frame.maxY + 5, width: width/4, height: 30)
        startTeamLabel.text = "Create a \n team"
        startTeamLabel.numberOfLines = 2
        startTeamLabel.textAlignment = .center
        startTeamLabel.font = UIFont.systemFont(ofSize: 17.5)
        startTeamLabel.sizeToFit()
        startTeamLabel.center.x = startTeamButton.center.x
        view.addSubview(startTeamLabel)
        
        searchLabel.frame = CGRect(x: 0, y: 100, width: width * 0.8, height: 100)
        searchLabel.text = "Search for an \nOrganization"
        searchLabel.numberOfLines = 2
        searchLabel.font = UIFont.systemFont(ofSize: 40)
        searchLabel.textAlignment = .center
        searchLabel.sizeToFit()
        searchLabel.center.x = view.center.x
        searchLabel.alpha = 0
        view.addSubview(searchLabel)
        
        searchField.frame = CGRect(x: 0, y: searchLabel.frame.maxY + 30, width: width * 0.8, height: 50)
        searchField.center.x = view.center.x
        searchField.itemSelectionHandler = {item, itemPosition in
            self.searchField.text = item[itemPosition].title
            self.view.endEditing(true)
        }
        searchField.autocorrectionType = .no
        searchField.layer.borderWidth = 2
        searchField.layer.cornerRadius = 5
        searchField.setLeftPaddingPoints(10)
        searchField.placeholder = "Enter Organization Name"
        searchField.theme.cellHeight = 50
        searchField.theme.font = UIFont.systemFont(ofSize: 20)
        searchField.maxNumberOfResults = 5
        searchField.maxResultsListHeight = 200
        searchField.alpha = 0
        searchField.delegate = self
        searchField.autocapitalizationType = .none
        view.addSubview(searchField)
        joinPWField.frame = searchField.frame
        joinPWField.autocorrectionType = .no
        joinPWField.layer.borderWidth = 2
        joinPWField.layer.cornerRadius = 5
        joinPWField.setLeftPaddingPoints(10)
        joinPWField.placeholder = "Enter Org Password"
        joinPWField.alpha = 0
        joinPWField.autocapitalizationType = .none
        joinPWField.isSecureTextEntry = true
        view.addSubview(joinPWField)
        
        
        joinButton.frame = CGRect(x: 0, y: searchField.frame.maxY + 5, width: 200, height: 200)
        joinButton.setTitle("Join", for: [])
        joinButton.titleLabel!.font  = UIFont.systemFont(ofSize: 30)
        joinButton.sizeToFit()
        joinButton.center.x = view.center.x
        joinButton.isEnabled = false
        joinButton.addTarget(self, action: #selector(tryJoining), for: .touchUpInside)
        joinButton.alpha = 0
        view.addSubview(joinButton)
        
        backButton.frame = CGRect(x: 20, y: searchLabel.frame.minY, width: 200, height: 200)
        backButton.setTitle("< Cancel", for: [])
        backButton.titleLabel!.font  = UIFont.systemFont(ofSize: 15)
        backButton.sizeToFit()
        backButton.center.y = searchLabel.center.y
        backButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: [])
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backButton.alpha = 0
        view.addSubview(backButton)
        
        sOrgTitle.frame = CGRect(x: 20, y: topbarHeight + 10, width: 500, height: 50)
        sOrgTitle.text = "New Organization"
        sOrgTitle.font = UIFont.systemFont(ofSize: 40)
        sOrgTitle.sizeToFit()
        sOrgTitle.center.x = view.center.x
        view.addSubview(sOrgTitle)
        
        sOrgNameLabel.frame = CGRect(x: 20, y: sOrgTitle.frame.maxY + 40, width: 500, height: 30)
        sOrgNameLabel.text = "Org Name:"
        sOrgNameLabel.font = UIFont.systemFont(ofSize: 25)
        sOrgNameLabel.sizeToFit()
        view.addSubview(sOrgNameLabel)
        sOrgName.frame = CGRect(x: sOrgNameLabel.frame.maxX + 10, y: 1, width: view.frame.width - sOrgNameLabel.frame.maxX - 20, height: 40)
        sOrgName.center.y = sOrgNameLabel.center.y
        sOrgName.layer.borderWidth = 2
        sOrgName.layer.cornerRadius = 5
        sOrgName.setLeftPaddingPoints(10)
        sOrgName.placeholder = "Enter Org Name"
        sOrgName.tag = 55
        sOrgName.autocapitalizationType = .allCharacters
        sOrgName.autocorrectionType = .no
        sOrgName.addTarget(self, action: #selector(checkName), for: .allEditingEvents)
        view.addSubview(sOrgName)
        
        sNameOK.frame = CGRect(x: 1, y: sOrgName.frame.maxY + 5, width: 500, height: 30)
        sNameOK.text = "Name must be 3+ characters"
        sNameOK.sizeToFit()
        sNameOK.center.x = sOrgName.center.x
        sNameOK.textColor = .red
        sNameOK.alpha = 0
        view.addSubview(sNameOK)
        
        sPrivateLabel.frame = CGRect(x: 20, y: sNameOK.frame.maxY + 30, width: 500, height: 30)
        sPrivateLabel.text = "Require password to join?"
        sPrivateLabel.font = UIFont.systemFont(ofSize: 25)
        sPrivateLabel.sizeToFit()
        view.addSubview(sPrivateLabel)
        sPrivateSwitch.frame = CGRect(x: view.bounds.width - 100, y: 1, width: 90, height: 40)
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
        
        sCancelButton.frame = CGRect(x: width / 9, y: sConfirmStatus.frame.maxY + 20, width: width / 3, height: 50)
        sCancelButton.backgroundColor = #colorLiteral(red: 0.9976730943, green: 0.7091811299, blue: 0.3273357749, alpha: 1)
        sCancelButton.setTitle("Cancel", for: [])
        sCancelButton.addTarget(self, action: #selector(cancelStartOrg), for: .touchUpInside)
        sCancelButton.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        sCancelButton.setTitleColor(.black, for: [])
        sCancelButton.layer.cornerRadius = 5
        view.addSubview(sCancelButton)
        
        sCreateButton.frame = CGRect(x: 5 * width / 9, y: sConfirmStatus.frame.maxY + 20, width: width / 3, height: 50)
        sCreateButton.setTitle("Create", for: [])
        sCreateButton.addTarget(self, action: #selector(createOrganization), for: .touchUpInside)
        sCreateButton.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        sCreateButton.setTitleColor(.black, for: [])
        sCreateButton.layer.cornerRadius = 5
        createNOTOK()
        view.addSubview(sCreateButton)
        
    }
    
    @objc func createOrganization() {
        view.endEditing(true)
        ProgressHUD.show("Creating \(sOrgName.text!)")
        
        let localreference = reference(.Organization).document()
        orgId = localreference.documentID
        admins = [FUser.currentId()]
        members = [FUser.currentId()]
        name = sOrgName.text!
        if sPassword.text!.count > 0 {
            privateValue = "Yes"
            let encryptedPW = Encryption.encryptText(chatRoomId: orgId, message: sPassword.text!)
            password = encryptedPW
        } else {
            privateValue = "No"
            password = ""
        }
        
        
        localreference.setData(["Admins":admins, "Members":members, "Name":name, "OrgId":orgId, "Password":password, "Private":privateValue]) { (error) in
            if error != nil {
                ProgressHUD.showError("There was an error creating your organization")
            } else {
                var myOrgs = FUser.currentUser()?.organizations
                myOrgs?.append(self.name)
                var myAdminOrgs = FUser.currentUser()?.adminOrgs
                myAdminOrgs!.append(self.orgId)
                updateCurrentUserInFirestore(withValues: [kORGANIZATIONS:myOrgs, kADMINORGS:myAdminOrgs]) { (error) in
                    if error != nil {
                        ProgressHUD.showError("There was an error adding your organization to your profile")
                    } else {
                        UserDefaults.standard.set("Created Organization Successfully!", forKey: "initialSMessage")
                        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "initialOptions") as! UINavigationController
                        
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
    
    @objc func cancelStartOrg() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.5) {
            for item in self.initialOptionStuff {
                item.alpha = 1
            }
        }
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
                if self.sOrgName.text!.count >= 3 {
                    self.createOK()
                }
            }
        }
    }
    
    @objc func checkName() {
        findOrgs()
        sNameOK.alpha = 1
        if sOrgName.text!.count >= 3 {
            if allOrgs.contains(sOrgName.text!) {
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
            sNameOK.text = "Name must be 3+ characters"
            sNameOK.textColor = .red
            nameOK = false
            createNOTOK()
        }
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
    
    func findOrgs() {
        if !allOrgsFound {
            reference(.Organization).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else { print("baderror(1232134") ; return }
                for recent in snapshot.documents {
                    let data = recent.data()
                    self.allOrgs.append(data["Name"] as! String)
                }
                self.searchField.filterStrings(self.allOrgs)
            }
            allOrgsFound = true
        }
    }
    
    func findTeams() {
        if !allTeamsFound {
            reference(.Team).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else { print("baderror(1232134") ; return }
                for recent in snapshot.documents {
                    let data = recent.data()
                    if data["NeedOrg"] as! String == "Yes" {
                        if (FUser.currentUser()?.organizations.contains(data["OrgName"] as! String))! {
                            self.allTeams.append(data["Name"] as! String)
                        }
                    } else {
                        self.allTeams.append(data["Name"] as! String)
                    }
                    
                }
                self.searchField.filterStrings(self.allTeams)
            }
            allTeamsFound = true
        }
    }
    
    @objc func joinTeam() {
        joinType = "Team"
        setupJoin()
        self.searchField.filterStrings(self.allTeams)
    }
    
    @objc func joinOrganization() {
        joinType = "Org"
        setupJoin()
        self.searchField.filterStrings(self.allOrgs)
    }
    
    @objc func setupJoin() {
        if joinType == "Org" {
            findOrgs()
            self.searchField.placeholder = "Enter Organization Name"
            self.searchLabel.text = "Search for an \nOrganization"
        } else {
            findTeams()
            self.searchField.placeholder = "Enter Team Name"
            self.searchLabel.text = "Search for a \nTeam"
        }
        
        
        UIView.animate(withDuration: 0.5) {
            self.searchLabel.alpha = 1
            self.backButton.alpha = 1
            self.searchField.alpha = 1
            self.searchField.text = ""
            self.joinPWField.alpha = 0
            self.joinPWField.text = ""
            self.searchLabel.font = UIFont.systemFont(ofSize: 40)
            self.passwordTime = false
            for button in self.fourButtons {
                button.alpha = 0
            }
            
            for button in self.fourLabels {
                button.alpha = 0
            }
        }
    }
    
    @objc func tryJoining() {
        if joinType == "Org" {
            tryJoiningOrg()
        } else {
            tryJoiningTeam()
        }
    }
    
    func tryJoiningTeam() {
        var orgName = ""
        var teamId = ""
        var needOrg = ""
        var teams = FUser.currentUser()?.teams as! [String]
        if !passwordTime {
            if !(teams.contains(searchField.text!)) {
                teams.append(searchField.text!)
                
                var team = reference(.Team).whereField("Name", isEqualTo: searchField.text!).getDocuments { (snapshot, error) in
                    guard let snapshot = snapshot else { return }
                    for recent in snapshot.documents {
                        orgName = recent.data()["OrgName"] as! String
                        needOrg = recent.data()["NeedOrg"] as! String
                        self.orgId = recent.data()["OrgId"] as! String
                        self.admins = recent.data()["Admins"] as! [String]
                        self.members = recent.data()["Members"] as! [String]
                        teamId = recent.data()["TeamId"] as! String
                        self.name = recent.data()["Name"] as! String
                        self.privateValue = recent.data()["Private"] as! String
                        self.password = recent.data()["Password"] as! String
                    }
                    if self.privateValue == "No" {
                        if !self.members.contains(FUser.currentId()) {
                            self.members.append(FUser.currentId())
                            reference(.Team).document(teamId).updateData(["Admins":self.admins, "Members":self.members, "Name":self.name, "OrgId":self.orgId,"Private":self.privateValue, "TeamId":teamId, "NeedOrg":needOrg, "OrgName":orgName])
                            updateCurrentUserInFirestore(withValues: [kTEAMS: teams]) { (error) in
                                if error != nil {
                                    print("error joining team")
                                } else {
                                    UserDefaults.standard.set("Joined Team Successfully!", forKey: "initialSMessage")
                                    let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "initialOptions") as! UINavigationController
                                    
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
                    } else {
                        self.joinPWField.alpha = 1
                        self.searchField.alpha = 0
                        self.searchLabel.alpha = 0
                        UIView.animate(withDuration: 0.5) {
                            self.searchLabel.text = "Enter Password \nto join \(self.searchField.text!)"
                            self.searchLabel.font = UIFont.systemFont(ofSize: 25)
                            self.searchLabel.center.x = self.view.center.x
                            self.passwordTime = true
                            self.searchField.placeholder = "Enter Password"
                            self.searchField.text = ""
                            self.searchLabel.alpha = 1
                            return
                        }
                    }
                }
            } else {
                ProgressHUD.showError("Already Joined!")
            }
        } else {
            let decryptedPW = Encryption.decryptText(chatRoomId: teamId, encryptedMessage: password)
            if password.count > 0 && (decryptedPW == joinPWField.text!) {
                if !members.contains(FUser.currentId()) {
                    members.append(FUser.currentId())
                    reference(.Team).document(teamId).updateData(["Admins":admins, "Members":members, "Name":name, "OrgId":orgId,"Private":privateValue, "TeamId":teamId, "NeedOrg":needOrg, "OrgName":orgName])
                    updateCurrentUserInFirestore(withValues: [kTEAMS: teams]) { (error) in
                        if error != nil {
                            print("error joining tea,")
                        } else {
                            UserDefaults.standard.set("Joined Team Successfully!", forKey: "initialSMessage")
                            let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "initialOptions") as! UINavigationController
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
            } else {
                self.joinPWField.alpha = 0
                self.joinPWField.text = ""
                self.searchField.alpha = 1
                ProgressHUD.showError("Incorrect Password")
                passwordTime = false
                self.searchField.text = ""
                self.searchLabel.text = "Search for a \nTeam"
                self.searchField.placeholder = "Enter Team Name"
                self.searchLabel.font = UIFont.systemFont(ofSize: 40)
                self.searchLabel.center.x = self.view.center.x
                self.joinButton.alpha = 0
            }
        }
    }
    
    @objc func tryJoiningOrg() {
        if !passwordTime {
            orgs = FUser.currentUser()?.organizations as! [String]
            if !(orgs.contains(searchField.text!)) {
                orgs.append(searchField.text!)
                
                var organization = reference(.Organization).whereField("Name", isEqualTo: searchField.text!).getDocuments { (snapshot, error) in
                    guard let snapshot = snapshot else { return }
                    for recent in snapshot.documents {
                        self.orgId = recent.data()["OrgId"] as! String
                        self.admins = recent.data()["Admins"] as! [String]
                        self.members = recent.data()["Members"] as! [String]
                        
                        self.name = recent.data()["Name"] as! String
                        self.privateValue = recent.data()["Private"] as! String
                        self.password = recent.data()["Password"] as! String
                        
                    }
                    if self.privateValue == "No" {
                        if !self.members.contains(FUser.currentId()) {
                            self.members.append(FUser.currentId())
                            reference(.Organization).document(self.orgId).updateData(["Admins":self.admins, "Members":self.members, "Name":self.name, "OrgId":self.orgId,"Private":self.privateValue])
                            updateCurrentUserInFirestore(withValues: [kORGANIZATIONS: self.orgs]) { (error) in
                                if error != nil {
                                    print("error joining org")
                                } else {
                                    UserDefaults.standard.set("Joined Organization Successfully!", forKey: "initialSMessage")
                                    let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "initialOptions") as! UINavigationController
                                    
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
                    } else {
                        self.joinPWField.alpha = 1
                        self.searchField.alpha = 0
                        self.searchLabel.alpha = 0
                        UIView.animate(withDuration: 0.5) {
                            self.searchLabel.text = "Enter Password \nto join \(self.searchField.text!)"
                            self.searchLabel.font = UIFont.systemFont(ofSize: 25)
                            self.searchLabel.center.x = self.view.center.x
                            self.passwordTime = true
                            self.searchField.placeholder = "Enter Password"
                            self.searchField.text = ""
                            self.searchLabel.alpha = 1
                            return
                        }
                    }
                }
            } else {
                ProgressHUD.showError("Already Joined!")
            }
        } else {
            let decryptedPW = Encryption.decryptText(chatRoomId: orgId, encryptedMessage: password)
            if password.count > 0 && (decryptedPW == joinPWField.text!) {
                if !members.contains(FUser.currentId()) {
                    members.append(FUser.currentId())
                    reference(.Organization).document(orgId).updateData(["Admins":admins, "Members":members, "Name":name, "OrgId":orgId,"Private":privateValue])
                    updateCurrentUserInFirestore(withValues: [kORGANIZATIONS: orgs]) { (error) in
                        if error != nil {
                            print("error joining org")
                        } else {
                            UserDefaults.standard.set("Joined Organization Successfully!", forKey: "initialSMessage")
                            let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "initialOptions") as! UINavigationController
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
            } else {
                self.joinPWField.alpha = 0
                self.joinPWField.text = ""
                self.searchField.alpha = 1
                ProgressHUD.showError("Incorrect Password")
                passwordTime = false
                self.searchField.text = ""
                self.searchLabel.text = "Search for an \nOrganization"
                self.searchField.placeholder = "Enter Organization Name"
                self.searchLabel.font = UIFont.systemFont(ofSize: 40)
                self.searchLabel.center.x = self.view.center.x
                self.joinButton.alpha = 0
            }
        }
        
        
    }
    
    @objc func backAction() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5) {
            self.searchLabel.alpha = 0
            for button in self.fourButtons {
                button.alpha = 1
            }
            
            for button in self.fourLabels {
                button.alpha = 1
            }
            
            self.searchField.alpha = 0
            self.backButton.alpha = 0
            self.joinButton.alpha = 0
            self.joinPWField.alpha = 0
        }
    }
    
    @objc func startOrganization() {
        findOrgs()
        let managementItems = [joinOrgLabel, joinOrgButton, joinTeamLabel, joinTeamButton, startOrgLabel, startOrgButton, startTeamLabel, startTeamButton]
        let itemsToUnhide = [sOrgTitle, sOrgName, sOrgNameLabel, sPrivateLabel, sPrivateSwitch, sCancelButton, sCreateButton]
        UIView.animate(withDuration: 0.5) {
            for item in itemsToUnhide {
                item.alpha = 1
            }
            for item in managementItems {
                item.alpha = 0
            }
        }
    }
    
    @objc func doneButtonPressed() {
        self.dismiss(animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !passwordTime {
            joinButton.alpha = 0
            joinButton.isEnabled = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !passwordTime {
            self.searchField.maxNumberOfResults = 5
            let text = textField.text!
            if text.count > 0 {
                if allOrgs.contains(text) || allTeams.contains(text) {
                    joinButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: [])
                    joinButton.isEnabled = true
                    joinButton.alpha = 1
                } else {
                    joinButton.alpha = 0
                    joinButton.isEnabled = false
                }
            }
        } else {
            self.searchField.maxNumberOfResults = 0
        }
    }
    @objc func viewTapped() {
        self.view.endEditing(true)
    }
    
    @objc func startTeam() {
        if FUser.currentUser()?.adminOrgs.count == 0 {
            ProgressHUD.showError("You must be an organization admin to create a team")
        } else {
            performSegue(withIdentifier: "showAllOrgs", sender: self)
        }
    }
}
