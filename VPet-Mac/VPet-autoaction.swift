//
//  VPet-autoaction.swift
//  VPet-Mac
//
//  Created by Just aLoli on 2023/9/4.
//

import Cocoa

class VPetAutoActionHandler{
    let VPET:VPet!
    var movehandler:VPetAutoMoveHandler?
    init(_ VPET:VPet) {
        self.VPET = VPET
        movehandler = VPetAutoMoveHandler(VPET)
    }
    var autoActionStarted = false;
    // 自动触发项目的长期包括：
    // IDEL发呆，关键词Boring & Squat
    // MOVE移动，关键词太多了
    // Music随音乐舞动，关键词Music
    // Sleep睡觉，这个睡觉和手动触发的睡觉略不同，可以在工作中途触发且不覆盖工作。
    // State待机，关键词StateOne & StateTwo
    
    // 自动触发短期项目
    // 表达饥饿、口渴；状态变好，变差；
    // Say说话，这个实现可能略困难
    
    // 这个类目前是用来处理长期项目的，因为它们不太涉及桌宠属性
    
    var autoActions = hardCodedText.autoActions
    
    var chooseGraphType:GraphInfo.GraphType!
    var chooseAnimeTitle:String!
    func isAutoAcitonAllowed() -> Bool{
        let t = VPET.VPetGraphTypeStack.last
        if((t == .Sleep && VPET.workAndSleepHandler.currentActionTitle != nil) || t == .Shutdown || t == .Raised_Static || t == .Raised_Dynamic || t == .Move){
            return false;
        }
        return true;
    }
    func startAutoAction(){
        if(!isAutoAcitonAllowed()){print("current dont allow autoaction");return;}
        
        if(autoActionStarted){return;}
        
        print("start")
        
        repeat{
            chooseGraphType = autoActions.randomElement()!.key
        }while(chooseGraphType == .StateTwo) //第一抽不要抽到statetwo
        if(chooseGraphType == .Move){
            //自动移动
            self.movehandler!.startAutoMove();
            self.autoActionStarted = true;
            return;
        }
        
        
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
            if(chooseGraphType == .StateTwo){break;} //stateTwo不允许退出
            playEndAutoAction();
            VPET.updateAnimation();
            return;
        default:break;
        }
        
        //决定换一个动作了！
        
        
        if(chooseGraphType == .StateTwo){
            fromStateTwotoStateOne();
            return;
        } // 原来stateTwo，只降到stateOne
        else{
            var gt:GraphInfo.GraphType?
            repeat{
                gt = autoActions.randomElement()!.key
            }while(gt == chooseGraphType   //不要抽到和原来相同的
                   || (chooseGraphType != .StateOne && gt == .StateTwo)) //stateTwo只有上一个是stateOne才能抽
            if(chooseGraphType == .StateOne && gt == .StateTwo){
                fromStateOnetoStateTwo();
                return;
            }
            playEndAutoAction()
            chooseGraphType = gt
        }
        
        if(chooseGraphType == .Move){
            self.movehandler?.startAutoMove();
            self.autoActionStarted = true;
            return;
        }
        
        chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
        print(chooseGraphType.rawValue)
        print(chooseAnimeTitle!)
        playAutoAction()
        
    }
    
    func instantlyquit(){
        if(!autoActionStarted){return}
        if(movehandler!.moveStarted){
            self.movehandler!.stopAutoMove();
            return;
        }
        playEndAutoAction()
        VPET.updateAnimation()
    }
    
    func playEndAutoAction(){
        let pl = VPET.generatePlayListC(graphtype:chooseGraphType,modetype: VPET.VPetStatus,title: chooseAnimeTitle);
        if(!pl.isEmpty){
            VPET.animeplayer.interruptAndSetPlayList(pl)
            VPET.animeplayer.removeCurrentAnimeAfterFinish = true;
        }
        VPET.VPetGraphTypeStack.removeLast()
        autoActionStarted = false;
    }
    
    func fromStateTwotoStateOne(){
        //不播放1的结束，直接插入2的开始
        
        chooseGraphType = .StateOne
        chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
        playAutoAction()
    }
    
    func fromStateOnetoStateTwo(){
        //不播放1的结束，直接插入2的开始
        
        chooseGraphType = .StateTwo
        chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
        playAutoAction()
    }
    
    func onUserInterrupted(){
        autoActionStarted = false;
        if(movehandler!.moveStarted){
            self.movehandler!.stopAutoMove();
            return;
        }
        playEndAutoAction()
        if(chooseGraphType == .StateTwo){
            chooseGraphType = .StateOne
            chooseAnimeTitle = autoActions[chooseGraphType!]!.randomElement()!
            //自动状态还不停，从stateTwo变为stateOne
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
