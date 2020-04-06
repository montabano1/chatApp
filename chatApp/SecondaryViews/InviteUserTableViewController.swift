//
//  InviteUserTableViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/1/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class InviteUserTableViewController: UITableViewController, UserTableViewCellDelegate {
    
    
    
    @IBOutlet weak var headerView: UIView!
    
    var allUsers: [FUser] = []
    var allUsersGrouped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList : [String] = []
    
    var newMemberIds: [String] = []
    var currentMemberIds: [String] = []
    var group: NSDictionary!
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers(filter: "team")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ProgressHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Users"
        tableView.tableFooterView = UIView()
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        currentMemberIds = group[kMEMBERS] as! [String]
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.allUsersGrouped.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionTitle = self.sectionTitleList[section]
        
        let users = self.allUsersGrouped[sectionTitle]
        
        return users!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUsersGrouped[sectionTitle]
        cell.generateCellWith(fUser: users![indexPath.row], indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionTitleList[section]
        
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        return self.sectionTitleList
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUsersGrouped[sectionTitle]
        let selectedUser = users![indexPath.row]
        if currentMemberIds.contains(selectedUser.objectId) {
            ProgressHUD.showError("Already in the group!")
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }
        
        let selected = newMemberIds.contains(selectedUser.objectId)
        
        if selected {
            let objectIndex = newMemberIds.index(of: selectedUser.objectId)!
            newMemberIds.remove(at: objectIndex)
        } else {
            newMemberIds.append(selectedUser.objectId)
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = newMemberIds.count > 0
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func loadUsers(filter: String) {
        ProgressHUD.show()
        
        var query: Query!
        
        switch filter {
        case kTEAMS:
            query = reference(.User).whereField(kTEAMS, isEqualTo: FUser.currentUser()!.teams).order(by: kFIRSTNAME, descending: false)
        case kORGANIZATIONS:
            query = reference(.User).whereField(kORGANIZATIONS, isEqualTo: FUser.currentUser()!.organizations).order(by: kFIRSTNAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapshot, error) in
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGrouped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss()
                return
            }
            
            if !snapshot.isEmpty {
                for userDictionary in snapshot.documents {
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    if fUser.objectId != FUser.currentId() {
                        self.allUsers.append(fUser)
                    }
                }
                
                self.splitDataIntoSections()
                self.tableView.reloadData()
            }
            
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
    }
    
    fileprivate func splitDataIntoSections() {
        var sectionTitle: String = ""
        for i in 0..<self.allUsers.count {
            let currentUser = self.allUsers[i]
            let firstChar = currentUser.firstname.first!
            let firstCharString = "\(firstChar)"
            if firstCharString != sectionTitle {
                sectionTitle = firstCharString
                self.allUsersGrouped[sectionTitle] = []
                if !sectionTitleList.contains(sectionTitle) {
                    self.sectionTitleList.append(sectionTitle)
                }
            }
            self.allUsersGrouped[firstCharString]?.append(currentUser)
        }
    }
    
    
    @IBAction func filterSegmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: kTEAMS)
        case 1:
            loadUsers(filter: kORGANIZATIONS)
        case 2:
            loadUsers(filter: "")
        default:
            return
        }
    }
    
    @objc func doneButtonPressed() {
        
        updateGroup(group: group)
        
    }
    
    
    
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "profileView") as! ProfileViewTableViewController
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        
        let users = self.allUsersGrouped[sectionTitle]
        profileVC.user = users![indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func updateGroup(group: NSDictionary) {
        let tempMembers = currentMemberIds + newMemberIds
        let tempMembersToPush = group[kMEMBERSTOPUSH] as! [String] + newMemberIds
        
        let withValues = [kMEMBERS : tempMembers, kMEMBERSTOPUSH : tempMembersToPush]
        Group.updateGroup(groupId: group[kGROUPID] as! String, withValues: withValues)
        
        createRecentForNewMembers(groupId: group[kGROUPID] as! String, groupName: group[kNAME] as! String, membersToPush: tempMembersToPush, avatar: group[kAVATAR] as! String)
        updateExistingRecentWithNewValues(chatroomId: group[kGROUPID] as! String, members: tempMembers, withValues: withValues)
        goToGroupChat(membersToPush: tempMembersToPush, members: tempMembers)
        
    }
    
    func goToGroupChat(membersToPush: [String], members: [String]) {
        let chatVC = ChatViewController()
        chatVC.titleName = group[kNAME] as! String
        chatVC.memberIds = members
        chatVC.membersToPush = membersToPush
        chatVC.chatroomId = group[kGROUPID] as! String
        chatVC.isGroup = true
        chatVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
}
