//
//  ManagerTableViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/9/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit

class ManagerTableViewController: UITableViewController {

    var orgs = [String]()
    var teams = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orgs = FUser.currentUser()!.organizations
        teams = FUser.currentUser()!.teams
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return orgs.count
        } else {
            return teams.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if indexPath.section == 0 {
            cell.textLabel?.text = orgs[indexPath.row]
        } else {
            cell.textLabel?.text = teams[indexPath.row]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Organizations"
        }
        return "Teams"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    

}
