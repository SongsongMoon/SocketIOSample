//
//  ViewController.swift
//  ChatSample
//
//  Created by grabity on 12/12/2019.
//  Copyright © 2019 Grabity. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    @IBOutlet var userListTable: UITableView!
    
    var users = [[String: AnyObject]]()
    var nickName: String!
    var configurationOK = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !configurationOK {
            configureNavigationBar()
            configureTableView()
            configurationOK = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if nickName == nil {
            askForNickname()
        }
    }

    @IBAction func exitChat(_ sender: Any) {
        
        SocketIOManager.shared.exitChat(nickName: nickName) {
            DispatchQueue.main.async {
                self.nickName = ""
                self.users.removeAll()
                self.userListTable.isHidden = true
                self.askForNickname()
            }
        }
    }
    
}

extension UserViewController {
    func configureNavigationBar() {
        navigationItem.title = "SocketChat"
    }
    
    func configureTableView() {
        userListTable.delegate = self
        userListTable.dataSource = self
        userListTable.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "idCellUser")
        userListTable.isHidden = true
        userListTable.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func askForNickname() {
        /*
        let alertController = UIAlertController(title: "socketChat", message: "Please enter a nickname : ", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            
            let textField = alertController.textFields![0]
            if textField.text?.count == 0 {
                self.askForNickname()
            }
            else {
                self.nickName = textField.text
                SocketIOManager.shared.connectToServer(nickName: self.nickName,
                                                       completion: { (userList) in
                                                        DispatchQueue.main.async {
                                                            if userList != nil {
                                                                self.users = userList!
                                                                self.userListTable.reloadData()
                                                                self.userListTable.isHidden = false
                                                            }
                                                        }
                })
            }
            
 
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
         */
    }
}

extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellUser", for: indexPath) as! UserCell
        cell.textLabel?.text = users[indexPath.row]["nickname"] as? String
        cell.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
        cell.detailTextLabel?.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.green : UIColor.red
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
}


