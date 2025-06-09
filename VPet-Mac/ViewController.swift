//
//  ViewController.swift
//  new2
//
//  Created by Just aLoli on 2023/8/27.
//

import Cocoa

class ViewController: NSViewController {
    
    //抄的
    @IBOutlet weak var imagev: NSImageView!
    //注意这一行左边有个圆圈。要在storyboard里面，viewcontroller，右键，菜单中找到这个imagev，和视图中的imageview连线，这样左边的圈变成实心的。
    
    var chooseActionMenu = ChooseActionMenu()
    @IBOutlet weak var viewMainMenu:NSMenu!
    
    var player: AnimePlayer!
    
    
    @IBOutlet weak var workingOverlayView: NSView!
    @IBOutlet weak var workingOverlayTitle: NSTextField!
    @IBOutlet weak var workingOverlayStop: NSButton!
    
    // 状态显示面板
    private lazy var statePanel: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
        view.layer?.cornerRadius = 8
        return view
    }()
    
    private lazy var stateLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .center
        return label
    }()
    
    private lazy var stateDurationLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .center
        return label
    }()
    
    // 计时器数字UI
    var timerLabel: NSTextField = {
        let label = NSTextField(labelWithString: "00:00:00")
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .center
        label.isHidden = true
        return label
    }()
    
    @IBOutlet weak var panelView: VPetStateDisplay!
    
    // 待机状态显示
    private lazy var idleStatusView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
        view.layer?.cornerRadius = 8
        return view
    }()
    
    private lazy var idleMoneyLabel: NSTextField = {
        let label = NSTextField(labelWithString: "金钱: $0.00")
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
        label.textColor = .white
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .left
        return label
    }()
    
    private lazy var idleExpLabel: NSTextField = {
        let label = NSTextField(labelWithString: "经验: 0")
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
        label.textColor = .white
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .left
        return label
    }()
    
    private var idleTimer: Timer?
    private var idleSeconds: Int = 0
    
    private lazy var idleStatusStack: NSStackView = {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        print("viewdidload")
        super.viewDidLoad()
        // ✅ 启动时隐藏状态面板
        panelView.isHidden = true
        
        // 添加状态显示面板
        setupStatePanel()
        
        // 添加待机状态显示
        setupIdleStatusView()
        
        // 将计时器UI添加到工作浮层并稍微向下偏移
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        workingOverlayView.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: workingOverlayView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: workingOverlayView.centerYAnchor, constant: 4),
            timerLabel.widthAnchor.constraint(equalToConstant: 100),
            timerLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        initButton()
        initMouseEvent()
        initViewMainMenu()
        
        // 绑定经验管理器回调，刷新面板
        VPetExpManager.shared.onExpOrLevelChanged = { [weak self] level, exp, expMax in
            self?.panelView.updateExpLevel(level: level, exp: exp, expMax: expMax)
            self?.updateIdleExpLabel()
        }
        
        // 绑定金钱管理器回调
        VPetMoneyManager.shared.onMoneyChanged = { [weak self] money in
            self?.updateIdleMoneyLabel()
        }
        
        VPetExpManager.shared.configure(level: 1, exp: 0)
        
        // 读取累计时间
        idleSeconds = UserDefaults.standard.integer(forKey: "idleSeconds")
        
        // 启动待机计时器
        startIdleTimer()
    }
    
    func setAnimePlayer(_ player: AnimePlayer) {
        self.player = player
    }
    
    func initViewMainMenu(){
        self.view.menu = viewMainMenu
        self.view.menu?.item(withTitle: "互动")!.submenu = chooseActionMenu.menu
//        self.view.menu?.addItem(withTitle: "退出当前互动", action: #selector(onActionMenuItemClicked),keyEquivalent: "")
    }
    func initButton(){
        for subv in self.view.subviews{
            if let button = subv as? NSButton{
//                if(button.title == "一键爬行"){continue;}
                button.isHidden = true
            }
        }
        
        self.workingOverlayView.isHidden = true;
    }
    func initMouseEvent(){
        //鼠标事件：鼠标右键切换按钮的显示和隐藏
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp, .leftMouseDragged], handler: { (event) -> NSEvent? in
            switch event.type{
            case .leftMouseDown:
                print("Mouse Down Event")
                guard let windowController = self.view.window?.windowController as? WindowController else{
                    print("Failed to get window controller")
                    return event
                }
                guard let VPET = windowController.VPET else{
                    print("Failed to get VPET")
                    return event
                }
                VPET.handleLeftMouseDown(event.locationInWindow)
                break;
            case .rightMouseUp:
                break;
            case .leftMouseDragged:
                print("Mouse Dragged Event")
                guard let windowController = self.view.window?.windowController as? WindowController else{
                    return event
                }
                guard let VPET = windowController.VPET else{
                    return event
                }
                VPET.handleLeftMouseDragged(event.locationInWindow)
                break;
            case .leftMouseUp:
                print("Mouse Up Event")
                guard let windowController = self.view.window?.windowController as? WindowController else{
                    return event
                }
                guard let VPET = windowController.VPET else{
                    return event
                }
                VPET.handleLeftMouseUp()
            default:break;
            }
            return event
        })
    }
    
    
    @IBAction func onButtonClicked(_ sender: NSButton) {
        if(sender.identifier?.rawValue == "workOverlayStopButton"){
            guard let windowController = self.view.window?.windowController as? WindowController else{
                return;
            }
            guard let VPET = windowController.VPET else{
                return;
            }
            VPET.workAndSleepHandler.endplayFromCurrentActionTitle();
            VPET.updateAnimation();
        }
        if(sender.title == "一键爬行"){
            guard let windowController = self.view.window?.windowController as? WindowController else{
                return;
            }
            guard let VPET = windowController.VPET else{
                return;
            }
            VPET.autoActionHendler.movehandler!.startAutoMove()
        }
        
    }
    
    
    
    @IBAction func onActionMenuItemClicked(_ sender: NSMenuItem) {
        print(sender.title)
        guard let windowController = self.view.window?.windowController as? WindowController else{
            return;
        }
        guard let VPET = windowController.VPET else{
            return;
        }
        switch sender.title{
        case "面板":
            // 切换面板显示/隐藏
            panelView.isHidden.toggle()
            if !panelView.isHidden {
                // 构造面板数据
                let info = VPetPanelInfo(
                    level: VPetExpManager.shared.getCurrentLevel(),
                    statusText: "已关闭数据计算, 可放心挂机",
                    money: VPetMoneyManager.shared.getCurrentMoney(),
                    exp: VPetExpManager.shared.getCurrentExp(),
                    expMax: VPetExpManager.shared.getExpToNextLevel(),
                    stamina: 80,
                    staminaMax: 100,
                    mood: 80,
                    moodMax: 100,
                    satiety: 50,
                    satietyMax: 100,
                    thirst: 50,
                    thirstMax: 100,
                    state: windowController.stateManager?.currentStateType?.rawValue ?? "Nomal",
                    stateDuration: 0
                )
                panelView.updatePanel(info: info)
            }
            // 同时切换待机状态显示
            idleStatusView.isHidden.toggle()
            break;
        case "退出":
            VPET.shutdown();break;
        case "退出当前互动":break;
        default:break;
        }
    }
    
    func setsize(width:Double,height:Double){
//        imagev.setFrameSize(NSSize(width: width, height: height))
//        view.setFrameSize(NSSize(width:width,height:height))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func mouseMoved(with event: NSEvent) {
        // 移除鼠标移动事件处理，因为我们不再需要它
    }

    private func setupStatePanel() {
        // 添加状态面板
        statePanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statePanel)
        
        // 添加状态标签
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        statePanel.addSubview(stateLabel)
        
        // 添加持续时间标签
        stateDurationLabel.translatesAutoresizingMaskIntoConstraints = false
        statePanel.addSubview(stateDurationLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 状态面板约束
            statePanel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            statePanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            statePanel.widthAnchor.constraint(equalToConstant: 100),
            statePanel.widthAnchor.constraint(equalToConstant: 100),
            statePanel.heightAnchor.constraint(equalToConstant: 60),
            
            // 状态标签约束
            stateLabel.topAnchor.constraint(equalTo: statePanel.topAnchor, constant: 8),
            stateLabel.leadingAnchor.constraint(equalTo: statePanel.leadingAnchor, constant: 8),
            stateLabel.trailingAnchor.constraint(equalTo: statePanel.trailingAnchor, constant: -8),
            
            // 持续时间标签约束
            stateDurationLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 4),
            stateDurationLabel.leadingAnchor.constraint(equalTo: statePanel.leadingAnchor, constant: 8),
            stateDurationLabel.trailingAnchor.constraint(equalTo: statePanel.trailingAnchor, constant: -8),
            stateDurationLabel.bottomAnchor.constraint(equalTo: statePanel.bottomAnchor, constant: -8)
        ])
        
        // 初始隐藏状态面板
        statePanel.isHidden = true
    }
    
    // 更新状态显示
    func updateStateDisplay(state: String, duration: TimeInterval) {
        stateLabel.stringValue = state
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        stateDurationLabel.stringValue = String(format: "%02d:%02d", minutes, seconds)
        statePanel.isHidden = false
    }

    private func setupIdleStatusView() {
        idleStatusView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(idleStatusView)
        // label样式统一
        idleMoneyLabel.font = idleMoneyLabel.font
        idleMoneyLabel.textColor = .white
        idleMoneyLabel.alignment = .left
        idleMoneyLabel.setContentHuggingPriority(.required, for: .horizontal)
        idleExpLabel.font = idleMoneyLabel.font
        idleExpLabel.textColor = .white
        idleExpLabel.alignment = .left
        idleExpLabel.setContentHuggingPriority(.required, for: .horizontal)
        // stackView管理两行
        idleStatusStack.addArrangedSubview(idleMoneyLabel)
        idleStatusStack.addArrangedSubview(idleExpLabel)
        idleStatusView.addSubview(idleStatusStack)
        NSLayoutConstraint.activate([
            idleStatusView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            idleStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            idleStatusView.widthAnchor.constraint(equalToConstant: 70),
            idleStatusView.heightAnchor.constraint(equalToConstant: 36),
            idleStatusStack.topAnchor.constraint(equalTo: idleStatusView.topAnchor, constant: 4),
            idleStatusStack.leadingAnchor.constraint(equalTo: idleStatusView.leadingAnchor, constant: 5),
            idleStatusStack.trailingAnchor.constraint(equalTo: idleStatusView.trailingAnchor, constant: -4),
            idleStatusStack.bottomAnchor.constraint(equalTo: idleStatusView.bottomAnchor, constant: -1)
        ])
        idleStatusView.isHidden = false
    }
    
    private func startIdleTimer() {
        idleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.idleSeconds += 1
            UserDefaults.standard.set(self.idleSeconds, forKey: "idleSeconds")
        }
        RunLoop.current.add(idleTimer!, forMode: .common)
    }
    
    private func updateIdleMoneyLabel() {
        idleMoneyLabel.stringValue = String(format: "金钱: $%.2f", VPetMoneyManager.shared.getCurrentMoney())
    }
    
    private func updateIdleExpLabel() {
        idleExpLabel.stringValue = String(format: "经验: %.2f", VPetExpManager.shared.getCurrentExp())
    }

    // 一次性重置等级、经验、金钱
    func resetAllStatus() {
        VPetExpManager.shared.reset()
        VPetMoneyManager.shared.reset()
        // 刷新面板
        let info = VPetPanelInfo(
            level: VPetExpManager.shared.getCurrentLevel(),
            statusText: "Normal",
            money: VPetMoneyManager.shared.getCurrentMoney(),
            exp: VPetExpManager.shared.getCurrentExp(),
            expMax: VPetExpManager.shared.getExpToNextLevel(),
            stamina: 80,
            staminaMax: 100,
            mood: 80,
            moodMax: 100,
            satiety: 80,
            satietyMax: 100,
            thirst: 80,
            thirstMax: 100,
            state: "Normal",
            stateDuration: 0
        )
        panelView.updatePanel(info: info)
    }

}

