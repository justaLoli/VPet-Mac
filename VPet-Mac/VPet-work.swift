//
//  VPet-playAction.swift
//  VPet-Mac
//
//  Created by Just aLoli on 2023/9/4.
//

import Cocoa


class VPetWorkHandler{
    let VPET:VPet!
    init(_ VPET:VPet) {
        self.VPET = VPET
    }
    var currentActionTitle:String? = nil
    
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
        var lists = VPET.animeplayer.animeInfoList.find(animatype:.A_Start,modetype: VPET.VPetStatus, keywordinfilename: searchkey)
        ;
        if(!lists.isEmpty){
            pl.append(lists.randomElement()!)
        }
        else{
            let lists = VPET.animeplayer.animeInfoList.find(animatype:.A_Start,modetype: .Normal, keywordinfilename: searchkey)
            ;
            if(!lists.isEmpty){
                pl.append(lists.randomElement()!)
            }
        }
        lists = VPET.animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: VPET.VPetStatus,keywordinfilename: searchkey)
        if(!lists.isEmpty){
            pl += lists;
        }
        else{
            lists = VPET.animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: .Normal,keywordinfilename: searchkey)
            if(!lists.isEmpty){
                pl += lists;
            }
        }
        
        ;
        if(lists.isEmpty){
            print("play: 播放列表为空，可能当前心情没有当前动作。");return;
        }
        if(isinterrupt){
            VPET.animeplayer.interruptAndSetPlayList(pl)
        }
        else{
            VPET.animeplayer.setPlayList(pl)
        }
        VPET.animeplayer.removeCurrentAnimeAfterFinish = true;
        VPET.animeplayer.setPlayMode(.Shuffle)
        
        let newActionGraphType = hardCodedText.actionToGraphType[title] ?? .Work
        VPET.VPetGraphTypeStack.append(newActionGraphType)
        self.currentActionTitle = title;
    }
    func endplayFromCurrentActionTitle(){
        guard currentActionTitle != nil else{return;}
        guard let k = hardCodedText.actionToKeyword[self.currentActionTitle!] else{return;}
        let searchkey = k + "/"
        let lists = VPET.animeplayer.animeInfoList.find(animatype:.C_End,modetype: VPET.VPetStatus,keywordinfilename: searchkey);
        var pl = [GraphInfo]()
        if(!lists.isEmpty){
            pl.append(lists.randomElement()!)
        }
        else{
            let lists = VPET.animeplayer.animeInfoList.find(animatype:.C_End,modetype: .Normal,keywordinfilename: searchkey);
            if(!lists.isEmpty){
                pl.append(lists.randomElement()!)
            }
        }
        VPET.animeplayer.interruptAndSetPlayList(pl)
        VPET.animeplayer.removeCurrentAnimeAfterFinish = true;
        VPET.VPetGraphTypeStack.removeLast();
        self.currentActionTitle = nil;
        VPET.updateAnimation()
    }
    
    func replayFromCurrentActionTitle(){
        guard currentActionTitle != nil else{return;}
        guard let k = hardCodedText.actionToKeyword[currentActionTitle!] else{return}
        let searchkey = k + "/"
        ;
        var pl = [GraphInfo]()
        var lists = VPET.animeplayer.animeInfoList.find(animatype:.A_Start,modetype: VPET.VPetStatus, keywordinfilename: searchkey)
        ;
        if(!lists.isEmpty){
            pl.append(lists.randomElement()!)
        }
        else{
            let lists = VPET.animeplayer.animeInfoList.find(animatype:.A_Start,modetype: .Normal, keywordinfilename: searchkey)
            ;
            if(!lists.isEmpty){
                pl.append(lists.randomElement()!)
            }
        }
        lists = VPET.animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: VPET.VPetStatus,keywordinfilename: searchkey)
        if(!lists.isEmpty){
            pl += lists;
        }
        else{
            lists = VPET.animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: .Normal,keywordinfilename: searchkey)
            if(!lists.isEmpty){
                pl += lists;
            }
        }
        
        ;
        
        VPET.animeplayer.setPlayList(pl)
        VPET.animeplayer.removeCurrentAnimeAfterFinish = true;
        VPET.animeplayer.setPlayMode(.Shuffle)
    }
}



//extension VPet{
//    func play(_ title:String,interrupt:Bool = true){
//        var isinterrupt = interrupt
//        if currentActionTitle != nil {
//            if(currentActionTitle != title){
//                //在已有事件的基础上，开启一个新的事件
//                endplayFromCurrentActionTitle()
//            }
//            //也有可能是重新播放当前事件
//            isinterrupt = false
//        }
//        guard let k = hardCodedText.actionToKeyword[title] else{return}
//        let searchkey = k + "/"
//        ;
//        var pl = [GraphInfo]()
//        var lists = animeplayer.animeInfoList.find(animatype:.A_Start,modetype: VPetStatus, keywordinfilename: searchkey)
//        ;
//        if(!lists.isEmpty){
//            pl.append(lists.randomElement()!)
//        }
//        else{
//            let lists = animeplayer.animeInfoList.find(animatype:.A_Start,modetype: .Normal, keywordinfilename: searchkey)
//            ;
//            if(!lists.isEmpty){
//                pl.append(lists.randomElement()!)
//            }
//        }
//        lists = animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: VPetStatus,keywordinfilename: searchkey)
//        if(!lists.isEmpty){
//            pl += lists;
//        }
//        else{
//            lists = animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: .Normal,keywordinfilename: searchkey)
//            if(!lists.isEmpty){
//                pl += lists;
//            }
//        }
//
//        ;
//        if(lists.isEmpty){
//            print("play: 播放列表为空，可能当前心情没有当前动作。");return;
//        }
//        if(isinterrupt){
//            self.animeplayer.interruptAndSetPlayList(pl)
//        }
//        else{
//            self.animeplayer.setPlayList(pl)
//        }
//        self.animeplayer.removeCurrentAnimeAfterFinish = true;
//        self.animeplayer.setPlayMode(.Shuffle)
//
//        let newActionGraphType = hardCodedText.actionToGraphType[title] ?? .Work
//        self.VPetGraphTypeStack.append(newActionGraphType)
//        self.currentActionTitle = title;
//    }
//    func endplayFromCurrentActionTitle(){
//        guard currentActionTitle != nil else{return;}
//        guard let k = hardCodedText.actionToKeyword[self.currentActionTitle!] else{return;}
//        let searchkey = k + "/"
//        let lists = animeplayer.animeInfoList.find(animatype:.C_End,modetype: VPetStatus,keywordinfilename: searchkey);
//        var pl = [GraphInfo]()
//        if(!lists.isEmpty){
//            pl.append(lists.randomElement()!)
//        }
//        else{
//            let lists = animeplayer.animeInfoList.find(animatype:.C_End,modetype: .Normal,keywordinfilename: searchkey);
//            if(!lists.isEmpty){
//                pl.append(lists.randomElement()!)
//            }
//        }
//        animeplayer.interruptAndSetPlayList(pl)
//        animeplayer.removeCurrentAnimeAfterFinish = true;
//        self.VPetGraphTypeStack.removeLast();
//        self.currentActionTitle = nil;
//        updateAction()
//    }
//
//    func replayFromCurrentActionTitle(){
//        guard currentActionTitle != nil else{return;}
//        guard let k = hardCodedText.actionToKeyword[currentActionTitle!] else{return}
//        let searchkey = k + "/"
//        ;
//        var pl = [GraphInfo]()
//        var lists = animeplayer.animeInfoList.find(animatype:.A_Start,modetype: VPetStatus, keywordinfilename: searchkey)
//        ;
//        if(!lists.isEmpty){
//            pl.append(lists.randomElement()!)
//        }
//        else{
//            let lists = animeplayer.animeInfoList.find(animatype:.A_Start,modetype: .Normal, keywordinfilename: searchkey)
//            ;
//            if(!lists.isEmpty){
//                pl.append(lists.randomElement()!)
//            }
//        }
//        lists = animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: VPetStatus,keywordinfilename: searchkey)
//        if(!lists.isEmpty){
//            pl += lists;
//        }
//        else{
//            lists = animeplayer.animeInfoList.find(animatype:.B_Loop,modetype: .Normal,keywordinfilename: searchkey)
//            if(!lists.isEmpty){
//                pl += lists;
//            }
//        }
//
//        ;
//
//        self.animeplayer.setPlayList(pl)
//        self.animeplayer.removeCurrentAnimeAfterFinish = true;
//        self.animeplayer.setPlayMode(.Shuffle)
//    }
//}
