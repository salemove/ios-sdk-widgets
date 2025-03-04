import XCTest
import Combine
@testable import GliaWidgets

final class SchedulerTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    func testImmediateSchedulerRunsSynchronously() {
        let scheduler = ImmediateScheduler()
        var flag = false
        scheduler.schedule(options: nil) {
            flag = true
        }
        XCTAssertTrue(flag, "ImmediateScheduler should execute its action immediately.")
    }

    func testAnyCombineSchedulerImmediateDelay() {
        let scheduler = AnyCombineScheduler.mock
        let expectation = self.expectation(description: "Immediate scheduler delivers value immediately")
        var received = false
        Just("test")
            .delay(for: .seconds(1), scheduler: scheduler.main)
            .sink { _ in
                received = true
                expectation.fulfill()
            }
            .store(in: &cancellables)

        XCTAssertTrue(received, "Immediate scheduler should deliver the value immediately without waiting.")
        wait(for: [expectation], timeout: 0.1)
    }

    func testAnyCombineSchedulerLiveDelay() {
        let scheduler = AnyCombineScheduler.live

        let expectation = self.expectation(description: "Live scheduler delivers value asynchronously")

        var received = false

        Just("test")
            .delay(for: .milliseconds(50), scheduler: scheduler.global)
            .sink { _ in
                received = true
                expectation.fulfill()
            }
            .store(in: &cancellables)

        XCTAssertFalse(received, "Live scheduler should not deliver the value immediately.")
        wait(for: [expectation], timeout: 0.2)
        XCTAssertTrue(received, "Live scheduler should eventually deliver the value.")
    }
}
