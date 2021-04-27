//
//  LaunchStyle.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/29/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation

/// LaunchStyle: An extendable class that indicates how FlowRepresentables should be launched
public final class LaunchStyle {
    /// default: The launch style that is used if you do not specify one. This behavior is very dependent on the responder (for example: SwiftUI and UIKit presenters will think "default" means something contextual to themselves, but it won't necessarily be the same between them)
    public static let `default` = LaunchStyle()
    /// new: A new instance of LaunchStyle. This should really only be used if you are extending launch styles with your own.
    public static var new: LaunchStyle { LaunchStyle() }

    private init() { }
}

extension LaunchStyle: Equatable {
    public static func == (lhs: LaunchStyle, rhs: LaunchStyle) -> Bool {
        lhs === rhs
    }
}