import Foundation

@MainActor
protocol DoNotDisturbHandling: AnyObject {
    var setupInstructions: String { get }

    func hasRequiredSetup() -> Bool

    @discardableResult
    func enableDoNotDisturb() -> Bool

    @discardableResult
    func disableDoNotDisturb() -> Bool
}

@MainActor
final class DoNotDisturbShortcutController: DoNotDisturbHandling {
    static let enableShortcutName = "Pomodoro Enable DND"
    static let disableShortcutName = "Pomodoro Disable DND"

    var setupInstructions: String {
        Self.setupInstructions
    }

    static var setupInstructions: String {
        """
        To use this option, create two Shortcuts named "\(enableShortcutName)" and "\(disableShortcutName)" that turn system Do Not Disturb on and off. Pomodoro will keep running normally without them.
        """
    }

    func hasRequiredSetup() -> Bool {
        let result = runShortcutsCommand(arguments: ["list"], captureOutput: true)
        guard result.exitCode == 0 else {
            return false
        }

        let shortcutNames = Set(
            result.output
                .split(whereSeparator: \.isNewline)
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        )

        return shortcutNames.contains(Self.enableShortcutName)
            && shortcutNames.contains(Self.disableShortcutName)
    }

    func enableDoNotDisturb() -> Bool {
        runShortcut(named: Self.enableShortcutName)
    }

    func disableDoNotDisturb() -> Bool {
        runShortcut(named: Self.disableShortcutName)
    }

    @discardableResult
    private func runShortcut(named name: String) -> Bool {
        let result = runShortcutsCommand(arguments: ["run", name], captureOutput: false)
        return result.exitCode == 0
    }

    private func runShortcutsCommand(arguments: [String], captureOutput: Bool) -> ShortcutsCommandResult {
        guard FileManager.default.isExecutableFile(atPath: "/usr/bin/shortcuts") else {
            return ShortcutsCommandResult(exitCode: 1, output: "")
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        process.arguments = arguments

        let outputPipe = Pipe()
        if captureOutput {
            process.standardOutput = outputPipe
            process.standardError = outputPipe
        }

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ShortcutsCommandResult(exitCode: 1, output: "")
        }

        let output: String
        if captureOutput,
           let data = try? outputPipe.fileHandleForReading.readToEnd(),
           let text = String(data: data, encoding: .utf8) {
            output = text
        } else {
            output = ""
        }

        return ShortcutsCommandResult(exitCode: process.terminationStatus, output: output)
    }
}

private struct ShortcutsCommandResult {
    let exitCode: Int32
    let output: String
}
