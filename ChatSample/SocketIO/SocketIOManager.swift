//
//  SocketIOManager.swift
//  ChatSample
//
//  Created by grabity on 12/12/2019.
//  Copyright © 2019 Grabity. All rights reserved.
//

import SocketIO

class SocketIOManager: NSObject {
    static let shared = SocketIOManager()
    static let manager = SocketManager(socketURL: URL(string: "http://192.168.35.151:3000")!)
    var socket = SocketIOManager.manager.defaultSocket
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToServer(nickName: String, completion:@escaping ([[String: AnyObject]]?) -> Void) {
        socket.emit("connectUser", nickName)
        
        socket.on("userList") { (dataArray, ack) in
            completion(dataArray[0] as? [[String: AnyObject]])
        }
        
        listenForOtherMessages()
    }
    
    func exitChat(nickName: String, completion: ()->Void) {
        socket.emit("exitUser", nickName)
        completion()
    }
    
    func sendMessage(_ message: String, withNickName nickName: String) {
        socket.emit("chatMessage", nickName, message)
    }
    
    func getChatMessage(completion: @escaping ([String: String]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) in
            var messageDictionary = [String: String]()
            messageDictionary["nickname"] = dataArray[0] as? String
            messageDictionary["message"] = dataArray[1] as? String
            messageDictionary["date"] = dataArray[2] as? String
            
            completion(messageDictionary)
        }
    }
    
    private func listenForOtherMessages() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("userExitUpdate") { (dataArray, socketAck) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: dataArray[0] as! String)
        }
        
        socket.on("userTypingUpdate") { (dataArray, socketAck) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userTypingNotification"), object: dataArray[0] as! [String: AnyObject])
        }
    }
    
    func sendStartTypingMessage(nickName: String) {
        socket.emit("startType", nickName)
    }
    
    func sendStopTypingMessage(nickName: String) {
        socket.emit("stopType", nickName)
    }
}
