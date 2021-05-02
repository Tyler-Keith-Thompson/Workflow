//
//  PickupOrDeliveryViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample
@testable import Workflow

class PickupOrDeliveryViewConrollerTests: ViewControllerTest<PickupOrDeliveryViewController> {
    func testShouldLoadOnlyIfThereAreMultipleOrderTypes() {
        let locationWithOne = Location(name: "", address: Address(), orderTypes: [.pickup], menuTypes: [])
        let locationWithMultiple = Location(name: "", address: Address(), orderTypes: [.pickup, .delivery(Address())], menuTypes: [])
        XCTAssertFalse(testViewController.shouldLoad(with: Order(location: locationWithOne)))
        XCTAssert(testViewController.shouldLoad(with: Order(location: locationWithMultiple)))
    }

    func testShouldLoadWithOnlyOneOrderTypeCallsBackImmediately() {
        var callbackCalled = false
        let locationWithOne = Location(name: "", address: Address(), orderTypes: [.delivery(Address())], menuTypes: [])
        loadFromStoryboard { viewController in
            viewController.proceedInWorkflowStorage = { data in
                callbackCalled = true
                XCTAssert(data is Order)
                XCTAssertEqual((data as? Order)?.orderType, .delivery(Address()))
            }
            _ = viewController.shouldLoad(with: Order(location: locationWithOne))
        }

        XCTAssert(callbackCalled)
    }

    func testSelectingPickupSetsItOnOrder() {
        var callbackCalled = false
        let location = Location(name: "", address: Address(), orderTypes: [.pickup, .delivery(Address())], menuTypes: [])
        loadFromStoryboard { viewController in
            viewController.proceedInWorkflowStorage = { data in
                callbackCalled = true
                XCTAssert(data is Order)
                XCTAssertEqual((data as? Order)?.orderType, .pickup)
            }
            _ = viewController.shouldLoad(with: Order(location: location))
        }

        testViewController.pickupButton?.simulateTouch()

        XCTAssert(callbackCalled)
    }

    func testSelectingDeliveryLaunchesWorkflowAndSetsSelectionOnOrder() {
        loadFromStoryboard()
        let unique = UUID().uuidString
        testViewController.order = Order(location: Location(name: unique, address: Address(), orderTypes: [], menuTypes: []))
        let listener = WorkflowListener()
        let orderOutput = Order(location: Location(name: unique, address: Address(), orderTypes: [], menuTypes: []))

        testViewController.deliveryButton?.simulateTouch()
        XCTAssertWorkflowLaunched(listener: listener, workflow: Workflow(EnterAddressViewController.self))

        let mock = MockOrchestrationResponder()
        listener.workflow?.applyOrchestrationResponder(mock)

        var proceedInWorkflowCalled = false
        testViewController.proceedInWorkflowStorage = { data in
            proceedInWorkflowCalled = true
            XCTAssert(data is Order)
            XCTAssertEqual(data as? Order, orderOutput)
        }

        listener.onFinish?(orderOutput)

        XCTAssertEqual(mock.abandonCalled, 1)

        XCTAssert(proceedInWorkflowCalled)
    }
}

fileprivate extension UIViewController {
    var pickupButton: UIButton? {
        view.viewWithAccessibilityIdentifier("pickupButton") as? UIButton
    }

    var deliveryButton: UIButton? {
        view.viewWithAccessibilityIdentifier("deliveryButton") as? UIButton
    }
}
