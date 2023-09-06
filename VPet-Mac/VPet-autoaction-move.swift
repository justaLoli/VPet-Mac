//
//  VPet-autoaction-move.swift
//  VPet-Mac
//
//  Created by Just aLoli on 2023/9/6.
//

import Cocoa

class VPetAutoMoveHandler{
    let VPET:VPet!
    init(_ VPET:VPet) {
        self.VPET = VPET
    }
    
    func getVPetCenterPos() -> NSPoint{
        // 得到当前宠物中心点坐标（相对屏幕左下角）
        let framesize = VPET.displayWindow.window!.frame.width;
        let middlexy = framesize/2
        
        let frameplace = VPET.displayWindow.window!.frame.origin;
        let middlePos = NSPoint(x: frameplace.x + middlexy, y: frameplace.y + middlexy)
        return middlePos
    }
    
    func getDisplayBorderInformation() -> NSRect{
        // 得到屏幕大小
        let screenFrame = NSScreen.main!.frame //出事直接崩溃就好了
        return screenFrame
    }
    
    // 肮脏的程序结构
    func leftClimbCenterX() -> CGFloat{
        var controllen:CGFloat = 145 //肮脏的硬编码
        var actuallen:CGFloat = controllen * 2;
        var imageres:CGFloat = 1000 //肮脏的硬编码
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
        let pointx = getDisplayBorderInformation().width - (middlexy - actualx)
        return pointx;
    }
    func upClimbCenterY() -> CGFloat{
        var controllen:CGFloat = 150
        var actuallen:CGFloat = controllen * 2;
        var imageres:CGFloat = 1000
        let actualy:CGFloat = actuallen/imageres * VPET.displayWindow.window!.frame.width;
        let middlexy:CGFloat = VPET.displayWindow.window!.frame.width/2
        let pointx = getDisplayBorderInformation().height - (middlexy - actualy)
        return pointx;
    }
    
    struct dist{
        var toleft:CGFloat;var toright:CGFloat;var toup:CGFloat;var todown:CGFloat;
    }
    func getBorderDistances(_ petpos:NSPoint?) -> dist{
        //给定点到边框的距离（给定的点可能是未来宠物会在的点，不一定是当前位置。）
        let pos = petpos ?? getVPetCenterPos();
        
        let DisplayRect = getDisplayBorderInformation();
        let toleft = pos.x;
        let todown = pos.y;
        let toup = DisplayRect.height - todown;
        let toright = DisplayRect.width - toleft;
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
    func getAvailableDirectionList(_ petpos: NSPoint?) -> [MoveDirections:CGFloat]{
        //返回值：方向：允许的最大长度
        //像爬这样的，就只有某些时候（贴近边框）能触发
        let borderDist = getBorderDistances(petpos);
        //给边框增加一定宽度，离边框太近就不要再往里了；
        let mindist = getDisplayBorderInformation().width / 10 //随便算的
//        let mindist = 0.0;
        var res = [MoveDirections:CGFloat]()
        if(borderDist.toleft > 0){
            res[.WalkLeft] = borderDist.toleft
        }
        if(borderDist.toright > 0){
            res[.WalkRight] = borderDist.toright
        }
        if(borderDist.toleft > 0 && borderDist.todown > 0){
            res[.FallLeft] = min(borderDist.toleft, borderDist.todown)
        }
        if(borderDist.toright > 0 && borderDist.todown > 0){
            res[.FallRight] = min(borderDist.toright,borderDist.todown);
        }
        if(borderDist.toleft < mindist){
            res[.ClimbLeftUp] = max(borderDist.toup,0)
            res[.ClimbLeftDown] = max(borderDist.todown,0)
        }
        if(borderDist.toright < mindist){
            res[.ClimbRightUp] = max(borderDist.toup,0)
            res[.ClimbRightDown] = max(borderDist.todown,0)
        }
        if(borderDist.toup < mindist){
            res[.MoveTopLeft] = max(borderDist.toleft,0)
            res[.MoveTopRight] = max(borderDist.toright,0)
        }
        return res;
    }
    
    
    func randomInRange(_ from: CGFloat, _ to: CGFloat) -> CGFloat {
        if(to < from){return 0;}
        // 生成一个从from到to之间的随机数（包括from和to）
        let random = arc4random_uniform(UInt32(to - from + 1)) + UInt32(from)
        return CGFloat(random)
    }
    func generateMoveList(){
        var pos = getVPetCenterPos();
        let iterateTime = 20; //移动次数
        var i = 0;
        var res = [(MoveDirections,CGFloat)]()
        print(pos)
        while( i<iterateTime ){
            let directions = getAvailableDirectionList(pos);
            let chooseDirection = directions.keys.randomElement()!
            let chooseDistance = randomInRange(100,directions[chooseDirection]!)//姑且动点，最少给老子动100px
            if(chooseDistance<=0){continue;}
            res.append((chooseDirection,chooseDistance))
            //肮脏的程序设计
            switch chooseDirection{
            case .WalkLeft: pos.x -= chooseDistance;break;
            case .WalkRight: pos.x += chooseDistance;break;
            case .FallLeft: pos.x -= chooseDistance;pos.y -= chooseDistance;break;
            case .FallRight: pos.x += chooseDistance;pos.y -= chooseDistance;break;
            //要把身体形成的直线瞬移到和边框重合。之后的坐标计算要注意到。
            case .ClimbLeftUp: pos.y += chooseDistance;pos.x = leftClimbCenterX(); break;
            case .ClimbRightUp: pos.y += chooseDistance;pos.x = rightClimbCenterX(); break;
            case .ClimbLeftDown: pos.y -= chooseDistance;pos.x = leftClimbCenterX(); break;
            case .ClimbRightDown: pos.y -= chooseDistance;pos.x = rightClimbCenterX(); break;
            case .MoveTopLeft: pos.x -= chooseDistance;pos.y = upClimbCenterY(); break;
            case .MoveTopRight: pos.x += chooseDistance;pos.y = upClimbCenterY(); break;
            }
            print(i)
            print(chooseDirection)
            print(chooseDistance)
            print(pos)
            print("")
            i+=1
        }
    }
    
    
}
