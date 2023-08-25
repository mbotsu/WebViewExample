import SwiftUI
import UIKit
import WebKit

struct ContentView: View {
  var didAppear: ((Self) -> Void)?
  var body: some View {
    VStack {
      WebUIViewControllerRepresentable()
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct WebUIViewControllerRepresentable: UIViewControllerRepresentable {
  typealias UIViewControllerType = WebUIViewController
  @EnvironmentObject var param: Param
  
  func makeUIViewController(context: Context) -> WebUIViewController {
    return WebUIViewController(self)
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class WebUIViewController: UIViewController {
  var viewcController: WebUIViewControllerRepresentable
  var webView: WKWebView!
  var coordinator: WebViewDelegate!
  
  init(_ viewcController: WebUIViewControllerRepresentable) {
    self.viewcController = viewcController
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let config = WKWebViewConfiguration()
    coordinator = WebViewDelegate(viewcController)
    
    let htmlFileName = "index"
    let onError: (WebViewError) -> Void = { error in
      print("\(error.message)")
    }
    
    webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = coordinator
    webView.load(htmlFileName, onError: onError)
    self.view = self.webView
  }
}

class WebViewDelegate: NSObject, WKNavigationDelegate {
  var parent: WebUIViewControllerRepresentable
  init(_ parent: WebUIViewControllerRepresentable) {
    self.parent = parent
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if isRunningTests() {
      parent.param.exception("complete")
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
