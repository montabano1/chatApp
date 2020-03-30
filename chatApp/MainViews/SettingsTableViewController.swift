//
//  SettingsTableViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/19/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD

class SettingsTableViewController: UITableViewController
{
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var avatarStatusSwitch: UISwitch!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    
    var avatarSwitchStatus = false
    var firstLoad: Bool?
    
    override func viewDidAppear(_ animated: Bool) {
        if FUser.currentUser() != nil {
            setupUI()
            loadUserDefaults()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            return 4
        }
        return 2
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    
    @IBAction func cleanCacheButtonPressed(_ sender: Any) {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentsURL().path)
            
            for file in files {
                try FileManager.default.removeItem(atPath: "\(getDocumentsURL().path)/\(file)")
            }
            ProgressHUD.showSuccess("Cache cleaned")
        } catch {
            ProgressHUD.showError("Couldn't clean media files.")
        }
    }
    @IBAction func showAvatarSwitchValueChanged(_ sender: UISwitch) {
        avatarSwitchStatus = sender.isOn
        saveUserDefaults()
    }
    
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        let text = "Hey! Lets chat on monTalk \(kAPPURL)"
        let objectsToShare : [Any] = [text]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.setValue("Lets Chat on monTalk", forKey: "subject")
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete the account? This cannot be undone", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alert) in
            self.deleteUser()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
        
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let currentPopoverpresentationcontroller = optionMenu.popoverPresentationController {
                currentPopoverpresentationcontroller.sourceView = deleteButtonOutlet
                currentPopoverpresentationcontroller.sourceRect = deleteButtonOutlet.bounds
                
                currentPopoverpresentationcontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        FUser.logOutCurrentUser { (success) in
            
            if success {
                self.showLoginView()
            }
            
        }
    }
    @IBAction func termsAndConditionsButton(_ sender: Any) {
        
    }
    
    func showLoginView() {
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "welcome")
        self.present(mainView, animated: true, completion: nil)
        
    }
    
    func setupUI() {
        let currentUser = FUser.currentUser()!
        
        fullNameLabel.text = currentUser.fullname
        
        if currentUser.avatar != "" {
            imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = version
        }
    }
    
    func deleteUser() {
        userDefaults.removeObject(forKey: kPUSHID)
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        reference(.User).document(FUser.currentId()).delete()
        FUser.deleteUser { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError("Couldn't delete User")
                }
                return
            }
            self.showLoginView()
        }
    }
    
    func saveUserDefaults() {
        userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() {
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
            userDefaults.synchronize()
        }
        
        avatarSwitchStatus = userDefaults.bool(forKey: kSHOWAVATAR)
        avatarStatusSwitch.isOn = avatarSwitchStatus
    }
    
}
