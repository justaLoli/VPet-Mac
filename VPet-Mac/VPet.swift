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
    
    private var isInHeadArea = false
    private var lastHeadAreaState = false
    
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
        print("Current stack:", VPetGraphTypeStack)
        
        // 如果栈为空，添加默认状态
        if VPetGraphTypeStack.isEmpty {
            print("Stack is empty, adding default state")
            VPetGraphTypeStack.append(.Default)
        }
        
        switch VPetGraphTypeStack.last! {
        case .Default:
            print("Updating to default animation")
            updateDefaultAnime()
            break
        case .Work:
            print("Updating to work animation")
            updateWorkAnime()
            break
        case .Sleep:
            print("Updating to sleep animation")
            updateSleepAnime()
            break
        case .Touch_Head:
            print("Touch head animation finished, returning to default")
            VPetGraphTypeStack.removeLast()
            VPetGraphTypeStack.append(.Default)
            updateDefaultAnime()
            break
        default:
            print("Unknown state, returning to default")
            VPetGraphTypeStack.removeAll()
            VPetGraphTypeStack.append(.Default)
            updateDefaultAnime()
            break
        }
    }
    
    func updateDefaultAnime(){
        print("[DEBUG] Loading default animations")
        let list2 = animeplayer.animeInfoList.find(graphtype: .Default, modetype: VPetStatus).shuffled()
        if !list2.isEmpty {
            print("[DEBUG] Found \(list2.count) default animations")
            animeplayer.setPlayList(list2)
            animeplayer.setPlayMode(.Shuffle)
            animeplayer.loopLastAnime = true
        } else {
            print("[DEBUG][Warning] No default animations found, setting placeholder image")
            animeplayer.ImageView.image = NSImage(size: NSSize(width: 300, height: 300))
        }
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
        
        // 如果有点击位置,判断是否在摸头或摸身体区域
        if let point = p {
            if isInTouchHeadArea(point) {
                handleTouchHead()
            } else if isInTouchBodyArea(point) {
                handleTouchBody()
            }
        }
    }
    
    // 判断点击位置是否在摸头区域内
    func isInTouchHeadArea(_ point: NSPoint) -> Bool {
        print("VPet: Checking head area for point: \(point)")
        
        // 获取视图大小
        let viewSize = displayView.view.frame.size
        print("VPet: View size: \(viewSize)")
        
        // 将窗口坐标转换为视图坐标
        let viewPoint = displayView.view.convert(point, from: nil)
        print("VPet: Converted view point: \(viewPoint)")
        
        // 计算相对坐标（基于300x300的基准大小）
        let scale = viewSize.width / 300.0  // 使用视图宽度计算缩放比例
        print("VPet: Scale factor: \(scale)")
        
        // 头部区域在原图中的位置（基于300x300）
        let baseHeadX: CGFloat =   100  // 头部区域左边界
        let baseHeadY: CGFloat = 30  // 头部区域下边界（更靠近头顶）
        let baseHeadWidth: CGFloat = 150  // 头部区域宽度
        let baseHeadHeight: CGFloat = 20  // 头部区域高度（更小更集中）
        
        // 根据当前视图大小计算实际头部区域
        let headX = baseHeadX * scale
        let headWidth = baseHeadWidth * scale
        let headHeight = baseHeadHeight * scale
        
        // 在 macOS 中，坐标系统是从左下角开始的，需要转换 Y 坐标
        let headY = viewSize.height - (baseHeadY * scale) - headHeight
        
        print("VPet: Calculated head area coordinates:")
        print("  - X: \(headX)")
        print("  - Y: \(headY)")
        print("  - Width: \(headWidth)")
        print("  - Height: \(headHeight)")
        
        // 创建头部区域的矩形
        let headArea = NSRect(x: headX, 
                            y: headY,
                            width: headWidth, 
                            height: headHeight)
        
        print("VPet: Head area: \(headArea)")
        
        // 检查点是否在头部区域内
        let isInArea = headArea.contains(viewPoint)
        print("VPet: Point \(viewPoint) in head area \(headArea): \(isInArea)")
        
        return isInArea
    }
    
    // 判断点击位置是否在身体区域内
    func isInTouchBodyArea(_ point: NSPoint) -> Bool {
        print("VPet: Checking body area for point: \(point)")
        
        // 获取视图大小
        let viewSize = displayView.view.frame.size
        print("VPet: View size: \(viewSize)")
        
        // 将窗口坐标转换为视图坐标
        let viewPoint = displayView.view.convert(point, from: nil)
        print("VPet: Converted view point: \(viewPoint)")
        
        // 计算相对坐标（基于300x300的基准大小）
        let scale = viewSize.width / 300.0  // 使用视图宽度计算缩放比例
        print("VPet: Scale factor: \(scale)")
        
        // 身体区域在原图中的位置（基于300x300）
        let baseBodyX: CGFloat = 100  // 身体区域左边界
        let baseBodyY: CGFloat = 200  // 身体区域下边界
        let baseBodyWidth: CGFloat = 400  // 身体区域宽度
        let baseBodyHeight: CGFloat = 10  // 身体区域高度
        
        // 根据当前视图大小计算实际身体区域
        let bodyX = baseBodyX * scale
        let bodyWidth = baseBodyWidth * scale
        let bodyHeight = baseBodyHeight * scale
        
        // 在 macOS 中，坐标系统是从左下角开始的，需要转换 Y 坐标
        let bodyY = viewSize.height - (baseBodyY * scale) - bodyHeight
        
        print("VPet: Calculated body area coordinates:")
        print("  - X: \(bodyX)")
        print("  - Y: \(bodyY)")
        print("  - Width: \(bodyWidth)")
        print("  - Height: \(bodyHeight)")
        
        // 创建身体区域的矩形
        let bodyArea = NSRect(x: bodyX, 
                            y: bodyY,
                            width: bodyWidth, 
                            height: bodyHeight)
        
        print("VPet: Body area: \(bodyArea)")
        
        // 检查点是否在身体区域内
        let isInArea = bodyArea.contains(viewPoint)
        print("VPet: Point \(viewPoint) in body area \(bodyArea): \(isInArea)")
        
        return isInArea
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
    
    func handleTouchHead() {
        print("VPet: handleTouchHead called")
        // 只有在默认状态下才响应摸头
        if VPetGraphTypeStack.last != .Default {
            print("VPet: Not in default state, ignoring touch head")
            return
        }
        
        // 获取所有摸头动画
        let touchHeadAnimes = animeplayer.animeInfoList.find(graphtype: .Touch_Head, modetype: VPetStatus)
        print("VPet: Found \(touchHeadAnimes.count) touch head animations")
        
        if let randomAnime = touchHeadAnimes.randomElement() {
            print("VPet: Playing random touch head animation")
            // 将摸头动作添加到栈中
            VPetGraphTypeStack.append(.Touch_Head)
            
            // 播放动画
            animeplayer.interruptAndSetPlayList([randomAnime])
            animeplayer.removeCurrentAnimeAfterFinish = true
            animeplayer.loopLastAnime = false  // 确保不会循环播放
        } else {
            print("VPet: No touch head animations found")
        }
    }
    
    func handleTouchBody() {
        print("VPet: handleTouchBody called")
        // 只有在默认状态下才响应摸身体
        if VPetGraphTypeStack.last != .Default {
            print("VPet: Not in default state, ignoring touch body")
            return
        }
        
        // 获取所有摸身体动画
        let touchBodyAnimes = animeplayer.animeInfoList.find(graphtype: .Touch_Body, modetype: VPetStatus)
        print("VPet: Found \(touchBodyAnimes.count) touch body animations")
        
        if let randomAnime = touchBodyAnimes.randomElement() {
            print("VPet: Playing random touch body animation")
            // 将摸身体动作添加到栈中
            VPetGraphTypeStack.append(.Touch_Body)
            
            // 播放动画
            animeplayer.interruptAndSetPlayList([randomAnime])
            animeplayer.removeCurrentAnimeAfterFinish = true
            animeplayer.loopLastAnime = false  // 确保不会循环播放
            
            // 设置动画完成后的回调
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                // 确保动画播放完成后更新状态
                if self.VPetGraphTypeStack.last == .Touch_Body {
                    self.VPetGraphTypeStack.removeLast()
                    self.updateAnimation()
                }
            }
        } else {
            print("VPet: No touch body animations found")
        }
    }
}
