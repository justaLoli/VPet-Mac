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
        VPET.autoActionHendler.instantlyquit();
        var isinterrupt = interrupt
        if currentActionTitle != nil {
            if(currentActionTitle != title){
                //在已有事件的基础上，开启一个新的事件
                endplayFromCurrentActionTitle()
            }
        }
        guard let k = hardCodedText.actionToKeyword[title] else{return}
        let searchkey = k + "/"
        
        let pl = VPET.generatePlayListAB(modetype: VPET.VPetStatus, keywordinfilename: searchkey);
        
        if(pl.isEmpty){
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
        
        if(newActionGraphType == .Work){
            
            VPET.displayView.workingOverlayTitle.stringValue = "当前正在" + title
            VPET.displayView.workingOverlayStop.title = "停止" + title;
            VPET.displayView.workingOverlayView.isHidden = false;
        }
    }
    func endplayFromCurrentActionTitle(){
        guard currentActionTitle != nil else{return;}
        //立刻丢掉自动动画
        VPET.autoActionHendler.instantlyquit();
        guard let k = hardCodedText.actionToKeyword[self.currentActionTitle!] else{return;}
        let searchkey = k + "/"
        
        let pl = VPET.generatePlayListC(modetype: VPET.VPetStatus,keywordinfilename: searchkey)
        
        VPET.animeplayer.interruptAndSetPlayList(pl)
        VPET.animeplayer.removeCurrentAnimeAfterFinish = true;
        VPET.VPetGraphTypeStack.removeLast();
        self.currentActionTitle = nil;
        VPET.updateAnimation()
        
        VPET.displayView.workingOverlayView.isHidden = true;
        
    }
    
    func replayFromCurrentActionTitle(){
        guard currentActionTitle != nil else{return;}
        guard let k = hardCodedText.actionToKeyword[currentActionTitle!] else{return}
        let searchkey = k + "/"
        
        let pl = VPET.generatePlayListAB(modetype:VPET.VPetStatus,keywordinfilename: searchkey);
        
        VPET.animeplayer.setPlayList(pl)
        VPET.animeplayer.removeCurrentAnimeAfterFinish = true;
        VPET.animeplayer.setPlayMode(.Shuffle)
        
        
        
    }
}

