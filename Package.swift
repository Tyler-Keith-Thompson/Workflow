// swift-tools-version:5.5
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
    ],
    dependencies: [
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: Version("2.0.0-beta.1")),
        .package(url: "https://github.com/mattgallagher/CwlCatchException.git", from: Version("2.0.0-beta.1")),
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/sindresorhus/ExceptionCatcher", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Workflow",
            dependencies: []),
        .target(
            name: "WorkflowUIKit",
            dependencies: ["Workflow"]),
        .testTarget(
            name: "WorkflowTests",
            dependencies: [
                "Workflow",
                "CwlPreconditionTesting",
                "CwlCatchException",
                "ExceptionCatcher",
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            exclude: ["Info.plist", "Workflow.xctestplan"]),
    ]
)
