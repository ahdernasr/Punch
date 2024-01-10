//
//  WatchConnector.swift
//  Punch
//
//  Created by Ahmed Nasr on 09/01/2024.
//

import Foundation
import WatchConnectivity

class WatchConnector : NSObject,  WCSessionDelegate, ObservableObject {
    
    var session: WCSession
    @Published var messageText = 0.0
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message["message"] as? Double ?? 0.0)
            DispatchQueue.main.async {
                self.messageText = message["message"] as? Double ?? 0.0
            }
        }
    
    
}
