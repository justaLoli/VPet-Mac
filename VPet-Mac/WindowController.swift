//
//  WindowController.swift
//  new2
//
//  Created by Just aLoli on 2023/8/29.
//

import Cocoa

class WindowController: NSWindowController,NSWindowDelegate {
    var VPET:VPet!
   
    override func windowDidLoad() {
        print("windowdidload")
        super.windowDidLoad()
        
        initWindowStyle()
        setViewController("new2ViewController")
        let viewcontroller = window?.contentViewController as! ViewController
        //让imageview的大小和window一致（整个程序生命中都应该保证这一点）
        viewcontroller.imagev.setFrameSize((window?.frame.size)!)
        
        
        window?.setFrameOrigin(NSPoint(x: 100, y: 100))
        
//        let appDelegate = NSApplication.shared.delegate as! AppDelegate
//        appDelegate.VPET = VPET
        VPET = VPet(displayWindow: self, animeplayer: viewcontroller.player,displayView: viewcontroller)
        VPET.startup()
        
        viewcontroller.chooseActionMenu.sendVPET(VPET)
        
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
