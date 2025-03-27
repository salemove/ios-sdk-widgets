@testable import GliaWidgets
import XCTest

final class TranscriptModelMigrateTests: XCTestCase {
    func test_migrateCallsStartsSocketObservationAndFetchesSiteConfiguration() {
        typealias TranscriptModel = SecureConversations.TranscriptModel
        typealias FileUploadListViewModel = SecureConversations.FileUploadListViewModel
        enum Call {
            case fetchSiteConfigurations
            case startSocketObservation
        }
        var calls: [Call] = []
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { _ in }
        modelEnv.fetchSiteConfigurations = { _ in
            calls.append(.fetchSiteConfigurations)
        }
        modelEnv.maximumUploads = { 2 }
        modelEnv.startSocketObservation = { calls.append(.startSocketObservation) }

        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let interactor: Interactor = .failing

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            interactor: interactor
        )

        viewModel.migrate(from: .mock())
        XCTAssertEqual(calls, [.startSocketObservation, .fetchSiteConfigurations])
    }
}
