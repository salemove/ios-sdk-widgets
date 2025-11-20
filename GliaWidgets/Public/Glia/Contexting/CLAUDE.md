Project Guide: iOS Screen Context SDK Module (for AI Assistants)

1. High-Level Goal

This project is a self-contained, isolated Proof of Concept (POC) for a module within a larger iOS SDK.

The primary goal of this module is to determine the feasibility of tracking a user's on-screen context within any host application that has installed our SDK.

The ultimate research objective is to create a JSON payload of on-screen text, structured by reading order, which can be fed to an LLM to determine the user's intent or context (e.g., "What was the user looking at right before they contacted customer support via our SDK?").

2. Core Design Philosophy: "Good SDK Citizen"

This is the most important constraint of our research:

We MUST NOT use method swizzling, private APIs, or any other "risky" techniques.

As an SDK, we run inside a host app we don't control. Our solution must be 100% safe, stable, and App Store-compliant.

Method swizzling is forbidden as it could conflict with the host app's logic or other SDKs (e.g., Firebase, Segment).

Private APIs are forbidden as they can lead to App Store rejection.

All of our research and implementation must be based on a "polling" mechanism that uses 100% public, documented UIKit APIs. We accept the performance/latency trade-offs of this approach in exchange for safety and stability.

3. Core Research Challenges

This POC is an attempt to solve three primary challenges. We are looking for the most robust and performant way to solve each one within our constraints.

Challenge #1: The "Event Trigger"

Problem: How do we reliably detect a change in user context without a system-level notification?

Context: A "context change" is not just navigation (e.g., UINavigationController.push(...)) but also scrolling (e.g., UIScrollView.contentOffset changing).

Hypothesis: The most viable approach is to run a Timer that periodically (e.g., every 500ms) polls a "state signature" of the application.

Open Question: What is the most efficient and accurate "state signature"? We are currently exploring a combination of String(describing: type(of: visibleVC)) + scrollView.contentOffset.y. Is there a better, more robust signature? How do we find the "primary" scroll view on any given screen without being computationally expensive on every poll?

Challenge #2: The "Data Extraction"

Problem: Once a "context change" is triggered, how do we exhaustively and safely extract all relevant text from the current screen?

Hypothesis: The best approach (to avoid OCR) is a recursive traversal of the UIView hierarchy, starting from the visible view controller's view.

Open Question: How do we make this traversal as complete as possible? We need to account for all common (and uncommon) UIKit elements (UILabel, UIButton, UITextField, UITextView, UISegmentedControl, etc.). What are the edge cases? (e.g., isHidden = true, alpha = 0, text within a UICollectionViewCell that is partially off-screen, etc.).

Challenge #3: The "Data Structuring"

Problem: A flat list of text strings is useless to an LLM. How do we structure the extracted text to represent the actual reading order?

Hypothesis: We can use the frame of each text element (normalized to window coordinates) to group them into "lines" based on spatial heuristics (e.g., elements with similar midY values are on the same line).

Open Question: Is this spatial grouping robust enough for complex layouts (e.g., grids, side-by-side forms)? What is the optimal JSON schema to represent this? Should it be an array of lines? An array of objects with frame and text? What format gives an LLM the best possible understanding of the screen's layout?

4. How to Partner on this Research

Your role is to be a "research partner" and a "what if" generator. When we collaborate, please:

Critique the Hypotheses: Challenge the polling signature, the view traversal logic, or the data structuring method. Propose alternatives that are still compliant with our constraints.

Brainstorm Edge Cases: Ask "What if...?"

"What if the app uses a horizontal UICollectionView?"

"What if a UITextView is scrolling inside a UITableViewCell?"

"What if a modal is presented and dismissed between polls?"

"What is the battery life/CPU impact of this polling frequency?"

Help Refine Logic: Suggest better ways to find the "primary" scroll view, or a more robust algorithm for grouping text elements into lines.

Always Adhere to Constraints: Every suggestion you make must respect the "Things to AVOID" list below.

5. Things to AVOID (The Hard Rules)

DO NOT suggest method swizzling. This is the #1 rule.

DO NOT suggest using private APIs (e.g., _snapshotView).

DO NOT perform any UI traversal or UIKit operations off the main thread.

DO NOT add any third-party dependencies. The SDK module must be self-contained.

DO NOT suggest the screenshot/OCR (Vision) approach. We are explicitly researching the view hierarchy traversal method.

DO NOT expose internal implementation details (classes, methods) as public. The final module must have a single, clean public API.