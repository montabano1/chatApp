//
//  CallTableViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/6/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseFirestore

class CallTableViewController: UITableViewController, UISearchResultsUpdating {

    var allCalls: [CallClass] = []
    var filteredCalls: [CallClass] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let searchController = UISearchController(searchResultsController: nil)
    var callListener: ListenerRegistration!

    
    override func viewWillAppear(_ animated: Bool) {
        loadCalls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        callListener.remove()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        let nextButton = UIBarButtonItem(title: "New Call", style: .plain, target: self, action: #selector(self.newButtonPressed))
        self.navigationItem.rightBarButtonItem = nextButton
        self.navigationItem.rightBarButtonItems = [nextButton]
        self.navigationItem.rightBarButtonItems!.first!.isEnabled = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredCalls.count
        }
        return allCalls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CallTableViewCell
        
        var call: CallClass!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            call = filteredCalls[indexPath.row]
        } else {
            call = allCalls[indexPath.row]
        }
        
        cell.generateCellWith(call: call)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var tempCall: CallClass!
            if searchController.isActive && searchController.searchBar.text != "" {
                tempCall = filteredCalls[indexPath.row]
                filteredCalls.remove(at: indexPath.row)
            } else {
                tempCall = allCalls[indexPath.row]
                allCalls.remove(at: indexPath.row)
            }
            
            tempCall.deleteCall()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var call: CallClass!
        var busPhone = ""
        if searchController.isActive && searchController.searchBar.text != "" {
            call = filteredCalls[indexPath.row]
        } else {
            call = allCalls[indexPath.row]
        }
        if call.isIncoming {
            reference(.User).document(call.callerId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                if snapshot.exists {
                    let userDictionary = snapshot.data() as! NSDictionary
                    let tempUser = FUser(_dictionary: userDictionary)
                    busPhone = tempUser.phoneNumber
                    self.makeCall(busPhone: busPhone)
                }
            }
        } else {
            reference(.User).document(call.withUserId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                if snapshot.exists {
                    let userDictionary = snapshot.data() as! NSDictionary
                    let tempUser = FUser(_dictionary: userDictionary)
                    busPhone = tempUser.phoneNumber
                    self.makeCall(busPhone: busPhone)
                }
            }
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
    
    @objc func newButtonPressed() {
        let contactsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "contactsView") as! ContactsTableViewController
        contactsVC.isCall = true
        self.navigationController?.pushViewController(contactsVC, animated: true)
    }
    
    func loadCalls() {
        callListener = reference(.Call).document(FUser.currentId()).collection(FUser.currentId()).order(by: kDATE, descending: true).limit(to: 20).addSnapshotListener({ (snapshot, error) in
            self.allCalls = []
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                let sortedDictionary = dictionaryFromSnapshots(snapshots: snapshot.documents)
                for callDictionary in sortedDictionary {
                    let call = CallClass(_dictionary: callDictionary)
                    self.allCalls.append(call)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func filteredContentForSearchText(searchText: String, scope: String = "All") {
        filteredCalls = allCalls.filter({ (call) -> Bool in
            var callerName: String!
            if call.callerId == FUser.currentId() {
                callerName = call.withUserFullName
            } else {
                callerName = call.callerFullName
            }
            return (callerName).lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
