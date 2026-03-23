import SwiftUI

struct ContentView: View {
    @StateObject private var service = LeetCodeService()
    @AppStorage("username") private var username: String = ""
    @FocusState private var isFocused: Bool
    
    // For background animation
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Search
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    TextField("Username", text: $username)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .font(.system(.body, design: .rounded))
                        .onSubmit {
                            Task { await service.fetchStats(username: username) }
                        }
                    
                    if service.isLoading {
                        ProgressView().scaleEffect(0.5)
                    } else {
                        Button {
                            Task { await service.fetchStats(username: username) }
                        } label: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.title3)
                                .symbolEffect(.bounce, value: service.isLoading)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.primary.opacity(0.8))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.white.opacity(0.1), lineWidth: 1))
                
                if let error = service.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red.opacity(0.8))
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding([.horizontal, .top], 20)
            
            // Stats Section
            if !service.userStats.isEmpty {
                ScrollView {
                    VStack(spacing: 24) {
                        // Main Circular Progress (All)
                        if let allSolved = service.userStats.first(where: { $0.difficulty == "All" }),
                           let allTotal = service.totalCounts.first(where: { $0.difficulty == "All" }) {
                            MainProgressView(solved: allSolved.count, total: allTotal.count)
                                .padding(.top, 10)
                        }
                        
                        // Difficulty Grid
                        HStack(spacing: 15) {
                            DifficultyCard(difficulty: "Easy", 
                                          solved: service.userStats.first(where: { $0.difficulty == "Easy" })?.count ?? 0,
                                          total: service.totalCounts.first(where: { $0.difficulty == "Easy" })?.count ?? 1,
                                          color: .green)
                            
                            DifficultyCard(difficulty: "Medium", 
                                          solved: service.userStats.first(where: { $0.difficulty == "Medium" })?.count ?? 0,
                                          total: service.totalCounts.first(where: { $0.difficulty == "Medium" })?.count ?? 1,
                                          color: .orange)
                            
                            DifficultyCard(difficulty: "Hard", 
                                          solved: service.userStats.first(where: { $0.difficulty == "Hard" })?.count ?? 0,
                                          total: service.totalCounts.first(where: { $0.difficulty == "Hard" })?.count ?? 1,
                                          color: .red)
                        }
                    }
                    .padding(20)
                }
            } else if !service.isLoading {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary.opacity(0.3))
                    Text("Ready to Track Progress?")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text("Enter your LeetCode username above")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary.opacity(0.7))
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            }
            
            Divider().opacity(0.1)
            
            // Footer Controls
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(.caption, design: .rounded).bold())
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.white.opacity(0.05))
                .clipShape(Capsule())
                
                Spacer()
                
                Text("LeetBar v1.1")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(width: 320, height: 480)
        .background(
            ZStack {
                Color(NSColor.windowBackgroundColor).opacity(0.8)
                
                // Animated Mesh Gradient-like background
                Group {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 250, height: 250)
                        .offset(x: animate ? 100 : -100, y: animate ? -150 : 150)
                    
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 300, height: 300)
                        .offset(x: animate ? -120 : 120, y: animate ? 120 : -120)
                    
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 200, height: 200)
                        .offset(x: animate ? 50 : -50, y: animate ? 50 : -50)
                }
                .blur(radius: 60)
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
                
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
        )
        .onAppear {
            animate = true
            if !username.isEmpty {
                Task { await service.fetchStats(username: username) }
            } else {
                isFocused = true
            }
        }
    }
}

struct MainProgressView: View {
    let solved: Int
    let total: Int
    
    var progress: Double {
        total == 0 ? 0 : Double(solved) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background Track
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: 20)
                
                // Progress
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(colors: [.blue, .purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.5, dampingFraction: 0.8), value: progress)
                
                VStack(spacing: 4) {
                    Text("\(solved)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .contentTransition(.numericText())
                    Text("/ \(total)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text("SOLVED")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 180, height: 180)
            .shadow(color: .blue.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

struct DifficultyCard: View {
    let difficulty: String
    let solved: Int
    let total: Int
    let color: Color
    
    var progress: Double {
        total == 0 ? 0 : Double(solved) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.1), lineWidth: 6)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.2, dampingFraction: 0.7), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .frame(width: 55, height: 55)
            
            VStack(spacing: 2) {
                Text(difficulty)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("\(solved)/\(total)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(.white.opacity(0.05), lineWidth: 1))
    }
}
