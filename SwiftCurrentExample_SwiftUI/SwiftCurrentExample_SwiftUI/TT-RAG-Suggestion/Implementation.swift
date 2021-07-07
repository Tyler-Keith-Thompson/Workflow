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

    public init<FR: FlowRepresentable & View>(_: FR.Type) {
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

    // MARK: AFTER MMP not right now but let's play it out
    public func presentationType(_ style: LaunchStyle) -> Self { self }
}

public struct WorkflowView: View {
    @Binding var isPresented: Bool
    #warning("This is a timebomb, but StateObject and State both failed us")
    @ObservedObject private var model = WorkflowViewModel()

    public var body: some View {
        if isPresented {
            VStack {
                model.body
            }.onAppear {
                model.launchOnce()
            }
        }
    }

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    // We could name args something more explicit to convey that it is the values the workflow is starting with... Possible name: thisWillBePassedToFirstFlowRepresentable
    public init(isPresented: Binding<Bool>, args: Any?) {
        self._isPresented = isPresented
        model.args = .args(args)
    }

    func thenProceed<Content: View>(with content: Content) -> Self { // This has some sort of type information at this point so that the user can be forced to do the right thing with adding the right type for Input/Output
        guard let metadata = content as? ViewMetadata else { fatalError("thenProceed(with:) must be called with WorkflowItem.") }

        if model.workflow == nil {
            let workflow = WorkflowBase(metadata.metadata)
            let anyWorkflow = AnyWorkflow(workflow)
            model.workflow = anyWorkflow

            model.launchClosure = { workflow.launch(withOrchestrationResponder: model,
                                             passedArgs: model.args,
                                             launchStyle: model.launchStyle,
                                             onFinish: { args in model.onFinish.forEach { $0(args) } })
            }
        } else {
            model.workflow?.append(metadata.metadata)
        }

        return self
    }

    func onFinish(_ closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        model.onFinish.append(closure)
        return self
    }
    func onAbandon(_ closure: @escaping () -> Void) -> Self {
        model.onAbandon.append(closure)
        return self
    }
    func launchStyle(_ style: LaunchStyle) -> Self {
        model.launchStyle = style
        return self
    }
}

extension WorkflowView {
    fileprivate class WorkflowViewModel: ObservableObject {
        var workflow: AnyWorkflow?
        var launchStyle = LaunchStyle.default
        var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
        var onAbandon = [() -> Void]()
        var args: AnyWorkflow.PassedArgs = .none

        var launched = false

        var launchClosure = { }

        // we determine this launch call and it should only launch once
        func launchOnce() {
            if !launched {
                launched.toggle()
                launchClosure()
            }
        }

        @Published var body = AnyView(EmptyView())
    }
}

extension WorkflowView.WorkflowViewModel: OrchestrationResponder {
    func launch(to: AnyWorkflow.Element) {
        guard let underlyingView = to.value.instance?.underlyingInstance as? AnyView else {
            fatalError("Underlying instance was not AnyView")
        }

        withAnimation {
            body = underlyingView
        }
    }

    func proceed(to: AnyWorkflow.Element, from: AnyWorkflow.Element) {
        guard let underlyingView = to.value.instance?.underlyingInstance as? AnyView else {
            fatalError("Underlying instance was not AnyView")
        }

        withAnimation {
            body = underlyingView
        }
    }

    func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) {
        guard let underlyingView = to.value.instance?.underlyingInstance as? AnyView else {
            fatalError("Underlying instance was not AnyView")
        }

        withAnimation {
            body = underlyingView
        }
    }
    func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {
        withAnimation {
            body = AnyView(EmptyView())
        }
    }
    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        withAnimation {
            body = AnyView(EmptyView())
        }
    }
}

extension FlowRepresentable where Self: View {
    public var _workflowUnderlyingInstance: Any {
        get {
            AnyView(self)
        }
    }
}
