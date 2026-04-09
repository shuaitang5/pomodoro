import XCTest
@testable import PomodoroTimer

@MainActor
final class AppSettingsStoreTests: XCTestCase {
    func testInitialValuesUsePersistedValidDurations() {
        let defaults = makeUserDefaults()
        defaults.set(30, forKey: "focusMinutes")
        defaults.set(10, forKey: "breakMinutes")

        let store = AppSettingsStore(userDefaults: defaults)

        XCTAssertEqual(store.focusMinutes, 30)
        XCTAssertEqual(store.breakMinutes, 10)
    }

    func testInvalidPersistedDurationsFallBackToDefaults() {
        let defaults = makeUserDefaults()
        defaults.set(0, forKey: "focusMinutes")
        defaults.set(200, forKey: "breakMinutes")

        let store = AppSettingsStore(userDefaults: defaults)

        XCTAssertEqual(store.focusMinutes, 25)
        XCTAssertEqual(store.breakMinutes, 5)
    }

    func testUpdatingSettingsPersistsNewValues() {
        let defaults = makeUserDefaults()
        let store = AppSettingsStore(userDefaults: defaults)

        store.focusMinutes = 20
        store.breakMinutes = 7
        store.soundsEnabled = false
        store.doNotDisturbDuringFocusEnabled = true

        XCTAssertEqual(defaults.object(forKey: "focusMinutes") as? Int, 20)
        XCTAssertEqual(defaults.object(forKey: "breakMinutes") as? Int, 5)
        XCTAssertEqual(store.breakMinutes, 5)
        XCTAssertEqual(defaults.object(forKey: "soundsEnabled") as? Bool, false)
        XCTAssertEqual(defaults.object(forKey: "doNotDisturbDuringFocusEnabled") as? Bool, true)
    }

    func testNormalizationUsesNearestAllowedPreset() {
        XCTAssertEqual(AppSettingsStore.normalizeFocusMinutes(22), 20)
        XCTAssertEqual(AppSettingsStore.normalizeFocusMinutes(24), 25)
        XCTAssertEqual(AppSettingsStore.normalizeBreakMinutes(9), 10)
        XCTAssertEqual(AppSettingsStore.normalizeBreakMinutes(13), 15)
    }

    func testApplyingQuickSessionPresetPersistsBothDurations() {
        let defaults = makeUserDefaults()
        let store = AppSettingsStore(userDefaults: defaults)
        let preset = AppSettingsStore.quickSessionPresets[2]

        store.applySessionPreset(preset)

        XCTAssertEqual(store.focusMinutes, 50)
        XCTAssertEqual(store.breakMinutes, 15)
        XCTAssertEqual(store.selectedQuickSessionPreset, preset)
        XCTAssertEqual(defaults.object(forKey: "focusMinutes") as? Int, 50)
        XCTAssertEqual(defaults.object(forKey: "breakMinutes") as? Int, 15)
    }

    func testCustomDurationCombinationDoesNotMatchQuickPreset() {
        let defaults = makeUserDefaults()
        let store = AppSettingsStore(userDefaults: defaults)

        store.focusMinutes = 30
        store.breakMinutes = 10

        XCTAssertNil(store.selectedQuickSessionPreset)
    }

    func testCyclingQuickSessionPresetsWrapsForwardAndBackward() {
        let defaults = makeUserDefaults()
        let store = AppSettingsStore(userDefaults: defaults)

        store.focusMinutes = 30
        store.breakMinutes = 10

        store.cycleQuickSessionPreset(step: 1)
        XCTAssertEqual(store.selectedQuickSessionPreset, AppSettingsStore.quickSessionPresets[0])

        store.cycleQuickSessionPreset(step: 1)
        XCTAssertEqual(store.selectedQuickSessionPreset, AppSettingsStore.quickSessionPresets[1])

        store.cycleQuickSessionPreset(step: -1)
        XCTAssertEqual(store.selectedQuickSessionPreset, AppSettingsStore.quickSessionPresets[0])

        store.cycleQuickSessionPreset(step: -1)
        XCTAssertEqual(store.selectedQuickSessionPreset, AppSettingsStore.quickSessionPresets[2])
    }

    private func makeUserDefaults() -> UserDefaults {
        let suiteName = "PomodoroTimerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
