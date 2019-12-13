//
//  SocketManager.swift
//  ChatSample
//
//  Created by grabity on 12/12/2019.
//  Copyright © 2019 Grabity. All rights reserved.
//
import SocketIO

class SocketManager1: NSObject {
    static let shared = SocketManager1()
    static let manager = SocketManager(socketURL: URL(string: "http://13.125.234.34:3000")!)
    var socket = SocketManager1.manager.defaultSocket
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    /*
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
    */
    func sendMessage(_ message: String) {
        socket.emit("serverReceiver", message)
    }
    
    func getChatMessage(completion: @escaping ([String: String]) -> Void) {
        socket.on("clientReceiver") { (dataArray, socketAck) in
            var messageDictionary = [String: String]()
            
            if let messageInfo = dataArray[0] as? [String: AnyObject],
                let clientID = messageInfo["clientID"] as? Int
            {    
                let nickName = "\(clientID) 회원"
                messageDictionary["clientID"] = nickName
                messageDictionary["message"] = messageInfo["message"] as? String
            }
            
            completion(messageDictionary)
        }
    }
    
    /*
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
    */
}

