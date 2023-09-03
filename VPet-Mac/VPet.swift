//
//  VPet.swift
//  new2
//
//  Created by Just aLoli on 2023/8/31.
//

import Cocoa

class VPet{
    let displayWindow:WindowController!
    let animeplayer:AnimePlayer!
    var VPetStatus = GraphInfo.ModeType.Happy
    
    
//    var VPetCurrentMovement = GraphInfo.GraphType.Default
    
    //栈，尾部为栈顶
    var VPetActionStack = [GraphInfo.GraphType]()
    var currentActionTitle:String? = nil
    
    init(displayWindow: WindowController, animeplayer: AnimePlayer) {
        self.displayWindow = displayWindow
        self.animeplayer = animeplayer
        
        
        
    }
    func linkstatusbar(sbi:StatusBarItemController){
        
    }
    
    
    func startup(){
        let lists = animeplayer.animeInfoList.find(graphtype: .StartUP,modetype: VPetStatus)
        if lists.isEmpty{print("startup(): list empty. strange.");return;}
        let first = lists.randomElement()!
        animeplayer.setPlayList([first])
        animeplayer.play()
        VPetActionStack.append(.Default)
        updateAction()
//        play("PlayONE")
    }
    
    func updateAction(){
//        print(")")
        switch VPetActionStack.last!{
        case .Default:
            makeDefault();break;
        case .Work:
            replayFromCurrentActionTitle();break;
        case .Sleep:
            replayFromCurrentActionTitle();break;
        default:
            break;
        }
    }
    
    func makeDefault(){
        let list2 = animeplayer.animeInfoList.find(graphtype: .Default,modetype: VPetStatus).shuffled()
        animeplayer.setPlayList(list2)
        animeplayer.setPlayMode(.Shuffle)
    }
    
    func replayFromCurrentActionTitle(){
        guard currentActionTitle != nil else{return;}
        guard let k = hardCodedText.actionToKeyword[currentActionTitle!] else{return}
        let searchkey = k + "/"
        ;
        var pl = [GraphInfo]()
        var lists = animeplayer.animeInfoList.find(animatype:.A_Start,modetype: VPetStatus, keywordinfilename: searchkey)
        ;
        if(!lists.isEmpty){
            pl.append(lists.randomElement()!)
        }
        else{
            var lists = animeplayer.animeInfoList.find(animatype:.A_Start,modetype: .Normal, keywordinfilename: searchkey)
            ;
            if(!lists.isEmpty){
                pl.append(lists.randomElement()!)
            }
        }
        lists = animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: VPetStatus,keywordinfilename: searchkey)
        if(!lists.isEmpty){
            pl += lists;
        }
        else{
            lists = animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: .Normal,keywordinfilename: searchkey)
            if(!lists.isEmpty){
                pl += lists;
            }
        }
        
        ;
        
        self.animeplayer.setPlayList(pl)
        self.animeplayer.removeCurrentAnimeAfterFinish = true;
        self.animeplayer.setPlayMode(.Shuffle)
    }
    
    func shutdown(){
        animeplayer.stop()
        print("shudown ")
        let lists = animeplayer.animeInfoList.find(graphtype: .Shutdown, modetype: VPetStatus)
        if lists.isEmpty{print("startup(): list empty. strange.");return;}

        let choose = lists.randomElement()!
        animeplayer.interruptAndSetPlayList([choose])
        animeplayer.loopLastAnime = false
        //等待5秒后关闭，不要立刻关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
            self.displayWindow.window?.close()
        }
    }
    
    
    
    
    func handleLeftMouseUp(_ p:NSPoint? = nil){
        if(self.VPetActionStack.last == .Raised_Static || self.VPetActionStack.last == .Raised_Dynamic){
            raisedEnd()
        }
    }
    
    func raised(_ p: NSPoint){
        if(self.VPetActionStack.last != .Raised_Static && self.VPetActionStack.last != .Raised_Dynamic){
            raisedStart()
        }
        raisedMoving(p)
    }
    
    func raisedStart(){
        //加载动画
        var dynamicOrStatic = [GraphInfo.GraphType.Raised_Dynamic,GraphInfo.GraphType.Raised_Static].randomElement()!
        if VPetStatus == .PoorCondition{dynamicOrStatic = .Raised_Static}
        //将被提起这一事件添加到栈
        self.VPetActionStack.append(dynamicOrStatic)
        
        //设置播放列表：开始动画只能最多有一个，如果有多个就抽一个
        let As = animeplayer.animeInfoList.find(animatype: .A_Start,graphtype: dynamicOrStatic,modetype: VPetStatus)
        var lists = [GraphInfo]()
        if !(As.isEmpty){lists.append(As.randomElement()!)}
        //循环的有几个无所谓，带上Single是以防万一
        lists += animeplayer.animeInfoList.find(animatype: .B_Loop,graphtype: dynamicOrStatic, modetype: VPetStatus).shuffled()
        lists += animeplayer.animeInfoList.find(animatype: .Single,graphtype: dynamicOrStatic,modetype: VPetStatus).shuffled()
        
        //增加响应速度用的一行
        animeplayer.ImageView.image = NSImage(byReferencingFile: animeplayer.allAnimes[lists.first!]![0])
        
        animeplayer.interruptAndSetPlayList(lists)
        //播放第一个开始动画之后从播放列表中移除开始动画，随后随机剩下的动画
        //如果有A，那么自动跳过开始动画，没A不跳过
        animeplayer.setPlayMode(.SingleLoop)
//        animeplayer.removeCurrentAnimeAfterFinish = true;
//        animeplayer.setPlayMode(.Shuffle)
    }
    func raisedMoving(_ targetPos:NSPoint){
        //移动窗口
        var raisePoint = [GraphInfo.ModeType:NSPoint]()
        raisePoint[.Happy] = NSPoint(x: 290, y: 128)
        raisePoint[.Normal] = NSPoint(x: 290, y: 128)
        raisePoint[.PoorCondition] = NSPoint(x: 290, y: 128)
        raisePoint[.Ill] = NSPoint(x: 225, y: 115)
        displayWindow.setWindowPos(controlPos: raisePoint[VPetStatus]!, targetPos: targetPos)
    }
    func raisedEnd(){
        let lists = animeplayer.animeInfoList.find(animatype: .C_End,graphtype: .Raised_Static,modetype: VPetStatus)
        if(!lists.isEmpty){
            let endanime = lists.randomElement()!
            animeplayer.interruptAndSetPlayList([endanime])
            animeplayer.removeCurrentAnimeAfterFinish = true;
            
        }
        self.VPetActionStack.removeLast()
        updateAction()
    }
    
    func play(_ title:String,interrupt:Bool = true){
        var isinterrupt = interrupt
        if currentActionTitle != nil {
            if(currentActionTitle != title){
                //在已有事件的基础上，开启一个新的事件
                endplayFromCurrentActionTitle()
            }
            //也有可能是重新播放当前事件
            isinterrupt = false
        }
        guard let k = hardCodedText.actionToKeyword[title] else{return}
        let searchkey = k + "/"
        ;
        var pl = [GraphInfo]()
        var lists = animeplayer.animeInfoList.find(animatype:.A_Start,modetype: VPetStatus, keywordinfilename: searchkey)
        ;
        if(!lists.isEmpty){
            pl.append(lists.randomElement()!)
        }
        else{
            var lists = animeplayer.animeInfoList.find(animatype:.A_Start,modetype: .Normal, keywordinfilename: searchkey)
            ;
            if(!lists.isEmpty){
                pl.append(lists.randomElement()!)
            }
        }
        lists = animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: VPetStatus,keywordinfilename: searchkey)
        if(!lists.isEmpty){
            pl += lists;
        }
        else{
            lists = animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: .Normal,keywordinfilename: searchkey)
            if(!lists.isEmpty){
                pl += lists;
            }
        }
        
        ;
        if(lists.isEmpty){
            print("play: 播放列表为空，可能当前心情没有当前动作。");return;
        }
        if(isinterrupt){
            self.animeplayer.interruptAndSetPlayList(pl)
        }
        else{
            self.animeplayer.setPlayList(pl)
        }
        self.animeplayer.removeCurrentAnimeAfterFinish = true;
        self.animeplayer.setPlayMode(.Shuffle)
        
        let newActionGraphType = hardCodedText.actionToGraphType[title] ?? .Work
        self.VPetActionStack.append(newActionGraphType)
        self.currentActionTitle = title;
    }
    func endplayFromCurrentActionTitle(){
        guard currentActionTitle != nil else{return;}
        guard let k = hardCodedText.actionToKeyword[self.currentActionTitle!] else{return;}
        let searchkey = k + "/"
        let lists = animeplayer.animeInfoList.find(animatype:.C_End,modetype: VPetStatus,keywordinfilename: searchkey);
        var pl = [GraphInfo]()
        if(!lists.isEmpty){
            pl.append(lists.randomElement()!)
        }
        else{
            let lists = animeplayer.animeInfoList.find(animatype:.C_End,modetype: .Normal,keywordinfilename: searchkey);
            if(!lists.isEmpty){
                pl.append(lists.randomElement()!)
            }
        }
        animeplayer.interruptAndSetPlayList(pl)
        animeplayer.removeCurrentAnimeAfterFinish = true;
        self.VPetActionStack.removeLast();
        self.currentActionTitle = nil;
        updateAction()
    }
    
}
