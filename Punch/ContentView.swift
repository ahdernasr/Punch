//
//  ContentView.swift
//  Punch
//
//  Created by Ahmed Nasr on 10/11/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var connector = WatchConnector()
    @State var reachable = "No"
    @State var timerValue = "Starting..."
        
    var body: some View {
        VStack{
            Text("Reachable \(reachable)")
            
            Button(action: {
                if self.connector.session.isReachable {
                    self.reachable = "Yes"
                }
                else{
                    self.reachable = "No"
                }
                
            }) {
                Text("Update")
            }
        
            Text("Value: \(connector.messageText)")
        
        Button(action: {
            let timer = CustomTimer(interval:  1, counter: 0, value: $timerValue, punchCallback: {
                connector.session.sendMessage(["punchState" : "Punch!"], replyHandler: nil) { (error) in
                                    print(error.localizedDescription)
                                }
            })
            timer.startTimer()
            
//            connector.session.sendMessage(["start" : true], replyHandler: nil) { (error) in
//                                print(error.localizedDescription)
//                            }
            
        }) {
            Text("Start")
        }
            Text("Countdown: \(self.timerValue)")
    }

    }
}

class CustomTimer {
    var interval: Double
    var counter: Double
    var timer: Timer?
    @Binding var value: String
    var punchCallback: (() -> Void)?
    
    init(interval: Double, counter: Double, value: Binding<String>, punchCallback: (() -> Void)?) {
        self.interval = interval
        self.counter = counter
        self._value = value
        self.punchCallback = punchCallback
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopTimer() {
            timer?.invalidate()
            timer = nil
            counter = 0
    }

    @objc func timerAction() {
        counter += interval
        if counter == 3{
            self.value = "3"
        }
        if counter == 4 {
            self.value = "2"
        }
        if counter == 5 {
            self.value = "1"
            punchCallback?() //Punch command sends a little early to the watch to make up for connectivity delay; does not have an effect on punch value
        }
        if counter == 6 {
            self.value = "Punch!"
        }
    }
    
    
}

#Preview {
    ContentView()
}
