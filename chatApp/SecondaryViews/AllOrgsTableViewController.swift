//
//  AllOrgsTableViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/5/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit

class AllOrgsTableViewController: UITableViewController {
    
    var myAdminOrgNames = [String]()
    var myAdminOrgIds = [String]()
    let headerView = UIView()
    var chosenOrg = ""
    var chosenName = ""

    override func viewWillAppear(_ animated: Bool) {
        
        
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: topbarHeight)
        tableView.tableHeaderView = headerView
        
        let titleLabel = UILabel()
        titleLabel.frame = headerView.frame
        titleLabel.textAlignment = .center
        titleLabel.text = "Choose Organization \n that team belongs to"
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 22)
        headerView.addSubview(titleLabel)
        
        
        let adminLabel = UILabel()
        adminLabel.frame = CGRect(x: 0, y: 20, width: tableView.frame.width - 20, height: 200)
        adminLabel.textAlignment = .center
        adminLabel.text = "\n \nYou must be an admin of an organization \nto be able to create a team. Admin\nstatus can be granted by your \norganization's admins."
        adminLabel.numberOfLines = 0
        adminLabel.font = UIFont.systemFont(ofSize: 22)
        adminLabel.sizeToFit()
        adminLabel.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        tableView.tableFooterView = adminLabel
        
        
        for org in FUser.currentUser()!.adminOrgs {
            reference(.Organization).document(org).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                let name = snapshot.data()!["Name"] as! String
                if !self.myAdminOrgIds.contains(org) {
                    self.myAdminOrgNames.append(name)
                    self.myAdminOrgIds.append(org)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myAdminOrgIds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = myAdminOrgNames[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenName = myAdminOrgNames[indexPath.row]
        chosenOrg = myAdminOrgIds[indexPath.row]
        
        performSegue(withIdentifier: "createTeam", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! CreateTeamViewController
        vc.orgName = chosenName
        vc.orgId = chosenOrg
    }

}
