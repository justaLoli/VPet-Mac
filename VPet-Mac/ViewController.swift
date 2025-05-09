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
    
    // 计时器相关变量
    var workStartTime: Date?
    var workTimer: Timer?
    
    override func viewDidLoad() {
        print("viewdidload")
        super.viewDidLoad()
        
        // 将计时器UI添加到工作浮层并稍微向下偏移
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        workingOverlayView.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: workingOverlayView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: workingOverlayView.centerYAnchor, constant: 4),
            timerLabel.widthAnchor.constraint(equalToConstant: 180),
            timerLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        initButton()
        initMouseEvent()
        initViewMainMenu()
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
            switch VPET.VPetStatus{
            case .Ill: VPET.VPetStatus = .Happy;break;
            case .Happy:VPET.VPetStatus = .Normal;break;
            case .Normal:VPET.VPetStatus = .PoorCondition;break;
            case .PoorCondition:VPET.VPetStatus = .Ill;break;
            }
            VPET.updateAnimation();break;
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

    // 启动计时器
    func startWorkTimer() {
        workStartTime = Date()
        timerLabel.isHidden = false
        updateWorkTimerLabel()
        workTimer?.invalidate()
        workTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateWorkTimerLabel()
        }
    }
    // 停止计时器
    func stopWorkTimer() {
        workTimer?.invalidate()
        workTimer = nil
        timerLabel.isHidden = true
        timerLabel.stringValue = "00:00:00"
    }
    // 更新时间显示
    func updateWorkTimerLabel() {
        guard let start = workStartTime else { timerLabel.stringValue = "00:00:00"; return }
        let interval = Int(Date().timeIntervalSince(start))
        let hours = interval / 3600
        let minutes = (interval % 3600) / 60
        let seconds = interval % 60
        timerLabel.stringValue = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    override func mouseMoved(with event: NSEvent) {
        // 移除鼠标移动事件处理，因为我们不再需要它
    }

}

