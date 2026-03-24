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
                RefreshButton(action: onRefresh)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .panelSurface(cornerRadius: 14, interactive: true)
    }
}

private struct RefreshButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Refresh stats", systemImage: "arrow.clockwise")
                .labelStyle(.iconOnly)
        }
        .leetBarButtonStyle(prominent: true)
        .help("Refresh stats")
    }
}
