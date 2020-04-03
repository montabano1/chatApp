//
//  ChatsViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/19/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RecentChatTableViewDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    var sentTexts: [[String : Any]] = []
    var usersNames: [String:String] = [:]
    var filteredAlready = false
    var recentListener: ListenerRegistration!
    let searchController = UISearchController(searchResultsController: nil)
    var popCounter = 0
    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        selectUserForChat(isGroup: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        sentTexts = []
        loadRecentChats()
        tableView.tableFooterView = UIView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        searchController.searchBar.text = ""
        sentTexts = []
        recentListener.remove()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.9400385618, green: 0.9401959181, blue: 0.9400178194, alpha: 1)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        setTableViewHeader()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredChats.count
        } else {
            return recentChats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentChatTableViewCell
        cell.delegate = self
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        } else {
            recent = recentChats[indexPath.row]
        }
        //print(recent)
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !searchController.isActive
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var tempRecent: NSDictionary!
        tempRecent = recentChats[indexPath.row]
        if !searchController.isActive {
            var muteTitle = "Unmute"
            var mute = false
            
            if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
                muteTitle = "Mute"
                mute = true
            }
            let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
                self.recentChats.remove(at: indexPath.row)
                
                deleteRecentChat(recentChatDictionary: tempRecent)
                
                self.tableView.reloadData()
            }
            let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
                self.updatePushMembers(recent: tempRecent, mute: mute)
            }
            muteAction.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
            
            return [deleteAction, muteAction]
        }
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var recent: NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        } else {
            recent = recentChats[indexPath.row]
        }
        
        //restart chat
        restartRecentChat(recent: recent)
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
        chatVC.memberIds = (recent[kMEMBERS] as? [String])!
        chatVC.chatroomId = (recent[kCHATROOMID] as? String)!
        chatVC.titleName = (recent[kWITHUSERFULLNAME] as? String)!
        chatVC.isGroup = (recent[kTYPE] as! String) == kGROUP
        chatVC.startMessage = (recent[kLASTMESSAGE] as? String)!
        navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    func loadRecentChats() {
        reference(.Text).whereField("receivers", arrayContains: FUser.currentId()).addSnapshotListener( { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            for recent in snapshot.documents {
                self.sentTexts.append(recent.data())
            }
            self.tableView.reloadData()
        })
        
        reference(.User).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            for recent in snapshot.documents {
                let data = recent.data()
                self.usersNames[data[kOBJECTID] as! String] = (data[kFULLNAME] as! String)
            }
            self.tableView.reloadData()
        }
        
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            self.recentChats = []
            if !snapshot.isEmpty {
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                    }
                }
                self.tableView.reloadData()
            }
        })
        
        
    }
    
    func setTableViewHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableView.frame.width, height: 35))
        
        let groupButton = UIButton(frame: CGRect(x: view.bounds.width - 110, y: 10, width: 100, height: 20))
        groupButton.addTarget(self, action: #selector(self.groupButtonPressed), for: .touchUpInside)
        groupButton.setTitle("New Group", for: .normal)
        let buttonColor = #colorLiteral(red: 0.006370984018, green: 0.4774341583, blue: 0.9984987378, alpha: 1)
        groupButton.setTitleColor(buttonColor, for: .normal)
        
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: tableView.frame.width, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        tableView.tableHeaderView = headerView
    }
    
    @objc func groupButtonPressed() {
        print("hello")
    }
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
        var recentChat: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            recentChat = filteredChats[indexPath.row]
        } else {
            recentChat = recentChats[indexPath.row]
        }
        if recentChat[kTYPE] as! String == kPRIVATE {
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                if snapshot.exists {
                    let userDictionary = snapshot.data() as! NSDictionary
                    let tempUser = FUser(_dictionary: userDictionary)
                    self.showUserProfile(user: tempUser)
                }
            }
        }
    }
    
    func showUserProfile(user: FUser) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "profileView") as! ProfileViewTableViewController
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredChats = recentChats.filter({ (recentChat) -> Bool in
            var nameHasIt = (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased()) && !(recentChat[kLASTMESSAGE] as! String).lowercased().contains(searchText.lowercased())
            
            return (nameHasIt)
        })
        if searchText.count >= 1 {
            for text in sentTexts {
                if (text["text"] as! String).lowercased().contains(searchText.lowercased()) {
                    let tempChat = NSMutableDictionary()
                    tempChat["chatRoomID"] = text["chatroomId"]
                    tempChat["avatar"] = ""
                    tempChat["counter"] = 0
                    tempChat["date"] = text["date"]
                    tempChat["members"] = text["receivers"]
                    tempChat["membersToPush"] = text["receivers"]
                    tempChat["recentId"] = text["messageId"]
                    tempChat["type"] = kPRIVATE
                    tempChat["userId"] = FUser.currentId()
                    for users in text["receivers"] as! [String] {
                        if users != FUser.currentId() {
                            tempChat["withUserFullName"] = usersNames[users]
                            tempChat["withUserUserID"] = users
                            var avatar = imageFromInitials(firstName: usersNames[users]?.components(separatedBy:  " ")[0] as! String, lastName: usersNames[users]?.components(separatedBy:  " ")[1] as! String) { (avatarInitials) in
                                
                                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
                                let avatar = avatarIMG?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                                
                                tempChat["avatar"] = avatar
                            }
                        }
                    }
                    tempChat["lastMessage"] = text["text"]
                    filteredChats.append(tempChat)
                    popCounter += 1
                }
            }
        }
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func selectUserForChat(isGroup: Bool) {
        let contactsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "contactsView") as! ContactsTableViewController

        contactsVC.isGroup = isGroup

        self.navigationController?.pushViewController(contactsVC, animated: true)
        
//        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "usersTableView") as! UsersTableViewController
//
//        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    func updatePushMembers(recent: NSDictionary, mute: Bool) {
        var membersToPush = recent[kMEMBERSTOPUSH] as! [String]
        if mute {
            let index = membersToPush.index(of: FUser.currentId())!
            membersToPush.remove(at: index)
        } else {
            membersToPush.append(FUser.currentId())
        }
        
        updateExistingRecentWithNewValues(chatroomId: recent[kCHATROOMID] as! String, members: recent[kMEMBERS] as! [String], withValues: [kMEMBERSTOPUSH : membersToPush])
    }
}
