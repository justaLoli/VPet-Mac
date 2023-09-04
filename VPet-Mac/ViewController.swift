//
//  ViewController.swift
//  new2
//
//  Created by Just aLoli on 2023/8/27.
//

import Cocoa

class ViewController: NSViewController {
    
    //抄的
    @IBOutlet var imagev: NSImageView!
    //注意这一行左边有个圆圈。要在storyboard里面，viewcontroller，右键，菜单中找到这个imagev，和视图中的imageview连线，这样左边的圈变成实心的。
    
    var chooseActionMenu = ChooseActionMenu()
    @IBOutlet var viewMainMenu:NSMenu!
    
    var player: AnimePlayer!
    
    
    
    override func viewDidLoad() {
        print("viewdidload")
        super.viewDidLoad()
        player = AnimePlayer(imagev)
        
        //让imageview的大小和window一致（整个程序生命中都应该保证这一点）
        //写在window里面了
//        imagev.setFrameSize(self.view.window!.frame.size)
        initButtons()
        initViewMainMenu()

    }
    func initViewMainMenu(){
        self.view.menu = viewMainMenu
        self.view.menu?.item(withTitle: "互动")!.submenu = chooseActionMenu.menu
        self.view.menu?.addItem(withTitle: "退出当前互动", action: #selector(onActionMenuItemClicked),keyEquivalent: "")
    }
    
    
    //我超 还有IBAction这种东西
//    @IBAction func drag(_ sender: NSPanGestureRecognizer) {
//        print("drag")
//        return
//        guard let windowController = self.view.window?.windowController as? WindowController else{return}
//        guard let VPET = windowController.VPET else{return}
//
//        if sender.state == .began {
//            print("拖动开始")
//            VPET.raisedStart()
//            //增加响应速度用的
//            VPET.raisedMoving(sender.location(in: self.view))
////
//        } else if sender.state == .changed {
//            print("进行中")
//            VPET.raisedMoving(sender.location(in: self.view))
//        } else if sender.state == .ended {
//            print("end")
//            VPET.raisedEnd()
//        }
//    }
    
    func initButtons(){
        
        for subv in self.view.subviews{
            if let button = subv as? NSButton{
                button.isHidden = true
            }
        }
        
        //鼠标事件：鼠标右键切换按钮的显示和隐藏
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp, .mouseMoved, .leftMouseDragged], handler: { (event) -> NSEvent? in
            switch event.type{
            case .leftMouseDown:
                guard let windowController = self.view.window?.windowController as? WindowController else{
                    return event
                }
                guard let VPET = windowController.VPET else{
                    return event
                }
                VPET.handleLeftMouseDown(event.locationInWindow)
            case .rightMouseUp:
//                for subview in self.view.subviews{
//                    if let button = subview as? NSButton{
//                        button.isHidden.toggle()
//                    }
//                }
                //改用menu之后，menu会自动弹出
//                self.view.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: self.view)
//                self.ZANbutton.isHidden = !self.ZANbutton.isHidden
//                self.BObutton.isHidden = !self.BObutton.isHidden
//                self.ACTIONMenuButton.isHidden = !self.ACTIONMenuButton.isHidden
                break;
            case .leftMouseDragged:
                guard let windowController = self.view.window?.windowController as? WindowController else{
                    return event
                }
                guard let VPET = windowController.VPET else{
                    return event
                }
                VPET.handleLeftMouseDragged(event.locationInWindow)
                break;
            case .leftMouseUp:
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
//        guard let windowController = self.view.window?.windowController as? WindowController else{
//            return;
//        }
//        guard let VPET = windowController.VPET else{
//            return;
//        }
//        if(sender.title == "退出"){
//            self.ZANbutton.isHidden = !self.ZANbutton.isHidden
//            self.BObutton.isHidden = !self.BObutton.isHidden
//            self.ACTIONMenuButton.isHidden = !self.ACTIONMenuButton.isHidden
//            VPET.shutdown()
//        }
//        else if(sender.title == "切换状态"){
//            switch VPET.VPetStatus{
//            case .Ill: VPET.VPetStatus = .Happy;break;
//            case .Happy:VPET.VPetStatus = .Normal;break;
//            case .Normal:VPET.VPetStatus = .PoorCondition;break;
//            case .PoorCondition:VPET.VPetStatus = .Ill;break;
//        }
//            VPET.updateAction()
////            ACTIONMenu
//        }
//        else if(sender.title == "动作"){
//            chooseActionMenu.sendVPET(VPET)
//            ACTIONMenuButton.menu = chooseActionMenu.menu
//            ACTIONMenuButton.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: ACTIONMenuButton)
//        }
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
        case "退出当前互动":
            VPET.workAndSleepHandler.endplayFromCurrentActionTitle();
            VPET.updateAnimation();break;
//            VPET.VPetActionStack.removeLast();
            
//            VPET.updateAction()
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


}

