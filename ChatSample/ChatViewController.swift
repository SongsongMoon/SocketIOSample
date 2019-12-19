//
//  ChatViewController.swift
//  ChatSample
//
//  Created by grabity on 13/12/2019.
//  Copyright © 2019 Grabity. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var msgEditor: UITextView!
    
    var nickname = "User"
    var roomName = "room1"
    var chatMessages = [[String: String]]()
    var bannerLabelTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardDidHide),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
        //        msgEditor.delegate = self
        SocketManager1.shared.joinRoom(roomName, nickName: nickname)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SocketManager1.shared.getChatMessage { (messageInfo) in
            DispatchQueue.main.async {
                self.chatMessages.append(messageInfo)
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "idCellChat")
        tableView.estimatedRowHeight = 90.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    private func scrollToBottom() {
        guard self.chatMessages.count > 0 else { return }
        
        let lastRowIndexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
        self.tableView.scrollToRow(at: lastRowIndexPath,
                                   at: .bottom,
                                   animated: true)
    }
    
    func askForNickname() {
        
        let alertController = UIAlertController(title: "socketChat", message: "Please enter a nickname : ", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            
            let textField = alertController.textFields![0]
            if textField.text?.count == 0 {
                self.askForNickname()
            }
            else {
                self.nickname = textField.text ?? "User"
            }
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func didTouchedSend(_ sender: UIButton) {
        if msgEditor.text.count > 0 {
            SocketManager1.shared.chatMessage(msgEditor.text, nickName: nickname, roomName: roomName)
            msgEditor.text = ""
            msgEditor.resignFirstResponder()
        }
    }
    
    @objc func handleKeyboardDidShow(notification: NSNotification) {
        
    }
    
    @objc func handleKeyboardDidHide(notification: NSNotification) {
        
    }
}


extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellChat", for: indexPath) as! ChatCell
        
        let currentChatMessage = chatMessages[indexPath.row]
        if let senderNickname = currentChatMessage["name"],
            let message = currentChatMessage["msg"]
        {
            cell.lblChatMessage.text = "\(senderNickname) : \(message)"
        }
        
        return cell
    }
}
