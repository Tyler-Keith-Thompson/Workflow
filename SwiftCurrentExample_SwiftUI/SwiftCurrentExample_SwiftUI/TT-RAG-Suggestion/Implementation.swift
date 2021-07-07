//
//  Implementation.swift
//  SwiftCurrentExample_SwiftUI
//
//  Created by Richard Gist on 7/2/21.
//

import Foundation
import SwiftUI
import SwiftCurrent

/*
 The style being implemented:
 WorkflowView(isPresented: $showWorkflow)
         .thenProceed(with: WorkflowItem(FR1.self))
         .thenProceed(with: WorkflowItem(FR2.self)
                               .launchStyle(.modal)
                               .presentationType(.navigationStack)
                               .persistence(.removedAfterProceeding)
                               .padding(10)
                               .transition(.fade))
         .thenProceed(with: WorkflowItem(FR3.self)
         .launchStyle(.modal) // launch style of WorkflowView, could be moved to the top, depends on consumer
         .onAbandon {
             showWorkflow = false
         }
 */

protocol ViewMetadata { var metadata: FlowRepresentableMetadata { get } }
extension ModifiedContent: ViewMetadata where Content: ViewMetadata { var metadata: FlowRepresentableMetadata { content.metadata } }

public struct WorkflowItem: View, ViewMetadata {
    public var body: some View {
        EmptyView()
    }
    var metadata: FlowRepresentableMetadata

    public init<FR: FlowRepresentable>(_: FR.Type) {
        metadata = FlowRepresentableMetadata(FR.self) { _ in .default }
    }

    public func persistence(_ persistence: FlowPersistence) -> Self {
        metadata._updatePersistenceClosure(persistence)

        return self
    }

    public func launchStyle(_ style: LaunchStyle) -> Self {
        metadata._updateLaunchStyle(style)

        return self
    }
}

public struct WorkflowView: View {
    @Binding var isPresented: Bool
    @StateObject private var model = WorkflowViewModel()
    public var body: some View {
        model.body()
            .onAppear {
                model.launchOnce()
            }
        // onAppear for an empty and then launch from there?
    }

    func thenProceed<Content: View>(with content: Content) -> Self { // This has some sort of type information at this point so that the user can be forced to do the right thing with adding the right type for Input/Output
        guard let metadata = content as? ViewMetadata else { fatalError("thenProceed(with:) must be called with WorkflowItem.") }

        print("metadata: \(metadata.metadata)")
        // append metadata
        if model.workflow == nil {
            let workflow = WorkflowBase(metadata.metadata)
            let anyWorkflow = AnyWorkflow(workflow)
            model.workflow = anyWorkflow

            model.launchClosure = { workflow.launch(withOrchestrationResponder: model.orchestrationResponder,
                                             passedArgs: model.args,
                                             launchStyle: model.launchStyle,
                                             onFinish: model.onFinish)
            }
        } else {
            model.workflow?.append(metadata.metadata)
        }

        return self
    }

    func onFinish(_ closure: (Any) -> Void) -> Self { self }// maybe adds to something on the VM
    func onAbandon(_ closure: () -> Void) -> Self { self }// maybe adds to something on the VM [abandon1, abandon2](maybe)
    func launchStyle(_ style: LaunchStyle) -> Self { self }
    func args(_ arguments: AnyWorkflow.PassedArgs) -> Self { self }

    private class WorkflowViewModel: ObservableObject {
        var workflow: AnyWorkflow?
        var orchestrationResponder = SwiftUIResponder()
        var launchStyle = LaunchStyle.default
        var onFinish: ((AnyWorkflow.PassedArgs) -> Void)?
        var args: AnyWorkflow.PassedArgs = .none

        var launchClosure = { }

        // we determine this launch call and it should only launch once
        func launchOnce() {
            launchClosure()
        }

        @ViewBuilder func body() -> some View {
            EmptyView()
        }
    }
}

class SwiftUIResponder: OrchestrationResponder {
    func launch(to: AnyWorkflow.Element) {
    }
    func proceed(to: AnyWorkflow.Element, from: AnyWorkflow.Element) {}
    func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) {}
    func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {}
    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {}
}
