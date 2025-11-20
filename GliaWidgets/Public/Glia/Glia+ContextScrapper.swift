import Vision

extension Glia {
    /// Starts context scraping using OCR (screenshot-based).
    /// Works universally with both UIKit and SwiftUI apps.
    /// Note: All elements will have type `.label` as OCR cannot determine element types.
    func startScrappingContextWithOCR() {
        // Check if already running to avoid redundant setup
        guard !OCR.ScreenTextExtractor.shared.isRunning else {
            print("--- Scrapping already running with OCR, skipping start ---")
            return
        }

        OCR.ScreenTextExtractor.shared.start()

        let builder = ScreenContextBuilder()
        OCR.ScreenTextExtractor.shared.onScreenDataAvailable = { screenName, scrollOffset, elements, previousScreenTimeSpent in
            // Process elements into content lines
            let contentLines = builder.groupElementsIntoLines(elements)

            // Get current timestamp
            let timestamp = builder.getCurrentTimestamp()

            // Use the previousScreenTimeSpent passed from the tracker
            // (this is the time spent on the PREVIOUS screen before transitioning to current screen)

            // Add or update the session in storage
            ScreenStorage.shared.addOrUpdateContext(
                screenName: screenName,
                scrollOffset: scrollOffset,
                content: contentLines,
                timestamp: timestamp,
                timeSpent: previousScreenTimeSpent
            )

            // Print all current sessions
            let allPayloads = ScreenStorage.shared.getAllPayloads()

            print("--- Current Screen Sessions (OCR) ---")
            print("[")
            for payload in allPayloads {
                if payload != allPayloads.last {
                    print("\(self.prettyPrint(data: payload)!),")
                } else {
                    print("\(self.prettyPrint(data: payload)!)")
                }
            }
            print("]")
            print("--------------------")
        }
        print("--- Scrapping started with OCR ---")
    }

    func stopScrappingContextWithOCR() {
        print("--- Scrapping stopped with OCR ---")
        OCR.ScreenTextExtractor.shared.stop()
    }

    func prettyPrint(data: Data) -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }

        guard let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) else {
            return nil
        }
        return String(data: prettyData, encoding: .utf8)
    }
}
