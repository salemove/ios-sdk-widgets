//
//  OCR.swift
//  GliaWidgets
//
//  Created by Yevhen Kyivskyi on 27/10/2025.
//

import Foundation
import Vision

enum OCR {
    public class ScreenTextExtractor {

        /// Shared singleton instance.
        public static let shared = ScreenTextExtractor()

        /// The tracker instance that detects screen changes.
        private let screenTracker = ScreenChangeTracker.shared

        /// A private, serial dispatch queue to run all expensive
        /// screenshot and OCR work off the main thread.
        private let ocrQueue = DispatchQueue(
            label: "com.sdk.screenExtractorQueue",
            qos: .userInitiated
        )

        /// A callback closure that is triggered when new screen data is available.
        /// Parameters:
        /// - screenName: The class name of the visible view controller
        /// - scrollOffset: The Y-axis scroll offset (nil if no scroll view exists)
        /// - elements: Array of `ScreenTextElement` found on the screen via OCR
        /// - previousScreenTimeSpent: Time spent on the PREVIOUS screen in seconds (nil if scroll event on same screen)
        public var onScreenDataAvailable: ((String, CGFloat?, [ScreenTextElement], Int?) -> Void)?

        /// The current running state.
        public private(set) var isRunning: Bool = false

        private init() {}

        /// Starts the screen extraction process.
        ///
        /// This configures and starts the underlying `ScreenChangeTracker`.
        public func start() {
            guard !isRunning else { return }

            // 1. Configure the screen tracker's callback.
            // This is the "trigger" for our screenshot/OCR pipeline.
            screenTracker.onScreenDidChange = { [weak self] screenName, scrollOffset, previousScreenTimeSpent in
                // When a change is detected, dispatch our expensive
                // work to the background queue.
                self?.processCurrentScreen(screenName: screenName, scrollOffset: scrollOffset, previousScreenTimeSpent: previousScreenTimeSpent)
            }

            // 2. Start the tracker.
            screenTracker.start()
            isRunning = true
        }

        /// Stops the screen extraction process.
        public func stop() {
            guard isRunning else { return }

            screenTracker.stop()
            isRunning = false
        }

        /// The core pipeline: Screenshot -> OCR -> Structurize.
        /// This is executed on the background `ocrQueue`.
        private func processCurrentScreen(screenName: String, scrollOffset: CGFloat?, previousScreenTimeSpent: Int?) {
            ocrQueue.async { [weak self] in
                guard let self = self else { return }

                // Step 1: Take Screenshot
                // This helper must run on the main thread, so we block
                // our background queue synchronously to get the image.
                var screenshot: UIImage?
                DispatchQueue.main.sync {
                    screenshot = self.takeScreenshot()
                }

                guard let imageToProcess = screenshot else {
                    return
                }

                // Step 2: Perform OCR on the captured image
                self.performOCR(on: imageToProcess) { result in
                    switch result {
                    case .success(let elements):
                        // Step 3: Send data back to the consumer on the main thread
                        DispatchQueue.main.async {
                            self.onScreenDataAvailable?(screenName, scrollOffset, elements, previousScreenTimeSpent)
                        }

                    case .failure:
                        break
                    }
                }
            }
        }

        /// Captures a `UIImage` of the application's key window.
        /// **Must be called on the main thread.**
        private func takeScreenshot() -> UIImage? {
            guard let window = screenTracker.getVisibleViewController()?.view.window else {
                return nil
            }

            let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
            let image = renderer.image { context in
                window.layer.render(in: context.cgContext)
            }

            return image
        }

        /// Runs the Vision framework's text recognition on a given image.
        /// This method is asynchronous and calls its completion handler.
        private func performOCR(on image: UIImage, completion: @escaping (Result<[ScreenTextElement], Error>) -> Void) {
            guard let cgImage = image.cgImage else {
                completion(.failure(ExtractorError.imageConversionFailed))
                return
            }

            // 1. Create the Vision text recognition request
            let request = VNRecognizeTextRequest { (request, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    // No text found is a success case with an empty array
                    completion(.success([]))
                    return
                }

                // 3. Process the results
                let screenElements = observations.compactMap { observation -> ScreenTextElement? in
                    // Get the most confident text candidate
                    guard let topCandidate = observation.topCandidates(1).first else {
                        return nil
                    }

                    // Convert Vision's normalized, bottom-left-origin
                    // rect to a standard UIKit (top-left-origin) rect.
                    let convertedFrame = self.convertVisionRect(observation.boundingBox)

                    // OCR cannot determine element type, default to .label
                    return ScreenTextElement(
                        text: topCandidate.string,
                        type: .label,
                        frame: convertedFrame
                    )
                }

                completion(.success(screenElements))
            }

            // Configure request for better accuracy.
            // Use .fast if performance becomes an issue.
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            // 2. Create a request handler and perform the request
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }

        /// Converts a Vision-normalized rect (bottom-left origin) to a
        /// UIKit-normalized rect (top-left origin).
        private func convertVisionRect(_ visionRect: CGRect) -> CGRect {
            return CGRect(
                x: visionRect.origin.x,
                y: 1.0 - visionRect.origin.y - visionRect.size.height,
                width: visionRect.size.width,
                height: visionRect.size.height
            )
        }

        enum ExtractorError: Error {
            case imageConversionFailed
        }
    }
}
