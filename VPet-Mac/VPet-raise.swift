//
//  VPet-raise.swift
//  VPet-Mac
//
//  Created by Just aLoli on 2023/9/3.
//
import Cocoa

//extension VPet{
class VPetRaiseHandler{
    //分析原版，某些时候（比如睡觉时）不允许拖动宠物
    var shouldhandle = true
    
    let VPET:VPet!
    init(_ VPET:VPet) {
        self.VPET = VPET
    }
    
    func judgeRaisable() -> Bool{
        let status = VPET.VPetGraphTypeStack.last;
        if(status == .Default || status == .Work){
            shouldhandle = true;
            return true;
        }
        shouldhandle = false;
        return false;
    }
    
    func raisedStart(){
        guard judgeRaisable() else{return}
        guard shouldhandle else{return}
        
        //加载动画
        var dynamicOrStatic = [GraphInfo.GraphType.Raised_Dynamic,GraphInfo.GraphType.Raised_Static].randomElement()!
        if VPET.VPetStatus == .PoorCondition{dynamicOrStatic = .Raised_Static}
        //将被提起这一事件添加到栈
        VPET.VPetGraphTypeStack.append(dynamicOrStatic)
        
        //设置播放列表：开始动画只能最多有一个，如果有多个就抽一个
        let As = VPET.animeplayer.animeInfoList.find(animatype: .A_Start,graphtype: dynamicOrStatic,modetype: VPET.VPetStatus)
        var lists = [GraphInfo]()
        if !(As.isEmpty){lists.append(As.randomElement()!)}
        //循环的有几个无所谓，带上Single是以防万一
        lists += VPET.animeplayer.animeInfoList.find(animatype: .B_Loop,graphtype: dynamicOrStatic, modetype: VPET.VPetStatus).shuffled()
        lists += VPET.animeplayer.animeInfoList.find(animatype: .Single,graphtype: dynamicOrStatic,modetype: VPET.VPetStatus).shuffled()
        
        //增加响应速度用的一行
        VPET.animeplayer.ImageView.image = NSImage(byReferencingFile: VPET.animeplayer.allAnimes[lists.first!]![0])
        
        VPET.animeplayer.interruptAndSetPlayList(lists)
        //播放第一个开始动画之后从播放列表中移除开始动画，随后随机剩下的动画
        //如果有A，那么自动跳过开始动画，没A不跳过
        VPET.animeplayer.setPlayMode(.SingleLoop)
//        animeplayer.removeCurrentAnimeAfterFinish = true;
//        animeplayer.setPlayMode(.Shuffle)
    }
    func raisedMoving(_ targetPos:NSPoint){
        guard shouldhandle else{return}
        
        //移动窗口
        let raisePoint = hardCodedText.raisePoint
        VPET.displayWindow.setWindowPos(controlPos: raisePoint[VPET.VPetStatus]!, targetPos: targetPos)
    }
    func raisedEnd(){
        guard shouldhandle else{return}
        
        let lists = VPET.animeplayer.animeInfoList.find(animatype: .C_End,graphtype: .Raised_Static,modetype: VPET.VPetStatus)
        if(!lists.isEmpty){
            let endanime = lists.randomElement()!
            VPET.animeplayer.interruptAndSetPlayList([endanime])
            VPET.animeplayer.removeCurrentAnimeAfterFinish = true;
            
        }
        VPET.VPetGraphTypeStack.removeLast()
        VPET.updateAnimation()
    }
}


//extension VPet{
//
//    func raisedStart(){
//        //加载动画
//        var dynamicOrStatic = [GraphInfo.GraphType.Raised_Dynamic,GraphInfo.GraphType.Raised_Static].randomElement()!
//        if VPetStatus == .PoorCondition{dynamicOrStatic = .Raised_Static}
//        //将被提起这一事件添加到栈
//        self.VPetGraphTypeStack.append(dynamicOrStatic)
//
//        //设置播放列表：开始动画只能最多有一个，如果有多个就抽一个
//        let As = animeplayer.animeInfoList.find(animatype: .A_Start,graphtype: dynamicOrStatic,modetype: VPetStatus)
//        var lists = [GraphInfo]()
//        if !(As.isEmpty){lists.append(As.randomElement()!)}
//        //循环的有几个无所谓，带上Single是以防万一
//        lists += animeplayer.animeInfoList.find(animatype: .B_Loop,graphtype: dynamicOrStatic, modetype: VPetStatus).shuffled()
//        lists += animeplayer.animeInfoList.find(animatype: .Single,graphtype: dynamicOrStatic,modetype: VPetStatus).shuffled()
//
//        //增加响应速度用的一行
//        animeplayer.ImageView.image = NSImage(byReferencingFile: animeplayer.allAnimes[lists.first!]![0])
//
//        animeplayer.interruptAndSetPlayList(lists)
//        //播放第一个开始动画之后从播放列表中移除开始动画，随后随机剩下的动画
//        //如果有A，那么自动跳过开始动画，没A不跳过
//        animeplayer.setPlayMode(.SingleLoop)
////        animeplayer.removeCurrentAnimeAfterFinish = true;
////        animeplayer.setPlayMode(.Shuffle)
//    }
//    func raisedMoving(_ targetPos:NSPoint){
//        //移动窗口
//        var raisePoint = hardCodedText.raisePoint
//        displayWindow.setWindowPos(controlPos: raisePoint[VPetStatus]!, targetPos: targetPos)
//    }
//    func raisedEnd(){
//        let lists = animeplayer.animeInfoList.find(animatype: .C_End,graphtype: .Raised_Static,modetype: VPetStatus)
//        if(!lists.isEmpty){
//            let endanime = lists.randomElement()!
//            animeplayer.interruptAndSetPlayList([endanime])
//            animeplayer.removeCurrentAnimeAfterFinish = true;
//
//        }
//        self.VPetGraphTypeStack.removeLast()
//        updateAction()
//    }
//}
