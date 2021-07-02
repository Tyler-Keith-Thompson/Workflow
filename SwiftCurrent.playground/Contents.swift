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

    func thenProceed<Content: View>(with wi: Content) -> Self { // This has some sort of type information at this point so that the user can be forced to do the right thing with adding the right type for Input/Output
        return self
    }

    func onFinish(_ closure: (Any) -> Void) -> Self { self }// maybe adds to something on the VM
    func onAbandon(_ closure: () -> Void) -> Self { self }// maybe adds to something on the VM [abandon1, abandon2](maybe)
    func launchStyle(_ style: LaunchStyle) -> Self { self }
}

extension ModifiedContent: FlowRepresentable where Content: FlowRepresentable{
    typealias Input = Content.Input
}

struct WorkflowItem: View {
    var body: some View { EmptyView() }
    var metadata: FlowRepresentableMetadata

    init<FR: FlowRepresentable>(_: FR.Type) {
        metadata = FlowRepresentableMetadata(FR.self)
    }

    func launchStyle(_ style: LaunchStyle) -> Self { self } // update metadata here
    func presentationType(_ presentation: PresentationType) -> Self { self } // update metadata here
    func persistence(_ persistence: Persistence) -> Self { self } // update metadata here
}

// for here not for prod
extension WorkflowItem: FlowRepresentable {
    typealias Input = Never
}

enum LaunchStyle {
    case modal
}
enum PresentationType { case navigationStack }
enum Persistence { case removedAfterProceeding }
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
struct FR2: FlowRepresentable { typealias Input = Never }
struct FR3: FlowRepresentable { typealias Input = Never }
struct TestView: View {
    @State var showWorkflow = false
    var body: some View {
        // Testing View
        WorkflowView(isPresented: $showWorkflow)
            .launchStyle(.modal)
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR1.self).launchStyle(.modal))
            .thenProceed(with: WorkflowItem(FR1.self).padding())
            .thenProceed(with: Text("This is not right"))
            .onFinish { args in print("Completed with \(args)") }
            .onAbandon { print("Abandoned") }
            .padding()
            .onAppear()

        // Example View
        WorkflowView(isPresented: $showWorkflow)
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self)
                                      .launchStyle(.modal)
                                      .presentationType(.navigationStack)
                                      .persistence(.removedAfterProceeding)
                                      .padding(10)
                                      .transition(.opacity))
                .thenProceed(with: WorkflowItem(FR3.self))
                .launchStyle(.modal) // launch style of WorkflowView, could be moved to the top, depends on consumer
                .onAbandon {
                    showWorkflow = false
                }
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
