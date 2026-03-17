// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "PomodoroTimer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "PomodoroTimer",
            targets: ["PomodoroTimer"]
        )
    ],
    targets: [
        .executableTarget(
            name: "PomodoroTimer",
            path: "Sources/PomodoroTimer"
        ),
        .testTarget(
            name: "PomodoroTimerTests",
            dependencies: ["PomodoroTimer"],
            path: "Tests/PomodoroTimerTests"
        )
    ]
)
