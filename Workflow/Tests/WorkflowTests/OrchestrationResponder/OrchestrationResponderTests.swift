//
//  OrchestrationResponderTests.swift
//  
//
//  Created by Tyler Thompson on 11/24/20.
//

import Foundation
import XCTest

import Workflow

class OrchestrationResponderTests : XCTestCase {
    func testWorkflowCanProceedForwardThroughFlow() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let launchedRepresentable = wf.launch(from: nil, with: nil)
        
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(launchedRepresentable?.value is FR1)
        XCTAssert(responder.lastTo is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR1.self)
        
        (launchedRepresentable?.value as? FR1)?.proceedInWorkflow()
        
        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastTo is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom is FR1)
        XCTAssert((responder.lastFrom as? FR1) === (launchedRepresentable?.value as? FR1))
        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR2.self)

        let fr2 = (responder.lastTo as? FR2)
        fr2?.proceedInWorkflow()
        
        XCTAssertEqual(responder.proceedCalled, 3)
        XCTAssert(responder.lastTo is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom is FR2)
        XCTAssert((responder.lastFrom as? FR2) === fr2)
        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR3.self)
    }
    
    func testWorkflowCallsOnFinishWhenItIsDone() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        let expectation = self.expectation(description: "OnFinish called")
        
        let launchedRepresentable = wf.launch(from: nil, with: nil) { _ in expectation.fulfill() }
        
        (launchedRepresentable?.value as? FR1)?.proceedInWorkflow()
        (responder.lastTo as? FR2)?.proceedInWorkflow()
        (responder.lastTo as? FR3)?.proceedInWorkflow()
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testWorkflowCallsOnFinishWhenItIsDone_andPassesForwardLastArguments() {
        class Object { }
        let val = Object()
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestFlowRepresentable<Never, Object>, FlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        let expectation = self.expectation(description: "OnFinish called")
        
        let launchedRepresentable = wf.launch(from: nil, with: nil) { args in
            XCTAssert(args as? Object === val)
            expectation.fulfill()
        }
        
        (launchedRepresentable?.value as? FR1)?.proceedInWorkflow()
        (responder.lastTo as? FR2)?.proceedInWorkflow()
        (responder.lastTo as? FR3)?.proceedInWorkflow(val)
        
        wait(for: [expectation], timeout: 3)
    }
}

extension OrchestrationResponderTests {
    class TestFlowRepresentable<Input, Output> {
        weak var workflow: AnyWorkflow?
        
        var proceedInWorkflowStorage: ((Any?) -> Void)?

        required init() { }
        static func instance() -> AnyFlowRepresentable { Self() as! AnyFlowRepresentable }

        typealias WorkflowInput = Input
        typealias WorkflowOutput = Output
    }
    
    class TestPassthroughFlowRepresentable: FlowRepresentable {
        weak var workflow: AnyWorkflow?
        
        var proceedInWorkflowStorage: ((Any?) -> Void)?
        
        required init() { }
        
        static func instance() -> AnyFlowRepresentable { Self() }
        
        typealias WorkflowInput = Never
        typealias WorkflowOutput = Never
    }
    
    class MockOrchestrationResponder: AnyOrchestrationResponder {
        var proceedCalled = 0
        var lastTo: Any?
        var lastFrom: Any?
        var lastMetadata:FlowRepresentableMetaData?
        func proceed(to: Any?, from: Any?, metadata:FlowRepresentableMetaData) {
            lastTo = to
            lastFrom = from
            lastMetadata = metadata
            proceedCalled += 1
        }
    }
}