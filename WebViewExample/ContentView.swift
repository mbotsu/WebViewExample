import SwiftUI
import UIKit
import WebKit

struct ContentView: View {
  var body: some View {
    VStack {
      WebUIViewController()
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct WebUIViewController: UIViewControllerRepresentable {
  typealias UIViewControllerType = UIViewController
  @EnvironmentObject var param: Param
  let htmlFileName = "index"
  let onError: (WebViewError) -> Void = { error in
    print("\(error.message)")
  }
  
  func makeUIViewController(context: Context) -> UIViewController {
    let config = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = context.coordinator
    webView.load(htmlFileName, onError: onError)
    let view = UIViewController()
    view.view = webView
    return view
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, WKNavigationDelegate {
    var parent: WebUIViewController
    init(_ parent: WebUIViewController) {
      self.parent = parent
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      if isRunningTests() {
        parent.param.exception("complete")
      }
    }
  }
}

extension WKWebView {
  func load(_ htmlFileName: String, onError: (WebViewError) -> Void){
    guard !htmlFileName.isEmpty else {
      return onError(.emptyFileName)
    }
    guard let filePath = Bundle.main.path(forResource: htmlFileName, ofType: "html") else {
      return onError(.inivalidFilePath)
    }
    do {
      let htmlString = try String(contentsOfFile: filePath, encoding: .utf8)
      self.loadHTMLString(htmlString, baseURL: URL(fileURLWithPath: filePath))
    } catch let error {
      onError(.contentConversion(error.localizedDescription))
    }
  }
}

enum WebViewError: Error {
  case contentConversion(String)
  case emptyFileName
  case inivalidFilePath
  
  var message: String {
    switch self {
    case let .contentConversion(message):
      return "There was an error converting the file path to an HTML String. Error \(message)"
    case .emptyFileName:
      return "The file name was empty."
    case .inivalidFilePath:
      return "The file path is invalid."
    }
  }
}
