import SwiftUI

struct MenuBarView: View {
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(viewModel.currentDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Spacer()
                
                // Mini Progress
                let active = viewModel.routines.filter { $0.isActive }
                let done = active.filter { viewModel.todayLogs[$0.id]?.isDone == true }.count
                let percent = active.isEmpty ? 0 : Int((Double(done) / Double(active.count)) * 100)
                
                Text("\(percent)%")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.accentColor))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Divider()
            
            // List
            if viewModel.routines.isEmpty {
                Text("Không có thói quen nào")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.routines.filter { $0.isActive }) { routine in
                    let isDone = viewModel.todayLogs[routine.id]?.isDone ?? false
                    HStack {
                        Image(systemName: routine.icon)
                        Text(routine.name)
                        Spacer()
                        Button {
                            withAnimation {
                                viewModel.toggleRoutine(routine)
                            }
                        } label: {
                            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isDone ? .green : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Mở ứng dụng") {
                    NSApp.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.link)
                .font(.caption)
                
                Button("Thoát") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.link)
                .font(.caption)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(width: 250)
        .padding(.top)
    }
}
