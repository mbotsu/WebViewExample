import SwiftUI

@main
struct WebViewExampleApp: App {
  @ObservedObject var param = Param()
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(param)
    }
  }
}

class Param: ObservableObject {
  @Published var exception: (String) -> Void = { _ in }
}

func isRunningTests() -> Bool {
  let env: [String: String] = ProcessInfo.processInfo.environment
  return env["XCInjectBundleInto"] != nil
}
