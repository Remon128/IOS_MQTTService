//
//  ViewController.swift
//  MyMqttApp
//
//  Created by Admin on 6/25/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import Moscapsule

class ViewController: UIViewController {

    @IBOutlet weak var ShowMessage: UILabel!
    let topic = "/path/to/myDevice"
    var mqttConfig:MQTTConfig!
    var mqttClient:MQTTClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        moscapsule_init()
        self.mqttConfig = MQTTConfig(clientId: "cid", host: "test.mosquitto.org", port: 1883, keepAlive: 60)
        self.mqttClient = nil
        mqttConfig.onPublishCallback = { messageId in
            if(messageId==1){
                self.ShowMessage.text = "Hello Message Published"
            }
            else if(messageId==2){
                self.ShowMessage.text = "Bye Message Published"
            }
        }
        
        mqttConfig.onConnectCallback = { returnCode in
            if returnCode == ReturnCode.success {
                print ("Client is Connected")
                self.ShowMessage.text = "Client is connected"
            }
            else {
                // error handling for connection failure
                self.ShowMessage.text = "Client is not Connected"
            }
        }
        
        mqttConfig.onSubscribeCallback = { (messageId, grantedQos) in
            NSLog("subscribed (mid=\(messageId),grantedQos=\(grantedQos))")
            self.ShowMessage.text = "Client is subscribed"
        }
        
        mqttConfig.onUnsubscribeCallback = { messageId in
            NSLog("unsubscribed (mid=\(messageId)")
            self.ShowMessage.text = "Client unsubscribed"
        }
        
        
    }
    
    @IBAction func connect(_ sender: Any) {
        self.mqttClient = MQTT.newConnection(mqttConfig)  // connect to Host
    }
    
    @IBAction func sendHello(_ sender: Any) {
       
        let msg = "Hello"
        self.mqttClient.publish(string: msg, topic: topic, qos: 2, retain: false)
        mqttConfig.onPublishCallback(1)
        
        
    }
    
    @IBAction func sendBye(_ sender: Any) {
        let msg = "Bye"
        self.mqttClient.publish(string: msg, topic: topic, qos: 2, retain: false)
        mqttConfig.onPublishCallback(2)
    }
    @IBAction func checkConnection(_ sender: Any) {
        if(self.mqttClient != nil){
            if(self.mqttClient.isConnected){
            mqttConfig.onConnectCallback(ReturnCode.success)
            }
        }
        else{
            mqttConfig.onConnectCallback(ReturnCode.unknown)
        }
    }
    
    @IBAction func subscribe(_ sender: Any) {
        self.mqttClient.subscribe(topic, qos: 2)             // subscribe a topic on MQTT broker
        let array:Array<Int32> = Array()
        mqttConfig.onSubscribeCallback(1,array)
    }
    
    @IBAction func unsubscribe(_ sender: Any) {
        self.mqttClient.unsubscribe(topic)
        mqttConfig.onUnsubscribeCallback(1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 

}

