import Foundation
import UIKit
import React

@objc(DragonFamilyCounterComponentViewManager)
class DragonFamilyCounterComponentViewManager: RCTViewManager {
  override func view() -> UIView! {
    return DragonFamilyCounterView()
  }

  @objc func setOnLimitReached(_ view: DragonFamilyCounterView, onLimitReached: @escaping RCTDirectEventBlock) {
          view.onLimitReached = onLimitReached
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}

class DragonFamilyCounterView: UIView {
  private var digitLabels: [UILabel] = []
  private var currentValue: Int = 0
  private var counterBridge: CounterBridge?
  private var isAnimatingInitialValue = false

  private let digitContainerView = UIView()

  private var initialAnimationTimer: DispatchSourceTimer?
  private var _initialAnimationDuration: Double = 0.0

  private var displayLink: CADisplayLink?
  private var startTime: CFTimeInterval = 0
  private var targetValue: Int = 0

  @objc var onLimitReached: RCTDirectEventBlock?

  @objc var thousandsSeparatorSpacing: NSNumber = 0 {
      didSet {
        setNeedsLayout()
      }
    }

  @objc var initialValue: NSNumber = 0 {
    didSet {
      counterBridge?.stop()
      currentValue = 0
      setupDigitLabels(for: currentValue)
      if initialValue.intValue > 1 {
        isAnimatingInitialValue = true
        animateToInitialValue()
      } else {
        counterBridge?.updateValue(initialValue.doubleValue)
      }
    }
  }

  @objc var limit: NSNumber = 1000 {
    didSet {
      setNeedsLayout()
      counterBridge?.updateLimit(limit.doubleValue)
    }
  }

  @objc var timeInterval: NSNumber = 1 {
    didSet {
      setNeedsLayout()
      counterBridge?.updateLoopTimeIntervalSeconds(timeInterval.doubleValue)
    }
  }

  @objc var countOfRubiesInInterval: NSNumber = 1 {
    didSet {
      setNeedsLayout()
        counterBridge?.updateCounterCountRubies(countOfRubiesInInterval.doubleValue)
    }
  }


  @objc var initialAnimationDuration: NSNumber = 100000 {
    didSet {
      setNeedsLayout()
      initialAnimationTimer?.cancel()
      _initialAnimationDuration = initialAnimationDuration.doubleValue
    }
  }

  @objc var textStyle: NSDictionary = [:] {
    didSet {
      updateTextStyle()
    }
  }

  private var animationDuration: Double = 0.2

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(digitContainerView)
    setupDigitLabels(for: currentValue)
    setupContainerConstraints()
  }

  override func didSetProps(_ changedProps: [String]!) {
    super.didSetProps(changedProps)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    addSubview(digitContainerView)
    setupDigitLabels(for: currentValue)
    setupContainerConstraints()
  }

    private func setupContainerConstraints() {
        digitContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            digitContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            digitContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
      }

    private func animateToInitialValue() {
        guard isAnimatingInitialValue, initialValue.intValue > 1 else { return }

        targetValue = initialValue.intValue
        startTime = CACurrentMediaTime()

        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .default)
    }

    @objc private func updateAnimation() {
        let animationDuration = _initialAnimationDuration
        let elapsedTime = CACurrentMediaTime() - startTime
        let progress = min(elapsedTime / animationDuration, 1.0)
        let tempValue = Int(Double(targetValue) * progress)

        self.animateNumberChange(to: tempValue)

        if progress == 1.0 {
            displayLink?.invalidate()
            displayLink = nil
            isAnimatingInitialValue = false
            startRegularAnimation()
        }
    }

  private func startRegularAnimation() {
    setupCounterLogic()
    counterBridge?.start()
  }

  private func setupCounterLogic() {
      counterBridge = CounterBridge(initialValue: Double(truncating: initialValue), loop_time_interval_seconds: timeInterval.doubleValue, loop_count_of_rubies_in_time_interval: countOfRubiesInInterval.doubleValue , limit: limit.doubleValue)
    counterBridge?.onUpdateBlock = { [weak self] newValue in
      DispatchQueue.main.async {
        self?.animateNumberChange(to: Int(newValue))
      }
    }
      counterBridge?.onLimitReachedBlock = { [weak self] newValue in
          DispatchQueue.main.async {
                  if let onLimitReached = self?.onLimitReached {
                      onLimitReached(["value": newValue])
                  }
              }
      }
  }

  private func setupDigitLabels(for number: Int) {
    digitLabels.forEach { $0.removeFromSuperview() }
    digitLabels = []

    let digits = String(number).compactMap { Int(String($0)) }
    for digit in digits {
      let label = createDigitLabel(for: digit)
      digitLabels.append(label)
        label.textAlignment = .center
      digitContainerView.addSubview(label)
    }

    positionDigitLabels()
  }

  private func createDigitLabel(for digit: Int) -> UILabel {
    let label = UILabel()
    applyTextStyle(to: label)
    label.text = "\(digit)"
    return label
  }

    private func positionDigitLabels() {
            // Удаляем существующие ограничения
            digitContainerView.subviews.forEach { $0.removeConstraints($0.constraints) }

            // Рассчитываем размер разделителя

            for (index, label) in digitLabels.enumerated() {
                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.centerYAnchor.constraint(equalTo: digitContainerView.centerYAnchor),
                ])
                let separatorSpacing = CGFloat(thousandsSeparatorSpacing.doubleValue)

                // Определяем, когда добавить отступ между тысячами
                if index > 0 && (digitLabels.count - index) % 3 == 0 {
                    label.leadingAnchor.constraint(equalTo: digitLabels[index - 1].trailingAnchor, constant: separatorSpacing).isActive = true
                } else if index > 0 {
                    label.leadingAnchor.constraint(equalTo: digitLabels[index - 1].trailingAnchor, constant: 0).isActive = true
                } else {
                    label.leadingAnchor.constraint(equalTo: digitContainerView.leadingAnchor).isActive = true
                }

                if index == digitLabels.count - 1 {
                    label.trailingAnchor.constraint(equalTo: digitContainerView.trailingAnchor).isActive = true
                }
            }
        }

  private func animateNumberChange(to newValue: Int) {
    let newDigits = String(newValue).compactMap { Int(String($0)) }
    let currentDigits = String(currentValue).compactMap { Int(String($0)) }

    if newDigits.count != currentDigits.count {
      setupDigitLabels(for: newValue)
    }

    for (index, newDigit) in newDigits.enumerated() {
      guard index < digitLabels.count else { continue }
      if index >= currentDigits.count || currentDigits[index] != newDigit {
        animateDigitChange(label: digitLabels[index], to: newDigit)
      }
    }

    currentValue = newValue
  }

  private func animateDigitChange(label: UILabel, to newDigit: Int) {
      label.text = "\(newDigit)"
      label.textAlignment = .center
  }

  private func updateTextStyle() {
    digitLabels.forEach { applyTextStyle(to: $0) }
  }

  private func applyTextStyle(to label: UILabel) {
    if let fontFamily = textStyle["fontFamily"] as? String,
       let fontSize = textStyle["fontSize"] as? CGFloat {
      var font: UIFont
      if let fontWeight = textStyle["fontWeight"] as? String, let weight = fontWeightFromString(fontWeight) {
        var fontDescriptor = UIFontDescriptor(name: fontFamily, size: fontSize)
        fontDescriptor = fontDescriptor.addingAttributes([
          UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        font = UIFont(descriptor: fontDescriptor, size: fontSize)
      } else {
        font = UIFont(name: fontFamily, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
      }
      label.font = font
    }

    if let colorHex = textStyle["color"] as? String {
      label.textColor = hexStringToUIColor(hex: colorHex)
    }

    if let letterSpacing = textStyle["letterSpacing"] as? CGFloat {
      let attributedText = NSMutableAttributedString(string: label.text ?? "")
      attributedText.addAttribute(.kern, value: letterSpacing, range: NSRange(location: 0, length: attributedText.length))
      label.attributedText = attributedText
    }
  }

  private func hexStringToUIColor(hex: String) -> UIColor {
    var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if cString.hasPrefix("#") {
      cString.remove(at: cString.startIndex)
    }
    if cString.count != 6 {
      return UIColor.black
    }
    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: 1.0
    )
  }

  private func fontWeightFromString(_ weight: String) -> CGFloat? {
    switch weight.lowercased() {
    case "ultralight": return UIFont.Weight.ultraLight.rawValue
    case "thin": return UIFont.Weight.thin.rawValue
    case "light": return UIFont.Weight.light.rawValue
    case "regular": return UIFont.Weight.regular.rawValue
    case "medium": return UIFont.Weight.medium.rawValue
    case "semibold": return UIFont.Weight.semibold.rawValue
    case "bold": return UIFont.Weight.bold.rawValue
    case "heavy": return UIFont.Weight.heavy.rawValue
    case "black": return UIFont.Weight.black.rawValue
    default: return nil
    }
  }
}
