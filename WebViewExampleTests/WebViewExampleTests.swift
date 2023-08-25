import XCTest
import ViewInspector
import SwiftUI
import WebKit

@testable import WebViewExample

final class WebViewExampleTests: XCTestCase {
 
  @MainActor
  func test_WebViewでHTMLの読み込みが終わるまで待機する() async throws {
    
    let exp = XCTestExpectation(description: "didAppear")
    let param = Param()
    param.exception = { message in
      XCTAssertEqual(message, "complete")
      exp.fulfill()
    }
    
    let sut = ContentView()
    ViewHosting.host(view: sut
      .environmentObject(param)
    )
    await fulfillment(of: [exp], timeout: 10)
  }
}
