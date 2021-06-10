# Installation
How to get the dependency for all supported dependency managers.

## Swift Package Manager
If you want more information about installing Swift packages with Xcode, [follow these instructions](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). If you want to learn more about Swift Package Manager, [this page goes into detail](https://swift.org/package-manager/).

### Get the package
Add the following line to the package dependencies in `Package.swift`:
```swift
.package(url: "https://github.com/wwt/Workflow.git", .upToNextMajor(from: "3.0.0")),
```

### Get the correct product
Add one one of the following products to your target dependencies.
#### If you want to use Workflow with UIKit:
```swift
.product(name: "WorkflowUIKit", package: "Workflow")
```
`WorkflowUIKit` will need to be built on a platform that supports UIKit, such as iOS or macOS with Catalyst.

#### If you want to use Workflow without UIKit:
```swift
.product(name: "Workflow", package: "Workflow"),
```
You will need to build your own [Orchestration Responders](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/OrchestrationResponder.html) for your domains.

## CocoaPods
Set up [CocoaPods](https://cocoapods.org/) for your project, then include Workflow in your dependencies by adding one of the following lines to your `Podfile`: 

#### If you want to use Workflow with UIKit:
```ruby
pod 'DynamicWorkflow/UIKit'
```

#### If you want to use Workflow without UIKit:
```ruby
pod 'DynamicWorkflow/Core'
```
You will need to build your own [Orchestration Responders](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/OrchestrationResponder.html) for your domains.
