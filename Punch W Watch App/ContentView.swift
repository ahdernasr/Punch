import SwiftUI
import CoreMotion

struct ContentView: View {
    // Properties
    
    @ObservedObject var connector = IOSConnector()
    
    @State private var interval: Double = 0.01
    
    @State private var accelerationsX: [Double] = []
    @State private var accelerationsY: [Double] = []
    @State private var accelerationsZ: [Double] = []
    
    @State private var atx: [(Double, Double, CFAbsoluteTime)] = []
    @State private var aty: [(Double, Double, CFAbsoluteTime)] = []
    @State private var atz: [(Double, Double, CFAbsoluteTime)] = []
    
    // CoreMotion
    var motionManager = CMMotionManager()
    
    class CustomTimer {
        var interval: Double
        var counter: Double
        var timer: Timer?
        
        init(interval: Double, counter: Double) {
            self.interval = interval
            self.counter = counter
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
        }
        
        
    }

    func findMaxVelocity(arr: [Double], axis: [(Double, Double, CFAbsoluteTime)], isRight: Bool) -> (Double, Int) {
        var currVelocity: Double = 0
        var maxVelocity: Double = 0
        var index: Int = 0
        
        for i in 1..<arr.count {
            
            let delta = axis[i].2-axis[i-1].2
            
            if (isRight == true) {
                currVelocity += delta*(arr[i] * -1)
            } else {
                currVelocity += delta*(arr[i])
            }
            
            if currVelocity > maxVelocity {
                maxVelocity = currVelocity
                index = i
            }
        }
        
        return (maxVelocity, index)
    }
    
    func startAccelerometerUpdates() {
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = interval
                
                let timer = CustomTimer(interval:  motionManager.accelerometerUpdateInterval, counter: 0)
                timer.startTimer()

                motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
                    if let accelerometerData = data {
                        let x = accelerometerData.userAcceleration.x
                        let y = accelerometerData.userAcceleration.y
                        let z = accelerometerData.userAcceleration.z

                        var mx: Double = x*9.81
                        mx = mx < 5 && mx > -5 ? 0 : mx;
                        var my: Double = y*9.81
                        my = my < 5 && my > -5 ? 0 : my;
                        var mz: Double = z*9.81
                        mz = mz < 5 && mz > -5 ? 0 : mz;
                        
                        if timer.counter > 3 && timer.counter < 7.5 {
                            
                            accelerationsX.append(mx)
                            accelerationsY.append(my)
                            accelerationsZ.append(mz)
                            
                            let timeStamp = CFAbsoluteTimeGetCurrent()
                            atx.append((mx, (timer.counter * 100).rounded() / 100, timeStamp))
                            aty.append((my, (timer.counter * 100).rounded() / 100, timeStamp))
                            atz.append((mz, (timer.counter * 100).rounded() / 100, timeStamp))
                            
                        }
                        
                        //Runs once when all the data is collected
                        if timer.counter > 8-interval && timer.counter < 8 {
                
                            // the max velocity is calculated on the plot of accelerations on the X or Z axis depending on the hand being used (left: x, right: z)
                            var chosenPlane = accelerationsX
                            var chosenAxis = atx
                            var isRight = false
                            
                            if (connector.handState == "Right Hand") {
                                chosenPlane = accelerationsY
                                chosenAxis = aty
                                isRight = true
                            }
                            
                            let (vx, _) = findMaxVelocity(arr: chosenPlane, axis: chosenAxis, isRight: isRight)
                            
                            
                            
                            connector.session.sendMessage(["message" : vx], replyHandler: nil) { (error) in
                                                print(error.localizedDescription)
                                            }
                            
                            //Reset values
                            connector.punchState = "None"
                            accelerationsX = []
                            accelerationsY = []
                            accelerationsZ = []
                            atx = []
                            aty = []
                            atz = []

//                            print(vy,vz,sqrt(pow(vx, 2) + pow(vy, 2) + pow(vz, 2))) !!!!!!!!!
                            stopAccelerometerUpdates()
                            
                        }
                    }
                }
                
            } else {
                print("Accelerometer not available!")
            }
        }

        func stopAccelerometerUpdates() {
            motionManager.stopAccelerometerUpdates()
        }
    
    
    var body: some View {
    VStack {
        Text("Follow instructions on iOS Companion.")
    }
    .padding()
    .onAppear {
    }
    .onDisappear {
        stopAccelerometerUpdates()
    }
    .onChange(of: connector.punchState) {
        handlePunchStateChange()
    }
}

func handlePunchStateChange() {
    if connector.punchState == "Punch!" {
        startAccelerometerUpdates()
    } else {
    }
}
    
    
    
}

#Preview {
    ContentView()
}

