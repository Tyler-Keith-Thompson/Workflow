import SwiftUI
print("Starting")
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

 Erase everything to start, then after it is working, start getting everything back to types

 Start with the API and then get it to actually do it correctly
 */

struct WorkflowView: View {
    @Binding var isPresented: Bool
    var body: some View { EmptyView() }
//    @State var anyWorkflow: AnyWorkflow?

    func thenProceed<Content: View & FlowRepresentable>(with wi: Content) -> WorkflowView { // This has some sort of type information at this point so that the user can be forced to do the right thing with adding the right type for Input/Output
//        anyWorkflow?.append(metadata: wi.metadata)
        return self
    }

    func onAbandon(_ closure: () -> Void) -> some View { self }// maybe goes on the VM
}
extension View where Body == WorkflowView {
    func onAbandon(_ closure: () -> Void) -> some View { self } // maybe goes on the VM
}
extension ModifiedContent: FlowRepresentable where Content: FlowRepresentable{
    typealias Input = Content.Input
}

struct WorkflowItem: View {
    var body: some View { EmptyView() }
//    var underlyingThing1: AnyWorkflow
//    var undleryingThing2: AnyFlowRepresentable
    var metadata: FlowRepresentableMetadata

    init<FR: FlowRepresentable>(_: FR.Type) {
//        underlyingThing1 = AnyWorkflow(Workflow<FR>())
//        underlyingThing2 = AnyFlowRepresentable(FR())
        metadata = FlowRepresentableMetadata(FR.self)
    }
}

// for here not for prod
extension WorkflowItem: FlowRepresentable {
    typealias Input = Never
}

protocol FlowRepresentable {
    associatedtype Input
}
class FlowRepresentableMetadata {
    init<FR: FlowRepresentable>(_ type: FR.Type) { }
}

class Workflow<F: FlowRepresentable> {}
class AnyWorkflow {
    init<F: FlowRepresentable>(_ workflow: Workflow<F>) {}
    func append(metadata: FlowRepresentableMetadata) { }
}

struct FR1: FlowRepresentable { typealias Input = Never }



struct TestView: View {
    @State var showWorkflow = false
    var body: some View {
        WorkflowView(isPresented: $showWorkflow)
            .thenProceed(with: WorkflowItem(FR1.self)
//                            .padding()
            )
            .onAbandon { print("Abandoned") }
            .padding()
            .onAppear()
    }
}

print("\(WorkflowItem(FR1.self).padding())")

print("RAN \(Date())")
//print("\(Text("Foo"))\n\n")
//print("\(Text("Foo").padding())\n\n")
//print("\(Text("Foo").padding().frame(width: 100, height: 200, alignment: .bottom))\n\n")
//
//print("\(Text("Foo").padding().frame(width: 100, height: 200, alignment: .bottom).printBodyType())\n\n")
//
//print("\(Text("Foo").background(Color.red).frame(width: 100, height: 200, alignment: .bottom).background(Color.blue))\n\n")
//print("\(Text("Foo").frame(width: 100, height: 200, alignment: .bottom).background(Color.red).background(Color.blue))\n\n")
//
//extension View {
//    func printBodyType() {
//        print("Body type: \(Body.self)")
//    }
//}
