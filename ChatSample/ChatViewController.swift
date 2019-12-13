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
    
    var nickname: String!
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
        let delay = 0.1 * Double(NSEC_PER_SEC)
        
        guard self.chatMessages.count > 0 else { return }
        
        let lastRowIndexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
        self.tableView.scrollToRow(at: lastRowIndexPath,
                                   at: .bottom,
                                   animated: true)
    }

    @IBAction func didTouchedSend(_ sender: UIButton) {
        if msgEditor.text.count > 0 {
            SocketManager1.shared.sendMessage(msgEditor.text)
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
        
        //{clientID: clientID, message: value}
        let currentChatMessage = chatMessages[indexPath.row]
        if let senderNickname = currentChatMessage["clientID"],
            let message = currentChatMessage["message"]
        {
            cell.lblChatMessage.text = "\(senderNickname) : \(message)"
        }
        
        return cell
    }
}
