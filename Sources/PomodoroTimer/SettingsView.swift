import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettingsStore
    let onDone: () -> Void

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

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Settings")
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                Spacer()

                Button("Done") {
                    onDone()
                }
                .buttonStyle(.borderedProminent)
            }

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
                    Text("Alert options")
                        .font(.headline)

                    Text("Use a gentle banner, popup, or sound when focus and break timers end.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Toggle("Show macOS notifications", isOn: $settings.notificationsEnabled)
                Toggle("Show in-app popups", isOn: $settings.inAppAlertsEnabled)
                Toggle("Play gentle sound", isOn: $settings.soundsEnabled)
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
        .padding(24)
    }
}
