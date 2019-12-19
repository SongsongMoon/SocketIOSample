//
//  SocketManager.swift
//  ChatSample
//
//  Created by grabity on 12/12/2019.
//  Copyright © 2019 Grabity. All rights reserved.
//
import SocketIO
import RxSwift

struct Message {
    let name: String
    let text: String
}

struct User {
    let name: String
    
}

class SocketManager1: NSObject {
    static let shared = SocketManager1()
    
    var socket = SocketManager(socketURL: URL(string: "http://13.125.234.34:3000")!).defaultSocket
    
    override init() { super.init() }
    
    func establishConnection() {
        socket.on("connect") { (data, ack) -> Void in
            print("socket connected",data,ack)
        }
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func chatMessage(_ message: String, nickName: String, roomName: String) {
        let data:[String:Any] = ["name": nickName, "room": roomName, "msg": message]
        socket.emit("chat message", data)
    }
    
    func getMessageOb() -> Observable<Message?> {
        return socket.rx_event
            .filter({ $0.event == "chat message" })
            .map({ (event) -> Message? in
                guard let msgDict = event.items?.first as? [String: String],
                    let userName = msgDict["name"],
                    let msg = msgDict["msg"] else {
                    return nil
                }
                
                return Message(name: userName, text: msg)
            })
    }
    
    func getChatMessage(completion: @escaping ([String: String]) -> Void) {
        socket.on("chat message") { (dataArray, socketAck) in
            var messageDictionary = [String: String]()
            
            if let messageInfo = dataArray[0] as? [String: AnyObject],
                let clientID = messageInfo["name"] as? String
            {
                let nickName = "\(clientID) 회원"
                messageDictionary["name"] = nickName
                messageDictionary["msg"] = messageInfo["msg"] as? String
            }
            
            completion(messageDictionary)
        }
    }
    
    func joinRoom(_ roomName: String, nickName: String) {
        let data:[String:Any] = ["room": roomName, "name": nickName]
        socket.emit("join", data)
    }
}

