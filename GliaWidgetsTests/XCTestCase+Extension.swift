import XCTest

extension XCTestCase {
    func waitUntil(
        timeout: TimeInterval = 1.0,
        pollInterval: TimeInterval = 0.01,
        file: StaticString = #file,
        line: UInt = #line,
        _ condition: @escaping () -> Bool
    ) async {
        let timeoutNano = UInt64(timeout * 1_000_000_000)
        let pollNano = UInt64(pollInterval * 1_000_000_000)
        let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNano
        while !condition() && DispatchTime.now().uptimeNanoseconds < deadline {
            try? await Task.sleep(nanoseconds: pollNano)
        }
        if !condition() {
            XCTFail("waitUntil: Condition not met within \(timeout)s", file: file, line: line)
        }
    }
}
