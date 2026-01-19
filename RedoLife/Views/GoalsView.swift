import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var newRoutineName = ""
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            HStack {
                Text("Thói quen")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
                
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.accent)
                        .frame(width: 36, height: 36)
                        .background(AppColors.accent.opacity(0.1))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 40)
            
            // Routines List
            VStack(spacing: 0) {
                ForEach(viewModel.routines) { routine in
                    RoutineRow(routine: routine, onDelete: {
                        deleteRoutine(routine)
                    })
                    
                    if routine.id != viewModel.routines.last?.id {
                        Divider()
                            .background(AppColors.lightGray)
                    }
                }
            }
            .card(padding: 0)
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .background(AppColors.bgPrimary.ignoresSafeArea())
        .sheet(isPresented: $showingAddSheet) {
            AddRoutineSheet(name: $newRoutineName) {
                addRoutine()
            }
            .presentationDetents([.height(180)])
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
    
    func addRoutine() {
        guard !newRoutineName.isEmpty else { return }
        let routine = Routine(name: newRoutineName, order: viewModel.routines.count)
        modelContext.insert(routine)
        newRoutineName = ""
        showingAddSheet = false
        viewModel.fetchData()
    }
    
    func deleteRoutine(_ routine: Routine) {
        modelContext.delete(routine)
        viewModel.fetchData()
    }
}

struct RoutineRow: View {
    @Bindable var routine: Routine
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    let iconOptions: [(name: String, icon: String)] = [
        ("Ngôi sao", "star.fill"),
        ("Lửa", "flame.fill"),
        ("Sách", "book.fill"),
        ("Chạy bộ", "figure.run"),
        ("Ngủ", "bed.double.fill"),
        ("Nước", "drop.fill"),
        ("Lá cây", "leaf.fill"),
        ("Trái tim", "heart.fill"),
        ("Mặt trời", "sun.max.fill"),
        ("Nhạc", "music.note"),
        ("Tập gym", "dumbbell.fill"),
        ("Thiền", "brain.head.profile")
    ]
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with menu
            Menu {
                Section("Đổi icon") {
                    ForEach(iconOptions, id: \.icon) { option in
                        Button {
                            routine.icon = option.icon
                        } label: {
                            Label(option.name, systemImage: option.icon)
                        }
                    }
                }
                
                Divider()
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Xoá", systemImage: "trash")
                }
            } label: {
                Image(systemName: routine.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(routine.isActive ? AppColors.accent : AppColors.textMuted)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(routine.isActive ? AppColors.accent.opacity(0.1) : AppColors.lightGray)
                    )
            }
            .menuStyle(.borderlessButton)
            
            TextField("Tên", text: $routine.name)
                .font(.system(size: 16))
                .foregroundStyle(routine.isActive ? AppColors.textPrimary : AppColors.textMuted)
            
            Toggle("", isOn: $routine.isActive)
                .toggleStyle(.switch)
                .tint(AppColors.accent)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(isHovering ? AppColors.lightGray.opacity(0.5) : Color.clear)
        .onHover { isHovering = $0 }
    }
}

struct AddRoutineSheet: View {
    @Binding var name: String
    let onAdd: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Thêm thói quen")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            TextField("Tên thói quen", text: $name)
                .textFieldStyle(.plain)
                .padding(16)
                .background(AppColors.lightGray)
                .cornerRadius(12)
            
            HStack {
                Button("Huỷ") { dismiss() }
                    .foregroundStyle(AppColors.textMuted)
                
                Spacer()
                
                Button("Thêm") { onAdd() }
                    .disabled(name.isEmpty)
                    .foregroundStyle(name.isEmpty ? AppColors.textMuted : AppColors.accent)
                    .fontWeight(.semibold)
            }
        }
        .padding(24)
        .background(AppColors.bgCard.ignoresSafeArea())
    }
}

#Preview {
    GoalsView()
        .environment(AppViewModel())
}
