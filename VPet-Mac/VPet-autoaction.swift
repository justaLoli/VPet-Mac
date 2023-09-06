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
    func isAutoAcitonAllowed() -> Bool{
        let t = VPET.VPetGraphTypeStack.last
        if((t == .Sleep && VPET.workAndSleepHandler.currentActionTitle != nil) || t == .Shutdown || t == .Raised_Static || t == .Raised_Dynamic){
            return false;
        }
        return true;
    }
    func startAutoAction(){
        if(!isAutoAcitonAllowed()){print("current dont allow autoaction");return;}
        
        print("start")
        
        repeat{
            chooseGraphType = autoActions.randomElement()!.key
        }while(chooseGraphType == .StateTWO) //第一抽不要抽到statetwo

        chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
        
        playAutoAction()
        
        print("startAutoAction: auto start anime")
        print(chooseGraphType.rawValue)
        print(chooseAnimeTitle!)
        
        
        
    }
    func playAutoAction(){
        let pl = VPET.generatePlayListAB(graphtype:chooseGraphType,modetype: VPET.VPetStatus,title: chooseAnimeTitle);
        //更新主类动作栈
        VPET.VPetGraphTypeStack.append(chooseGraphType);
        VPET.animeplayer.setPlayList(pl);
        VPET.animeplayer.setPlayMode(.Shuffle)
        autoActionStarted = true;
        
        let timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { _ in
            self.switchToNextAutoAction()
        })
        
    }
    func switchToNextAutoAction(){
        guard autoActionStarted else{return}
        //已经开始，随机时长，切换下一个
        let nextaction = ["keepcurrent","switchnext","quit"].randomElement()!
        print(nextaction)
        switch nextaction{
        case "keepcurrent":
            let timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { _ in
                self.switchToNextAutoAction()
            })
            return;
        case "quit":
            if(chooseGraphType == .StateTWO){break;} //stateTWO不允许退出
            playEndAutoAction();
            VPET.updateAnimation();
            return;
        default:break;
        }
        
        //决定换一个动作了！
        
        
        if(chooseGraphType == .StateTWO){
            fromStateTwotoStateOne();
            return;
        } // 原来statetwo，只降到stateone
        else{
            var gt:GraphInfo.GraphType?
            repeat{
                gt = autoActions.randomElement()!.key
            }while(gt == chooseGraphType   //不要抽到和原来相同的
                   || (chooseGraphType != .StateONE && gt == .StateTWO)) //statetwo只有上一个是stateone才能抽
            if(chooseGraphType == .StateONE && gt == .StateTWO){
                fromStateOnetoStateTwo();
                return;
            }
            playEndAutoAction()
            chooseGraphType = gt
        }
        
        chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
        print(chooseGraphType.rawValue)
        print(chooseAnimeTitle!)
        playAutoAction()
        
    }
    
    func instantlyquit(){
        guard autoActionStarted else{return}
        autoActionStarted = false;
        VPET.animeplayer.interruptAndSetPlayList([]);
        //更新主类动作栈
        if !(autoActions.keys.contains(VPET.VPetGraphTypeStack.last!)){
            print("instantlyendAutoAction: strange. stack top is not an autoaction")
        }
        VPET.VPetGraphTypeStack.removeLast();
    }
    
    func playEndAutoAction(){
        let pl = VPET.generatePlayListC(graphtype: chooseGraphType, modetype: VPET.VPetStatus, title: chooseAnimeTitle);
        VPET.animeplayer.interruptAndSetPlayList(pl);
        VPET.animeplayer.setPlayMode(.Shuffle);
        autoActionStarted = false;
        //更新主类动作栈
        if !(autoActions.keys.contains(VPET.VPetGraphTypeStack.last!)){
            print("endAutoAction: strange. stack top is not an autoaction")
        }
        VPET.VPetGraphTypeStack.removeLast();
    }
    
    func fromStateTwotoStateOne(){
        playEndAutoAction()
        chooseGraphType = .StateONE
        chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
        //自动状态还不停，从stateTWO变为stateONE,直接进入循环
        let pl = VPET.generatePlayListB(graphtype:chooseGraphType,modetype: VPET.VPetStatus,title: chooseAnimeTitle);
//        更新主类动作栈
//        VPET.VPetGraphTypeStack.append(chooseGraphType);
        VPET.animeplayer.setPlayList(pl);
        VPET.animeplayer.setPlayMode(.Shuffle)
        autoActionStarted = true;
        let timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { _ in
            self.switchToNextAutoAction()
        })
        return
    }
    func fromStateOnetoStateTwo(){
        //不播放1的结束，直接插入2的开始
        
        chooseGraphType = .StateTWO
        chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
        playAutoAction()
    }
    
    func onUserInterrupted(){
        guard autoActionStarted else{return}
        autoActionStarted = false;
        playEndAutoAction()
        if(chooseGraphType == .StateTWO){
            chooseGraphType = .StateONE
            chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
            //自动状态还不停，从stateTWO变为stateONE
            let pl = VPET.generatePlayListB(graphtype:chooseGraphType,modetype: VPET.VPetStatus,title: chooseAnimeTitle);
            //更新主类动作栈
            VPET.VPetGraphTypeStack.append(chooseGraphType);
            VPET.animeplayer.setPlayList(pl);
            VPET.animeplayer.setPlayMode(.Shuffle)
            autoActionStarted = true;
            return
        }
        VPET.HuDongZhouQiCountWithoutAction = 0;
        VPET.updateAnimation()
    }
}
