//
//  ScreenStorage.swift
//  Pods
//
//  Created by Yevhen Kyivskyi on 30/10/2025.
//

class ScreenStorage {
    static let shared = ScreenStorage()

    // Array of screen sessions (each visit to a screen is a session)
    private var sessions: [LLMContextPayload] = []

    private let maxSessions = 5
    private let maxCapturesPerSession = 10

    /// Adds or updates context based on whether we're in the same session or starting a new one.
    func addOrUpdateContext(
        screenName: String,
        scrollOffset: CGFloat?,
        content: [Element],
        timestamp: String,
        timeSpent: Int?
    ) {
        // Check if we're continuing the last session (same screen name)
        if let lastSession = sessions.last,
           lastSession.screenName == screenName {
            // Same screen - append capture if scroll view exists
            // Do NOT update time_spent_in_seconds (only set when leaving screen)

            if let offset = scrollOffset,
               var captures = lastSession.capturedOffsets {

                // Deduplicate: check if offset already exists
                if captures.contains(where: { $0.offset == offset }) {
                    return
                }

                // Check capture limit
                if captures.count >= maxCapturesPerSession {
                    captures.removeFirst()
                }

                // Append new capture
                captures.append(OffsetCapture(offset: offset, content: content.map { $0.text }))

                // Update last session (keep time_spent_in_seconds as nil - only set when leaving)
                let updatedSession = LLMContextPayload(
                    screenName: screenName,
                    timestamp: lastSession.timestamp,  // Keep original timestamp
                    time_spent_in_seconds: nil,  // Keep as nil until user leaves this screen
                    content: nil,
                    capturedOffsets: captures
                )
                sessions[sessions.count - 1] = updatedSession
            }
            // If no scroll offset, nothing to update (simple screens don't accumulate)

        } else {
            // Different screen - new session
            // First, finalize the previous session's time_spent_in_seconds
            if sessions.count > 0 {
                let previousIndex = sessions.count - 1
                let previousSession = sessions[previousIndex]

                // Update the previous session with the final time spent
                let finalizedSession = LLMContextPayload(
                    screenName: previousSession.screenName,
                    timestamp: previousSession.timestamp,
                    time_spent_in_seconds: timeSpent,  // Set the time for the PREVIOUS screen
                    content: previousSession.content,
                    capturedOffsets: previousSession.capturedOffsets
                )
                sessions[previousIndex] = finalizedSession
            }
            // Now create the new session (with time_spent_in_seconds as nil)
            let newSession: LLMContextPayload

            if let offset = scrollOffset {
                // Has scroll view
                newSession = LLMContextPayload(
                    screenName: screenName,
                    timestamp: timestamp,
                    time_spent_in_seconds: nil,  // Nil until user leaves this screen
                    content: nil,
                    capturedOffsets: [OffsetCapture(offset: offset, content: content.map { $0.text })]
                )
            } else {
                // No scroll view
                newSession = LLMContextPayload(
                    screenName: screenName,
                    timestamp: timestamp,
                    time_spent_in_seconds: nil,  // Nil until user leaves this screen
                    content: content.map { $0.text },
                    capturedOffsets: nil
                )
            }

            sessions.append(newSession)

            // Limit total sessions
            if sessions.count > maxSessions {
                sessions.removeFirst()
            }
        }
    }

    /// Returns all sessions as JSON Data array
    func getAllPayloads() -> [Data] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        return sessions.compactMap { session in
            try? encoder.encode(session)
        }
    }
}
