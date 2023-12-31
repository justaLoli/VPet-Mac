//
//  ChooseActionMenu.swift
//  VPet-Mac
//
//  Created by Just aLoli on 2023/9/2.
//

import Cocoa


import Cocoa

var actionTypesShownInMenu = [
    "睡觉":["睡觉"],
    "学习":["学习","研究"],
    "玩耍":["玩游戏","删错误"],
    "工作":["文案","清屏","直播"]
]

// Create an NSMenu
let menu = NSMenu()



// You can attach this menu to a view or another UI element as needed
// For example, if you have a button 'myButton', you can set the menu like this:
// myButton.menu = menu


class ChooseActionMenu {
//create a menu based on hardCodedText.actionTypesShownInMenu
    
    
    var menu = NSMenu()
    var VPET:VPet?
    init(){
        inflateMenu()
    }
    func sendVPET(_ VPET:VPet){
        self.VPET = VPET
    }
    func inflateMenu(){
        let actionMenus = hardCodedText.actionMenus
        let actionTypesShownInMenu = hardCodedText.actionTypesShownInMenu
        // 按照顺序添加，顺序来自 hardCodedText.actionMenus
        
        for category in actionMenus{
            guard let actions = actionTypesShownInMenu[category] else{
                if category == "---"{
                    //add a separator
                    menu.addItem(NSMenuItem.separator())
                    
                }
                continue
            }
            // if there is only one action， dont add submenu
            if actions.count == 1 {
                let menuItem = NSMenuItem(title: category, action: #selector(menuItemClicked), keyEquivalent: "")
                menuItem.target = self // Set the target to the appropriate object
                menu.addItem(menuItem)
                continue
            }

            // Create a submenu for each category
            let submenu = NSMenu(title: category)

            for action in actions {
                // Create a menu item for each action
                let menuItem = NSMenuItem(title: action, action: #selector(menuItemClicked), keyEquivalent: "")
                menuItem.target = self // Set the target to the appropriate object

                // Add the menu item to the submenu
                submenu.addItem(menuItem)
            }

            // Add the submenu to the main menu
            menu.addItem(NSMenuItem(title: category, action: nil, keyEquivalent: ""))
            menu.setSubmenu(submenu, for: menu.item(withTitle: category)!)
        }
//        let item = NSMenuItem(title: "移动动画", action: #selector(menuItemClicked), keyEquivalent: "")
//        item.target = self;
//        menu.addItem(item)
    }
    
    @objc func menuItemClicked(_ sender: NSMenuItem) {
        // Do something when a menu item is clicked
        print("Menu item clicked: \(sender.title)")
        if(VPET?.workAndSleepHandler.currentActionTitle == sender.title){
            VPET?.workAndSleepHandler.endplayFromCurrentActionTitle()
            return;
        }
        VPET?.workAndSleepHandler.play(sender.title)
    }
    

}
