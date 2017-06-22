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
    
    func log(_ text: String) {
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
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unsupported:
            log("Unsupported")
        case .unauthorized:
            log("Unauthorized")
        case .unknown:
            log("Unknown")
        case .resetting:
            log("Resettinhg")
        case .poweredOn:
            log("Powering on")
            startScanning()
        case .poweredOff:
            log("Powering off")
        }
    }
    
    func startScanning() {
        log("Scanning")
        sendDisconnect()
        let serviceUUID = CBUUID(string: UUID);
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func showState(_ peripheral: CBPeripheral) {
        switch peripheral.state {
        case .connected:
            log("Peripheral: Connected")
        case .connecting:
            log("Peripheral: Connecting")
        case .disconnected:
            log("Peripheral: Disconnected")
            startScanning()
        case .disconnecting:
            log("Peripheral: Disconnecting")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name != nil) {
            log("\(peripheral.name!) : \(RSSI) dBm")
        }
        
        myPeripheral = peripheral
        
        showState(myPeripheral)
        
        central.stopScan()
        myPeripheral.delegate = self
        central.connect(myPeripheral, options: nil)
        
        showState(myPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("Connected")
        showState(myPeripheral)
        myPeripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log("Disconnect")
        showState(myPeripheral)
        sendDisconnect()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in myPeripheral.services! {
            log("Service discoverd: \(service.uuid)" )
            myPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            myCharacteristic = characteristic
            log("Characteristic discovered: \(myCharacteristic.uuid)" )
            
            sendConnect()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let value = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)
        
        log("\(String(describing: value))")
    }
    
    func sendData(_ value: String) {
        myPeripheral.writeValue(value.data(using: String.Encoding.utf8)!,
                                for: myCharacteristic,
                                type: CBCharacteristicWriteType.withoutResponse)
        
    }
}
