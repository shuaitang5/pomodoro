import AppKit
import SwiftUI

struct ContentView: View {
    enum SurfaceStyle {
        case roundedPanel
        case fullWindow
    }

    static let panelWidth: CGFloat = 336
    static let panelHeight: CGFloat = 460

    @ObservedObject var settings: AppSettingsStore
    @ObservedObject var panelState: MenuPanelState
    @ObservedObject var viewModel: PomodoroViewModel
    var surfaceStyle: SurfaceStyle = .roundedPanel

    private let surfaceCornerRadius: CGFloat = 30

    var body: some View {
        cardContainer
            .frame(width: Self.panelWidth, height: Self.panelHeight)
            .background(Color.clear)
            .onDisappear {
                panelState.showTimer()
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
        .frame(width: Self.panelWidth, height: Self.panelHeight)
        .modifier(SurfaceBackgroundModifier(style: surfaceStyle, cornerRadius: surfaceCornerRadius))
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
            .buttonStyle(.bordered)
            .keyboardShortcut("q", modifiers: [.command])
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 24)
    }
}

private struct SurfaceBackgroundModifier: ViewModifier {
    let style: ContentView.SurfaceStyle
    let cornerRadius: CGFloat

    private var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.99, green: 0.97, blue: 0.92),
                Color(red: 0.97, green: 0.94, blue: 0.88)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func body(content: Content) -> some View {
        switch style {
        case .roundedPanel:
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(surfaceGradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.72), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        case .fullWindow:
            content
                .background(surfaceGradient)
        }
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
