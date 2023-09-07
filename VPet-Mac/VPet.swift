//
//  VPet.swift
//  new2
//
//  Created by Just aLoli on 2023/8/31.
//

import Cocoa

class VPet{
    let displayWindow:WindowController!
    let displayView:ViewController!
    let animeplayer:AnimePlayer!
    var VPetStatus = GraphInfo.ModeType.Happy
    
    var VPetStatusRefreshTimer:Timer? = nil
    
    var HuDongZhouQiCountWithoutAction = 0
    
    //栈，尾部为栈顶
    var VPetGraphTypeStack = [GraphInfo.GraphType]()
//    var currentActionTitle:String? = nil
    
    
    var raiseHandler:VPetRaiseHandler!
    var workAndSleepHandler:VPetWorkHandler!
    var autoActionHendler:VPetAutoActionHandler!
    
    
    
    init(displayWindow: WindowController, animeplayer: AnimePlayer,displayView:ViewController) {
        self.displayWindow = displayWindow
        self.animeplayer = animeplayer
        self.displayView = displayView
        
        self.raiseHandler = VPetRaiseHandler(self)
        self.workAndSleepHandler = VPetWorkHandler(self)
        self.autoActionHendler = VPetAutoActionHandler(self)
        
        
    }
    
    func initVPetStatesRefreshTimer(){
        VPetStatusRefreshTimer = Timer.scheduledTimer(withTimeInterval: hardCodedText.JiSuanJianGe, repeats: true, block: { _ in
            self.refreshTimerTimeOut()
        })
    }
    func refreshTimerTimeOut(){
        //数据更新（没写）
        
        //互动周期计算
        HuDongZhouQiCountWithoutAction += 1
        if(Double(HuDongZhouQiCountWithoutAction) >= hardCodedText.HuDongZhouQi/10 && autoActionHendler.autoActionStarted == false){
            autoActionHendler.startAutoAction()
        }
    }
    
    func startup(){
        let lists = animeplayer.animeInfoList.find(graphtype: .StartUP,modetype: VPetStatus)
        if lists.isEmpty{print("startup(): list empty. strange.");return;}
        let first = lists.randomElement()!
        animeplayer.setPlayList([first])
        animeplayer.play()
        VPetGraphTypeStack.append(.Default)
        updateAnimation()
        
        initVPetStatesRefreshTimer()
        
    }
    
    func updateAnimation(){
        print("updateAnimation")
        print(VPetGraphTypeStack)
        switch VPetGraphTypeStack.last!{
        case .Default:
            updateDefaultAnime();break;
        case .Work:
            updateWorkAnime();break;
        case .Sleep:
            updateSleepAnime();break;
        default:
            break;
        }
    }
    
    func updateDefaultAnime(){
        let list2 = animeplayer.animeInfoList.find(graphtype: .Default,modetype: VPetStatus).shuffled()
        animeplayer.setPlayList(list2)
        animeplayer.setPlayMode(.Shuffle)
    }
    func updateWorkAnime(){
        workAndSleepHandler.replayFromCurrentActionTitle()
    }
    func updateSleepAnime(){
//        replayFromCurrentActionTitle();
        workAndSleepHandler.replayFromCurrentActionTitle()
    }
    
    
    
    func shutdown(){
        animeplayer.stop()
        print("shudown ")
        let lists = animeplayer.animeInfoList.find(graphtype: .Shutdown, modetype: VPetStatus)
        if lists.isEmpty{print("startup(): list empty. strange.");return;}

        let choose = lists.randomElement()!
        animeplayer.interruptAndSetPlayList([choose])
        animeplayer.loopLastAnime = false
        
        //更新栈，真的发生了关闭的这一段时间自动任务被触发的诡异事情
        VPetGraphTypeStack.append(.Shutdown)
        
        //等待3秒后关闭，不要立刻关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            self.displayWindow.window?.close()
        }
    }
    
    
    
    
    // 提起
    // 提起
    // 提起
    // 提起
    // 提起
    
    func handleLeftMouseDown(_ p:NSPoint? = nil){
        print("无操作互动周期清零！")
        HuDongZhouQiCountWithoutAction = 0
    }
    
    func handleLeftMouseUp(_ p:NSPoint? = nil){
        
        if(self.autoActionHendler.autoActionStarted){
            self.autoActionHendler.onUserInterrupted()
            return;
        }
        //当前在睡觉？那么叫醒！
        if(self.VPetGraphTypeStack.last == .Sleep){
            self.workAndSleepHandler.endplayFromCurrentActionTitle()
        }
        if(self.VPetGraphTypeStack.last == .Raised_Static || self.VPetGraphTypeStack.last == .Raised_Dynamic){
            self.raiseHandler.raisedEnd()
        }
    }
    
    func handleLeftMouseDragged(_ p: NSPoint){
        if(self.VPetGraphTypeStack.last != .Raised_Static && self.VPetGraphTypeStack.last != .Raised_Dynamic){
            self.raiseHandler.raisedStart()
        }
        self.raiseHandler.raisedMoving(p)
    }
    
    
    
    
    
    // 播放互动
    // 播放互动
    // 播放互动
    // 播放互动
    // 播放互动
    
   
    // 播放列表生成
    // 播放列表生成
    // 播放列表生成
    
    func generatePlayListC(graphtype:GraphInfo.GraphType? = nil,modetype:GraphInfo.ModeType? = nil, keywordinfilename:String? = nil,title:String? = nil) -> [GraphInfo]{
        var searchkey:String? = nil;
        if(title != nil){searchkey = title! + "/"}
        if(keywordinfilename != nil){searchkey = keywordinfilename}
        var pl = [GraphInfo]()
        
        var lists = animeplayer.animeInfoList.find(animatype: .C_End,modetype: modetype,keywordinfilename: searchkey);
        if(!lists.isEmpty){pl.append(lists.randomElement()!)}
        else{
            lists = animeplayer.animeInfoList.find(animatype: .C_End,modetype: .Normal,keywordinfilename: searchkey);
            if(!lists.isEmpty){pl.append(lists.randomElement()!)}
        }
        return pl;
    }
    func generatePlayListB(graphtype:GraphInfo.GraphType? = nil,modetype:GraphInfo.ModeType? = nil, keywordinfilename:String? = nil,title:String? = nil) -> [GraphInfo]{
        var searchkey:String? = nil;
        if(title != nil){searchkey = title! + "/"}
        if(keywordinfilename != nil){searchkey = keywordinfilename}
        var lists = animeplayer.animeInfoList.find(animatype: .B_Loop,modetype: modetype,keywordinfilename: searchkey);
        if(!lists.isEmpty){return lists}
        lists = animeplayer.animeInfoList.find(animatype: .B_Loop,modetype: .Normal,keywordinfilename: searchkey);
        return lists
    }
    func generatePlayListAB(graphtype:GraphInfo.GraphType? = nil,
                            modetype:GraphInfo.ModeType? = nil,
                            keywordinfilename:String? = nil,title:String? = nil) -> [GraphInfo]{
        var searchkey:String? = nil;
        if(title != nil){
            searchkey = title! + "/"
        }
        if(keywordinfilename != nil){searchkey = keywordinfilename}
        ;
        var pl = [GraphInfo]()
        var lists = animeplayer.animeInfoList.find(animatype:.A_Start,modetype: modetype, keywordinfilename: searchkey)
        ;
        if(!lists.isEmpty){
            pl.append(lists.randomElement()!)
        }
        else{
            let lists = animeplayer.animeInfoList.find(animatype:.A_Start,modetype: .Normal, keywordinfilename: searchkey)
            ;
            if(!lists.isEmpty){
                pl.append(lists.randomElement()!)
            }
        }
        lists = animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: modetype,keywordinfilename: searchkey)
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
        return pl;
    }
    
    
    
    
}
