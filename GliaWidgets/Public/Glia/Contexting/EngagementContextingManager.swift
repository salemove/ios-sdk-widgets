import Foundation

public class EngagementContextingManager {
    public static let shared = EngagementContextingManager()

    private let screenStorage: ScreenStorage
    private let apiClient: ContextingAPIClient

    private init(
        screenStorage: ScreenStorage = .shared,
        apiClient: ContextingAPIClient = .shared
    ) {
        self.screenStorage = screenStorage
        self.apiClient = apiClient
    }

    public func getEngagementContext(
        completion: @escaping (Result<EngagementContext, ContextingAPIError>) -> Void
    ) {
        let payloads = screenStorage.getAllPayloads()

        guard !payloads.isEmpty else {
            completion(.failure(.invalidConfiguration))
            return
        }

        let contextJSON = payloads.compactMap { String(data: $0, encoding: .utf8) }.joined(separator: ",\n")

        let enrichedPrompt = prompt(data: contextJSON)

        print("📤 Sending contexting request:")
        print("Context: \(payloads.count) screen(s)")
        print("\n--- Full Payload ---")
        print(enrichedPrompt)
        print("--- End Payload ---\n")

        apiClient.sendContextingRequest(prompt: enrichedPrompt) { result in
            switch result {
            case .success(let rawResponse):
                print("✅ Received response from API")
                print("Response: \(rawResponse)")

                let cleanedJSON = self.extractJSON(from: rawResponse)
                print("Cleaned JSON: \(cleanedJSON)")

                guard let jsonData = cleanedJSON.data(using: .utf8) else {
                    print("❌ Failed to convert response to Data")
                    completion(.failure(.serverError))
                    return
                }

                let decoder = JSONDecoder()
                do {
                    let context = try decoder.decode(EngagementContext.self, from: jsonData)
                    print("✅ Successfully parsed EngagementContext:")
                    print("  - Loans: \(context.loans)%")
                    print("  - Accounts: \(context.accounts)%")
                    print("  - Insurance: \(context.insurance)%")
                    print("  - Transactions: \(context.transactions)%")
                    print("  - Overview: \(context.overview)")
                    completion(.success(context))
                } catch {
                    print("❌ Failed to decode EngagementContext: \(error)")
                    completion(.failure(.serverError))
                }

            case .failure(let error):
                print("❌ API request failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    public func getCollectedScreensCount() -> Int {
        return screenStorage.getAllPayloads().count
    }

    public func clearScreenHistory() {
        // This would need to be added to ScreenStorage
    }
}

private extension EngagementContextingManager {
    func extractJSON(from response: String) -> String {
        var cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleaned.hasPrefix("```json") {
            cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        }
        if cleaned.hasPrefix("```") {
            cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func prompt(data: String) -> String {
        """
        You are a financial app behavior analyst. Analyze the provided Android screen data to determine user interest in specific financial topics.

        INPUT DATA FORMAT:
        You will receive a list of ScreenTextData objects containing:
        - screenName: The screen identifier
        - timestamp: Unix timestamp in milliseconds
        - texts: Array of all text content from that screen (UI labels, buttons, fields, user content)
        - screenType: Type of screen event
        - contentHash: Unique identifier for screen content

        TASK 1:
            Analyze the screen data to determine the user's interest level in each of the following topics:
            1. Loans
            2. Accounts
            3. Insurance
            4. Transactions

            ANALYSIS CRITERIA:
            Consider ALL of the following factors:
            - Frequency: How often screens related to a topic appear
            - Time spent: Duration between timestamps on topic-related screens
            - Engagement depth: Variety and detail of content viewed for each topic
            - Content relevance: Keywords, phrases, and context indicating topic interest

            SCORING GUIDELINES:
            - 0-20: Minimal or no evidence of interest
            - 21-40: Low interest (brief exposure or incidental viewing)
            - 41-60: Moderate interest (some engagement or exploration)
            - 61-80: High interest (significant time/frequency or active exploration)
            - 81-100: Very high interest (extensive engagement, multiple visits, detailed exploration)

        TASK 2:
            Create a 1-2 sentence overview describing what the visitor did in the app.

            ANALYSIS GUIDELINES:
            1. Identify main areas of focus from these categories based on screen content:
               - Loans
               - Accounts
               - Insurance
               - Transactions
               - General (for screens that don't fit the above categories, including demo/test screens)

            2. Use relative time indicators:
               - "spent significant time on..." (multiple screens or long duration)
               - "briefly looked at..." (quick visit)
               - "explored..." (moderate engagement)
               - "was switching back and forth between..." (repetitive visits to same screens)

            3. Focus on the journey's main areas, not strict chronological order

            4. Use casual, conversational tone (e.g., "The visitor checked out...", "They spent time...")

            SPECIAL CASES:
            - Very short sessions (1-2 screens): Say "The visitor spent very little time in the app" and name the specific areas viewed
            - Repetitive behavior: Mention total time and note they were "switching back and forth"
            - Ignore non-content screens (navigation, menus) unless they're the only activity

        
        OUTPUT FORMAT:
        Return ONLY a JSON object with probabilities (0-100) for each topic. Probabilities are independent and do NOT need to sum to 100.

        
        IMPORTANT:
        - Base scores on evidence in the data only
        - Multiple high scores are acceptable if data supports it
        - Return only the JSON object, no explanations, no ```json ``` statements, or additional text, just raw JSON
        Example output:
        {
        "loans": 75,
        "accounts": 85,
        "insurance": 30,
        "transactions": 60
        "overview": "The visitor spent significant time exploring their accounts and transactions, while also checking out loan options."
        }

        SCREEN DATA:
        \(data)
        """
    }
}
