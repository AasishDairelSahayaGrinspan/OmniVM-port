// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2026 BarutSRB — https://github.com/OmniNull/OmniWM

import Foundation
import Observation

struct MotionSnapshot: Equatable, Sendable {
    let animationsEnabled: Bool

    static let enabled = MotionSnapshot(animationsEnabled: true)
    static let disabled = MotionSnapshot(animationsEnabled: false)
}

@MainActor @Observable
final class MotionPolicy {
    var userAnimationsEnabled: Bool
    var systemReducesMotion = false
    /// Intel low-power mode: defaults ON on x86_64 for max smoothness.
    var lowPowerMode = IntelPerfPolicy.lowPowerDefault

    var animationsEnabled: Bool {
        get { userAnimationsEnabled && !systemReducesMotion && !lowPowerMode }
        set { userAnimationsEnabled = newValue }
    }

    init(animationsEnabled: Bool = true, lowPowerMode: Bool = IntelPerfPolicy.lowPowerDefault) {
        userAnimationsEnabled = animationsEnabled
        self.lowPowerMode = lowPowerMode
    }

    func snapshot() -> MotionSnapshot {
        MotionSnapshot(animationsEnabled: animationsEnabled)
    }

    /// Shorter durations when low-power so animations settle faster on old iGPU.
    func scaledDuration(_ base: TimeInterval) -> TimeInterval {
        lowPowerMode ? base * 0.5 : base
    }
}
