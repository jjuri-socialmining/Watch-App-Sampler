//
//  DeviceMotionController.swift
//  Watch-App-Sampler WatchKit Extension
//
//  Created by DCSnail on 2018/6/25.
//  Copyright © 2018年 DCSnail. All rights reserved.
//  DCSnail: https://github.com/wangyanchang21WatchOS
//  watchOS开发教程: https://blog.csdn.net/wangyanchang21/article/details/80928126
//

import UIKit
import WatchKit
import CoreMotion

@available(watchOSApplicationExtension 6.0, *)

class DeviceMotionController: WKInterfaceController,URLSessionWebSocketDelegate  {
    
    private var webSocket: URLSessionWebSocketTask?
    
    @IBOutlet var RollLabel: WKInterfaceLabel!
    @IBOutlet var PitchLabel: WKInterfaceLabel!
    @IBOutlet var YawLabel: WKInterfaceLabel!
    
    @IBOutlet var RotXLabel: WKInterfaceLabel!
    @IBOutlet var RotYLabel: WKInterfaceLabel!
    @IBOutlet var RotZLabel: WKInterfaceLabel!
    
    @IBOutlet var GraXLabel: WKInterfaceLabel!
    @IBOutlet var GraYLabel: WKInterfaceLabel!
    @IBOutlet var GraZLabel: WKInterfaceLabel!
    
    @IBOutlet var AccXLabel: WKInterfaceLabel!
    @IBOutlet var AccYLabel: WKInterfaceLabel!
    @IBOutlet var AccZLabel: WKInterfaceLabel!
    
    @IBOutlet var MagXLabel: WKInterfaceLabel!
    @IBOutlet var MagYLabel: WKInterfaceLabel!
    @IBOutlet var MagZLabel: WKInterfaceLabel!
    @IBOutlet var MagAccLabel: WKInterfaceLabel!
    
    @IBOutlet var headingLabel: WKInterfaceLabel!
    
    
    lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 1.75
        return manager
    }()
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
            //let url = URL(string:"wss://echo.websocket.events")
            let url = URL(string:"ws://3.98.59.221/ws/simple")
            webSocket = session.webSocketTask(with: url!)
            webSocket?.resume()
        
        
        if motionManager.isDeviceMotionAvailable {
            

            
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
                if let attitude = data?.attitude {
                    self.RollLabel.setText(String(format: "%.2f", attitude.roll))
                    self.PitchLabel.setText(String(format: "%.2f", attitude.pitch))
                    self.YawLabel.setText(String(format: "%.2f", attitude.yaw))
                    
                    DispatchQueue.global().asyncAfter(deadline: .now()+1) {
                        
                        self.send()
                        self.webSocket?.send(.string("este mensaje \(String(format: "%.2f", attitude.roll))"), completionHandler: { error in
                            if let error = error {
                                print("send error: \(error)")
                            }
                        })
                        
                    }
                }
                if let rotationRate = data?.rotationRate {
                    self.RotXLabel.setText(String(format: "%.2f", rotationRate.x))
                    self.RotYLabel.setText(String(format: "%.2f", rotationRate.y))
                    self.RotZLabel.setText(String(format: "%.2f", rotationRate.z))
                }
                if let gravity = data?.gravity {
                    self.GraXLabel.setText(String(format: "%.2f", gravity.x))
                    self.GraYLabel.setText(String(format: "%.2f", gravity.y))
                    self.GraZLabel.setText(String(format: "%.2f", gravity.z))
                }
                if let userAcceleration = data?.userAcceleration {
                    self.AccXLabel.setText(String(format: "%.2f", userAcceleration.x))
                    self.AccYLabel.setText(String(format: "%.2f", userAcceleration.y))
                    self.AccZLabel.setText(String(format: "%.2f", userAcceleration.z))
                }
                if let magneticField = data?.magneticField.field {
                    self.MagXLabel.setText(String(format: "%.2f", magneticField.x))
                    self.MagYLabel.setText(String(format: "%.2f", magneticField.y))
                    self.MagZLabel.setText(String(format: "%.2f", magneticField.z))
                }
                if let accuracy = data?.magneticField.accuracy {
                    self.MagAccLabel.setText("\(accuracy)")
                }
                if let heading = data?.heading {
                    self.headingLabel.setText(String(format: "%.2f", heading))
                }
            }
        } else {
            print("Not Available")
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        //motionManager.stopDeviceMotionUpdates()
    }
    
    func ping(){
           webSocket?.sendPing(pongReceiveHandler: { error in
               if let error = error{
                   print("ping error \(error)")
               }
           })
       }
       
       func close(){
           webSocket?.cancel(with: .goingAway, reason: "demon ended".data(using: .utf8))
       }
       
    func send(){
        DispatchQueue.global().asyncAfter(deadline: .now()+1) {
            
            let doubleStr = String(format: "%.2f", Double.random(in: 0.00...4.00)) ;

            //print(doubleStr)
            self.send()
            self.webSocket?.send(.string(doubleStr), completionHandler: { error in
                if let error = error {
                    print("send error: \(error)")
                }
            })
            
        }
                                          
    }
                                             
       
       func receive(){
           webSocket?.receive(completionHandler: { [weak self] result in
               switch result {
               case .success(let message):
                   switch message {
                   case .data(let data):
                       print("Got Data:  \(data)")
                   case .string(let message):
                       print("got string \(message)")
                   @unknown default:
                       break
                   }
               case .failure(let error):
                   print("recibi el error: \(error)")
                   
               }
               self?.receive()
           })
       }
       
       func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
         print("Nos conectamos")
           ping()
           receive()
           send()
       }

       func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
           print("Nos desconectamos porque: ")
       }
}
