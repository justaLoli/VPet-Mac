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
        let todown = pos.y;
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
    func getAvailableDirectionList(_ petpos: Vector?) -> [MoveDirections:CGFloat]{
        //返回值：方向：允许的最大长度
        //像爬这样的，就只有某些时候（贴近边框）能触发
        let borderDist = getBorderDistances(petpos);
        //给边框增加一定宽度，离边框太近就不要再往里了；
        let mindist = getDisplayBorderInformation().x / 10 //随便算的
        
        var res = [MoveDirections:CGFloat]()
        if(borderDist.toleft > mindist && borderDist.toup > mindist && borderDist.toright > mindist){
            res[.WalkLeft] = borderDist.toleft
            res[.WalkRight] = borderDist.toright
        }
        
        if(borderDist.toleft > mindist && borderDist.todown > getDisplayBorderInformation().y/3){
            res[.FallLeft] = min(borderDist.toleft, borderDist.todown)
        }
        if(borderDist.toright > mindist && borderDist.todown > getDisplayBorderInformation().y/3){
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
    
    func generateMove(){
        return animateWindow();
        let petCenterPos = getVPetCenterPos();
        let availableDirList = getAvailableDirectionList(petCenterPos);
        //抽取一个方向
        let chooseDirection = availableDirList.keys.randomElement()!
        
        //抽取一个距离
        let mindist = getDisplayBorderInformation().x / 10 //得多少走点，别在那倒
        let chooseDistance = randomInRange(mindist,availableDirList[chooseDirection]!)
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
        //终点
        var endPos = startPos + chooseDistance * directionVector[chooseDirection]!;
        print("startpos: \(startPos)")
        print("direction: \(chooseDirection)")
        print("distance(by axis): \(chooseDistance)")
        print("endpos: \(endPos)")
        
        //真的动一下！
        let framesize = VPET.displayWindow.window!.frame.width;
        let middlexy = framesize/2
//        moveWindowPos(startPos: startPos, endPos: endPos)
        moveWindow(startPos: startPos, direction: directionVector[chooseDirection]!, distance: chooseDistance, speed: 14)
        
    }
    
    var framecost:Int? = nil
    var framecount = 0;
    var timer:Timer? = nil
    var direction:Vector? = nil
    var speed:Int? = nil
    func moveWindow(startPos:Vector,direction:Vector,distance:CGFloat,speed:Int){
        //中心点startpos，按照direction的方向，移动distance，速度speed
        //先把窗口弄到startpos（对于爬墙，startpos不一定是当前的pos）
        let premove = startPos + (-1) * getVPetCenterPos();
        let t = VPET.displayWindow.window?.convertPoint(toScreen: NSPoint(x: premove.x , y: premove.y))
        VPET.displayWindow.window?.setFrameOrigin(t!)
        //需要移动多少帧
        framecost = Int(distance/CGFloat(speed))
        self.direction = direction;
        self.speed = speed;
        timer = Timer(timeInterval: 0.125, target: self, selector:#selector(moveWindowFrame), userInfo: nil, repeats: true )
        RunLoop.main.add(timer!,forMode: .common)
        
    }
    @objc func moveWindowFrame(){
        guard framecost != nil else{return;}; guard timer != nil else{return;};
        guard direction != nil else{return;}; guard speed != nil else{return;};
        let move = CGFloat(speed!) * direction!;
        let t2 = VPET.displayWindow.window?.convertPoint(toScreen: NSPoint(x: move.x, y: move.y))
        VPET.displayWindow.window?.setFrameOrigin(t2!)
        framecount += 1;
        if(framecount == framecost){
            timer?.invalidate();
            timer = nil;
            framecount = 0;
        }
        
    }
//    func moveWindowPos(startPos: Vector,endPos: Vector){
//        //先把窗口弄到startpos（对于爬墙，startpos不一定是当前的pos）
//        let premove = startPos + (-1) * getVPetCenterPos();
//        let t = VPET.displayWindow.window?.convertPoint(toScreen: NSPoint(x: premove.x , y: premove.y))
//        VPET.displayWindow.window?.setFrameOrigin(t!)
//        //controlPos和targetPos都是相对窗口的坐标
//        let movement = endPos + (-1)*startPos;
//        let t2 = VPET.displayWindow.window?.convertPoint(toScreen: NSPoint(x: movement.x, y: movement.y))
//        VPET.displayWindow.window?.setFrameOrigin(t2!)
//    }
    
    func animateWindow() {
        var currentPosition: NSPoint = NSPoint(x: 100, y: 100) // 初始位置
        VPET.displayWindow.window?.setFrameOrigin(currentPosition)
        var targetPosition: NSPoint = NSPoint(x: 300, y: 300) // 目标位置
        let duration: TimeInterval = 2.0 // 移动持续时间（秒）
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction.init(name: .linear)
            let window = VPET.displayWindow.window!
            var rect = window.frame;rect.origin = targetPosition;
            window.animator().setFrame(rect, display: true, animate: true)
        },completionHandler: {
            print("回调")
        })
        
    }
    
    
}
