//
//  SocketIO + Rx.swift
//  ChatSample
//
//  Created by grabity on 19/12/2019.
//  Copyright © 2019 Grabity. All rights reserved.
//

import RxSwift
import SocketIO

private var rxKey: UInt8 = 0 // We still need this boilerplate
extension SocketIOClient {
    
    var rx_event: Observable<SocketAnyEvent> {
        get {
            return associatedObject(base: self, key: &rxKey) {
                return Observable.create { observer -> Disposable in
                    
                    self.onAny() { event in
                        observer.onNext(event)
                    }
                    return Disposables.create {
                        //self.disconnect() //side effect, risky
                    }
                }.share()
            } // Set the initial value of the var
        }
        set { associateObject(base: self, key: &rxKey, value: newValue) }
    }
}

//Ref: https://medium.com/@ttikitu/swift-extensions-can-add-stored-properties-92db66bce6cd#.2t442w1hp
func associatedObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>, initialiser: () -> ValueType) -> ValueType {
    if let associated = objc_getAssociatedObject(base, key) as? ValueType {
        return associated
    }
    
    let associated = initialiser()
    objc_setAssociatedObject(base, key, associated, .OBJC_ASSOCIATION_RETAIN)
    
    return associated
}

func associateObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>, value: ValueType) {
    objc_setAssociatedObject(base, key, value,.OBJC_ASSOCIATION_RETAIN)
}

