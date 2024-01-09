import Foundation
import WatchConnectivity

class IOSConnector : NSObject,  WCSessionDelegate, ObservableObject {
    var session: WCSession
    @Published var punchState: String = "None"
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            print(message["message"] as? String ?? "Unknown")
            DispatchQueue.main.async {
                self.punchState = message["punchState"] as? String ?? "X"
            }
        }
}

//    func sendToIOS(result: Double) {
//        if session.isReachable {
//            let data: [String: Any] = [
//                "vx": result
//            ]
//            session.sendMessage(data, replyHandler: { reply in
//                // Handle reply if needed
//                print("Reply received: \(reply)")
//            }, errorHandler: { error in
//                print("Error sending message: \(error.localizedDescription)")
//            })
//            print("Message sent")
//        } else {
//            print("Session not reachable")
//        }
//    }
