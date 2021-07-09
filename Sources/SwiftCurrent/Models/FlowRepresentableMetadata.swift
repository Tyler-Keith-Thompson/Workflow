//
//  FlowRepresentableMetadata.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
/**
 Data about a `FlowRepresentable`.

 ### Discussion
 Every time a `Workflow` is created, the defining characteristics about a `FlowRepresentable` are stored in the `FlowRepresentableMetadata` to be used later.
 */
public class FlowRepresentableMetadata {
    /// Preferred `LaunchStyle` of the associated `FlowRepresentable`.
    public private(set) var launchStyle: LaunchStyle
    /// Preferred `FlowPersistence` of  the associated `FlowRepresentable`; set when `FlowRepresentableMetadata` instantiates an instance.
    public private(set) var persistence: FlowPersistence?
    private(set) var flowRepresentableFactory: (AnyWorkflow.PassedArgs) -> AnyFlowRepresentable
    private var flowPersistence: (AnyWorkflow.PassedArgs) -> FlowPersistence

    /**
     Creates an instance that holds onto metadata associated with the `FlowRepresentable`.

     - Parameter flowRepresentableType: specific type of the associated `FlowRepresentable`.
     - Parameter launchStyle: the style to use when launching the `FlowRepresentable`.
     - Parameter flowPersistence: a closure passing arguments to the caller and returning the preferred `FlowPersistence`.
     */
    public init<FR: FlowRepresentable>(_ flowRepresentableType: FR.Type,
                                       launchStyle: LaunchStyle = .default,
                                       flowPersistence:@escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) {
        flowRepresentableFactory = { args in
            AnyFlowRepresentable(FR.self, args: args)
        }
        self.flowPersistence = flowPersistence
        self.launchStyle = launchStyle
    }

    public init<FR: FlowRepresentable>(_ flowRepresentableType: FR.Type,
                                       launchStyle: LaunchStyle = .default,
                                       flowPersistence:@escaping (AnyWorkflow.PassedArgs) -> FlowPersistence,
                                       factory: @escaping (AnyWorkflow.PassedArgs) -> AnyFlowRepresentable) {
        flowRepresentableFactory = factory
        self.flowPersistence = flowPersistence
        self.launchStyle = launchStyle
    }

    // Needed because FR was lost after the init so I can't init again with just this info
//    public func _updatePersistenceClosure(_ persistence: FlowPersistence) {
//        flowPersistence = { _ in persistence }
//    }
//    public func _updateLaunchStyle(_ launchStyle: LaunchStyle) {
//        self.launchStyle = launchStyle
//    }
//    public func _updateFlowRepresentableFactory(with closure: @escaping (AnyWorkflow.PassedArgs) -> AnyFlowRepresentable) {
//        flowRepresentableFactory = closure
//    }

    func setPersistence(_ args: AnyWorkflow.PassedArgs) -> FlowPersistence {
        let val = flowPersistence(args)
        persistence = val
        return val
    }
}
