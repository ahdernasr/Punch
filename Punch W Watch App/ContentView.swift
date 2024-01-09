//
//  ContentView.swift
//  Punch W Watch App
//
//  Created by Ahmed Nasr on 10/11/2023.
//

//https://www.youtube.com/watch?v=QzwHU0Xu_EY
//https://www.youtube.com/watch?v=yuo50-TiKgo
//https://www.youtube.com/playlist?list=PLYxzS__5yYQnUzfbty9g5zjEeGjYA9xjK

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
    
    func findVelocityAt(arr: [Double], at: Int) -> Double {
        var currVelocity: Double = 0
        
        for i in 1..<at {
            let delta = atx[i].2-atx[i-1].2
            currVelocity += delta*(arr[i])
        }
        
        return currVelocity
    }

    func findMaxVelocity(arr: [Double]) -> (Double, Int) {
        var currVelocity: Double = 0
        var maxVelocity: Double = 0
        var index: Int = 0
        
        for i in 1..<arr.count {
            let delta = atx[i].2-atx[i-1].2
            
            currVelocity += delta*(arr[i])
            
//            print((arr[i], currVelocity))
            
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
                        
                        if timer.counter > 4 && timer.counter < 9.5 {
                            
                            accelerationsX.append(mx)
                            accelerationsY.append(my)
                            accelerationsZ.append(mz)
                            
                            let timeStamp = CFAbsoluteTimeGetCurrent()
                            atx.append((mx, (timer.counter * 100).rounded() / 100, timeStamp))
                            aty.append((my, (timer.counter * 100).rounded() / 100, timeStamp))
                            atz.append((mz, (timer.counter * 100).rounded() / 100, timeStamp))
                            
                        }
                        
                        if timer.counter > 5-interval && timer.counter < 5 {
//                            print("X:", atx)
//                            print("Y:", aty)
//                            print("Z:", atz)
                            
                            //is this really the best way to do it?
                            //what if I could find the max velocity relative to y and z and compare which has the highest?
                            let (vx, _) = findMaxVelocity(arr: accelerationsX)
                            
                            connector.session.sendMessage(["message" : vx], replyHandler: nil) { (error) in
                                                print(error.localizedDescription)
                                            }
//                            print(vx)
//                            let vy = findVelocityAt(arr: accelerationsY, at: i)
//                            let vz = findVelocityAt(arr: accelerationsZ, at: i)
//                            print(vy,vz,sqrt(pow(vx, 2) + pow(vy, 2) + pow(vz, 2))) !!!!!!!!!
                            
                            
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
            Text("State: \(connector.punchState)")
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
            print("Started")
            startAccelerometerUpdates()
        } else {
            print("Nothing")
        }
    }
    
    
    
}

#Preview {
    ContentView()
}

