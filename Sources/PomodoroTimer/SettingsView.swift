import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettingsStore
    @ObservedObject var viewModel: PomodoroViewModel

    private var focusMinutesBinding: Binding<Int> {
        Binding(
            get: { settings.focusMinutes },
            set: { settings.focusMinutes = AppSettingsStore.normalizeFocusMinutes($0) }
        )
    }

    private var breakMinutesBinding: Binding<Int> {
        Binding(
            get: { settings.breakMinutes },
            set: { settings.breakMinutes = AppSettingsStore.normalizeBreakMinutes($0) }
        )
    }

    private var doNotDisturbBinding: Binding<Bool> {
        Binding(
            get: { settings.doNotDisturbDuringFocusEnabled },
            set: { viewModel.setDoNotDisturbDuringFocusEnabled($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Settings")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Focus length")
                    Spacer()
                    Picker("Focus length", selection: focusMinutesBinding) {
                        ForEach(AppSettingsStore.allowedFocusMinutes, id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 110)
                }

                HStack {
                    Text("Break length")
                    Spacer()
                    Picker("Break length", selection: breakMinutesBinding) {
                        ForEach(AppSettingsStore.allowedBreakMinutes, id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 110)
                }

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Alerts")
                        .font(.headline)

                    Text("Popup windows always appear when focus and break timers end.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Toggle("Play gentle sound", isOn: $settings.soundsEnabled)

                VStack(alignment: .leading, spacing: 6) {
                    Toggle("Turn on Do Not Disturb during focus", isOn: doNotDisturbBinding)

                    Text(
                        "Requires Shortcuts named \"\(DoNotDisturbShortcutController.enableShortcutName)\" and \"\(DoNotDisturbShortcutController.disableShortcutName)\" that toggle system Do Not Disturb."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}
