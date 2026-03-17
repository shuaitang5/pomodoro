import Combine
import Foundation

@MainActor
final class AppSettingsStore: ObservableObject {
    static let allowedFocusMinutes = [5, 15, 20, 25, 30, 35, 40, 45, 50]
    static let allowedBreakMinutes = [5, 10, 15]
    static let defaultFocusMinutes = 25
    static let defaultBreakMinutes = 5

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

    var focusDuration: TimeInterval {
        Self.focusDuration(forMinutes: focusMinutes)
    }

    var breakDuration: TimeInterval {
        Self.breakDuration(forMinutes: breakMinutes)
    }

    private let userDefaults: UserDefaults

    private static let focusMinutesKey = "focusMinutes"
    private static let breakMinutesKey = "breakMinutes"
    private static let soundsEnabledKey = "soundsEnabled"

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
