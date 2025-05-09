import Cocoa

class VPetTouchHandler {
    let VPET: VPet!
    
    init(_ VPET: VPet) {
        self.VPET = VPET
    }
    
    var currentActionTitle: String? = nil
    
    func playTouchHead(interrupt: Bool = true) {
        VPET.autoActionHendler.instantlyquit()
        
        if currentActionTitle != nil {
            if currentActionTitle != "摸头" {
                endCurrentAction()
            }
        }
        
        // 使用 "touch_head/" 作为搜索关键字
        let searchkey = "touch_head/"
        
        // 生成包含开始和循环动画的播放列表
        let pl = VPET.generatePlayListAB(graphtype: .Touch_Head, modetype: VPET.VPetStatus, keywordinfilename: searchkey)
        
        if pl.isEmpty {
            print("playTouchHead: 播放列表为空，可能当前心情没有当前动作。")
            return
        }
        
        // 找到循环B帧
        let loopBFrame = pl.first { info in
            info.filename.contains("循环B") || info.filename.contains("B_Loop")
        }
        
        if interrupt {
            VPET.animeplayer.interruptAndSetPlayList(pl)
        } else {
            VPET.animeplayer.setPlayList(pl)
        }
        
        // 设置为单次循环模式
        VPET.animeplayer.setPlayMode(.SingleLoop)
        
        // 如果找到了循环B帧，设置一个定时器来检查当前播放的帧
        if let loopBFrame = loopBFrame {
            Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                // 检查当前播放的是否是循环B帧
                if let currentFrame = self.VPET.animeplayer.playList.first,
                   currentFrame.filename == loopBFrame.filename {
                    // 更新播放列表只包含循环B帧
                    self.VPET.animeplayer.playList = [loopBFrame]
                    self.VPET.animeplayer.playIndex = 0
                    self.VPET.animeplayer.frameCount = 0
                    timer.invalidate()
                }
            }
        }
        
        VPET.animeplayer.removeCurrentAnimeAfterFinish = true
        
        // 将摸头动作添加到状态栈
        VPET.VPetGraphTypeStack.append(.Touch_Head)
        self.currentActionTitle = "摸头"
    }
    
    func endCurrentAction() {
        guard currentActionTitle != nil else { return }
        
        VPET.autoActionHendler.instantlyquit()
        
        // 使用 "touch_head/" 作为搜索关键字
        let searchkey = "touch_head/"
        
        // 生成结束动画的播放列表
        let pl = VPET.generatePlayListC(graphtype: .Touch_Head, modetype: VPET.VPetStatus, keywordinfilename: searchkey)
        
        VPET.animeplayer.interruptAndSetPlayList(pl)
        VPET.animeplayer.removeCurrentAnimeAfterFinish = true
        
        VPET.VPetGraphTypeStack.removeLast()
        self.currentActionTitle = nil
        
        VPET.updateAnimation()
    }
} 