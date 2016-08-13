//
//  BLEProtocol.swift
//  BLEDemo
//
//  Created by Quintin Balsdon on 2016/06/11.
//  Copyright © 2016 Quintin Balsdon. All rights reserved.
//

import Foundation

protocol BLEProtocol {
    func log(data: String)
    func onReady()
    func onDisconnect()
}