//
//  StatusBarItemController.swift
//  new2
//
//  Created by Just aLoli on 2023/8/31.
//

import Cocoa

class StatusBarItemController: NSObject {
    var statusItem:NSStatusItem!
    var VPET:VPet!
    let listAllAnimeMenuItemSubMenu = NSMenu()
    override init(){
        super.init()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button{
            button.image = NSImage(named: "循环A_000_125")
            button.toolTip = "事例"
            button.action = #selector(statusItemClick(_ :))
        }
        let listAllAnimeMenuItem = NSMenuItem(title: "所有动画", action: #selector(menuItemAction(_ :)), keyEquivalent: "")
        
        listAllAnimeMenuItem.submenu = listAllAnimeMenuItemSubMenu
        let menu = NSMenu()
        menu.addItem(listAllAnimeMenuItem)
        statusItem.menu = menu;
        statusItem?.isVisible = true
    }
    func loadVPet(vpet:VPet){
        VPET = vpet
    }
    @objc func statusItemClick(_ sender: Any?) {
        // 在这里处理图标点击事件
        print("菜单栏图标被点击")
    }
    // 菜单项点击事件
    @objc func menuItemAction(_ sender: NSMenuItem) {
       // 在这里处理菜单项点击事件
       if sender.title == "选项1" {
           print("选项1被点击")
       } else if sender.title == "选项2" {
           print("选项2被点击")
       }
    }
}
