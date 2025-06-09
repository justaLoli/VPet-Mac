//  VPetExpManager.swift
//  VPet-Mac
//
//  Created by AI Assistant
//

import Foundation
import Cocoa

class VPetExpManager {
    static let shared = VPetExpManager()
    
    private(set) var level: Int = 1
    private(set) var exp: Double = 0
    private(set) var expMax: Double = 100
    
    // 经验增长曲线，可自定义
    private func expRequired(for level: Int) -> Double {
        // 例：每级所需经验递增
        return 100 + Double(level - 1) * 50
    }
    
    // 绑定 UI 刷新回调
    var onExpOrLevelChanged: ((Int, Double, Double) -> Void)?
    
    // 初始化（可传入初始值）
    func configure(level: Int, exp: Double) {
        // 读取本地存储
        let savedLevel = UserDefaults.standard.integer(forKey: "vpet_level")
        let savedExp = UserDefaults.standard.double(forKey: "vpet_exp")
        if savedLevel > 0 {
            self.level = savedLevel
            self.exp = savedExp
        } else {
            self.level = level
            self.exp = exp
        }
        self.expMax = expRequired(for: self.level)
    }
    
    // 增加经验
    func addExp(amount: Double) {
        exp += amount
        var leveledUp = false
        while exp >= expMax {
            exp -= expMax
            level += 1
            expMax = expRequired(for: level)
            leveledUp = true
        }
        // 保存到本地
        UserDefaults.standard.set(level, forKey: "vpet_level")
        UserDefaults.standard.set(exp, forKey: "vpet_exp")
        onExpOrLevelChanged?(level, exp, expMax)
        // 升级后暂不做特殊处理
    }
    
    func getCurrentLevel() -> Int { level }
    func getCurrentExp() -> Double { exp }
    func getExpToNextLevel() -> Double { expMax }
    
    // 重置等级和经验
    func reset() {
        self.level = 1
        self.exp = 50
        self.expMax = expRequired(for: 1)
        UserDefaults.standard.set(self.level, forKey: "vpet_level")
        UserDefaults.standard.set(self.exp, forKey: "vpet_exp")
        onExpOrLevelChanged?(self.level, self.exp, self.expMax)
    }
} 