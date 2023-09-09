//
//  VPet-autoaction-move.swift
//  VPet-Mac
//
//  Created by Just aLoli on 2023/9/6.
//

import Cocoa


struct Vector:CustomStringConvertible{
    var x: CGFloat;
    var y: CGFloat;
    // 从 CGPoint 转换到 Vector
    init(point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
    init(x:CGFloat,y:CGFloat) {
        self.x = x;self.y = y;
    }
    // CustomStringConvertible 协议的要求，定义如何将 Vector 转换为字符串
    var description: String {
        return "Vector(x: \(x), y: \(y))"
    }
}
// 重载 + 运算符
func +(lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
// 重载 * 运算符
func *(lhs: CGFloat, rhs: Vector) -> Vector {
    return Vector(x: lhs * rhs.x, y: lhs * rhs.y)
}


class VPetAutoMoveHandler{
    let VPET:VPet!
    
    var moveStarted = false;
    
    init(_ VPET:VPet) {
        self.VPET = VPET
    }
    
    func getVPetCenterPos() -> Vector{
        // 得到当前宠物中心点坐标（相对屏幕左下角）
        let framesize = VPET.displayWindow.window!.frame.width;
        let middlexy = framesize/2
        
        let frameplace = VPET.displayWindow.window!.frame.origin;
        let middlePos = Vector(x: frameplace.x + middlexy, y: frameplace.y + middlexy)
        return middlePos
    }
    func getVPetCenterPosInWindow() -> Vector{
        // 得到当前宠物中心点坐标（相对窗口左下角）
        let framesize = VPET.displayWindow.window!.frame.width;
        let middlexy = framesize/2
        return Vector(x: middlexy, y: middlexy)
    }
    
    func getDisplayBorderInformation() -> Vector{
        // 得到屏幕大小
        let screenFrame = NSScreen.main!.frame //出事直接崩溃就好了
        return Vector(x: screenFrame.width, y: screenFrame.height)
    }
    
    // 肮脏的程序结构
    func leftClimbCenterX() -> CGFloat{
        let controllen:CGFloat = 145 //肮脏的硬编码
        let actuallen:CGFloat = controllen * 2;
        let imageres:CGFloat = 1000 //肮脏的硬编码
        let actualx:CGFloat = actuallen/imageres * VPET.displayWindow.window!.frame.width;
        let middlexy:CGFloat = VPET.displayWindow.window!.frame.width/2
        let pointx = middlexy - actualx
        return pointx;
    }
    func rightClimbCenterX() -> CGFloat{
        var controllen:CGFloat = 185
        var actuallen:CGFloat = controllen * 2;
        var imageres:CGFloat = 1000
        let actualx:CGFloat = actuallen/imageres * VPET.displayWindow.window!.frame.width;
        let middlexy:CGFloat = VPET.displayWindow.window!.frame.width/2
        let pointx = getDisplayBorderInformation().x - (middlexy - actualx)
        return pointx;
    }
    func upClimbCenterY() -> CGFloat{
        var controllen:CGFloat = 150
        var actuallen:CGFloat = controllen * 2;
        var imageres:CGFloat = 1000
        let actualy:CGFloat = actuallen/imageres * VPET.displayWindow.window!.frame.width;
        let middlexy:CGFloat = VPET.displayWindow.window!.frame.width/2
        let pointx = getDisplayBorderInformation().y - (middlexy - actualy)
        return pointx;
    }
    
    struct dist{
        var toleft:CGFloat;var toright:CGFloat;var toup:CGFloat;var todown:CGFloat;
    }
    func getBorderDistances(_ petpos:Vector?) -> dist{
        //给定点到边框的距离（给定的点可能是未来宠物会在的点，不一定是当前位置。）
        let pos = petpos ?? getVPetCenterPos();
        
        let DisplayRect = getDisplayBorderInformation();
        let toleft = pos.x;
        let todown = pos.y - 100;
        let toup = DisplayRect.y - todown;
        let toright = DisplayRect.x - toleft;
        return dist(toleft: toleft, toright: toright, toup: toup, todown: todown);
    }
    
    enum MoveDirections{
        case WalkLeft
        case WalkRight
        case FallLeft
        case FallRight
        case ClimbLeftUp
        case ClimbLeftDown
        case ClimbRightUp
        case ClimbRightDown
        case MoveTopLeft
        case MoveTopRight
    }
    let directionVector:[MoveDirections:Vector] = [
        .WalkLeft: Vector(x: -1, y: 0),
        .WalkRight: Vector(x: 1, y: 0),
        .FallLeft: Vector(x: -1, y: -1),
        .FallRight: Vector(x: 1, y: -1),
        .ClimbLeftUp: Vector(x: 0, y: 1),
        .ClimbRightUp: Vector(x: 0, y: 1),
        .ClimbLeftDown: Vector(x: 0, y: -1),
        .ClimbRightDown: Vector(x: 0, y: -1),
        .MoveTopLeft: Vector(x: -1, y: 0),
        .MoveTopRight: Vector(x: 1, y: 0),
    ]
    let directionKeyword:[MoveDirections:[String]] = [
        .WalkLeft: ["walk.left","crawl.left","walk.left.faster"],
        .WalkRight: ["walk.right","crawl.right","walk.right.faster"],
        .FallLeft: ["fall.left"],
        .FallRight: ["fall.right"],
        .ClimbLeftUp: ["climb.left"],
        .ClimbRightUp: ["climb.right"],
        .ClimbLeftDown: ["climb.left"],
        .ClimbRightDown: ["climb.right"],
        .MoveTopLeft: ["climb.top.left"],
        .MoveTopRight: ["climb.top.right"],
    ]
    func getAvailableDirectionList(_ petpos: Vector?) -> [MoveDirections:CGFloat]{
        //返回值：方向：允许的最大长度
        //像爬这样的，就只有某些时候（贴近边框）能触发
        let borderDist = getBorderDistances(petpos);
        //给边框增加一定宽度，离边框太近就不要再往里了；
        let mindist = getDisplayBorderInformation().x / 10 //随便算的
        
        var res = [MoveDirections:CGFloat]()
        if(borderDist.toleft > mindist && borderDist.toup > mindist){
            res[.WalkLeft] = borderDist.toleft
        }
        if(borderDist.toright > mindist && borderDist.toup > mindist){
            res[.WalkRight] = borderDist.toright
        }
        if(borderDist.toleft > mindist && borderDist.todown > getDisplayBorderInformation().y/4){
            res[.FallLeft] = min(borderDist.toleft, borderDist.todown)
        }
        if(borderDist.toright > mindist && borderDist.todown > getDisplayBorderInformation().y/4){
            res[.FallRight] = min(borderDist.toright,borderDist.todown);
        }
        if(borderDist.toleft < mindist){
            if(borderDist.toup > mindist){
                res[.ClimbLeftUp] = borderDist.toup}
            if(borderDist.todown > mindist){
                res[.ClimbLeftDown] = borderDist.todown
            }
        }
        if(borderDist.toright < mindist){
            if(borderDist.toup > mindist){
                res[.ClimbRightUp] = borderDist.toup
            }
            if(borderDist.todown > mindist){
                res[.ClimbRightDown] = borderDist.todown
            }
        }
        if(borderDist.toup < mindist){
            if(borderDist.toleft > mindist){
                res[.MoveTopLeft] = borderDist.toleft
            }
            if(borderDist.toright > mindist){
                res[.MoveTopRight] = borderDist.toright
            }
        }
        return res;
    }
    
    
    func randomInRange(_ from: CGFloat, _ to: CGFloat) -> CGFloat {
        if(to < from){return 0;}
        // 生成一个从from到to之间的随机数（包括from和to）
        let random = arc4random_uniform(UInt32(to - from + 1)) + UInt32(from)
        return CGFloat(random)
    }
    
    func startAutoMove(){
        if(moveStarted){return;}
        moveStarted = true;
        self.VPET.autoActionHendler.autoActionStarted = true;
        generateMove();
    }
    func stopWindowMove(){
        moveStarted = false;
        self.VPET.autoActionHendler.autoActionStarted = false;
        //终止当前可能存在的动画的方法
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.0
            context.timingFunction = CAMediaTimingFunction.init(name: .linear)
            let window = self.VPET.displayWindow.window!
            let rect = window.frame
            window.animator().setFrame(rect, display: true, animate: true)
        } )
    }
    func stopAutoMove(){
        //被用户交互阻止。
        stopWindowMove();
        moveStarted = false;
        let pl = self.VPET.generatePlayListC(graphtype: .Move, modetype: self.VPET.VPetStatus, title: self.playingKeyword!)
        self.VPET.animeplayer.interruptAndSetPlayList(pl);
        print(self.VPET.VPetGraphTypeStack)
        if(self.VPET.VPetGraphTypeStack.last != .Move){
            print("automove stopAutoMove: strange... stack top is not .Move")
        }
        self.VPET.VPetGraphTypeStack.removeLast();
        self.VPET.updateAnimation();
    }
    
    func generateMove(){
        if(!moveStarted){return;}
//        return animateWindow();
        let petCenterPos = getVPetCenterPos();
        let availableDirList = getAvailableDirectionList(petCenterPos);
        if(availableDirList.isEmpty){
            print("this really happened..")
        }
        //抽取一个方向
        let chooseDirection = availableDirList.keys.randomElement()!
        
        //抽取一个距离
        let mindist = getDisplayBorderInformation().x / 10 //得多少走点，别在那倒
        let chooseDistance = min(randomInRange(mindist,availableDirList[chooseDirection]! + mindist),availableDirList[chooseDirection]!)
        //对于爬行，把起始点规定在贴边的位置。正常情况起始点就是宠物所在点
        var startPos = petCenterPos;
        if(chooseDirection == .ClimbLeftUp || chooseDirection == .ClimbLeftDown){
            startPos.x = leftClimbCenterX();
        }
        else if(chooseDirection == .ClimbRightUp || chooseDirection == .ClimbRightDown){
            startPos.x = rightClimbCenterX();
        }
        else if(chooseDirection == .MoveTopLeft || chooseDirection == .MoveTopRight){
            startPos.y = upClimbCenterY();
        }
        
        
        //主要数据： （瞬移到）起始点；（过渡到）终止点；需要的时间。
        let endPos = startPos + chooseDistance * directionVector[chooseDirection]!
        let speed:CGFloat = 10.0;
        let framecount = chooseDistance / speed;
        //按照一秒8帧算
        let duration:CGFloat = framecount / 8
        print("direction: \(chooseDirection)")
        print("startpos: \(startPos)")
        print("endpos: \(endPos)")
        print("duration: \(duration)")
        
        animateWindow(startPos: startPos, endPos: endPos, duration: duration,direction: chooseDirection)
    }
    
    var playingKeyword:String? = nil;
    func animateWindow(startPos:Vector,endPos:Vector,duration:CGFloat,direction:MoveDirections) {
        if(!moveStarted){return;}
        //动画播放
        if direction == .WalkLeft{
            switch VPET.VPetStatus{
            case .Happy:playingKeyword = "walk.left.faster";break;
            default:playingKeyword = "walk.left"
            }
        }
        else if direction == .WalkRight{
            switch VPET.VPetStatus{
            case .Happy:playingKeyword = "walk.right.faster";break;
            default:playingKeyword = "walk.right"
            }
        }
        else{
            playingKeyword = directionKeyword[direction]!.randomElement()!
        }
        let pl = VPET.generatePlayListAB(graphtype: .Move, modetype: VPET.VPetStatus, title: playingKeyword!)
        
        VPET.animeplayer.interruptAndSetPlayList(pl);
        VPET.animeplayer.setPlayMode(.Shuffle);
        VPET.animeplayer.removeCurrentAnimeAfterFinish = true;
        VPET.VPetGraphTypeStack.append(.Move)
        
        
        
        //由于低劣的异步，窗口移动等待一段随机时间再触发（这个更多是为了连续多个动画播放的时候，中间要停顿一点时间。）
        _ = Timer.scheduledTimer(withTimeInterval: Double.random(in: 0.5...1.0), repeats: false, block: { _ in
            print("?")
            
            let window = self.VPET.displayWindow.window!
            let originStartPos = startPos + (-1)*self.getVPetCenterPosInWindow();//初始位置
            window.setFrameOrigin(NSPoint(x: originStartPos.x, y: originStartPos.y))
            let originEndPos = endPos + (-1)*self.getVPetCenterPosInWindow();
            let duration: TimeInterval = duration // 移动持续时间（秒）
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction.init(name: .linear)
                let window = self.VPET.displayWindow.window!
                var rect = window.frame;rect.origin = NSPoint(x: originEndPos.x, y: originEndPos.y);
                window.animator().setFrame(rect, display: true, animate: true)
            },completionHandler: {
                if(!self.moveStarted){return;}
                print("回调")//手动停止也会激活回调！不过现在就不需要它响应了
                let pl = self.VPET.generatePlayListC(graphtype: .Move, modetype: self.VPET.VPetStatus, title: self.playingKeyword!)
                self.VPET.animeplayer.interruptAndSetPlayList(pl);
                if(self.VPET.VPetGraphTypeStack.last != .Move){
                    print("move animateWindow: strange.. stack top is not .move")
                }
                self.VPET.VPetGraphTypeStack.removeLast();
                
                //是否接着移动
                //多么优秀的抽签方式
//                let iscontinue = [true,true,true,false,false].randomElement()!
                let iscontinue = true;
                if(iscontinue){
                    self.generateMove()
                }
                else{
                    self.moveStarted = false;
                    self.VPET.autoActionHendler.autoActionStarted = false;
                    self.VPET.updateAnimation()
                }
                
            })
            
        })
        
        
    }
    
    
}
