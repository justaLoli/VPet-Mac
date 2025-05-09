//
//  AnimePlayer.swift
//  new2
//
//  Created by Just aLoli on 2023/8/30.
//

import Cocoa

class AnimeInfoList{
    var playlist = [GraphInfo]()
    init(_ playlist: [GraphInfo] = [GraphInfo]()) {
        self.playlist = playlist
    }
    func find(animatype:GraphInfo.AnimatType? = nil,
              graphtype:GraphInfo.GraphType? = nil,
              modetype:GraphInfo.ModeType? = nil,
              keywordinfilename:String? = nil) -> [GraphInfo]{
        var result = [GraphInfo]()
        for i in playlist{
            if ((keywordinfilename) != nil) && !(i.filename.contains(keywordinfilename!)){
                continue
            }
            if ((modetype) != nil) && (i.modetype != modetype){
                continue
            }
            if ((graphtype) != nil) && (i.graphtype != graphtype){
                continue
            }
            if ((animatype) != nil) && (i.animatype != animatype){
                continue
            }
            result.append(i)
        }
        return result
    }
    func toStringList() -> [String]{
        var res = [String]()
        for i in playlist{
            res.append(i.generateName())
        }
        return res
    }
}

class AnimePlayer{
    var ImageView:NSImageView!
    
    // 添加 VPET 属性
    weak var VPET: VPet?
    
    let allAnimes:[GraphInfo:[String]]!
    let animeInfoList:AnimeInfoList!
    
    
    var playList = [GraphInfo]()
    
    var playIndex = 0
    
    var frameCount = 0;
    
    enum PlayMode {
        case Line
        case SingleLoop
        case Shuffle
    }
    var playMode = PlayMode.Line
    
    var loopLastAnime = true
    
    var removeCurrentAnimeAfterFinish = false
    
    // 添加变量记录原始播放模式
    var originalPlayMode: PlayMode?
    
    // 添加变量记录动画播放次数
    var animationPlayCount = 1
    var currentPlayCount = 0
    
    var timer:Timer?
    
    // 计时器相关属性
    var studyTimer: Timer?
    var studySecondsElapsed: Int = 0
    
    // 计时器数字Label
    var timerLabel: NSTextField = {
        let label = NSTextField(labelWithString: "00:00:00")
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .center
        label.isHidden = true
        label.backgroundColor = .clear
        return label
    }()
    var workStartTime: Date?
    var workTimer: Timer?
    
    // 学习计时器面板UI
    class StudyPanelView: NSView {
        let titleLabel = NSTextField(labelWithString: "当前正在学习")
        let timerLabel = NSTextField(labelWithString: "00:00:00")
        let stopButton = NSButton(title: "停止学习", target: nil, action: nil)
        var stopAction: (() -> Void)?
        
        override init(frame: NSRect) {
            super.init(frame: frame)
            wantsLayer = true
            layer?.backgroundColor = NSColor(white: 0, alpha: 0.7).cgColor
            layer?.cornerRadius = 16
            // 标题
            titleLabel.font = NSFont.boldSystemFont(ofSize: 20)
            titleLabel.textColor = .white
            titleLabel.alignment = .center
            // 计时器
            timerLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 36, weight: .bold)
            timerLabel.textColor = .white
            timerLabel.alignment = .center
            // 按钮
            stopButton.font = NSFont.boldSystemFont(ofSize: 18)
            stopButton.bezelStyle = .rounded
            stopButton.contentTintColor = .white
            stopButton.wantsLayer = true
            stopButton.layer?.backgroundColor = NSColor(white: 1, alpha: 0.15).cgColor
            stopButton.layer?.cornerRadius = 8
            stopButton.action = #selector(stopButtonPressed)
            stopButton.target = self
            // 布局
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            timerLabel.translatesAutoresizingMaskIntoConstraints = false
            stopButton.translatesAutoresizingMaskIntoConstraints = false
            addSubview(titleLabel)
            addSubview(timerLabel)
            addSubview(stopButton)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
                titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                timerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                stopButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 18),
                stopButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                stopButton.widthAnchor.constraint(equalToConstant: 120),
                stopButton.heightAnchor.constraint(equalToConstant: 36),
                stopButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
            ])
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        @objc func stopButtonPressed() { stopAction?() }
        func setTime(_ seconds: Int) {
            let h = seconds / 3600, m = (seconds % 3600) / 60, s = seconds % 60
            timerLabel.stringValue = String(format: "%02d:%02d:%02d", h, m, s)
        }
    }
    var studyPanel: StudyPanelView?
    var studyTimerSeconds: Int = 0
    var studyPanelTimer: Timer?
    
    // 摸头动画循环计数
    var touchHeadLoopCount = 0
    let touchHeadLoopTarget = 3
    
    // AC帧专属慢速因子
    let acFrameSlowFactor = 1// 可根据需要调整倍数
    
    init(_ ImageView: NSImageView?, _ VPET: VPet? = nil) {
        self.ImageView = ImageView
        self.VPET = VPET
        //文件读取所有动画
//
//        guard let assetsURL = Bundle.main.resourceURL?.appendingPathComponent("0000_core/pet/vup") else{
//            print("strange... cant get the assets file.")
//            return;
//        }
        
        // 从内置资源文件中读取动画
        let assetsURL = Bundle.main.resourceURL?.appendingPathComponent("0000_core/pet/vup");
        print(assetsURL!.path);

        
        self.allAnimes = FileSniffer(assetsURL!.path).sniff()
        animeInfoList = AnimeInfoList(Array(allAnimes.keys))
        // 自动启动学习计时器
        startStudyTimer()
        
        // 添加计时器Label到ImageView的superview
        if let superview = ImageView?.superview {
            timerLabel.translatesAutoresizingMaskIntoConstraints = false
            superview.addSubview(timerLabel)
            NSLayoutConstraint.activate([
                timerLabel.centerXAnchor.constraint(equalTo: ImageView!.centerXAnchor),
                timerLabel.topAnchor.constraint(equalTo: ImageView!.topAnchor, constant: 220), // 下移到面板数字区域
                timerLabel.widthAnchor.constraint(equalToConstant: 220),
                timerLabel.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
    }
    
    func setImageView(_ ImageView:NSImageView){self.ImageView = ImageView}
    
    func setPlayMode(_ mode:PlayMode){self.playMode = mode;}
    
    func judgePlayModeFromPlayList(){
        if playList.isEmpty {return;}
        switch playList.first!.animatype{
        case .A_Start:
            self.playMode = .Line;
            self.removeCurrentAnimeAfterFinish = true
            break;
        case .C_End:
            self.playMode = .Line;
            self.removeCurrentAnimeAfterFinish = true
            break;
        case .B_Loop:
            self.playMode = .SingleLoop;
            self.removeCurrentAnimeAfterFinish = false
            break;
        case .Single:
            self.playMode = .Line;
            self.removeCurrentAnimeAfterFinish = false
            break;
        }
    }
    
    func interruptAndSetPlayList(_ pl:[GraphInfo]){
        //设置播放列表并播放，阻断当前动画
        self.stop()
        
        // 确保新的播放列表不为空
        if !pl.isEmpty {
            playList = pl
            judgePlayModeFromPlayList()
            self.play()
        } else {
            print("Warning: Attempted to set empty playlist")
            // 如果播放列表为空，重置所有状态
            stopAndReset()
        }
    }
    func setPlayList(_ pl:[GraphInfo]){
        if(playList.isEmpty){return interruptAndSetPlayList(pl)}
        
        //设置播放列表并播放，当前动画结束后再播放新的动画
        self.pause()
        
        let currentPlayInfo = playList[playIndex]
        
        // 确保新的播放列表不为空
        if !pl.isEmpty {
            playList = [currentPlayInfo] + pl
            playIndex = 0
            
            judgePlayModeFromPlayList()
            
            removeCurrentAnimeAfterFinish = true
            self.play()
        } else {
            print("Warning: Attempted to set empty playlist")
        }
    }
    
    func stopAndReset(){
        stop()
        ImageView.image = nil
        playList.removeAll()
        playMode = .Line
    }
    func stop(){
        //关定时器
        timer?.invalidate()
        timer = nil
        //把播放进度设为0
        frameCount = 0
        singleFrameTimeCount = 0;
        currentFrameTimeLength = 0;
        playIndex = 0
        
    }
    func pause(){
        timer?.invalidate()
        timer = nil
        //并不改变播放进度，因此接下来可以接着放
    }
    func play(){
        //创建多个计时器是不好的
        if (timer != nil){return}
        //创建计时器
        timer = Timer(timeInterval: 0.125, target: self, selector:#selector(playerFrameHandler), userInfo: nil, repeats: true )
        RunLoop.main.add(timer!,forMode: .common)
    }
    func next(){
        pause()
        playIndex+=1
        if(playIndex >= playList.count){stopAndReset();return;}
        play()
    }
    
    var singleFrameTimeCount = 0
    var currentFrameTimeLength:Int? = nil;
    func getFrameTimeFromFileName(_ inputString:String) -> Int{
        // /Users/justaloli/Downloads/0000_core/pet/vup/StartUP/Happy_1/_000_125.png
        //chatGPT 给的代码，somehow works
        let regex = try! NSRegularExpression(pattern: "\\d+(?!.*\\d)", options: [])
        if let match = regex.firstMatch(in: inputString, options: [], range: NSRange(location: 0, length: inputString.utf16.count)) {
            if let range = Range(match.range, in: inputString) {
                let matchedString = inputString[range]
                if let number = Int(matchedString) {
//                    print("提取的数字是：\(number)")
                    return number;
                }
            }
        }
        return 125
    }
    
    @objc private func playerFrameHandler(_ timer: Timer?) -> Void {
        // 防御性判断，防止数组越界
        guard !playList.isEmpty && playIndex >= 0 && playIndex < playList.count else {
            stopAndReset()
            return
        }
        
        // 检查是否为摸头动画，若是则初始化计数
        let isTouchHead = !playList.isEmpty && (playList[playIndex].graphtype == .Touch_Head)
        if isTouchHead && frameCount == 0 && singleFrameTimeCount == 0 {
            if touchHeadLoopCount == 0 {
                touchHeadLoopCount = 0 // 初始化
            }
        }
        
        if(frameCount == 0 && singleFrameTimeCount == 0){
            for i in playList{
                print("Current playlist: \(i.generateName())")
            }
            print("Current playIndex: \(playIndex)")
            print("")
            
            // 设置动画播放次数
            let currentPlayAnimeInfo = playList[playIndex]
            if currentPlayAnimeInfo.graphtype == .Touch_Head {
                if currentPlayAnimeInfo.animatype == .A_Start || currentPlayAnimeInfo.animatype == .C_End {
                    animationPlayCount = 2  // A和C帧播放两次
                    currentPlayCount = 0
                } else if currentPlayAnimeInfo.animatype == .B_Loop {
                    animationPlayCount = 1  // B帧只播放一次
                    currentPlayCount = 0
                }
            }
        }
        
        //确保播放列表非空且索引有效
        guard !playList.isEmpty && playIndex >= 0 && playIndex < playList.count else {
            print("Warning: Invalid playlist or playIndex")
            stopAndReset()
            return
        }
        
        let currentPlayAnimeInfo = playList[playIndex]
        
        //确保动画帧存在
        guard let animeFrames = allAnimes[currentPlayAnimeInfo],
              !animeFrames.isEmpty else {
            print("Warning: No animation frames found")
            stopAndReset()
            return
        }
        
        //设置图片
        if let image = NSImage(byReferencingFile: animeFrames[frameCount]) {
            ImageView.image = image
        } else {
            print("Warning: Failed to load image frame")
        }
        
        //帧计数
        singleFrameTimeCount += 1
        if(currentFrameTimeLength == nil){
            currentFrameTimeLength = getFrameTimeFromFileName(animeFrames[frameCount])
        }
        
        // 对摸头动画的循环B帧和AC帧特殊处理
        let frameTime: Int
        if currentPlayAnimeInfo.graphtype == .Touch_Head {
            if currentPlayAnimeInfo.animatype == .B_Loop {
                // 摸头循环B帧保持正常速度
                frameTime = currentFrameTimeLength!
            } else if currentPlayAnimeInfo.animatype == .A_Start || currentPlayAnimeInfo.animatype == .C_End {
                // AC帧变慢
                frameTime = currentFrameTimeLength! * acFrameSlowFactor
            } else {
                frameTime = currentFrameTimeLength!
            }
        } else {
            // 其他动画保持原样
            frameTime = currentFrameTimeLength!
        }
        
        if(singleFrameTimeCount * 125 >= frameTime){
            singleFrameTimeCount = 0
            frameCount += 1
            currentFrameTimeLength = nil
            // 如果是摸头动画且到达最后一帧，计数+1
            if isTouchHead && frameCount >= animeFrames.count {
                touchHeadLoopCount += 1
            }
        }
        
        //播放结束的处理
        if frameCount >= animeFrames.count {
            // 如果是摸头动画且循环次数达到目标，彻底停止并回到default
            if isTouchHead && touchHeadLoopCount >= touchHeadLoopTarget {
                self.timer?.invalidate()
                self.timer = nil
                frameCount = 0
                singleFrameTimeCount = 0
                currentFrameTimeLength = nil
                playList.removeAll()
                playIndex = 0
                playMode = .Line
                removeCurrentAnimeAfterFinish = false
                touchHeadLoopCount = 0
                // 从栈中移除 Touch_Head
                if VPET?.VPetGraphTypeStack.last == .Touch_Head {
                    VPET?.VPetGraphTypeStack.removeLast()
                }
                print("[DEBUG] 循环三次后，准备回到default动画")
                VPET?.updateAnimation()
                return
            }
            // 如果是摸头动画的B_Loop帧，播放一次后也回到default
            if isTouchHead && currentPlayAnimeInfo.animatype == .B_Loop && frameCount >= animeFrames.count {
                self.timer?.invalidate()
                self.timer = nil
                frameCount = 0
                singleFrameTimeCount = 0
                currentFrameTimeLength = nil
                playList.removeAll()
                playIndex = 0
                playMode = .Line
                removeCurrentAnimeAfterFinish = false
                touchHeadLoopCount = 0
                if VPET?.VPetGraphTypeStack.last == .Touch_Head {
                    VPET?.VPetGraphTypeStack.removeLast()
                }
                print("[DEBUG] B_Loop帧播放一次后，准备回到default动画")
                VPET?.updateAnimation()
                return
            }
            
            frameCount = 0
            currentPlayCount += 1
            
            // 检查是否需要继续播放
            if currentPlayCount < animationPlayCount {
                return  // 继续播放当前动画
            }
            
            // 重置播放计数
            currentPlayCount = 0
            animationPlayCount = 1
            
            // 如果是摸头动画的A或C帧，播放完两次后更新动画
            if currentPlayAnimeInfo.graphtype == .Touch_Head && 
               (currentPlayAnimeInfo.animatype == .A_Start || currentPlayAnimeInfo.animatype == .C_End) {
                if playIndex < playList.count {
                    // 停止定时器
                    self.timer?.invalidate()
                    self.timer = nil
                    // 重置所有播放状态
                    frameCount = 0
                    singleFrameTimeCount = 0
                    currentFrameTimeLength = nil
                    // 从播放列表中移除当前动画
                    playList.remove(at: playIndex)
                    playIndex = 0
                    // 重置播放模式
                    playMode = .Line
                    removeCurrentAnimeAfterFinish = true
                    // 从栈中移除 Touch_Head
                    if VPET?.VPetGraphTypeStack.last == .Touch_Head {
                        VPET?.VPetGraphTypeStack.removeLast()
                    }
                    // 更新动画状态
                    VPET?.updateAnimation()
                }
                return
            }
            
            //removeCurrent
            if (removeCurrentAnimeAfterFinish){
                removeCurrentAnimeAfterFinish = false
                if playIndex < playList.count {
                    playList.remove(at: playIndex)
                }
                playIndex = 0
                return
            }
            
            // A or C (非摸头动画)
            if(currentPlayAnimeInfo.animatype == .A_Start || currentPlayAnimeInfo.animatype == .C_End){
                if playIndex < playList.count {
                    playList.remove(at: playIndex)
                }
                playIndex = 0
                return
            }
            
            //LoopLastAnime处理
            if (loopLastAnime && playList.count == 1){
                //不更改playIndex和playList
                return
            }
            
            //一般情况
            switch playMode{
            case .Line: 
                playIndex += 1
                if playIndex >= playList.count {
                    stopAndReset()
                }
                return
            case .SingleLoop: return
            case .Shuffle: 
                if !playList.isEmpty {
                    playIndex = Int(arc4random_uniform(UInt32(playList.count)))
                }
                return
            }
        }
    }
    
    func startStudyTimer() {
        studyTimer?.invalidate()
        studySecondsElapsed = 0
        // 使用main线程RunLoop的.common模式注册Timer
        studyTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateStudyTimer), userInfo: nil, repeats: true)
        if let timer = studyTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
        print("学习计时器已启动")
    }
    
    func stopStudyTimer() {
        studyTimer?.invalidate()
        studyTimer = nil
    }
    
    @objc func updateStudyTimer() {
        studySecondsElapsed += 1
        let hours = studySecondsElapsed / 3600
        let minutes = (studySecondsElapsed % 3600) / 60
        let seconds = studySecondsElapsed % 60
        print(String(format: "学习计时：%02d:%02d:%02d", hours, minutes, seconds))
    }
    
    // 启动计时器
    func startWorkTimer() {
        workStartTime = Date()
        timerLabel.isHidden = false
        updateWorkTimerLabel()
        workTimer?.invalidate()
        workTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateWorkTimerLabel()
        }
    }
    // 停止计时器
    func stopWorkTimer() {
        workTimer?.invalidate()
        workTimer = nil
        timerLabel.isHidden = true
        timerLabel.stringValue = "00:00:00"
    }
    // 更新时间显示
    func updateWorkTimerLabel() {
        guard let start = workStartTime else { timerLabel.stringValue = "00:00:00"; return }
        let interval = Int(Date().timeIntervalSince(start))
        let hours = interval / 3600
        let minutes = (interval % 3600) / 60
        let seconds = interval % 60
        timerLabel.stringValue = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func showStudyPanel() {
        guard let superview = ImageView?.superview else { return }
        if studyPanel == nil {
            let panel = StudyPanelView(frame: NSRect(x: 0, y: 0, width: 260, height: 180))
            panel.stopAction = { [weak self] in self?.hideStudyPanel() }
            studyPanel = panel
        }
        guard let panel = studyPanel else { return }
        if panel.superview == nil { superview.addSubview(panel) }
        panel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            panel.centerXAnchor.constraint(equalTo: ImageView.centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: ImageView.centerYAnchor, constant: 60),
            panel.widthAnchor.constraint(equalToConstant: 260),
            panel.heightAnchor.constraint(equalToConstant: 180)
        ])
        panel.setTime(0)
        panel.isHidden = false
        studyTimerSeconds = 0
        studyPanelTimer?.invalidate()
        studyPanelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.studyTimerSeconds += 1
            self.studyPanel?.setTime(self.studyTimerSeconds)
        }
    }
    func hideStudyPanel() {
        studyPanelTimer?.invalidate()
        studyPanel?.isHidden = true
    }
}
