//
//  VPetStateManager.swift
//  VPet-Mac
//
//  Created by AI Assistant on 2024/3/21.
//

import Cocoa

// MARK: - State Protocol
protocol VPetState {
    var name: String { get }
    var duration: TimeInterval { get }
    var canTransitionTo: [VPetStateType] { get }
    func onEnter()
    func onExit()
    func onUpdate()
}

// MARK: - State Types
enum VPetStateType: String {
    case happy = "Happy"
    case illed = "Illed"
    case normal = "Normal"
    case poorCondition = "PoorCondition"
}

// MARK: - State Manager
class VPetStateManager {
    // MARK: - Properties
    private var currentState: VPetState?
    private var stateTimer: Timer?
    private var stateUpdateInterval: TimeInterval = 1.0
    private var stateHistory: [VPetStateType] = []
    private var stateObservers: [String: (VPetStateType) -> Void] = [:]
    
    // MARK: - State Instances
    private lazy var states: [VPetStateType: VPetState] = [
        .happy: HappyState(manager: self),
        .illed: IlledState(manager: self),
        .normal: NormalState(manager: self),
        .poorCondition: PoorConditionState(manager: self)
    ]
    
    // MARK: - Initialization
    init() {
        startStateUpdateTimer()
    }
    
    // MARK: - Public Methods
    func transition(to stateType: VPetStateType) {
        guard let newState = states[stateType] else { return }
        
        // Check if transition is allowed
        if let currentState = currentState,
           !currentState.canTransitionTo.contains(stateType) {
            print("Cannot transition from \(currentState.name) to \(stateType.rawValue)")
            return
        }
        
        // Exit current state
        currentState?.onExit()
        
        // Update state history
        if let currentState = currentState {
            stateHistory.append(VPetStateType(rawValue: currentState.name)!)
        }
        
        // Enter new state
        currentState = newState
        currentState?.onEnter()
        
        // Notify observers
        notifyStateChange(to: stateType)
    }
    
    func addObserver(_ id: String, handler: @escaping (VPetStateType) -> Void) {
        stateObservers[id] = handler
    }
    
    func removeObserver(_ id: String) {
        stateObservers.removeValue(forKey: id)
    }
    
    // MARK: - Private Methods
    private func startStateUpdateTimer() {
        stateTimer = Timer.scheduledTimer(withTimeInterval: stateUpdateInterval, repeats: true) { [weak self] _ in
            self?.currentState?.onUpdate()
        }
        RunLoop.current.add(stateTimer!, forMode: .common)
    }
    
    private func notifyStateChange(to state: VPetStateType) {
        for (_, handler) in stateObservers {
            handler(state)
        }
    }
    
    // 当前状态类型
    var currentStateType: VPetStateType? {
        if let name = currentState?.name {
            return VPetStateType(rawValue: name)
        }
        return nil
    }
}

// MARK: - Base State
class BaseState: VPetState {
    let manager: VPetStateManager
    let name: String
    let duration: TimeInterval
    let canTransitionTo: [VPetStateType]
    var remainingTime: TimeInterval
    
    init(manager: VPetStateManager, name: String, duration: TimeInterval, canTransitionTo: [VPetStateType]) {
        self.manager = manager
        self.name = name
        self.duration = duration
        self.remainingTime = duration
        self.canTransitionTo = canTransitionTo
    }
    
    func onEnter() {
        remainingTime = duration
    }

    func onExit() {}
    
    func onUpdate() {
        remainingTime -= 1.0
    }
}

// MARK: - Concrete States
class HappyState: BaseState {
    init(manager: VPetStateManager) {
        super.init(manager: manager,
                  name: VPetStateType.happy.rawValue,
                  duration: 60,
                  canTransitionTo: [.normal, .poorCondition])
    }
    
    override func onEnter() {
        print("Entering happy state")
    }
    
    override func onUpdate() {
        super.onUpdate()
        if remainingTime <= 0 {
            manager.transition(to: .normal)
        }
    }
}

class IlledState: BaseState {
    init(manager: VPetStateManager) {
        super.init(manager: manager,
                  name: VPetStateType.illed.rawValue,
                  duration: 120,
                  canTransitionTo: [.poorCondition, .normal])
    }
    
    override func onEnter() {
        print("Entering illed state")
    }
    
    override func onUpdate() {
        super.onUpdate()
        if remainingTime <= 0 {
            manager.transition(to: .poorCondition)
        }
    }
}

class NormalState: BaseState {
    init(manager: VPetStateManager) {
        super.init(manager: manager,
                  name: VPetStateType.normal.rawValue,
                  duration: 60,
                  canTransitionTo: [.happy, .poorCondition, .illed])
    }
    
    override func onEnter() {
        print("Entering normal state")
    }
    
    override func onUpdate() {
        super.onUpdate()
        if remainingTime <= 0 {
            // 随机转换到其他状态
            let nextState = canTransitionTo.randomElement()!
            manager.transition(to: nextState)
        }
    }
}

class PoorConditionState: BaseState {
    init(manager: VPetStateManager) {
        super.init(manager: manager,
                  name: VPetStateType.poorCondition.rawValue,
                  duration: 90,
                  canTransitionTo: [.normal, .illed])
    }
    
    override func onEnter() {
        print("Entering poor condition state")
    }
    
    override func onUpdate() {
        super.onUpdate()
        if remainingTime <= 0 {
            manager.transition(to: .illed)
        }
    }
} 