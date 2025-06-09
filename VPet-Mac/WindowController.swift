//
//  WindowController.swift
//  new2
//
//  Created by Just aLoli on 2023/8/29.
//

import Cocoa

class WindowController: NSWindowController,NSWindowDelegate {
    var VPET:VPet!
    var stateManager: VPetStateManager!
    private var stateDisplay: VPetStateDisplay!
   
    override func windowDidLoad() {
        print("windowdidload")
        super.windowDidLoad()
        
        initWindowStyle()
        setViewController("new2ViewController")
        let viewcontroller = window?.contentViewController as! ViewController
        //让imageview的大小和window一致（整个程序生命中都应该保证这一点）
        viewcontroller.imagev.setFrameSize((window?.frame.size)!)
        
        window?.setFrameOrigin(NSPoint(x: 100, y: 100))
        
        // 启用鼠标移动追踪
        window?.acceptsMouseMovedEvents = true
        
        // 设置窗口大小
        window?.setContentSize(NSSize(width: 300, height: 300))
        
        // 初始化 AnimePlayer
        let player = AnimePlayer(imageView: viewcontroller.imagev, vPet: nil, timerLabel: viewcontroller.timerLabel)
        viewcontroller.setAnimePlayer(player)
        
        // 初始化VPET
        VPET = VPet(displayWindow: self, animeplayer: player, displayView: viewcontroller)
        VPET.startup()
        
        // 更新 AnimePlayer 的 VPET 引用
        player.VPET = VPET
        
        viewcontroller.chooseActionMenu.sendVPET(VPET)
        
        // 初始化状态管理器
        stateManager = VPetStateManager()
        
        // 初始化状态显示组件
        stateDisplay = VPetStateDisplay(frame: viewcontroller.view.bounds)
        stateDisplay.translatesAutoresizingMaskIntoConstraints = false
        viewcontroller.view.addSubview(stateDisplay)
        
        // 设置状态显示组件的约束
        NSLayoutConstraint.activate([
            stateDisplay.leadingAnchor.constraint(equalTo: viewcontroller.view.leadingAnchor),
            stateDisplay.trailingAnchor.constraint(equalTo: viewcontroller.view.trailingAnchor),
            stateDisplay.topAnchor.constraint(equalTo: viewcontroller.view.topAnchor),
            stateDisplay.bottomAnchor.constraint(equalTo: viewcontroller.view.bottomAnchor)
        ])
        
        // 初始化金钱管理器
        _ = VPetMoneyManager.shared
        
        // 初始化经验管理器
        _ = VPetExpManager.shared
        
        // 启动状态管理器
        stateManager.transition(to: .normal)
        
//        let windowController = self.view.window?.windowController as! WindowController
//        let dragGesture = NSPanGestureRecognizer(target: viewcontroller, action: #selector(VPET.raised2(_:)))
////        yourCustomView.addGestureRecognizer(dragGesture)
//        viewcontroller.imagev.addGestureRecognizer(dragGesture)
    }
    
    
    func initWindowStyle(){
        window?.delegate = self
        
        window?.title = ""
        window?.level = .floating
        window?.level = .screenSaver // 这个是让窗口置顶
        window?.collectionBehavior = [.canJoinAllSpaces, .transient]
        
        window?.isMovableByWindowBackground = true
        window?.makeKeyAndOrderFront(nil)
        
        // 这两行是让窗口透明
        window?.isOpaque = false
        window?.backgroundColor = .clear
//        window?.ignoresMouseEvents = true
        window?.styleMask.insert(.borderless)
        window?.styleMask.remove(.titled)
    }
    
    
    func setViewController(_ identifier: String) {
        let sceneIdentifier = NSStoryboard.SceneIdentifier(identifier)
        let viewController = storyboard?.instantiateController(withIdentifier: sceneIdentifier) as! ViewController
        window?.contentViewController = viewController
    }
       
    
    func setWindowPos(controlPos: NSPoint,targetPos: NSPoint){
        //controlPos和targetPos都是相对窗口的坐标
        var x = controlPos.x * 2
        var y = controlPos.y * 2
        var pictureResolution = CGFloat(1000)
        //现在，(x,y)代表图片上，以左上角为原点的坐标，接下来转变为以左下角为原点的坐标
        y = pictureResolution - y
        //现在，转换为imageview尺寸的坐标
        x = x * CGFloat(Float((window?.frame.width)! / pictureResolution))
        y = y * CGFloat(Float((window?.frame.height)! / pictureResolution))
        //移动窗口，使(x,y)移到targetpos
        let dx = targetPos.x - x
        let dy = targetPos.y - y
        
        let t = window?.convertPoint(toScreen: NSPoint(x: dx, y: dy))
        window?.setFrameOrigin(t!)
    }
    
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        self.VPET.shutdown()
        //阻止关机，等待一段时间后再关机
        return false
    }
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        //按1:1修改大小
        let t = (frameSize.width + frameSize.height)/2
        return NSSize(width: t,height: t)
    }
    
}
