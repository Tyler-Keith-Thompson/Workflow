//
//  OrchestrationResponder.swift
//  
//
//  Created by Tyler Thompson on 11/24/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
/// A type capable of responding to `Workflow` actions.
public protocol OrchestrationResponder {
    /**
     Respond to the `Workflow` launching.
     - Parameter to: Passes the `AnyWorkflow.Element` and `FlowRepresentableMetadata` so the responder can decide how to launch the first loaded instance.
     */
    func launch(to: AnyWorkflow.Element)
    /**
     Respond to the `Workflow` proceeding.
     - Parameter to: Passes the `AnyWorkflow.Element` and `FlowRepresentableMetadata` so the responder can decide how to proceed.
     - Parameter from: Passes the `AnyWorkflow.Element` and `FlowRepresentableMetadata` so the responder has context on where to proceed from.
     */
    func proceed(to: AnyWorkflow.Element, from: AnyWorkflow.Element)
    /**
     Respond to the `Workflow` backing up.
     - Parameter to: Passes the `AnyWorkflow.Element` and `FlowRepresentableMetadata` so the responder can decide how to back up.
     - Parameter from: Passes the `AnyWorkflow.Element` and `FlowRepresentableMetadata` so the responder has context on where to back up from.
     */
    func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element)
    /**
     Respond to the `Workflow` getting abandoned.
     - Parameter workflow: The `AnyWorkflow` that is being abandoned.
     - Parameter onFinish: A closure that is executed when the responder is finished abandoning.
     */
    func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?)
    /**
     Respond to the `Workflow` completing.
     - Parameter workflow: The `AnyWorkflow` that is being completed.
     - Parameter passedArgs: The `AnyWorkflow.PassedArgs` to be passed to `onFinish`.
     - Parameter onFinish: A closure that is executed when the responder is finished completing.
     */
    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?)
}

extension OrchestrationResponder {
    func launchOrProceed(to: AnyWorkflow.Element,
                         from: AnyWorkflow.Element?) {
        if let root = from {
            proceed(to: to, from: root)
        } else {
            launch(to: to)
        }
    }
}
