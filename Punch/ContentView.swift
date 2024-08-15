import AlertToast
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var connector = WatchConnector()
    @State var selectedHand = "Left Hand"
    @State var startOrTryAgain = "Start"
    @State var reachable = false
    @State var timerValue = "PRESS START!"
    @State var msValueOn = false
    @State var showConnectToast = false
    @State var showDisconnectToast = false
    
    var body: some View {
        NavigationView {
            VStack{
                                    
                HStack {
                    Button("Left Hand") {
                        selectedHand = "Left Hand"
                    }.buttonStyle(.bordered).controlSize(.large).buttonBorderShape(.roundedRectangle).tint(selectedHand == "Left Hand" ? .purple : .gray).foregroundColor(colorScheme == .dark ? .white : .black)
                    Button("Right Hand") {
                        selectedHand = "Right Hand"
                    }.buttonStyle(.bordered)
                        .controlSize(.large).buttonBorderShape(.roundedRectangle).tint(selectedHand == "Right Hand" ? .purple : .gray).foregroundColor(colorScheme == .dark ? .white : .black)
                    
                }
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.purple, lineWidth: 10)
                            .frame(width: 250, height: 250).padding(.top, 20)
                            .padding(.bottom, 20)
                        
                        
                        HStack {
                            Text("\(self.connector.isReachable ? self.timerValue : "CONNECT WATCH")")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Text(self.msValueOn ? "m/s" : "")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Button(action: {
                    self.msValueOn = false
                    
                    let timer = CustomTimer(interval:  1, counter: 0, value: $timerValue, punchCallback: {
                        connector.session.sendMessage(["punchState" : "Punch!", "handState": selectedHand], replyHandler: nil) { (error) in
                            print(error.localizedDescription)
                        }
                    })
                    timer.startTimer()
                    
                }) {
                    Text("\(self.startOrTryAgain)").frame(width: 150, height: 20)
                }.buttonStyle(.bordered).controlSize(.large).buttonBorderShape(.roundedRectangle(radius: 12)).tint(.gray).foregroundColor(colorScheme == .dark ? .white : .black).disabled(!self.connector.isReachable)
                
                
//                Button(action: {
//                    //View punch history, future feature
//                    
//                }) {
//                    Text("Punch History").frame(width: 150, height: 20)
//                }.buttonStyle(.bordered).controlSize(.large).buttonBorderShape(.roundedRectangle(radius: 12)).tint(.gray).foregroundColor(colorScheme == .dark ? .white : .black).disabled(true)
//                
                //            Text("Value: \(connector.messageText)")
                
            }.navigationBarItems(leading: Button(action: {
                
            }) {
                NavigationLink(destination: FirstLaunchView().navigationBarBackButtonHidden(true)) {
                    Image(systemName: "info.circle").foregroundColor(.purple)
                }
            }).onChange(of: connector.messageText) {
                handleMessageReciept()
            }.onChange(of: self.connector.isReachable) {
                if (self.connector.isReachable) {
                    showConnectToast = true
                } else {
                    showDisconnectToast = true
                }
            }.toast(isPresenting: $showConnectToast){
                    AlertToast(displayMode: .hud, type: .complete(.green), title: "Watch Connected!")
            }.toast(isPresenting: $showDisconnectToast){
                    AlertToast(displayMode: .hud, type: .regular, title: "Connection Lost")
            }
            
        }
    }
    
    func handleMessageReciept() {
        let roundedResult = (connector.messageText * 100).rounded() / 100
        let stringResult = String(format: "%.3f", roundedResult)
        self.timerValue = stringResult
        self.msValueOn = true
        self.startOrTryAgain = "Try Again"
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
        self.value = "Ready?"
        punchCallback?() //Starts the operation on the apple watch
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        counter = 0
    }
    
    @objc func timerAction() {
        counter += interval
        if counter == 3{
            //Punch command sends a little early to the watch to make up for connectivity delay; does not have an effect on punch value
            self.value = "3"
            punchCallback?()
        }
        if counter == 4 {
            self.value = "2"
        }
        if counter == 5 {
            self.value = "1"
        }
        if counter == 6 {
            self.value = "Punch!"
        }
    }
    
    
}

#Preview {
    ContentView()
}
