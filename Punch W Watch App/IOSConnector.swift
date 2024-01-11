import Foundation
import WatchConnectivity

class IOSConnector : NSObject,  WCSessionDelegate, ObservableObject {
    var session: WCSession
    @Published var punchState: String = "None"
    @Published var handState: String = "Left Hand"
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.punchState = message["punchState"] as? String ?? ""
            self.handState = message["handState"] as? String ?? "Left Hand"
        }
    }
}
