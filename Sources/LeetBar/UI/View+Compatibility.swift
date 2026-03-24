import SwiftUI

extension View {
    func rootVisualContainer(spacing: CGFloat = 0) -> some View {
        self
    }

    @ViewBuilder
    func leetBarButtonStyle(prominent: Bool = false) -> some View {
        if prominent {
            self.buttonStyle(.borderedProminent)
        } else {
            self.buttonStyle(.bordered)
        }
    }
}
