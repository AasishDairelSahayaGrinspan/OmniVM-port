// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2026 BarutSRB — https://github.com/OmniNull/OmniWM

import Foundation
import FoundationModels

@available(macOS 27.0, *)
@MainActor
final class FoundationModelsIssueEngine: IssueRewriting {
    var availability: IssueAIAvailability {
        switch SystemLanguageModel.default.availability {
        case .available:
            .available
        case let .unavailable(reason):
            Self.map(reason)
        @unknown default:
            .modelNotReady
        }
    }

    func rewrite(_ freeform: String, hotkeyContext: String) async throws -> RewrittenIssue {
        // INTEL PORT: Apple Intelligence / macOS 27 unavailable on Intel (Tahoe 26 is last Intel release).
        // Upstream calls session.respond (throwing in SDK 27); SDK 26.2 signature differs, so stub out.
        // This code path is unreachable on Intel (caller checks availability first).
        throw IssueReportError.generationFailed("On-device AI requires Apple Silicon")
    }

    private static func map(_ reason: SystemLanguageModel.Availability.UnavailableReason) -> IssueAIAvailability {
        switch reason {
        case .deviceNotEligible:
            .deviceNotEligible
        case .appleIntelligenceNotEnabled:
            .appleIntelligenceNotEnabled
        case .modelNotReady:
            .modelNotReady
        @unknown default:
            .modelNotReady
        }
    }
}

@available(macOS 27.0, *)
@Generable
private struct GeneratedIssue {
    @Guide(description: "A short, specific issue title")
    var title: String
    @Guide(description: "One-sentence summary of the problem, or 'Not provided'")
    var summary: String
    @Guide(description: "Minimal, numbered, deterministic steps to reproduce, or 'Not provided'")
    var stepsToReproduce: String
    @Guide(description: "What the user expected to happen, or 'Not provided'")
    var expectedBehavior: String
    @Guide(description: "What actually happened and how it deviates from expected, or 'Not provided'")
    var actualBehavior: String
    @Guide(description: "Other context the user gave: layout, monitors, app/window, hotkey+command, or 'Not provided'")
    var additionalContext: String
}
