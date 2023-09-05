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
    
    
    override func viewDidLoad() {
        print("viewdidload")
        super.viewDidLoad()
        player = AnimePlayer(imagev)
        
        //让imageview的大小和window一致（整个程序生命中都应该保证这一点）
        //写在window里面了
//        imagev.setFrameSize(self.view.window!.frame.size)
        initButton()
        initMouseEvent()
        initViewMainMenu()

    }
    func initViewMainMenu(){
        self.view.menu = viewMainMenu
        self.view.menu?.item(withTitle: "互动")!.submenu = chooseActionMenu.menu
//        self.view.menu?.addItem(withTitle: "退出当前互动", action: #selector(onActionMenuItemClicked),keyEquivalent: "")
    }
    func initButton(){
        for subv in self.view.subviews{
            if let button = subv as? NSButton{
                button.isHidden = true
            }
        }
        self.workingOverlayView.isHidden = true;
    }
    func initMouseEvent(){
        
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


}

