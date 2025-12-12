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

    public func getQuickReplyContext(
        completion: @escaping (Result<QuickReplyContext, ContextingAPIError>) -> Void
    ) {
        let payloads = screenStorage.getAllPayloads()

        guard !payloads.isEmpty else {
            completion(.failure(.invalidConfiguration))
            return
        }

        let contextJSON = payloads.compactMap { String(data: $0, encoding: .utf8) }.joined(separator: ",\n")

        let enrichedPrompt = quickReplyPrompt(data: contextJSON)

        print("📤 Sending quick reply contexting request:")
        print("Context: \(payloads.count) screen(s)")
        print("\n--- Full Payload ---")
        print(enrichedPrompt)
        print("--- End Payload ---\n")

        apiClient.sendContextingRequest(prompt: enrichedPrompt) { result in
            switch result {
            case .success(let rawResponse):
                print("✅ Received quick reply response from API")
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
                    let context = try decoder.decode(QuickReplyContext.self, from: jsonData)
                    print("✅ Successfully parsed QuickReplyContext:")
                    print("  - Quick Replies Count: \(context.quickReplies.count)")
                    context.quickReplies.forEach { reply in
                        print("    • \(reply.text) (value: \(reply.value))")
                    }
                    completion(.success(context))
                } catch {
                    print("❌ Failed to decode QuickReplyContext: \(error)")
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

    func quickReplyPrompt(data: String) -> String {
        """
        You are a customer support assistant AI. Analyze the provided screen context data from a user's mobile app session to generate a conversational opening message and relevant quick reply options.

                INPUT DATA FORMAT:
                You will receive a list of ScreenTextData objects containing:
                - screenName: The screen identifier
                - timestamp: Unix timestamp in milliseconds
                - texts: Array of all text content from that screen (UI labels, buttons, fields, user content)
                - screenType: Type of screen event

                TASK:
                1. Analyze the user's current context.
                2. Generate a single, human-like opening **message** inviting the user to ask for help.
                3. Generate 3-4 **quick reply options**.

                CATEGORIZATION LOGIC (CRITICAL):
                - **Generalize specific merchants:** If the user sees charges from specific merchants (e.g., "Netflix", "Uber", "Amazon"), do NOT use the merchant name in the topic label or the user message. Map them to categories (e.g., "Subscriptions", "Transport", "Online Shopping").
                - **Generalize specific dates/amounts:** Do not mention specific dollar amounts or dates.
                - **Focus on Product Types:** Use standard banking product names (e.g., "Credit Card", "Savings", "Mortgage").

                QUICK REPLY GUIDELINES:
                Each option must have three components:
                1. **text**: The button label. Must be a short Noun/Topic (1-3 words, Title Case). E.g., "Subscriptions".
                2. **value**: Backend tag. E.g., "subscriptions".
                3. **message**: The actual sentence the user would "say" to start the chat. This should be a natural, first-person sentence. E.g., "I want to see a list of my recurring subscriptions."

                OUTPUT FORMAT:
                Return ONLY a JSON object.
                
                Example structure:
                {
                  "quickReplies": [
                    {
                      "text": "Subscriptions",
                      "value": "subscriptions",
                      "message": "I would like to review my recurring subscriptions."
                    },
                    {
                      "text": "Dispute Charge",
                      "value": "dispute_charge",
                      "message": "I need to dispute a transaction I don't recognize."
                    },
                    {
                      "text": "Spending Analysis",
                      "value": "spending_analysis",
                      "message": "Can you show me a breakdown of my spending this month?"
                    }
                  ]
                }

                IMPORTANT:
                - Return only the JSON object, no explanations, no ```json ``` statements.
                - Ensure "text" remains a short topic, while "message" is a full sentence.

                SCREEN DATA:
                \(data)
        """
    }
}
