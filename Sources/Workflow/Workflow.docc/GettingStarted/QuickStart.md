# Quick Start

Minimal steps to getting started with Workflow.

## CocoaPods
```ruby
pod 'DynamicWorkflow/UIKit'
```
Then make your first FlowRepresentable view controller:
```swift
import Workflow
class ExampleViewController: UIWorkflowItem<Never, Never>, FlowRepresentable {
    override func viewDidLoad() {
        view.backgroundColor = .green
    }
}
```
Then from your root view controller, call: 
```swift
import Workflow
...
launchInto(Workflow(ExampleViewController.self))
```

And just like that you're started!  To see something more practical and in-depth, check out the example app in the repo.  For a more in-depth starting guide, checkout out our <doc:Getting-Started>.
