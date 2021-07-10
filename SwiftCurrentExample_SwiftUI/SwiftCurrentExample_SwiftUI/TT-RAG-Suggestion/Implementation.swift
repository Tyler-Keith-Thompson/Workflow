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

class AnyFlowRepresentableView: AnyFlowRepresentable {
    var setViewOnModel: () -> Void = { }
    fileprivate var model: WorkflowView.WorkflowViewModel? {
        didSet {
            setViewOnModel()
        }
    }

    init<FR: FlowRepresentable & View>(viewType: FR.Type, args: AnyWorkflow.PassedArgs) {
        var instance: FR
        switch args {
            case _ where FR.WorkflowInput.self == Never.self:
                instance = FR._factory(FR.self)
            case _ where FR.WorkflowInput.self == AnyWorkflow.PassedArgs.self:
                // swiftlint:disable:next force_cast
                instance = FR(with: args as! FR.WorkflowInput)
            case .args(let extracted):
                guard let cast = extracted as? FR.WorkflowInput else { fatalError("TYPE MISMATCH: \(String(describing: args)) is not type: \(FR.WorkflowInput.self)") }
                instance = FR._factory(FR.self, with: cast)
            default: fatalError("No arguments were passed to representable: \(FR.self), but it expected: \(FR.WorkflowInput.self)")
        }
        super.init(&instance)
        setViewOnModel = { [weak self] in
            self?.model?.body = AnyView(instance)
        }
    }

    func changeUnderlyingView<V: View>(to view: V) {
        setViewOnModel = { [weak self] in
            self?.model?.body = AnyView(view)
        }
    }
}

public final class WorkflowItem<F: FlowRepresentable & View> {
    
    public var metadata: FlowRepresentableMetadata
    var modifierClosure: ((AnyFlowRepresentableView) -> Void)?
    var flowPersistence: (AnyWorkflow.PassedArgs) -> FlowPersistence = { _ in .default }

    public init(_: F.Type) {
        // set self so I can reference self for the factory
        metadata = FlowRepresentableMetadata(F.self) { _ in .default }
        metadata = FlowRepresentableMetadata(F.self,
                                             flowPersistence: flowPersistence,
                                             factory: factory)
    }

    public func launchStyle(_ style: LaunchStyle) -> Self {
        metadata = FlowRepresentableMetadata(F.self,
                                             launchStyle: style,
                                             flowPersistence: flowPersistence,
                                             factory: factory)

        return self
    }

    // MARK: AFTER MMP not right now but let's play it out
    public func presentationType(_ style: LaunchStyle) -> Self { self }

    // MARK: Modifier code (TT suggestion)
    public typealias Viewy<V: View> = (F) -> V
    public func applyModifiers<V: View>(@ViewBuilder _ closure: @escaping Viewy<V>) -> Self {
        modifierClosure = {
            let f = $0.underlyingInstance as! F
            let modified = closure(f)
            $0.changeUnderlyingView(to: modified)
        }

        return self
    }

    private func factory(args: AnyWorkflow.PassedArgs) -> AnyFlowRepresentable {
        let afrv = AnyFlowRepresentableView(viewType: F.self, args: args)

        if let closure = self.modifierClosure {
            closure(afrv)
        }

        return afrv
    }
}
// MARK: Persistence extensions
extension WorkflowItem where F.WorkflowInput == Never {
    public func persistence(_ persistence: @escaping @autoclosure () -> FlowPersistence) -> Self {
        flowPersistence = { _ in persistence() }

        return self
    }
}
extension WorkflowItem  {
    public func persistence(_ persistence: @escaping (F.WorkflowInput) -> FlowPersistence) -> Self where F.WorkflowInput == AnyWorkflow.PassedArgs {
        flowPersistence = { persistence($0) }

        return self
    }

    public func persistence(_ persistence: FlowPersistence) -> Self {
        flowPersistence = { _ in persistence }

        return self
    }

    public func persistence(_ persistence: @escaping (F.WorkflowInput) -> FlowPersistence) -> Self {
        flowPersistence = { args in
            guard case.args(let extracted) = args,
                  let cast = extracted as? F.WorkflowInput else { fatalError("\(args) did not match expected Input type: \(F.WorkflowInput.self)") }
            return persistence(cast)
        }

        return self
    }
}

struct ViewDidLoadModifier: ViewModifier {
    @State private var didLoad = false
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}

extension View {
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
}

public struct WorkflowView: View {
    @Binding public var isPresented: Bool
    #warning("This is a timebomb, but StateObject and State both failed us")
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-stateobject-to-create-and-monitor-external-objects
    // says Weimer is right, here's a workaround
    @StateObject private var model = WorkflowViewModel()
    @State private var workflow: AnyWorkflow?
    @State private var launchStyle = LaunchStyle.default
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()
    @State private var args: AnyWorkflow.PassedArgs = .none

    public var body: some View {
        if isPresented {
            VStack {
                if true {
                    model.body
                }
            }.onLoad {
                model.workflow = workflow
                model.launchStyle = launchStyle
                model.onFinish = onFinish
                model.onAbandon = onAbandon
                model.args = args
                model.workflow?.launch(withOrchestrationResponder: model,
                                                 passedArgs: model.args,
                                                 launchStyle: model.launchStyle,
                                                 onFinish: { args in model.onFinish.forEach { $0(args) } })
            }
        }
    }

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    // We could name args something more explicit to convey that it is the values the workflow is starting with... Possible name: thisWillBePassedToFirstFlowRepresentable
    public init(isPresented: Binding<Bool>, args: Any?) {
        self._isPresented = isPresented
        _args = State(initialValue: .args(args))
    }

    private init(isPresented: Binding<Bool>,
                 workflow: AnyWorkflow?,
                 launchStyle: LaunchStyle,
                 onFinish: [(AnyWorkflow.PassedArgs) -> Void],
                 onAbandon: [() -> Void],
                 args: AnyWorkflow.PassedArgs) {
        self._isPresented = isPresented
        self._workflow = State(initialValue: workflow)
        self._launchStyle = State(initialValue: launchStyle)
        self._onFinish = State(initialValue: onFinish)
        self._onAbandon = State(initialValue: onAbandon)
        self._args = State(initialValue: args)
    }

    func thenProceed<FR: FlowRepresentable & View>(with content: WorkflowItem<FR>) -> Self { // This has some sort of type information at this point so that the user can be forced to do the right thing with adding the right type for Input/Output
        var workflow = self.workflow
        if workflow == nil {
            let typedWorkflow = Workflow<FR>(content.metadata)
            workflow = AnyWorkflow(typedWorkflow)
        } else {
            workflow?.append(content.metadata)
        }

        return WorkflowView(isPresented: $isPresented,
                            workflow: workflow,
                            launchStyle: launchStyle,
                            onFinish: onFinish,
                            onAbandon: onAbandon,
                            args: args)
    }

    func onFinish(_ closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish
        onFinish.append(closure)
        return WorkflowView(isPresented: $isPresented,
                            workflow: workflow,
                            launchStyle: launchStyle,
                            onFinish: onFinish,
                            onAbandon: onAbandon,
                            args: args)
    }
    func onAbandon(_ closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return WorkflowView(isPresented: $isPresented,
                            workflow: workflow,
                            launchStyle: launchStyle,
                            onFinish: onFinish,
                            onAbandon: onAbandon,
                            args: args)
    }
    func launchStyle(_ style: LaunchStyle) -> Self {
        var launchStyle = self.launchStyle
        launchStyle = style
        return WorkflowView(isPresented: $isPresented,
                            workflow: workflow,
                            launchStyle: launchStyle,
                            onFinish: onFinish,
                            onAbandon: onAbandon,
                            args: args)
    }
}

extension WorkflowView {
    fileprivate class WorkflowViewModel: ObservableObject {
        @Published var body = AnyView(EmptyView())
        var workflow: AnyWorkflow?
        var launchStyle = LaunchStyle.default
        var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
        var onAbandon = [() -> Void]()
        var args: AnyWorkflow.PassedArgs = .none
    }
}

extension WorkflowView.WorkflowViewModel: OrchestrationResponder {
    func launch(to: AnyWorkflow.Element) {
        guard let afvr = to.value.instance as? AnyFlowRepresentableView else {
            fatalError("instance was not AnyFlowRepresentableView")
        }

        afvr.model = self
    }

    func proceed(to: AnyWorkflow.Element, from: AnyWorkflow.Element) {
        guard let afvr = to.value.instance as? AnyFlowRepresentableView else {
            fatalError("instance was not AnyFlowRepresentableView")
        }

        afvr.model = self
    }

    func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) {
        guard let afvr = to.value.instance as? AnyFlowRepresentableView else {
            fatalError("instance was not AnyFlowRepresentableView")
        }

        afvr.model = self
    }
    func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {
        withAnimation {
            body = AnyView(EmptyView())
            onAbandon.forEach { $0() }
            onFinish?()
        }
    }
    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        withAnimation {
            body = AnyView(EmptyView())
            onFinish?(passedArgs)
        }
    }
}

extension FlowRepresentable where Self: View {
    public var _workflowUnderlyingInstance: Any {
        get {
            self
        }
    }
}
