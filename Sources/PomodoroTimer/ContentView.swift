import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var settings: AppSettingsStore
    @ObservedObject var panelState: MenuPanelState
    @StateObject private var viewModel: PomodoroViewModel

    init(settings: AppSettingsStore, panelState: MenuPanelState) {
        self.settings = settings
        self.panelState = panelState
        _viewModel = StateObject(wrappedValue: PomodoroViewModel(settings: settings))
    }

    var body: some View {
        cardContainer
            .padding(14)
        .frame(width: 352, height: 476)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.93),
                    Color(red: 0.99, green: 0.92, blue: 0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onDisappear {
            panelState.showTimer()
        }
        .alert(item: $viewModel.activeAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var cardContainer: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                timerPage
                    .frame(width: geometry.size.width, height: geometry.size.height)

                SettingsView(settings: settings) {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        panelState.showTimer()
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .offset(x: panelState.page == .timer ? 0 : -geometry.size.width)
            .animation(.easeInOut(duration: 0.22), value: panelState.page)
        }
        .frame(width: 324, height: 444)
        .clipped()
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.65), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.10), radius: 24, y: 10)
    }

    private var timerPage: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        panelState.showSettings()
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(red: 0.50, green: 0.32, blue: 0.18))
                }
                .buttonStyle(.plain)
                .help("Settings")
            }

            AppIconIllustration()

            VStack(spacing: 10) {
                Text(viewModel.statusText)
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.42, green: 0.20, blue: 0.14))

                Text(viewModel.timerText)
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.47, green: 0.08, blue: 0.08))
            }

            HStack(spacing: 14) {
                Button("Start") {
                    viewModel.start()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.82, green: 0.16, blue: 0.12))
                .disabled(!viewModel.isStartEnabled)
                .keyboardShortcut(.space, modifiers: [])

                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut("r", modifiers: [])
            }

            Text("\(settings.focusMinutes)-minute focus session followed by a \(settings.breakMinutes)-minute break.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 280)

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
                .keyboardShortcut("q", modifiers: [.command])
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 24)
    }
}

private struct AppIconIllustration: View {
    var body: some View {
        Image(nsImage: NSApp.applicationIconImage)
            .resizable()
            .interpolation(.high)
            .frame(width: 156, height: 156)
            .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
    }
}
