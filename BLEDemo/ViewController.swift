//
//  ViewController.swift
//  BLEDemo
//
//  Created by Quintin Balsdon on 2016/06/11.
//  Copyright © 2016 Quintin Balsdon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BLEProtocol {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sendText: UITextField!
    @IBOutlet weak var logLabel: UILabel!
    
    var manager: BLEManager = BLEManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.logger = self
        logLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
    }
    
    @IBAction func sendTapped(sender: AnyObject, forEvent event: UIEvent) {
        manager.sendData(sendText.text!)
        log("SENT: [\(sendText.text!)]")
        sendText.text = "";
    }
    
    func log(data: String) {
        dispatch_async(dispatch_get_main_queue(),{
            self.logLabel.text = "\(data)\n \(self.logLabel.text!)"
            print(data)
        })
    }
    
    func onReady() {
        statusLabel.text = "Connected"
        statusLabel.backgroundColor = UIColor.greenColor()
    }
    
    func onDisconnect() {
        statusLabel.text = "Disconnected"
        statusLabel.backgroundColor = UIColor.redColor()
    }



}

