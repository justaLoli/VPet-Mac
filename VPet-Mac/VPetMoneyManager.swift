//  VPetMoneyManager.swift
//  VPet-Mac
//
//  Created by AI Assistant
//

import Foundation
import Cocoa

class VPetMoneyManager {
    static let shared = VPetMoneyManager()
    
    private(set) var money: Double = 0
    private var idleTimer: Timer?
    private var idleStartTime: Date?
    
    // 每分钟获得的经验值
    private let expPerMinute: Double = 5.0
    
    // 绑定 UI 刷新回调
    var onMoneyChanged: ((Double) -> Void)?
    
    private init() {
        // 读取本地存储
        money = UserDefaults.standard.double(forKey: "vpet_money")
        startIdleTimer()
    }
    
    private func startIdleTimer() {
        // 每分钟检查一次
        idleTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.addMoney(amount: 1.0)
            // 同时增加经验值
            VPetExpManager.shared.addExp(amount: self?.expPerMinute ?? 5.0)
        }
        RunLoop.current.add(idleTimer!, forMode: .common)
    }
    
    func addMoney(amount: Double) {
        money += amount
        UserDefaults.standard.set(money, forKey: "vpet_money")
        onMoneyChanged?(money)
    }
    
    func getCurrentMoney() -> Double { money }
    
    // 重置金钱
    func reset() {
        self.money = 0
        UserDefaults.standard.set(self.money, forKey: "vpet_money")
        onMoneyChanged?(self.money)
    }
} 