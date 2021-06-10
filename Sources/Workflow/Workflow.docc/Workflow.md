# ``Workflow``

Workflow is a library that lets you easily manage journeys through your Swift application.


## Overview

When Developing in UIKit, each view controller has to know about the one following it in order to share data.  Now imagine a flow where the first 3 screens are optional.  What would it look like if you could decouple all of that?

```swift
let workflow = Workflow(LocationsViewController.self) // Skip this if you have GPS
                .thenProceed(with: PickupOrDeliveryViewController.self) // Skip this if you only have 1 choice
                .thenProceed(with: MenuSelectionViewController.self) // Skip this for new stores
                .thenProceed(with: FoodSelectionViewController.self)
                .thenProceed(with: ReviewOrderViewController.self) // This lets you edit anything you've already picked
                .thenProceed(with: SubmitPaymentViewController.self)

// from wherever this flow is launched
launchInto(workflow)
```
The above code is all that is needed from the screen starting this flow. Each screen determines if it needs to show based on data passed in and what that screen knows about the system (such as GPS availability), and all of it is type safe. If you ever want to re-order these, simply move their position in the chain.

As you continue to develop your applications, each view controller will become more decoupled from the rest of the app.  That means, if you want a completely different order of screens, just define a new [Workflow](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/Workflow.html).

## Topics

### Getting Started

- <doc:QuickStart>
- <doc:Installation>
- <doc:Getting-Started>

### General
- <doc:Why-This-Library>
