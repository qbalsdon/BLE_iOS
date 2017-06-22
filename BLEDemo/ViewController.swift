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
        logLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    @IBAction func sendTapped(_ sender: AnyObject, forEvent event: UIEvent) {
        manager.sendData(sendText.text!)
        log("SENT: [\(sendText.text!)]")
        sendText.text = "";
    }
    
    func log(_ data: String) {
        DispatchQueue.main.async(execute: {
            self.logLabel.text = "\(data)\n \(self.logLabel.text!)"
            print(data)
        })
    }
    
    func onReady() {
        statusLabel.text = "Connected"
        statusLabel.backgroundColor = UIColor.green
    }
    
    func onDisconnect() {
        statusLabel.text = "Disconnected"
        statusLabel.backgroundColor = UIColor.red
    }



}

