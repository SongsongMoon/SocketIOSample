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
}

