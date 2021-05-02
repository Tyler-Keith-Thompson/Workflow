//
//  FoodSelectionViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample

class FoodSelectionViewControllerTests: ViewControllerTest<FoodSelectionViewController> {
    func testViewShouldAlwaysLoad() {
        XCTAssert(testViewController.shouldLoad(with: Order(location: Location(name: "", address: Address(), orderTypes: [], menuTypes: []))))
    }

    func testSelectingFirstFoodChoice() {
        let order = Order(location: Location(name: "", address: Address(), orderTypes: [], menuTypes: []))
        testViewController.order = order
        var proceedInWorkflowCalled = false
        testViewController.proceedInWorkflowStorage = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.shoppingCart.last?.name, "Combo #1")
        }

        testViewController.firstFoodChoiceButton?.simulateTouch()
        XCTAssert(proceedInWorkflowCalled)
    }

    func testSelectingSecondFoodChoice() {
        let order = Order(location: Location(name: "", address: Address(), orderTypes: [], menuTypes: []))
        testViewController.order = order
        var proceedInWorkflowCalled = false
        testViewController.proceedInWorkflowStorage = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.shoppingCart.last?.name, "Combo #2")
        }

        testViewController.secondFoodChoiceButton?.simulateTouch()
        XCTAssert(proceedInWorkflowCalled)
    }

    func testSelectingThirdFoodChoice() {
        let order = Order(location: Location(name: "", address: Address(), orderTypes: [], menuTypes: []))
        testViewController.order = order
        var proceedInWorkflowCalled = false
        testViewController.proceedInWorkflowStorage = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.shoppingCart.last?.name, "Combo #3")
        }

        testViewController.thirdFoodChoiceButton?.simulateTouch()
        XCTAssert(proceedInWorkflowCalled)
    }
}

fileprivate extension UIViewController {
    var firstFoodChoiceButton: UIButton? {
        view.viewWithAccessibilityIdentifier("firstFoodChoiceButton") as? UIButton
    }

    var secondFoodChoiceButton: UIButton? {
        view.viewWithAccessibilityIdentifier("secondFoodChoiceButton") as? UIButton
    }

    var thirdFoodChoiceButton: UIButton? {
        view.viewWithAccessibilityIdentifier("thirdFoodChoiceButton") as? UIButton
    }
}
