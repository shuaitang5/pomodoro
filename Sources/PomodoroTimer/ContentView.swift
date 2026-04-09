import AppKit
import SwiftUI

struct ContentView: View {
    enum SurfaceStyle {
        case roundedPanel
        case fullWindow
    }

    static let panelWidth: CGFloat = 300
    static let panelHeight: CGFloat = 460

    @ObservedObject var settings: AppSettingsStore
    @ObservedObject var panelState: MenuPanelState
    @ObservedObject var viewModel: PomodoroViewModel
    var surfaceStyle: SurfaceStyle = .roundedPanel

    private let surfaceCornerRadius: CGFloat = 30
    private var isTimerPageVisible: Bool {
        panelState.page == .timer
    }

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

                SettingsView(settings: settings, viewModel: viewModel)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .offset(x: panelState.page == .timer ? 0 : -geometry.size.width)
            .animation(.easeInOut(duration: 0.22), value: panelState.page)
        }
        .frame(width: Self.panelWidth, height: Self.panelHeight)
        .modifier(SurfaceBackgroundModifier(style: surfaceStyle, cornerRadius: surfaceCornerRadius))
        .overlay(alignment: .topTrailing) {
            topTrailingButton
                .padding(.top, 18)
                .padding(.trailing, 24)
        }
    }

    @ViewBuilder
    private var topTrailingButton: some View {
        if panelState.page == .timer {
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
        } else {
            Button("Done") {
                withAnimation(.easeInOut(duration: 0.22)) {
                    panelState.showTimer()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var timerPage: some View {
        VStack(spacing: 14) {
            // Top spacing to keep layout consistent (gear icon moved to cardContainer overlay)
            Color.clear
                .frame(height: 15)
                .padding(.top, 2)

            AppIconIllustration(size: 108)

            VStack(spacing: 10) {
                Text(viewModel.statusText)
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.42, green: 0.20, blue: 0.14))

                Text(viewModel.timerText)
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.47, green: 0.08, blue: 0.08))
            }

            QuickSessionPresetPicker(
                presets: AppSettingsStore.quickSessionPresets,
                selectedPreset: settings.selectedQuickSessionPreset,
                isEnabled: viewModel.isSessionPresetSelectionEnabled,
                onAdvance: { direction in
                    settings.cycleQuickSessionPreset(step: direction)
                }
            ) { preset in
                settings.applySessionPreset(preset)
            }

            HStack(spacing: 14) {
                Button("Start") {
                    viewModel.start()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.82, green: 0.16, blue: 0.12))
                .disabled(!viewModel.isStartEnabled || !isTimerPageVisible)
                .keyboardShortcut(.space, modifiers: [])

                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
                .disabled(!isTimerPageVisible)
                .keyboardShortcut("r", modifiers: [])
            }

            Text("\(settings.focusMinutes)-minute focus + \(settings.breakMinutes)-minute break.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 260)

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.bordered)
            .keyboardShortcut("q", modifiers: [.command])
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}

private struct QuickSessionPresetPicker: View {
    let presets: [SessionPreset]
    let selectedPreset: SessionPreset?
    let isEnabled: Bool
    let onAdvance: (Int) -> Void
    let onSelect: (SessionPreset) -> Void

    private var displayedPresets: [DisplayedPreset] {
        guard let selectedPreset,
              let selectedIndex = presets.firstIndex(of: selectedPreset),
              presets.count >= 3 else {
            return presets.map { DisplayedPreset(preset: $0, role: .compact) }
        }

        return [
            DisplayedPreset(preset: presets[(selectedIndex - 1).positiveModulo(presets.count)], role: .compact),
            DisplayedPreset(preset: presets[selectedIndex], role: .selected),
            DisplayedPreset(preset: presets[(selectedIndex + 1).positiveModulo(presets.count)], role: .compact)
        ]
    }

    var body: some View {
        HStack(spacing: 8) {
            CarouselStepButton(symbolName: "chevron.left", isEnabled: isEnabled) {
                onAdvance(-1)
            }

            HStack(spacing: 8) {
                ForEach(displayedPresets) { displayedPreset in
                    QuickSessionPresetButton(
                        preset: displayedPreset.preset,
                        role: displayedPreset.role,
                        isSelected: selectedPreset == displayedPreset.preset,
                        isEnabled: isEnabled
                    ) {
                        onSelect(displayedPreset.preset)
                    }
                }
            }

            CarouselStepButton(symbolName: "chevron.right", isEnabled: isEnabled) {
                onAdvance(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.26))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.52), lineWidth: 1)
        )
    }
}

private struct QuickSessionPresetButton: View {
    enum Role {
        case selected
        case compact
    }

    let preset: SessionPreset
    let role: Role
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void

    private var backgroundColor: Color {
        if isSelected {
            return Color(red: 0.93, green: 0.63, blue: 0.53)
        }

        return Color.white.opacity(role == .selected ? 0.46 : 0.60)
    }

    private var borderColor: Color {
        if isSelected {
            return Color(red: 0.78, green: 0.42, blue: 0.31)
        }

        return Color.black.opacity(0.06)
    }

    private var textColor: Color {
        isSelected ? Color.white : Color(red: 0.41, green: 0.21, blue: 0.15)
    }

    private var width: CGFloat {
        role == .selected ? 84 : 58
    }

    private var height: CGFloat {
        role == .selected ? 48 : 36
    }

    private var fontSize: CGFloat {
        role == .selected ? 16 : 12
    }

    var body: some View {
        Button(action: action) {
            Text(preset.buttonTitle)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(textColor)
                .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.72)
        .scaleEffect(role == .selected ? 1 : 0.94)
        .offset(y: role == .selected ? 0 : 5)
        .help(preset.description)
        .accessibilityLabel("\(preset.focusMinutes)-minute focus and \(preset.breakMinutes)-minute break")
    }
}

private struct CarouselStepButton: View {
    let symbolName: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbolName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color(red: 0.47, green: 0.30, blue: 0.18))
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.56))
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.58)
    }
}

private struct DisplayedPreset: Identifiable {
    let preset: SessionPreset
    let role: QuickSessionPresetButton.Role

    var id: String {
        "\(role)-\(preset.id)"
    }
}

private extension Int {
    func positiveModulo(_ divisor: Int) -> Int {
        let remainder = self % divisor
        return remainder >= 0 ? remainder : remainder + divisor
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
    let size: CGFloat

    var body: some View {
        Image(nsImage: NSApp.applicationIconImage)
            .resizable()
            .interpolation(.high)
            .frame(width: size, height: size)
            .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
    }
}
