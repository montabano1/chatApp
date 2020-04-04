//
//  ContactsTableViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/29/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import Contacts
import FirebaseFirestore
import ProgressHUD

class ContactsTableViewController: UITableViewController, UISearchResultsUpdating, UserTableViewCellDelegate {
    
    var users: [FUser] = []
    var matchedUsers: [FUser] = []
    var filteredMatchedUsers: [FUser] = []
    var allUsersGrouped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList: [String] = []
    
    var isGroup = false
    var filterType = ""
    var memberIdsOfGroupChat: [String] = []
    var membersOfGroupChat: [FUser] = []
    
    let headerView = UIView()
    let participantsLabel = UILabel()
    var originalFilter = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var contacts: [CNContact] = {
        
        let contactStore = CNContactStore()
        
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try     contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        
        membersOfGroupChat = []
        memberIdsOfGroupChat = []
        
        loadUsers()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contacts"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        participantsLabel.frame = CGRect(x: 20, y: 0, width: 200, height: 40)
        headerView.addSubview(participantsLabel)
        
        setupButtons()
        
    }
    
    //MARK: TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        } else {
            return self.allUsersGrouped.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredMatchedUsers.count
        } else {
            // find section title
            let sectionTitle = self.sectionTitleList[section]
            
            // find users for given section title
            let users = self.allUsersGrouped[sectionTitle]
            
            // return count for users
            return users!.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UserTableViewCell
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredMatchedUsers[indexPath.row]
        } else {
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            //get all users of the section
            let users = self.allUsersGrouped[sectionTitle]
            
            user = users![indexPath.row]
        }
        
        cell.delegate = self
        cell.generateCellWith(fUser: user, indexPath: indexPath)
        
        switch filterType {
        case "team":
            if user.team == FUser.currentUser()?.team {
                cell.accessoryType = .checkmark
                memberIdsOfGroupChat.append(user.objectId)
                membersOfGroupChat.append(user)
                self.navigationItem.rightBarButtonItems!.first!.isEnabled = true
                let teamName = UILabel()
                teamName.text = "" + user.organization + "-" + user.team
                cell.addSubview(teamName)
                teamName.frame = CGRect(x: cell.frame.width , y: 75, width: 100, height: 25)
                teamName.sizeToFit()
                teamName.center.x -= (teamName.frame.width + 10)
            }
        case "org":
            if user.organization == FUser.currentUser()?.organization {
                cell.accessoryType = .checkmark
                memberIdsOfGroupChat.append(user.objectId)
                membersOfGroupChat.append(user)
                self.navigationItem.rightBarButtonItems!.first!.isEnabled = true
                let teamName = UILabel()
                teamName.text = "" + user.organization
                cell.addSubview(teamName)
                teamName.frame = CGRect(x: cell.frame.width , y: 75, width: 100, height: 25)
                teamName.sizeToFit()
                teamName.center.x -= (teamName.frame.width + 10)
            }
        default:
            print("no group filter")
        }
        originalFilter = true
        participantsLabel.text = "PARTICIPANTS: \(membersOfGroupChat.count)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return ""
        } else {
            return self.sectionTitleList[section]
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        } else {
            return self.sectionTitleList
        }
    }
    
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    
    //MARK: TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let userToChat : FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            userToChat = filteredMatchedUsers[indexPath.row]
        } else {
            let users = self.allUsersGrouped[sectionTitle]
            userToChat = users![indexPath.row]
        }
        if !isGroup {
            if !checkBlockedStatus(withUser: userToChat) {
                let chatVC = ChatViewController()
                chatVC.titleName = userToChat.firstname
                chatVC.memberIds = [FUser.currentId(), userToChat.objectId]
                chatVC.membersToPush = [FUser.currentId(), userToChat.objectId]
                chatVC.chatroomId = startPrivateChat(user1: FUser.currentUser()!, user2: userToChat)
                chatVC.isGroup = false
                chatVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(chatVC, animated: true)
            } else {
                ProgressHUD.showError("This user is not available for chat")
            }
        } else {
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                } else {
                    cell.accessoryType = .checkmark
                }
            }
            let selected = memberIdsOfGroupChat.contains(userToChat.objectId)
            
            if selected {
                let objectIndex = memberIdsOfGroupChat.lastIndex(of: userToChat.objectId)
                memberIdsOfGroupChat.remove(at: objectIndex!)
                membersOfGroupChat.remove(at: objectIndex!)
            } else {
                memberIdsOfGroupChat.append(userToChat.objectId)
                membersOfGroupChat.append(userToChat)
            }
            participantsLabel.text = "PARTICIPANTS: \(membersOfGroupChat.count)"
            
            self.navigationItem.rightBarButtonItem?.isEnabled = memberIdsOfGroupChat.count > 0
        }
        
    }
    
    @objc func inviteButtonPressed() {
        let text = "Hey! Lets chat on monTalk \(kAPPURL)"
        let objectsToShare : [Any] = [text]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.setValue("Lets Chat on monTalk", forKey: "subject")
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func nextButtonPressed() {
        let newGroupVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "newGroup") as! NewGroupViewController
        
        newGroupVC.memberIds = memberIdsOfGroupChat
        newGroupVC.allMembers = membersOfGroupChat
        
        self.navigationController?.pushViewController(newGroupVC, animated: true)
        
    }
    
    func loadUsers() {
        ProgressHUD.show()
        
        reference(.User).order(by: kFIRSTNAME, descending: false).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss()
                return
            }
            
            if !snapshot.isEmpty {
                self.matchedUsers = []
                self.users.removeAll()
                
                for userDictionary in snapshot.documents {
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    if fUser.objectId != FUser.currentId() && !fUser.blockedUsers.contains(FUser.currentId()) {
                        self.users.append(fUser)
                    }
                    
                }
                ProgressHUD.dismiss()
                self.tableView.reloadData()
            }
            
            ProgressHUD.dismiss()
            self.compareUsers()
        }
    }
    
    
    func compareUsers() {
        
        
        for user in users {
            if FUser.currentUser()?.organization == user.organization {
                matchedUsers.append(user)
                self.tableView.reloadData()
            }
            
            if user.phoneNumber != "" {
                
                
                let contact = searchForContactUsingPhoneNumber(phoneNumber: user.phoneNumber)
                
                //if we have a match, we add to our array to display them
                if contact.count > 0 {
                    matchedUsers.append(user)
                }
                
                self.tableView.reloadData()
                
            }
        }
        //        updateInformationLabel()
        
        self.splitDataInToSection()
    }
    
    //MARK: Contacts
    
    func searchForContactUsingPhoneNumber(phoneNumber: String) -> [CNContact] {
        
        var result: [CNContact] = []
        
        //go through all contacts
        for contact in self.contacts {
            
            if !contact.phoneNumbers.isEmpty {
                
                for number in contact.phoneNumbers {
                    let x = (number.value).value(forKey: "digits") as! String
                    if phoneNumber == x {
                        result.append(contact)
                    }
                }
                
                self.tableView.reloadData()
                
            }
        }
        
        return result
    }
    
    
    func updatePhoneNumber(phoneNumber: String, replacePlusSign: Bool) -> String {
        
        if replacePlusSign {
            return phoneNumber.replacingOccurrences(of: "+", with: "").components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
            
        } else {
            return phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
        }
    }
    
    
    fileprivate func splitDataInToSection() {
        
        // set section title "" at initial
        var sectionTitle: String = ""
        
        // iterate all records from array
        for i in 0..<self.matchedUsers.count {
            
            // get current record
            let currentUser = self.matchedUsers[i]
            
            // find first character from current record
            let firstChar = currentUser.firstname.first!
            
            // convert first character into string
            let firstCharString = "\(firstChar)"
            
            // if first character not match with past section title then create new section
            if firstCharString != sectionTitle {
                
                // set new title for section
                sectionTitle = firstCharString
                
                // add new section having key as section title and value as empty array of string
                self.allUsersGrouped[sectionTitle] = []
                
                // append title within section title list
                if !sectionTitleList.contains(sectionTitle) {
                    self.sectionTitleList.append(sectionTitle)
                }
                
            }
            
            // add record to the section
            self.allUsersGrouped[firstCharString]?.append(currentUser)
        }
        
        tableView.reloadData()
    }
    
    func filteredContentForSearchText(searchText: String, scope: String = "All") {
        filteredMatchedUsers = matchedUsers.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased()) && !checkBlockedStatus(withUser: user)
        })
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "profileView") as! ProfileViewTableViewController
        
        var user: FUser!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredMatchedUsers[indexPath.row]
        } else {
            let sectionTitle = self.sectionTitleList[indexPath.section]
            let users = self.allUsersGrouped[sectionTitle]
            user = users![indexPath.row]
        }
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func setupButtons() {
        if isGroup {
            let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextButtonPressed))
            self.navigationItem.rightBarButtonItem = nextButton
            self.navigationItem.rightBarButtonItems!.first!.isEnabled = false
        } else {
            let inviteButton = UIBarButtonItem(image: UIImage(named: "invite"), style: .plain, target: self, action: #selector(self.inviteButtonPressed))
            self.navigationItem.rightBarButtonItems = [inviteButton]
        }
    }
    
    func addContact() {
        reference(.User).whereField(kPHONE, isEqualTo: "9145894003").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            if !snapshot.isEmpty {
                for user in snapshot.documents {
                    let userDictionary = user.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    print(fUser.fullname)
                }
            }
        }
    }
    
    
    
}
