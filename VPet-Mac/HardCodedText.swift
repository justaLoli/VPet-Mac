//
//  texts.swift
//  VPet-Mac
//
//  Created by Just aLoli on 2023/9/2.
//

import Cocoa

//class texts {
//
//}

class HardCodedText{
    
    var actionMenus = [
        "睡觉",
        "---",
        "学习",
        "玩耍",
        "工作"]
    var actionTypesShownInMenu = [
        "睡觉":["睡觉"],
        "学习":["学习","研究"],
        "玩耍":["玩游戏","删错误"],
        "工作":["文案","清屏","直播"]
    ]
    var actionToKeyword = [
        "睡觉":"Sleep",
        "学习":"Study",
        "研究":"StudyTWO",
        "玩游戏":"PlayONE",
        "删错误":"RemoveObject",
        "文案":"WorkONE",
        "直播":"WorkTWO",
        "清屏":"WorkClean",
        "移动动画":"walk.left",
    ]
    var actionToGraphType:[String:GraphInfo.GraphType] = [
        "睡觉": .Sleep,
        "学习": .Work,
        "研究": .Work,
        "玩游戏": .Work,
        "删错误": .Work,
        "文案": .Work,
        "直播": .Work,
        "清屏": .Work,
    ]
    
    var raisePoint:[GraphInfo.ModeType:NSPoint] = [
        .Happy:NSPoint(x: 290, y: 128),
        .Normal:NSPoint(x: 290, y: 128),
        .PoorCondition:NSPoint(x: 290, y: 128),
        .Ill:NSPoint(x: 225, y: 115)
    ]
    
    
    var JiSuanJianGe = 15.0
    var HuDongZhouQi = 30.0
    
    
    var autoActions:[GraphInfo.GraphType:[String]] = [
        .Sleep:["Sleep"],
        .Boring:["Boring","Squat"],
        .Move:["climb.left",
               "climb.left",
               "climb.right",
               "climb.right",
               "climb.top.left",
               "climb.top.right",
               "fall.left",
               "fall.right",
               "walk.left",
               "walk.right",
               "walk.left.faster",
//               "walk.left.slow",
               "walk.right.faster",
               "walk.right.slow",
               "crawl.left",
               "crawl.right"],
        .StateOne:["StateOne"],
        .StateTwo:["StateTwo"]
    ]
    
}

let hardCodedText = HardCodedText()
