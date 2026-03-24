import SwiftUI

extension View {
    @ViewBuilder
    func rootVisualContainer(spacing: CGFloat = 0) -> some View {
        if #available(macOS 26, *) {
            RootGlassContainer(spacing: spacing) {
                self
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func leetBarButtonStyle(prominent: Bool = false) -> some View {
        if #available(macOS 26, *) {
            if prominent {
                ProminentGlassButton(content: self)
            } else {
                SecondaryGlassButton(content: self)
            }
        } else if prominent {
            self.buttonStyle(.borderedProminent)
        } else {
            self.buttonStyle(.bordered)
        }
    }
}

@available(macOS 26, *)
private struct RootGlassContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(spacing: CGFloat, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        GlassEffectContainer(spacing: spacing) {
            content
        }
    }
}

@available(macOS 26, *)
private struct SecondaryGlassButton<Content: View>: View {
    let content: Content

    var body: some View {
        content.buttonStyle(.glass)
    }
}

@available(macOS 26, *)
private struct ProminentGlassButton<Content: View>: View {
    let content: Content

    var body: some View {
        content.buttonStyle(.glassProminent)
    }
}
