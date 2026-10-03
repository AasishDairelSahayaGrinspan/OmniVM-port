// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2026 BarutSRB — https://github.com/OmniNull/OmniWM

import AppKit

@MainActor
final class QuakeTerminalGlassView: NSView {
    // INTEL PORT: NSGlassEffectView is macOS 26+; use NSVisualEffectView on Sequoia.
    private let effectView: NSVisualEffectView
    private let tintOverlay: NSView

    override init(frame frameRect: NSRect) {
        effectView = NSVisualEffectView()
        tintOverlay = NSView()
        super.init(frame: frameRect)
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        effectView = NSVisualEffectView()
        tintOverlay = NSView()
        super.init(coder: coder)
        configureSubviews()
    }

    func configure(
        style: QuakeGhosttyGlassStyle,
        backgroundColor: NSColor,
        backgroundOpacity: Double,
        isKeyWindow: Bool
    ) {
        // INTEL LOW-POWER: behindWindow live blur is a fullscreen GPU composite
        // on UHD 630 — downgrade to opaque withinWindow on old hardware.
        if IntelPerfPolicy.lowPowerDefault {
            effectView.material = .windowBackground
            effectView.blendingMode = .withinWindow
            effectView.state = .inactive
        } else {
            effectView.material = style == .clear ? .sheet : .hudWindow
            effectView.blendingMode = .behindWindow
            effectView.state = .active
        }
        effectView.wantsLayer = true
        effectView.layer?.cornerRadius = 0
        updateKeyStatus(isKeyWindow, backgroundColor: backgroundColor)
    }

    func updateKeyStatus(_ isKeyWindow: Bool, backgroundColor: NSColor) {
        let tint = inactiveTint(for: backgroundColor)
        tintOverlay.layer?.backgroundColor = tint.color.cgColor
        tintOverlay.alphaValue = isKeyWindow ? 0 : tint.opacity
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    private func configureSubviews() {
        effectView.frame = bounds
        effectView.autoresizingMask = [.width, .height]
        addSubview(effectView)

        tintOverlay.frame = bounds
        tintOverlay.autoresizingMask = [.width, .height]
        tintOverlay.wantsLayer = true
        addSubview(tintOverlay, positioned: .above, relativeTo: effectView)
    }

    private func inactiveTint(for color: NSColor) -> (color: NSColor, opacity: CGFloat) {
        guard let rgb = color.usingColorSpace(.sRGB) else {
            return (color, 0.85)
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        rgb.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        rgb.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        let tint = NSColor(
            hue: hue,
            saturation: min(max(saturation * 1.2, 0), 1),
            brightness: brightness,
            alpha: alpha
        )
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return (tint, luminance > 0.5 ? 0.35 : 0.85)
    }
}
