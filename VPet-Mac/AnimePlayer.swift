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
    
    
    
    var timer:Timer?
    
    
    
    
    
    init(_ ImageView: NSImageView?) {
        self.ImageView = ImageView
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
        playList = pl;
        judgePlayModeFromPlayList()
        self.play()
    }
    func setPlayList(_ pl:[GraphInfo]){
        if(playList.isEmpty){return interruptAndSetPlayList(pl)}
        
        //设置播放列表并播放，当前动画结束后再播放新的动画
        self.pause()
        
        
        let currentPlayInfo = playList[playIndex]
        
        playList = [currentPlayInfo] + pl
        playIndex = 0
        
        judgePlayModeFromPlayList()
        
        removeCurrentAnimeAfterFinish = true
        self.play()
        
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
        if(frameCount == 0){
            for i in playList{
                print(i.generateName())
            }
            print(playIndex)
            print("")
        }
        //确保播放列表非空
//        guard let currentPlayAnimeInfo = playList.first else{stopAndReset();return}
        if !(playIndex < playList.count && playIndex >= 0){stopAndReset();return;}
        let currentPlayAnimeInfo = playList[playIndex]
        
//        let currentPlayName = currentPlayAnime.0
//        let isloop = currentPlayAnimeInfo.animatype == GraphInfo.AnimatType.B_Loop
        
        
        //名称合法
        guard let animeFrames = allAnimes[currentPlayAnimeInfo] else{return}
        
        //设置图片
        ImageView.image = NSImage(byReferencingFile: animeFrames[frameCount])
        
        
        //帧计数
        singleFrameTimeCount += 1
        if(currentFrameTimeLength == nil){currentFrameTimeLength = getFrameTimeFromFileName(animeFrames[frameCount])}
        if(singleFrameTimeCount * 125 >= currentFrameTimeLength!){
            singleFrameTimeCount = 0;
            frameCount += 1
            currentFrameTimeLength = nil
        }
//        let frameLength = animeFrames[frameCount].split(separator: "_")
//        let frameLength = animeFrames[frameCount].split(separator: ".")
        
        ;
        
//        //帧计数
//        frameCount+=1
        
        
        //播放结束的处理
        if frameCount == animeFrames.count{
            frameCount = 0;
            
            
            
            //removeCurrent
            if (removeCurrentAnimeAfterFinish){
                removeCurrentAnimeAfterFinish = false;
                playList.remove(at: playIndex);
                playIndex = 0;//设置为第一个
                return;
            }
            
            // A or C
            if(currentPlayAnimeInfo.animatype == .A_Start || currentPlayAnimeInfo.animatype == .C_End){
                playList.remove(at: playIndex)
                playIndex = 0;
                return;
            }
            
            //LoopLastAnime处理
            if (loopLastAnime && playList.count == 1){
                //不更改playIndex和playList
                return;
            }
            
            //一般情况
            switch playMode{
            case .Line: playIndex+=1;return;
            case .SingleLoop: return;
            case .Shuffle: playIndex = Int(arc4random_uniform(UInt32(playList.count)));return;
            }
            
        }
    }
}
