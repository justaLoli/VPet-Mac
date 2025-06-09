import Cocoa

struct VPetPanelInfo {
    var level: Int
    var statusText: String
    var money: Double
    var exp: Double
    var expMax: Double
    var stamina: Double
    var staminaMax: Double
    var mood: Double
    var moodMax: Double
    var satiety: Double
    var satietyMax: Double
    var thirst: Double
    var thirstMax: Double
    var state: String
    var stateDuration: TimeInterval
}

// Custom progress bar
class ThemedProgressBar: NSProgressIndicator {
    private let orangeColor = NSColor(calibratedRed: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
    private let yellowColor = NSColor.systemYellow
    
    override func draw(_ dirtyRect: NSRect) {
        // Draw the background
        let bgPath = NSBezierPath(roundedRect: bounds, xRadius: 3, yRadius: 3)
        NSColor.white.withAlphaComponent(0.2).setFill()
        bgPath.fill()
        
        // Draw border
        NSColor.white.withAlphaComponent(0.3).setStroke()
        bgPath.lineWidth = 1
        bgPath.stroke()
        
        // Draw the progress
        if doubleValue > 0 {
            let progressWidth = CGFloat(doubleValue / maxValue) * bounds.width
            let progressRect = NSRect(x: 0, y: 0, width: progressWidth, height: bounds.height)
            let progressPath = NSBezierPath(roundedRect: progressRect, xRadius: 3, yRadius: 3)
            NSColor.white.withAlphaComponent(0.6).setFill()
            progressPath.fill()
        }
    }
}

class VPetStateDisplay: NSView {
    private let levelLabel = makeLabel(fontSize: 22, weight: .bold, color: .white)
    private let stateLabel = makeLabel(fontSize: 12, weight: .regular, color: .white)
    private let moneyLabel = makeLabel(fontSize: 14, weight: .bold, color: .white, align: .right)

    private let expBar = ThemedProgressBar()
    private let staminaBar = ThemedProgressBar()
    private let moodBar = ThemedProgressBar()
    private let satietyBar = ThemedProgressBar()
    private let thirstBar = ThemedProgressBar()

    private let expValueLabel = makeValueLabel()
    private let staminaValueLabel = makeValueLabel()
    private let moodValueLabel = makeValueLabel()
    private let satietyValueLabel = makeValueLabel()
    private let thirstValueLabel = makeValueLabel()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
        isHidden = true
        
        // 设置默认值
        let defaultInfo = VPetPanelInfo(
            level: 1,
            statusText: "Normal",
            money: 0,
            exp: 0,
            expMax: 100,
            stamina: 80,
            staminaMax: 100,
            mood: 80,
            moodMax: 100,
            satiety: 80,
            satietyMax: 100,
            thirst: 80,
            thirstMax: 100,
            state: "Normal",
            stateDuration: 0
        )
        updatePanel(info: defaultInfo)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        isHidden = true
    }

    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
        layer?.cornerRadius = 10
        layer?.shadowColor = NSColor.black.cgColor
        layer?.shadowOpacity = 0.15
        layer?.shadowOffset = CGSize(width: 0, height: -2)
        layer?.shadowRadius = 6

        // 顶部三元素直接添加并约束
        addSubview(levelLabel)
        addSubview(stateLabel)
        addSubview(moneyLabel)
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        moneyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // LvX 左上
            levelLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            levelLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            // Normal 紧跟LvX右侧，顶部对齐
            stateLabel.leadingAnchor.constraint(equalTo: levelLabel.trailingAnchor, constant: 4),
            stateLabel.firstBaselineAnchor.constraint(equalTo: levelLabel.firstBaselineAnchor),
            // 金额右上
            moneyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            moneyLabel.firstBaselineAnchor.constraint(equalTo: levelLabel.firstBaselineAnchor)
        ])

        // 属性条区 mainStack
        let mainStack = NSStackView()
        mainStack.orientation = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        // 经验
        addBarRowSmallFont(to: mainStack, label: "经验", bar: expBar, valueLabel: expValueLabel)
        addBarRowSmallFont(to: mainStack, label: "体力", bar: staminaBar, valueLabel: staminaValueLabel)
        addBarRowSmallFont(to: mainStack, label: "心情", bar: moodBar, valueLabel: moodValueLabel)
        addBarRowSmallFont(to: mainStack, label: "饱腹度", bar: satietyBar, valueLabel: satietyValueLabel)
        addBarRowSmallFont(to: mainStack, label: "口渴度", bar: thirstBar, valueLabel: thirstValueLabel)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func addBarRowSmallFont(to stack: NSStackView, label: String, bar: NSProgressIndicator, valueLabel: NSTextField) {
        let labelView = makeLabel(text: label, fontSize: 11, weight: .regular, color: .white)
        labelView.widthAnchor.constraint(equalToConstant: 54).isActive = true
        bar.controlSize = .small
        bar.heightAnchor.constraint(equalToConstant: 6).isActive = true
        bar.widthAnchor.constraint(equalToConstant: 260).isActive = true
        valueLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        valueLabel.alignment = .right
        valueLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        valueLabel.textColor = .white
        let hStack = NSStackView(views: [labelView, bar, valueLabel])
        hStack.orientation = .horizontal
        hStack.spacing = 8
        hStack.alignment = .centerY
        hStack.distribution = .fill
        hStack.setHuggingPriority(.defaultLow, for: .horizontal)
        stack.addArrangedSubview(hStack)
    }

    func updatePanel(info: VPetPanelInfo) {
        levelLabel.stringValue = "Lv \(info.level)"
        stateLabel.stringValue = info.state
        moneyLabel.stringValue = String(format: "$ %.2f", info.money)
        updateBar(bar: expBar, valueLabel: expValueLabel, value: info.exp, max: info.expMax)
        updateBar(bar: staminaBar, valueLabel: staminaValueLabel, value: info.stamina, max: info.staminaMax)
        updateBar(bar: moodBar, valueLabel: moodValueLabel, value: info.mood, max: info.moodMax)
        updateBar(bar: satietyBar, valueLabel: satietyValueLabel, value: info.satiety, max: info.satietyMax)
        updateBar(bar: thirstBar, valueLabel: thirstValueLabel, value: info.thirst, max: info.thirstMax)
    }

    private func updateBar(bar: NSProgressIndicator, valueLabel: NSTextField, value: Double, max: Double) {
        bar.maxValue = max
        bar.doubleValue = value
        valueLabel.stringValue = String(format: "%.2f / %.0f", value, max)
    }

    // 新增：外部刷新经验和等级
    func updateExpLevel(level: Int, exp: Double, expMax: Double) {
        levelLabel.stringValue = "Lv \(level)"
        updateBar(bar: expBar, valueLabel: expValueLabel, value: exp, max: expMax)
    }
}

private func makeLabel(text: String = "", fontSize: CGFloat, weight: NSFont.Weight, color: NSColor, align: NSTextAlignment = .left) -> NSTextField {
    let label = NSTextField(labelWithString: text)
    label.font = NSFont.systemFont(ofSize: fontSize, weight: weight)
    label.textColor = color
    label.alignment = align
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}

private func makeValueLabel() -> NSTextField {
    let label = NSTextField(labelWithString: "")
    label.font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    label.textColor = .white
    label.alignment = .right
    label.translatesAutoresizingMaskIntoConstraints = false
    label.widthAnchor.constraint(equalToConstant: 80).isActive = true
    return label
}
