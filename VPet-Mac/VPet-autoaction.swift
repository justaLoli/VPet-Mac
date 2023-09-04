//
//  VPet-autoaction.swift
//  VPet-Mac
//
//  Created by Just aLoli on 2023/9/4.
//

import Cocoa

class VPetAutoActionHandler{
    let VPET:VPet!
    init(_ VPET:VPet) {
        self.VPET = VPET
    }
    var autoActionStarted = false;
    // 自动触发项目的长期包括：
    // IDEL发呆，关键词Boring & Squat
    // MOVE移动，关键词太多了
    // Music随音乐舞动，关键词Music
    // Sleep睡觉，这个睡觉和手动触发的睡觉略不同，可以在工作中途触发且不覆盖工作。
    // State待机，关键词StateONE & StateTWO
    
    // 自动触发短期项目
    // 表达饥饿、口渴；状态变好，变差；
    // Say说话，这个实现可能略困难
    
    // 这个类目前是用来处理长期项目的，因为它们不太涉及桌宠属性
    
    var autoActions = hardCodedText.autoActions
    
    var chooseGraphType:GraphInfo.GraphType!
    var chooseAnimeTitle:String!
    
    func startAutoAction(){
        print("start")
        chooseGraphType = autoActions.randomElement()!.key
//        chooseGraphType = GraphInfo.GraphType.Idel

        chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
        
        playAutoAction()
        
        print("startAutoAction: auto start anime")
        print(chooseGraphType.rawValue)
        print(chooseAnimeTitle!)
        
    }
    func playAutoAction(){
        let pl = VPET.animeplayer.animeInfoList.generatePlayListAB(graphtype:chooseGraphType,modetype: VPET.VPetStatus,title: chooseAnimeTitle);
        //更新主类动作栈
        VPET.VPetGraphTypeStack.append(chooseGraphType);
        VPET.animeplayer.setPlayList(pl);
        VPET.animeplayer.setPlayMode(.Shuffle)
        autoActionStarted = true;
    }
    func switchToNextAutoAction(){
        
    }
    func endAutoAction(){
        guard autoActionStarted else{return}
        autoActionStarted = false;
        let pl = VPET.animeplayer.animeInfoList.generatePlayListC(graphtype: chooseGraphType, modetype: VPET.VPetStatus, title: chooseAnimeTitle);
        VPET.animeplayer.interruptAndSetPlayList(pl);
        VPET.animeplayer.setPlayMode(.Shuffle);
        autoActionStarted = false;
        //更新主类动作栈
        if !(autoActions.keys.contains(VPET.VPetGraphTypeStack.last!)){
            print("endAutoAction: strange. stack top is not an autoaction")
        }
        VPET.VPetGraphTypeStack.removeLast();
        if(chooseGraphType == .StateTWO){
            chooseGraphType = .StateONE
            chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
            let pl = VPET.animeplayer.animeInfoList.generatePlayListB(graphtype: .StateONE, modetype: VPET.VPetStatus, title: chooseAnimeTitle)
            VPET.VPetGraphTypeStack.append(chooseGraphType);
            VPET.animeplayer.setPlayList(pl);
            VPET.animeplayer.setPlayMode(.Shuffle)
            autoActionStarted = true;
            //自动状态还不停，从stateTWO变为stateONE
            return
        }
        VPET.HuDongZhouQiCountWithoutAction = 0;
        VPET.updateAnimation()
    }
}
