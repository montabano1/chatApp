//
//  InitialOptionsViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/30/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD
import ChromaColorPicker

class InitialOptionsViewController: UIViewController {
    
    var textButton = UIButton()
    var textLabel = UILabel()
    var videoButton = UIButton()
    var videoLabel = UILabel()
    var broadcastButton = UIButton()
    var broadcastLabel = UILabel()
    var goToChatsButton = UIButton()
    var goToChatsLabel = UILabel()
    var callButton = UIButton()
    var callLabel = UILabel()
    var settingsButton = UIButton()
    var settingsLabel = UILabel()
    var titleLabel = UILabel()
    var optionLabel = UILabel()
    
    var singleMessage = UIButton()
    var singleMessageLabel = UILabel()
    var groupMessage = UIButton()
    var groupMessageLabel = UILabel()
    var teamMessage = UIButton()
    var teamMessageLabel = UILabel()
    var orgMessage = UIButton()
    var orgMessageLabel = UILabel()
    var undoButton = UIButton()
    
    var sixButtons = [UIButton]()
    var sixLabels = [UILabel]()
    var modeButtons = [UIButton]()
    var modeLabels = [UILabel]()
    
    
    var messageType = ""
    var mode = ""
    var isGroup = true
    
    var width = CGFloat(0)

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        if let message = UserDefaults.standard.string(forKey: "initialSMessage") {
            if message.count > 0 {
                print("\(message)")
                ProgressHUD.showSuccess(message)
                UserDefaults.standard.set("", forKey: "initialSMessage")
            }
        }
        if let message = UserDefaults.standard.string(forKey: "initialEMessage") {
            if message.count > 0 {
                ProgressHUD.showError(message)
                UserDefaults.standard.set("", forKey: "initialEMessage")
            }
        }
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        width = view.bounds.width
        sixButtons = [textButton, videoButton, broadcastButton, goToChatsButton, callButton, settingsButton]
        sixLabels = [textLabel, videoLabel, broadcastLabel, goToChatsLabel, callLabel, settingsLabel]
        var i = 1
        for button in sixButtons {
            button.layer.borderWidth = 1
            button.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            button.layer.cornerRadius = 10
            button.tag = i
            i += 1
        }
        videoButton.isHidden = true
        videoLabel.isHidden = true
        settingsButton.isHidden = true
        settingsLabel.isHidden = true
        goToChatsButton.isHidden = true
        goToChatsLabel.isHidden = true
        
        
        modeButtons = [singleMessage, groupMessage, teamMessage, orgMessage]
        modeLabels = [singleMessageLabel, groupMessageLabel, teamMessageLabel, orgMessageLabel]
        for button in modeButtons {
            button.layer.borderWidth = 1
            button.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            button.layer.cornerRadius = 10
            button.imageView?.contentMode = .center
            button.frame = CGRect(x: 1, y: 1, width: width / 3, height: width / 3)
            button.alpha = 0
            view.addSubview(button)
            button.tag = i
            i += 1
        }
        for label in modeLabels {
            view.addSubview(label)
            label.alpha = 0
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
        }
        undoButton.alpha = 0
        undoButton.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        view.addSubview(undoButton)
        
        let safeArea = UIApplication.shared.statusBarFrame.height
        titleLabel.frame = CGRect(x: 0, y: safeArea + 30, width: width/3, height: 1)
        titleLabel.text = "monTalk"
        titleLabel.font = UIFont(name: "Chalkduster", size: 35)
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        titleLabel.center.x = view.center.x
        view.addSubview(titleLabel)
        optionLabel.frame = CGRect(x: 0, y: titleLabel.frame.maxY + 35, width: width, height: width)
        optionLabel.text = "Text Message"
        optionLabel.font = UIFont.systemFont(ofSize: 30)
        optionLabel.alpha = 0
        optionLabel.sizeToFit()
        view.addSubview(optionLabel)
        
        singleMessage.center.x = 5 * width / 18
        singleMessage.center.y = view.center.y * 0.7
        singleMessage.setImage(UIImage(named: "mode1on1")!.scaleImageToSize(newSize: CGSize(width: width/4, height: width/4)), for: [])
        singleMessage.addTarget(self, action: #selector(startChat), for: .touchUpInside)
        groupMessage.center.x = 13 * width / 18
        groupMessage.center.y = view.center.y * 0.7
        groupMessage.setImage(UIImage(named: "modeGroup")!.scaleImageToSize(newSize: CGSize(width: width/4, height: width/4)), for: [])
        groupMessage.addTarget(self, action: #selector(startChat), for: .touchUpInside)
        teamMessage.center.x = 5 * width / 18
        teamMessage.center.y = view.center.y * 1.3
        teamMessage.setImage(UIImage(named: "modeTeam")!.scaleImageToSize(newSize: CGSize(width: width/4, height: width/4)), for: [])
        teamMessage.addTarget(self, action: #selector(startChat), for: .touchUpInside)
        orgMessage.center.x = 13 * width / 18
        orgMessage.center.y = view.center.y * 1.3
        orgMessage.setImage(UIImage(named: "modeOrg")!.scaleImageToSize(newSize: CGSize(width: width/4, height: width/4)), for: [])
        orgMessage.addTarget(self, action: #selector(startChat), for: .touchUpInside)
        
        textButton.frame = CGRect(x: width/6, y: 1, width: width/4, height: width/4)
        textButton.setImage(UIImage(named: "optiontext")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        textButton.imageView?.contentMode = .center
        textButton.center.y = view.center.y/2
        textButton.addTarget(self, action: #selector(showModes), for: .touchUpInside)
        view.addSubview(textButton)
        textLabel.frame = CGRect(x: textButton.frame.minX, y: textButton.frame.maxY + 5, width: width/4, height: 30)
        textLabel.text = "Start a new \n text chat"
        textLabel.numberOfLines = 2
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 17.5)
        textLabel.sizeToFit()
        textLabel.center.x = textButton.center.x
        view.addSubview(textLabel)
        
        videoButton.frame = CGRect(x: 7*width/12, y: 1, width: width/4, height: width/4)
        videoButton.setImage(UIImage(named: "optionvideo")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        videoButton.imageView?.contentMode = .center
        videoButton.center.y = view.center.y/2
        videoButton.addTarget(self, action: #selector(notAvailable), for: .touchUpInside)
        view.addSubview(videoButton)
        videoLabel.frame = CGRect(x: videoButton.frame.minX, y: videoButton.frame.maxY + 5, width: width/4, height: 30)
        videoLabel.text = "Start a new \n video chat"
        videoLabel.numberOfLines = 2
        videoLabel.textAlignment = .center
        videoLabel.font = UIFont.systemFont(ofSize: 18)
        videoLabel.sizeToFit()
        videoLabel.center.x = videoButton.center.x
        view.addSubview(videoLabel)
        
        callButton.frame = CGRect(x: width/6, y: 1, width: width/4, height: width/4)
        callButton.setImage(UIImage(named: "optionsTeam")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        callButton.imageView?.contentMode = .center
        callButton.center.y = view.center.y
        callButton.addTarget(self, action: #selector(joinOrg), for: .touchUpInside)
        view.addSubview(callButton)
        callLabel.frame = CGRect(x: callButton.frame.minX, y: callButton.frame.maxY + 5, width: width/2, height: 30)
        callLabel.text = "Create or join \nOrg/Team"
        callLabel.numberOfLines = 2
        callLabel.textAlignment = .center
        callLabel.font = UIFont.systemFont(ofSize: 18)
        callLabel.sizeToFit()
        callLabel.center.x = callButton.center.x
        view.addSubview(callLabel)
            
        broadcastButton.frame = CGRect(x: 7*width/12, y: 1, width: width/4, height: width/4)
        broadcastButton.setImage(UIImage(named: "optioncall")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        broadcastButton.imageView?.contentMode = .center
        broadcastButton.center.y = view.center.y
        broadcastButton.addTarget(self, action: #selector(goToCalls), for: .touchUpInside)
        view.addSubview(broadcastButton)
        broadcastLabel.frame = CGRect(x: broadcastButton.frame.minX, y: broadcastButton.frame.maxY + 5, width: width, height: 30)
        broadcastLabel.text = "Make a call"
        broadcastLabel.numberOfLines = 2
        broadcastLabel.textAlignment = .center
        broadcastLabel.font = UIFont.systemFont(ofSize: 18)
        broadcastLabel.sizeToFit()
        broadcastLabel.center.x = broadcastButton.center.x
        view.addSubview(broadcastLabel)
        
        goToChatsButton.frame = CGRect(x: width/6, y: 1, width: width/4, height: width/4)
        goToChatsButton.setImage(UIImage(named: "optionrecents")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        goToChatsButton.imageView?.contentMode = .center
        goToChatsButton.center.y = view.center.y * 1.5
        goToChatsButton.addTarget(self, action: #selector(goToChats), for: .touchUpInside)
        view.addSubview(goToChatsButton)
        goToChatsLabel.frame = CGRect(x: goToChatsButton.frame.minX, y: goToChatsButton.frame.maxY + 5, width: width/4, height: 30)
        goToChatsLabel.text = "Recent Chats"
        goToChatsLabel.numberOfLines = 1
        goToChatsLabel.textAlignment = .center
        goToChatsLabel.font = UIFont.systemFont(ofSize: 18)
        goToChatsLabel.sizeToFit()
        goToChatsLabel.center.x = goToChatsButton.center.x
        view.addSubview(goToChatsLabel)
        
        settingsButton.frame = CGRect(x: 7*width/12, y: 1, width: width/4, height: width/4)
        settingsButton.setImage(UIImage(named: "optionsettings")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        settingsButton.imageView?.contentMode = .center
        settingsButton.center.y = view.center.y * 1.5
        settingsButton.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        view.addSubview(settingsButton)
        settingsLabel.frame = CGRect(x: settingsButton.frame.minX, y: settingsButton.frame.maxY + 5, width: width/4, height: 30)
        settingsLabel.text = "Settings"
        settingsLabel.numberOfLines = 1
        settingsLabel.textAlignment = .center
        settingsLabel.font = UIFont.systemFont(ofSize: 18)
        settingsLabel.sizeToFit()
        settingsLabel.center.x = settingsButton.center.x
        view.addSubview(settingsLabel)
        
        self.singleMessageLabel.frame = CGRect(x: self.singleMessage.frame.minX, y: self.singleMessage.frame.maxY + 10, width: self.width/4, height: 30)
        self.singleMessageLabel.text = "1 on 1 Chat"
        self.singleMessageLabel.sizeToFit()
        self.singleMessageLabel.center.x = self.singleMessage.center.x
        
        self.groupMessageLabel.frame = CGRect(x: self.groupMessage.frame.minX, y: self.groupMessage.frame.maxY + 10, width: self.width/4, height: 30)
        self.groupMessageLabel.text = "Group Chat"
        self.groupMessageLabel.sizeToFit()
        self.groupMessageLabel.center.x = self.groupMessage.center.x
        
        self.teamMessageLabel.frame = CGRect(x: self.teamMessage.frame.minX, y: self.teamMessage.frame.maxY + 10, width: self.width/4, height: 30)
        self.teamMessageLabel.text = "Team Chat"
        self.teamMessageLabel.sizeToFit()
        self.teamMessageLabel.center.x = self.teamMessage.center.x
        
        self.orgMessageLabel.frame = CGRect(x: self.orgMessage.frame.minX, y: self.orgMessage.frame.maxY + 10, width: self.width/3, height: 30)
        self.orgMessageLabel.text = "Organization Chat"
        self.orgMessageLabel.sizeToFit()
        self.orgMessageLabel.center.x = self.orgMessage.center.x
        
        self.undoButton.frame = CGRect(x: 10, y: 1, width: 100, height: 30)
        self.undoButton.setTitle("< Back", for: [])
        self.undoButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: [])
        self.undoButton.center.y = self.optionLabel.center.y
        
        
    }
    
    @objc func showModes(_ sender: UIButton) {
        let tag = sender.tag
        switch tag {
        case 1:
            showFour()
        default:
            print("okok")
        }
    }
    
    @objc func joinOrg() {
        let contactsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "orgteam") as! OrgTeamRegistrationViewController
        self.navigationController?.pushViewController(contactsVC, animated: true)
    }
    
    func showFour() {
        
        UIView.animate(withDuration: 0.5) {
            let width = self.width
            self.optionLabel.alpha = 1
            self.optionLabel.center.x = self.titleLabel.center.x
            for button in self.sixButtons {
                button.alpha = 0
            }
            for label in self.sixLabels {
                label.alpha = 0
            }
            for button in self.modeButtons {
                button.alpha = 1
                
            }
            for label in self.modeLabels {
                label.alpha = 1
            }
            
            
            
            self.undoButton.alpha = 1
        }
        
    }
    
    @objc func undoAction() {
        UIView.animate(withDuration: 1) {
            self.optionLabel.alpha = 0
            self.undoButton.alpha = 0
            for button in self.sixButtons {
                button.alpha = 1
            }
            for label in self.sixLabels {
                label.alpha = 1
            }
            for button in self.modeButtons {
                button.alpha = 0
            }
            for label in self.modeLabels {
                label.alpha = 0
            }
            
        }
        
    }
    
    @objc func goToChats() {
        self.performSegue(withIdentifier: "showChats", sender: nil)
    }
    
    @objc func notAvailable() {
        ProgressHUD.showError("Coming soon!")
    }
    
    @objc func goToSettings() {
        self.performSegue(withIdentifier: "showSettings", sender: nil)
    }
    
    @objc func startChat(_ sender: UIButton) {
        
        isGroup = (sender.tag != 7)
        let contactsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "contactsView") as! ContactsTableViewController

        contactsVC.isGroup = isGroup
        switch sender.tag {
        case 9:
            contactsVC.filterType = "team"
            contactsVC.startIndex = 0
        case 10:
            contactsVC.filterType = "org"
            contactsVC.startIndex = 1
        default:
            contactsVC.filterType = ""
            contactsVC.startIndex = 2
        }

        self.navigationController?.pushViewController(contactsVC, animated: true)
    }
    
    @objc func goToCalls() {
        let callsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "allCallsView") as! CallTableViewController
        self.navigationController?.pushViewController(callsVC, animated: true)
    }
    

}
