//
//  Implementation.swift
//  SwiftCurrentExample_SwiftUI
//
//  Created by Richard Gist on 7/2/21.
//

import SwiftUI
import SwiftCurrent

class AnyFlowRepresentableView: AnyFlowRepresentable {
    var setViewOnModel: () -> Void = { }
    fileprivate var model: WorkflowViewModel? {
        didSet {
            setViewOnModel()
        }
    }

    init<FR: FlowRepresentable & View>(viewType: FR.Type, args: AnyWorkflow.PassedArgs) {
        super.init(FR.self, args: args)
        guard let instance = underlyingInstance as? FR else { fatalError("Somehow we couldn't cast instance to itself: \(FR.self)") }

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
    public func applyModifiers<V: View>(@ViewBuilder _ closure: @escaping (F) -> V) -> Self {
        modifierClosure = {
            let f = $0.underlyingInstance as! F
            let modified = closure(f)
            $0.changeUnderlyingView(to: modified)
        }

        return self
    }

    private func factory(args: AnyWorkflow.PassedArgs) -> AnyFlowRepresentable {
        let afrv = AnyFlowRepresentableView(viewType: F.self, args: args)

        if let closure = modifierClosure {
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

public struct WorkflowView<A>: View {
    @Binding public var isPresented: Bool
    @StateObject private var model = WorkflowViewModel()
    @State private var workflow: AnyWorkflow?
    @State private var launchStyle = LaunchStyle.default
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()
    @State private var args: AnyWorkflow.PassedArgs = .none

    public var body: some View {
        if isPresented {
            VStack(spacing: 0) {
                if true { // maybe not needed?
                    model.body
                }
            }
            .onLoad {
                model.workflow = workflow
                model.launchStyle = launchStyle
                model.onFinish = onFinish
                model.onAbandon = onAbandon
                model.args = args
                model.isPresented = $isPresented
                model.workflow?.launch(withOrchestrationResponder: model,
                                       passedArgs: model.args,
                                       launchStyle: model.launchStyle,
                                       onFinish: { args in model.onFinish.forEach { $0(args) } })
            }
        }
    }

    public init(isPresented: Binding<Bool>) where A == Never {
        self._isPresented = isPresented
    }

    // We could name args something more explicit to convey that it is the values the workflow is starting with... Possible name: thisWillBePassedToFirstFlowRepresentable
    public init(isPresented: Binding<Bool>, args: A) {
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

    func onFinish(_ closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish // capturing this variable is required for things to work. :shrug:
        onFinish.append(closure)
        return WorkflowView(isPresented: $isPresented,
                            workflow: workflow,
                            launchStyle: launchStyle,
                            onFinish: onFinish,
                            onAbandon: onAbandon,
                            args: args)
    }
    func onAbandon(_ closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon // capturing this variable is required for things to work. :shrug:
        onAbandon.append(closure)
        return WorkflowView(isPresented: $isPresented,
                            workflow: workflow,
                            launchStyle: launchStyle,
                            onFinish: onFinish,
                            onAbandon: onAbandon,
                            args: args)
    }
    func launchStyle(_ style: LaunchStyle) -> Self {
        var launchStyle = self.launchStyle // capturing this variable is required for things to work. :shrug:
        launchStyle = style
        return WorkflowView(isPresented: $isPresented,
                            workflow: workflow,
                            launchStyle: launchStyle,
                            onFinish: onFinish,
                            onAbandon: onAbandon,
                            args: args)
    }
}

extension WorkflowView where A == Never {
    func thenProceed<FR: FlowRepresentable & View>(with content: WorkflowItem<FR>) -> WorkflowView<FR.WorkflowOutput> where FR.WorkflowInput == Never { // This has some sort of type information at this point so that the user can be forced to do the right thing with adding the right type for Input/Output
        var workflow = self.workflow // capturing this variable is required for things to work. :shrug:
        if workflow == nil {
            let typedWorkflow = Workflow<FR>(content.metadata)
            workflow = AnyWorkflow(typedWorkflow)
        } else {
            workflow?.append(content.metadata)
        }

        return WorkflowView<FR.WorkflowOutput>(isPresented: $isPresented,
                                               workflow: workflow,
                                               launchStyle: launchStyle,
                                               onFinish: onFinish,
                                               onAbandon: onAbandon,
                                               args: args)
    }
}

extension WorkflowView {
    func thenProceed<FR: FlowRepresentable & View>(with content: WorkflowItem<FR>) -> WorkflowView<FR.WorkflowOutput> where A == FR.WorkflowInput { // This has some sort of type information at this point so that the user can be forced to do the right thing with adding the right type for Input/Output
        var workflow = self.workflow // capturing this variable is required for things to work. :shrug:
        if workflow == nil {
            let typedWorkflow = Workflow<FR>(content.metadata)
            workflow = AnyWorkflow(typedWorkflow)
        } else {
            workflow?.append(content.metadata)
        }

        return WorkflowView<FR.WorkflowOutput>(isPresented: $isPresented,
                                               workflow: workflow,
                                               launchStyle: launchStyle,
                                               onFinish: onFinish,
                                               onAbandon: onAbandon,
                                               args: args)
    }
}

fileprivate class WorkflowViewModel: ObservableObject {
    @Published var body = AnyView(EmptyView())
    var isPresented: Binding<Bool>?
    var workflow: AnyWorkflow?
    var launchStyle = LaunchStyle.default
    var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    var onAbandon = [() -> Void]()
    var args: AnyWorkflow.PassedArgs = .none
}

extension WorkflowViewModel: OrchestrationResponder {
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
        isPresented?.wrappedValue.toggle()
        onAbandon.forEach { $0() }
        onFinish?()
    }
    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        onFinish?(passedArgs)
    }
}

extension Workflow {
    public func abandon() {
        AnyWorkflow(self).abandon()
    }
}

extension AnyWorkflow {
    public func abandon() {
        if let responder = orchestrationResponder {
            responder.abandon(self) { [weak self] in
                self?._abandon()
            }
        } else {
            _abandon()
        }
    }
}
