//
//  BLEManager.swift
//  BTController
//
//  Created by Quintin Balsdon on 2016/05/25.
//  Copyright © 2016 Quintin Balsdon. All rights reserved.
//

import CoreBluetooth

class BLEManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    let UUID = "4afb720a-5214-4337-841b-d5f954214877"
    
    var centralManager: CBCentralManager!
    
    var myPeripheral : CBPeripheral!
    var myCharacteristic : CBCharacteristic!
    var logger: BLEProtocol!
    
    func log(text: String) {
        print(text)
        if (logger != nil) {
            logger.log(text)
        }
    }
    
    func sendDisconnect() {
        if (logger != nil) {
            logger.onDisconnect()
        }
    }
    
    func sendConnect() {
        if (logger != nil) {
            logger.onReady()
        }
    }
    
    override init() {
        super.init()
        log("Manager init")
        centralManager = CBCentralManager(delegate: self, queue: nil)
        sendDisconnect()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .Unsupported:
            log("Unsupported")
        case .Unauthorized:
            log("Unauthorized")
        case .Unknown:
            log("Unknown")
        case .Resetting:
            log("Resettinhg")
        case .PoweredOn:
            log("Powering on")
            startScanning()
        case .PoweredOff:
            log("Powering off")
        }
    }
    
    func startScanning() {
        log("Scanning")
        sendDisconnect()
        let serviceUUID = CBUUID(string: UUID);
        centralManager.scanForPeripheralsWithServices([serviceUUID], options: nil)
    }
    
    func showState(peripheral: CBPeripheral) {
        switch peripheral.state {
        case .Connected:
            log("Peripheral: Connected")
        case .Connecting:
            log("Peripheral: Connecting")
        case .Disconnected:
            log("Peripheral: Disconnected")
            startScanning()
        case .Disconnecting:
            log("Peripheral: Disconnecting")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if (peripheral.name != nil) {
            log("\(peripheral.name!) : \(RSSI) dBm")
        }
        
        myPeripheral = peripheral
        
        showState(myPeripheral)
        
        central.stopScan()
        myPeripheral.delegate = self
        central.connectPeripheral(myPeripheral, options: nil)
        
        showState(myPeripheral)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        log("Connected")
        showState(myPeripheral)
        myPeripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        log("Disconnect")
        showState(myPeripheral)
        sendDisconnect()
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in myPeripheral.services! {
            log("Service discoverd: \(service.UUID)" )
            myPeripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for characteristic in service.characteristics! {
            myCharacteristic = characteristic
            log("Characteristic discoverd: \(myCharacteristic.UUID)" )
            
            sendConnect()
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        let value = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
        
        log("\(value)")
    }
    
    func sendData(value: String) {
        myPeripheral.writeValue(value.dataUsingEncoding(NSUTF8StringEncoding)!,
                                forCharacteristic: myCharacteristic,
                                type: CBCharacteristicWriteType.WithoutResponse)
        
    }
}
