// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2026 BarutSRB — https://github.com/OmniNull/OmniWM

import Foundation

/// Intel low-power policy for old hardware (e.g. MBP 16" 2019, i7 + UHD 630 / 5300M).
/// Max-smoothness defaults: cap frame work, kill live blur, coalesce events.
enum IntelPerfPolicy: Sendable {
    /// True on x86_64 Macs (Intel). Compile-time + runtime guard.
    static var isIntel: Bool {
#if arch(x86_64)
        true
#else
        false
#endif
    }

    /// Master low-power switch. Defaults ON for Intel, OFF for Apple Silicon.
    /// Users can override via Settings → Enable Animations / Reduce Motion.
    static var lowPowerDefault: Bool {
        isIntel
    }

    /// Target tick divisor: 2 = ~30fps worth of work on 60Hz panels.
    static var displayLinkTickDivisor: Int {
        lowPowerDefault ? 2 : 1
    }

    /// Trailing park audits after DisplayLink idle stop (was 30x100ms = 3s).
    static var trailingAuditCount: Int {
        lowPowerDefault ? 5 : 30
    }

    /// Clipboard poll interval seconds (was 0.5s).
    static var clipboardPollInterval: TimeInterval {
        lowPowerDefault ? 1.5 : 0.5
    }

    /// AX debounce nanos (upstream 4ms created / 8ms changed — too hot on 6c i7).
    static var axCreatedDebounceNs: UInt64 {
        lowPowerDefault ? 16_000_000 : 4_000_000
    }

    static var axChangedDebounceNs: UInt64 {
        lowPowerDefault ? 32_000_000 : 8_000_000
    }

    /// Preferred focus-border width on Intel (thinner = less overdraw).
    static var preferredBorderWidth: Double {
        lowPowerDefault ? 3.5 : 5.0
    }

    /// Sequoia AppKit window radius on Intel (Finder/Safari ≈ 9-10pt).
    /// Fallback when SkyLight returns all-zero sample.
    static var fallbackCornerRadius: Double {
        10.0
    }

    /// Tolerance to avoid border redraw flicker on sub-pixel radius noise.
    static var cornerRadiusEpsilon: Double {
        0.5
    }

    /// Feather blend width (pt) outside the rim for curved-edge blending.
    static var borderFeatherWidth: Double {
        1.0
    }
}
