import Combine
import Foundation

struct SessionPreset: Equatable, Identifiable {
    let focusMinutes: Int
    let breakMinutes: Int

    var id: String {
        "\(focusMinutes)-\(breakMinutes)"
    }

    var buttonTitle: String {
        "\(focusMinutes)+\(breakMinutes)"
    }

    var description: String {
        "\(focusMinutes) min focus • \(breakMinutes) min break"
    }
}

@MainActor
final class AppSettingsStore: ObservableObject {
    static let allowedFocusMinutes = [5, 15, 20, 25, 30, 35, 40, 45, 50]
    static let allowedBreakMinutes = [5, 10, 15]
    static let defaultFocusMinutes = 25
    static let defaultBreakMinutes = 5
    static let quickSessionPresets = [
        SessionPreset(focusMinutes: 25, breakMinutes: 5),
        SessionPreset(focusMinutes: 35, breakMinutes: 10),
        SessionPreset(focusMinutes: 50, breakMinutes: 15)
    ]

    @Published var focusMinutes: Int {
        didSet {
            let normalized = Self.normalizeFocusMinutes(focusMinutes)
            guard focusMinutes == normalized else {
                focusMinutes = normalized
                return
            }
            userDefaults.set(focusMinutes, forKey: Self.focusMinutesKey)
        }
    }

    @Published var breakMinutes: Int {
        didSet {
            let normalized = Self.normalizeBreakMinutes(breakMinutes)
            guard breakMinutes == normalized else {
                breakMinutes = normalized
                return
            }
            userDefaults.set(breakMinutes, forKey: Self.breakMinutesKey)
        }
    }

    @Published var soundsEnabled: Bool {
        didSet {
            userDefaults.set(soundsEnabled, forKey: Self.soundsEnabledKey)
        }
    }

    @Published var doNotDisturbDuringFocusEnabled: Bool {
        didSet {
            userDefaults.set(doNotDisturbDuringFocusEnabled, forKey: Self.doNotDisturbDuringFocusEnabledKey)
        }
    }

    var focusDuration: TimeInterval {
        Self.focusDuration(forMinutes: focusMinutes)
    }

    var breakDuration: TimeInterval {
        Self.breakDuration(forMinutes: breakMinutes)
    }

    var selectedQuickSessionPreset: SessionPreset? {
        Self.quickSessionPresets.first {
            $0.focusMinutes == focusMinutes && $0.breakMinutes == breakMinutes
        }
    }

    var selectedQuickSessionPresetIndex: Int? {
        guard let selectedQuickSessionPreset else {
            return nil
        }

        return Self.quickSessionPresets.firstIndex(of: selectedQuickSessionPreset)
    }

    private let userDefaults: UserDefaults

    private static let focusMinutesKey = "focusMinutes"
    private static let breakMinutesKey = "breakMinutes"
    private static let soundsEnabledKey = "soundsEnabled"
    private static let doNotDisturbDuringFocusEnabledKey = "doNotDisturbDuringFocusEnabled"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let persistedFocusMinutes = userDefaults.object(forKey: Self.focusMinutesKey) as? Int
        let persistedBreakMinutes = userDefaults.object(forKey: Self.breakMinutesKey) as? Int

        self.focusMinutes = Self.allowedFocusMinutes.contains(persistedFocusMinutes ?? Self.defaultFocusMinutes)
            ? (persistedFocusMinutes ?? Self.defaultFocusMinutes)
            : Self.defaultFocusMinutes
        self.breakMinutes = Self.allowedBreakMinutes.contains(persistedBreakMinutes ?? Self.defaultBreakMinutes)
            ? (persistedBreakMinutes ?? Self.defaultBreakMinutes)
            : Self.defaultBreakMinutes
        self.soundsEnabled = userDefaults.object(forKey: Self.soundsEnabledKey) as? Bool ?? true
        self.doNotDisturbDuringFocusEnabled = userDefaults.object(forKey: Self.doNotDisturbDuringFocusEnabledKey) as? Bool ?? false
    }

    static func normalizeFocusMinutes(_ value: Int) -> Int {
        nearestAllowedValue(to: value, allowedValues: allowedFocusMinutes) ?? defaultFocusMinutes
    }

    static func normalizeBreakMinutes(_ value: Int) -> Int {
        nearestAllowedValue(to: value, allowedValues: allowedBreakMinutes) ?? defaultBreakMinutes
    }

    static func focusDuration(forMinutes value: Int) -> TimeInterval {
        TimeInterval(value * 60)
    }

    static func breakDuration(forMinutes value: Int) -> TimeInterval {
        TimeInterval(value * 60)
    }

    func applySessionPreset(_ preset: SessionPreset) {
        focusMinutes = Self.normalizeFocusMinutes(preset.focusMinutes)
        breakMinutes = Self.normalizeBreakMinutes(preset.breakMinutes)
    }

    func cycleQuickSessionPreset(step: Int) {
        guard !Self.quickSessionPresets.isEmpty else {
            return
        }

        let presetCount = Self.quickSessionPresets.count
        let currentIndex = selectedQuickSessionPresetIndex ?? (step >= 0 ? -1 : 0)
        let nextIndex = (currentIndex + step).positiveModulo(presetCount)
        applySessionPreset(Self.quickSessionPresets[nextIndex])
    }

    private static func nearestAllowedValue(to value: Int, allowedValues: [Int]) -> Int? {
        allowedValues.min { left, right in
            let leftDistance = abs(left - value)
            let rightDistance = abs(right - value)

            if leftDistance == rightDistance {
                return left < right
            }

            return leftDistance < rightDistance
        }
    }
}

private extension Int {
    func positiveModulo(_ divisor: Int) -> Int {
        let remainder = self % divisor
        return remainder >= 0 ? remainder : remainder + divisor
    }
}
