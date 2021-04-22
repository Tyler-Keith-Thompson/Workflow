//
//  FlowRepresentableMetadata.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//

import Foundation

public class FlowRepresentableMetaData {
    private(set) var flowRepresentableFactory: () -> AnyFlowRepresentable
    private var flowPersistance: (AnyWorkflow.PassedArgs) -> FlowPersistance
    private(set) public var launchStyle: LaunchStyle
    private(set) public var persistance: FlowPersistance?

    func calculatePersistance(_ args: AnyWorkflow.PassedArgs) -> FlowPersistance {
        let val = flowPersistance(args)
        persistance = val
        return val
    }

    public init<FR: FlowRepresentable>(_ flowRepresentableType: FR.Type,
                                       launchStyle: LaunchStyle = .default,
                                       flowPersistance:@escaping (AnyWorkflow.PassedArgs) -> FlowPersistance) {
        self.flowRepresentableFactory = {
            var instance = FR.instance()
            return AnyFlowRepresentable(&instance)
        }
        self.flowPersistance = flowPersistance
        self.launchStyle = launchStyle
    }

    public convenience init<FR: FlowRepresentable>(with flowRepresentable: FR, launchStyle: LaunchStyle, persistance: FlowPersistance) {
        self.init(FR.self, launchStyle: launchStyle, flowPersistance: { _ in persistance })
    }
}