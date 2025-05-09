import Cocoa

class GraphInfo:Hashable{
    static func == (lhs: GraphInfo, rhs: GraphInfo) -> Bool {
        return lhs.name == rhs.name && lhs.animatype == rhs.animatype && lhs.graphtype == rhs.graphtype && lhs.modetype == rhs.modetype && lhs.filename == rhs.filename
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(animatype)
        hasher.combine(graphtype)
        hasher.combine(modetype)
        hasher.combine(filename)
    }
    
    func generateName() -> String{
        return filename + "-" + graphtype.rawValue + "-" + animatype.rawValue + "-" + modetype.rawValue;
    }
    
    /// 类型: 主要动作分类
    public enum GraphType:String,CaseIterable
    {
        /// 普通
        case Common = "Common"
        /// 默认
        case Default = "Default"
        /// 工作
        case Work = "Work"
        /// 睡觉
        case Sleep = "Sleep"
        /// 移动
        case Move = "Move"
        /// 摸头
        case Touch_Head = "Touch_Head"
        /// 摸身体
        case Touch_Body = "Touch_Body"
        /// 被提起
        case Raised_Static = "Raised_Static"
        /// 被提起动态
        case Raised_Dynamic = "Raised_Dynamic"
        /// 启动
        case StartUP = "StartUP"
        /// 关闭
        case Shutdown = "Shutdown"
        /// 工作一
        case WorkOne = "WorkOne"
        /// 工作二
        case WorkTwo = "WorkTwo"
        /// 学习
        case Study = "Study"
        /// 清屏
        case WorkClean = "WorkClean"
        /// 状态
        case State = "State"
        /// 状态一
        case StateOne = "StateOne"
        /// 状态二
        case StateTwo = "StateTwo"
        /// 音乐
        case Music = "Music"
        /// 无聊
        case Boring = "Boring"
        /// 蹲下
        case Squat = "Squat"
        /// 向上切换状态
        case Switch_Up = "Switch/Up"
        /// 向下切换状态
        case Switch_Down = "Switch/Down"
        /// 口渴
        case Switch_Thirsty = "Switch/Thirsty"
        /// 饥饿
        case Switch_Hunger = "Switch/Hunger"
        /// 吃东西
        case Eat = "Eat"
        /// 喝东西
        case Drink = "Drink"
        /// 收到礼物
        case Gift = "Gift"
    }
    // 动作: 动画的动作 Start Loop End
    public enum AnimatType:String,CaseIterable
    {
        /// 动画只有一个动作
        case Single = "Single"
        /// 开始动作
        case A_Start = "A_Start"
        /// 循环动作
        case B_Loop = "B_Loop"
        /// 结束动作
        case C_End = "C_End"
    }
    public enum ModeType:String,CaseIterable{
        case Happy = "Happy"
        case Normal = "Normal"
        case PoorCondition = "PoorCondition"
        case Ill = "Ill"
    }
    
    var name = ""
    var animatype = AnimatType.Single
    var graphtype = GraphType.Common
    var modetype = ModeType.Normal
    var filename = ""
    
    init(name:String,type:GraphType,animat:AnimatType,modet:ModeType,filename:String) {
        self.name = name
        self.animatype = animat
        self.graphtype = type
        self.modetype = modet
        self.filename = filename
    }
//    func simpleregex(input:String,pattern:String)->Bool{
//        // 创建NSPredicate对象
//        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
//
//        // 使用NSPredicate来判断是否匹配
//        if predicate.evaluate(with: input) {
//            return true
//        } else {
//            return false
//        }
//    }
    init(filepath:String){
        self.filename = filepath
        let filepathlower = filepath.lowercased()
        
        // Special handling for State directory
        if filepathlower.contains("/state/") {
            if filepathlower.contains("stateone") || filepathlower.contains("state_one") || filepathlower.contains("stateONE") {
                self.graphtype = .StateOne
            } else if filepathlower.contains("statetwo") || filepathlower.contains("state_two") || filepathlower.contains("stateTWO") {
                self.graphtype = .StateTwo
            } else {
                self.graphtype = .State
            }
        } else {
            for i in GraphType.allCases{
                if(filepathlower.contains(i.rawValue.lowercased())){
                    self.graphtype = i
                    break;
                }
            }
        }
        
        for i in ModeType.allCases{
            if(filepathlower.contains(i.rawValue.lowercased())){
                self.modetype = i
                break;
            }
        }
        
        if filepath.contains("/A/") || filepath.contains("/A_") || filepathlower.contains("start"){
          self.animatype = AnimatType.A_Start
       }
       else if filepath.contains("/B/") || filepath.contains("/B_") || filepathlower.contains("loop"){
          self.animatype = AnimatType.B_Loop
       }
       else if filepath.contains("/C/") || filepath.contains("/C_") || filepathlower.contains("end"){
          self.animatype = AnimatType.C_End
       }
       else{
//           if filepath.contains("A"){self.animatype = .A_Start}
//           else if filepath.contains("B"){self.animatype = .B_Loop}
//           else if filepath.contains("C"){self.animatype = .C_End}
//           else{
               self.animatype = .Single
//           }
       }
//
        var filepathseparated = filepath.lowercased().split(separator: "/")
//        print(filepathseparated)

        self.name = String(filepathseparated.last!)
        name = String(name.split(separator: "_").first!)
        if name == ""{
            name = "unnamed"
        }
//        print(name)
//        print(animatype)
//        print(graphtype)
//        print(modetype)
    }
}

class FileSniffer{
    var animepath = ""
    init(_ animepath:String) {
        self.animepath = animepath
    }
    private func isDir(_ fp:String)->Bool{
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: fp, isDirectory: &isDir){
            return false
        }
        return isDir.boolValue;
    }
    private func generateAShortName(_ fn: String) -> String{
        //    "/Users/justaloli/Downloads/VPet-main/VPet-Simulator.Windows/mod/0000_core/pet/vup/MOVE/walk.right/B_Nomal/走路向右_000_125.png"
        var splited = fn.split(separator: "/")
        var filename = splited.last?.split(separator: "_")[0] ?? ""
        var result = ""
        var flag = false
        for i in splited[0...splited.count-2]{
            if flag{
                result += i;
                result += "|"
            }
            if i == "vup"{
                flag = true
            }
        }
        result += filename
        return result
    }
    func sniff() -> [GraphInfo:[String]]{
//        return getAllFilePath(animepath)
        var result = [GraphInfo:[String]]()
        
        let t = getAllFilePath(animepath)
        for i in t{
            if(i.isEmpty){continue}
            let startIndex = String.Index.init(utf16Offset: animepath.count, in: i[0])
            let tt = i[0][startIndex...]
//            print(tt)
            result[GraphInfo(filepath: String(tt))] = i
        }
        return result;
    }
    func getAllFilePath(_ dirPath: String) -> [[String]] {
        var result = [[String]]()
        var isrootfolder = true;
        do {
            let array = try FileManager.default.contentsOfDirectory(atPath: dirPath)
            var photos = [String]()
            for fileName in array {
                let fullPath = "\(dirPath)/\(fileName)"
                if(isDir(fullPath)){
                    var restobeemerged = getAllFilePath(fullPath)
//                    for (key,value) in restobeemerged.reversed() {
//                        result[key] = value
//                    }
                    result += restobeemerged
                    isrootfolder = false;
                }
                else{
                    photos.append(fullPath)
                }
            }
            if isrootfolder{
                photos.sort()
                result.append(photos)
//                result[generateAShortName(photos[0])] = photos
            }
            
        } catch let error as NSError {
            print("get file path error: \(error)")
        }
        
        return result
    }
}
