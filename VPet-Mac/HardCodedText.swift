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
        "清屏":"WorkClean"
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
}

let hardCodedText = HardCodedText()
