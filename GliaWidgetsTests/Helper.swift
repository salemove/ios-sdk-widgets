import XCTest

func fail(_ failingFuncName: String, file: StaticString = #filePath, line: UInt = #line) {
    XCTFail("\(failingFuncName) - A failing environment function is invoked.", file: file, line: line)
}
