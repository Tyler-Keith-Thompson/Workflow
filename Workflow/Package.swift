// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Workflow",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "Workflow",
            targets: ["Workflow"]),
        .library(
            name: "WorkflowUIKit",
            targets: ["WorkflowUIKit"]),
        .library(
            name: "WorkflowDI",
            targets: ["WorkflowDI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", .upToNextMajor(from: "2.7.1")),
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: Version("2.0.0-beta.1")),
        .package(url: "https://github.com/mattgallagher/CwlCatchException.git", from: Version("2.0.0-beta.1")),
    ],
    targets: [
        .target(
            name: "Workflow",
            dependencies: []),
        .target(
            name: "WorkflowUIKit",
            dependencies: ["Workflow"]),
        .target(
            name: "WorkflowDI",
            dependencies: ["Workflow", "Swinject"],
            path: "Sources/DependencyInjection"),
        .testTarget(
            name: "WorkflowTests",
            dependencies: [
                "Workflow",
                "CwlPreconditionTesting",
                "CwlCatchException",
            ],
            exclude: ["Info.plist"]),
        .testTarget(
            name: "DependencyInjectionTests",
            dependencies: [
                "Workflow",
                "WorkflowDI",
            ],
            exclude: ["Info.plist"]),
    ]
)