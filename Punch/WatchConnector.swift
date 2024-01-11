import Foundation
import WatchConnectivity

class WatchConnector : NSObject,  WCSessionDelegate, ObservableObject {
    
//    var session: WCSession
//    @Published var messageText = 0.0
//    @Published var isConnected = false
//    
//    init(session: WCSession = .default) {
//        self.session = session
//        super.init()
//        session.delegate = self
//        session.activate()
//    }
//    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        updateConnectionStatus()
//    }
    
    var session: WCSession
    @Published var messageText = 0.0
    @Published var isReachable = false
    
    override init() {
        self.session = WCSession.default
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
            DispatchQueue.main.async {
                self.isReachable = session.isReachable
            }
        }
    
    func sessionDidBecomeInactive(_ session: WCSession) {

    }
    
    func sessionDidDeactivate(_ session: WCSession) {

    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.messageText = message["message"] as? Double ?? 0.0
        }
    }

    
    
}
