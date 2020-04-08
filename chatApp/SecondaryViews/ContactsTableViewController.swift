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
    var matchedUserIds: [String] = []
    
    var filteredMatchedUsers: [FUser] = []
    var allUsersGrouped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList: [String] = []
    
    var addedLabels: [UILabel] = []
    
    var isGroup = false
    var isCall = false
    var filterType = ""
    var memberIdsOfGroupChat: [String] = []
    var membersOfGroupChat: [FUser] = []
    var checkedUsers: [String] = []
    
    var filteredContacts: [FUser] = []
    var segmentedControl = UISegmentedControl()
    var startIndex = 2
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
        
        let width = view.bounds.width
        
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        
        membersOfGroupChat = []
        memberIdsOfGroupChat = []
        
        
        loadUsers()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = view.bounds.width
        
        title = "Contacts"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        participantsLabel.frame = CGRect(x: 20, y: 40, width: 200, height: 40)
        
        
        headerView.addSubview(participantsLabel)
        
        segmentedControl.frame = CGRect(x: 20, y: 0, width: width, height: 40)
        segmentedControl = UISegmentedControl(items: ["My Teams", "My Org", "All Contacts"])
        segmentedControl.addTarget(self, action: #selector(filterTeam), for: .valueChanged)
        segmentedControl.setWidth(width/3, forSegmentAt: 0)
        segmentedControl.setWidth(width/3, forSegmentAt: 1)
        segmentedControl.setWidth(width/3, forSegmentAt: 2)
        segmentedControl.selectedSegmentIndex = startIndex
        headerView.addSubview(segmentedControl)
        
        
        setupButtons()
        
    }
    
    @objc func filterTeam() {
        startIndex = segmentedControl.selectedSegmentIndex
        for label in addedLabels {
            label.removeFromSuperview()
        }
        addedLabels.removeAll()
        compareUsers()
    }
    
    //MARK: TableViewDataSofurce
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        } else {
            return self.allUsersGrouped.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != ""   {
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
            let users = self.allUsersGrouped[sectionTitle]
            user = users![indexPath.row]
        }
        
        cell.delegate = self
        
        switch filterType {
        case "team":
            var checkMe = false
            let myTeams = FUser.currentUser()?.teams
            for team in user.teams {
                if (myTeams?.contains(team))! {
                    checkMe = true
                }
            }
            if checkMe {
                if !memberIdsOfGroupChat.contains(user.objectId) {
                    cell.accessoryType = .checkmark
                    memberIdsOfGroupChat.append(user.objectId)
                    membersOfGroupChat.append(user)
                    checkedUsers.append(user.objectId)
                }
                self.navigationItem.rightBarButtonItems!.first!.isEnabled = true
            } else {
                cell.accessoryType = .none
            }
        case "org":
            var checkMe = false
            let myOrgs = FUser.currentUser()?.organizations
            for org in user.organizations {
                if (myOrgs?.contains(org))! {
                    checkMe = true
                }
            }
            if checkMe {
                if !memberIdsOfGroupChat.contains(user.objectId) {
                    cell.accessoryType = .checkmark
                    memberIdsOfGroupChat.append(user.objectId)
                    membersOfGroupChat.append(user)
                    checkedUsers.append(user.objectId)
                }
                self.navigationItem.rightBarButtonItems!.first!.isEnabled = true
            } else {
                cell.accessoryType = .none
            }
        default:
            cell.accessoryType = .none
        }
        
        if checkedUsers.contains(user.objectId) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        switch startIndex {
        case 0:
            var showMe = false
            var teamText = ""
            let myTeams = FUser.currentUser()?.teams
            for team in user.teams {
                if (myTeams?.contains(team))! {
                    showMe = true
                    teamText += " " + team
                }
            }
            if showMe {
                let teamName = UILabel()
                teamName.text = "" + teamText
                cell.addSubview(teamName)
                addedLabels.append(teamName)
                teamName.frame = CGRect(x: 80 , y: 75, width: tableView.frame.width - 100, height: 25)
                teamName.textAlignment = .right
                teamName.adjustsFontSizeToFitWidth = true
            }
        case 1:
            var showMe = false
            var orgText = ""
            let myOrgs = FUser.currentUser()?.organizations
            for org in user.organizations {
                if (myOrgs?.contains(org))! {
                    showMe = true
                    orgText += " " + org
                }
            }
            if showMe {
                let teamName = UILabel()
                teamName.text = "" + orgText
                cell.addSubview(teamName)
                addedLabels.append(teamName)
                teamName.frame = CGRect(x: 80 , y: 75, width: tableView.frame.width - 100, height: 25)
                teamName.textAlignment = .right
                teamName.adjustsFontSizeToFitWidth = true
            }
        default:
            true
        }
        cell.generateCellWith(fUser: user, indexPath: indexPath)
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
        if !isGroup && !isCall {
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
        } else if !isGroup && isCall{
            let busPhone = userToChat.phoneNumber
            makeCall(busPhone: busPhone)
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
                let checkedIndex = checkedUsers.lastIndex(of: userToChat.objectId)
                checkedUsers.remove(at: checkedIndex!)
            } else {
                memberIdsOfGroupChat.append(userToChat.objectId)
                membersOfGroupChat.append(userToChat)
                checkedUsers.append(userToChat.objectId)
            }
            participantsLabel.text = "PARTICIPANTS: \(membersOfGroupChat.count)"
            self.navigationItem.rightBarButtonItem?.isEnabled = memberIdsOfGroupChat.count > 0
        }
        
    }
    
    func makeCall(busPhone: String) {
        if let url = URL(string: "tel://\(busPhone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
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
                self.matchedUserIds = []
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
        var contacts = FUser.currentUser()?.contacts
        var updateMe = false
        matchedUsers.removeAll()
        matchedUserIds.removeAll()
        if startIndex == 2 {
            for user in users {
                for org in user.organizations {
                    let myOrgs = FUser.currentUser()?.organizations
                    if (myOrgs?.contains(org))! {
                        if !(contacts?.contains(user.objectId))! {
                            contacts?.append(user.objectId)
                        }
                        updateMe = true
                        if !matchedUserIds.contains(user.objectId) {
                            matchedUsers.append(user)
                            matchedUserIds.append(user.objectId)
                        }
                        self.tableView.reloadData()
                        continue
                    }
                }
                if user.phoneNumber != "" {
                    let contact = searchForContactUsingPhoneNumber(phoneNumber: user.phoneNumber)
                    if contact.count > 0 {
                        if !(contacts?.contains(user.objectId))! {
                            contacts?.append(user.objectId)
                        }
                        updateMe = true
                        if !matchedUserIds.contains(user.objectId) {
                            matchedUsers.append(user)
                            matchedUserIds.append(user.objectId)
                        }
                        self.tableView.reloadData()
                        continue
                    }
                    
                }
                if (contacts?.contains(user.objectId))! {
                        if !matchedUserIds.contains(user.objectId) {
                            matchedUsers.append(user)
                            matchedUserIds.append(user.objectId)
                        }
                        self.tableView.reloadData()
                        continue
                }
                self.tableView.reloadData()
            }
        } else if startIndex == 1 {
            for user in users {
                for org in user.organizations {
                    let myOrgs = FUser.currentUser()?.organizations
                    if (myOrgs?.contains(org))! {
                        if !(contacts?.contains(user.objectId))! {
                            contacts?.append(user.objectId)
                        }
                        updateMe = true
                        if !matchedUserIds.contains(user.objectId) {
                            matchedUsers.append(user)
                            matchedUserIds.append(user.objectId)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        } else if startIndex == 0 {
            for user in users {
                for team in user.teams {
                    let myTeams = FUser.currentUser()?.teams
                    if (myTeams?.contains(team))! {
                        
                        if !(contacts?.contains(user.objectId))! {
                            contacts?.append(user.objectId)
                        }
                        updateMe = true
                        if !matchedUserIds.contains(user.objectId) {
                            matchedUsers.append(user)
                            matchedUserIds.append(user.objectId)
                        }
                    }
                    self.tableView.reloadData()
                }
                self.tableView.reloadData()
            }
        }
        if updateMe {
            updateCurrentUserInFirestore(withValues: [kCONTACT : contacts as! [String]]) { (success) in
            }
        }
        participantsLabel.text = "PARTICIPANTS: \(membersOfGroupChat.count)"
        self.splitDataInToSection()
    }
    
    func searchForContactUsingPhoneNumber(phoneNumber: String) -> [CNContact] {
        var result: [CNContact] = []
        for contact in self.contacts {
            if !contact.phoneNumbers.isEmpty {
                for number in contact.phoneNumbers {
                    let x = (number.value).value(forKey: "digits") as! String
                    let last10 = String(x.suffix(10))
                    if phoneNumber == last10 {
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
    
    
    func splitDataInToSection() {
        allUsersGrouped.removeAll()
        sectionTitleList = []
        var sectionTitle: String = ""
        for currentUser in matchedUsers {
            let firstChar = currentUser.firstname.first!.uppercased()
            let firstCharString = "\(firstChar)"
            if !sectionTitleList.contains(firstCharString) {
                sectionTitleList.append(firstCharString)
                allUsersGrouped[firstCharString] = [currentUser]
            } else {
                allUsersGrouped[firstCharString]?.append(currentUser)
            }
            sectionTitleList = sectionTitleList.sorted()
        }
        
        participantsLabel.text = "PARTICIPANTS: \(membersOfGroupChat.count)"
        tableView.reloadData()
    }
    
    func filteredContentForSearchText(searchText: String, scope: String = "All") {
        filteredMatchedUsers = matchedUsers.filter({ (user) -> Bool in
            return user.fullname.lowercased().contains(searchText.lowercased()) && !checkBlockedStatus(withUser: user)
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
        let addButton: UIButton = UIButton(type: UIButton.ButtonType.contactAdd)
        addButton.addTarget(self, action: #selector(addContact), for: .touchUpInside)
        addButton.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        let addBarButton = UIBarButtonItem(customView: addButton)
        if isGroup {
            let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextButtonPressed))
            self.navigationItem.rightBarButtonItem = nextButton
            self.navigationItem.rightBarButtonItems = [nextButton, addBarButton]
            self.navigationItem.rightBarButtonItems!.first!.isEnabled = false
        } else {
            let inviteButton = UIBarButtonItem(image: UIImage(named: "invite"), style: .plain, target: self, action: #selector(self.inviteButtonPressed))
            self.navigationItem.rightBarButtonItems = [inviteButton, addBarButton]
        }
    }
    
    @objc func addContact() {
        let addVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "addContact") as! AddContactViewController
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    
    
}
