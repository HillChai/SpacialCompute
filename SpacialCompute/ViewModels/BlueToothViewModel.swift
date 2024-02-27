//
//  BlueToothViewModel.swift
//  SpacialCompute
//
//  Created by cccc on 2024/2/27.
//

import Foundation
import CoreBluetooth
import os

enum ConnectionStatus: String {
    case connected
    case disconnected
    case scanning
    case connecting
    case error
}

class BlueToothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    static var instance = BlueToothViewModel()
    
    private var centralManager = CBCentralManager()
    @Published var peripheralStatus: ConnectionStatus = .disconnected
    
    // BlueTooth Configurations
    public var savedName: String = UserDefaults.standard.string(forKey: "Name") ?? "BT04-E"
    public var savedServiceUUID: String = UserDefaults.standard.string(forKey: "ServiceUUID") ?? "FFE0"
    public var savedCharacteristicUUID: String = UserDefaults.standard.string(forKey: "CharacteristicUUID") ?? "FFE1"
    
    //BlueTooth connected
    weak var discoveredPeripheral: CBPeripheral?
    @Published var data = ""
    public var completemessage = ["not start"]
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("CB is powered on")
            scanForPeripherals()
        }
    }
    
    func scanForPeripherals() {
        peripheralStatus = .scanning
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == savedName {
            discoveredPeripheral = peripheral
            centralManager.connect(peripheral)  // attempt to connect it
            peripheralStatus = .connecting
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralStatus = .connected
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        centralManager.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheralStatus = .disconnected
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        peripheralStatus = .error
        print(error?.localizedDescription ?? "no error")
    }
    
    
    // Mark: Characteristic transportation starts.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            if service.uuid == CBUUID(string: savedServiceUUID) {
                print("Service for \(savedServiceUUID) Found!")
                peripheral.discoverCharacteristics([CBUUID(string: savedCharacteristicUUID)], for: service)
            }
        }
    }
 
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CBUUID(string: savedCharacteristicUUID) {
            guard let characteristicData = characteristic.value,
                  let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
            
            if !stringFromData.hasPrefix("\r\n") {
                data.append(stringFromData)
            } else {
                data.append(stringFromData)
                
                if completemessage.count <= 2 {
                    completemessage.append(data)
                } else {
                    completemessage.remove(at: 0)
                    completemessage.append(data)
                }
                
                data = ""
            }
        }
        
    }
    
}
