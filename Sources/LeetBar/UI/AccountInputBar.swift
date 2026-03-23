import SwiftUI

struct AccountInputBar: View {
    @Binding var username: String
    let isLoading: Bool
    let onRefresh: () -> Void
    let isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.crop.circle")
                .foregroundStyle(.secondary)

            TextField("LeetCode username", text: $username)
                .textFieldStyle(.plain)
                .focused(isFocused)
                .onSubmit(onRefresh)

            if isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                RefreshButton(isLoading: isLoading, action: onRefresh)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .panelSurface(cornerRadius: 14, interactive: true)
    }
}

private struct RefreshButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Group {
            if #available(macOS 26, iOS 26, *) {
                Button(action: action) {
                    Label("Refresh stats", systemImage: "arrow.clockwise")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.glassProminent)
                .symbolEffect(.rotate.byLayer, value: isLoading)
                .help("Refresh stats")
            } else {
                Button(action: action) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
