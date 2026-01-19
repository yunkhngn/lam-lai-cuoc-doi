import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var newRoutineName = ""
    @State private var showingAddRoutine = false
    @State private var showingAddGoal = false
    @State private var editingGoal: Goal? = nil
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Daily Routines Header
                HStack {
                    Text("Thói quen hằng ngày")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        showingAddRoutine = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColors.green)
                            .frame(width: 36, height: 36)
                            .background(AppColors.green.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 40)
                
                // Routines List
                if viewModel.routines.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "repeat.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.textMuted.opacity(0.3))
                        Text("Chưa có thói quen nào")
                            .foregroundStyle(AppColors.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .card()
                } else {
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
                }
                
                // Goals Section
                HStack {
                    Text("Mục tiêu")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.green)
                            .frame(width: 30, height: 30)
                            .background(AppColors.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
                
                // Goals Progress Bar
                if !viewModel.goals.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(viewModel.goals.filter { $0.isCompleted }.count)/\(viewModel.goals.count) hoàn thành")
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.textMuted)
                            Spacer()
                            Text("\(Int(viewModel.goalsProgress * 100))%")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppColors.green)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppColors.lightGray)
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppColors.green.gradient)
                                    .frame(width: geo.size.width * viewModel.goalsProgress, height: 8)
                                    .animation(.spring(duration: 0.5), value: viewModel.goalsProgress)
                            }
                        }
                        .frame(height: 8)
                    }
                }
                
                // Goals List
                if viewModel.goals.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.textMuted.opacity(0.3))
                        Text("Chưa có mục tiêu nào")
                            .foregroundStyle(AppColors.textMuted)
                        Text("Thêm các mục tiêu bạn muốn đạt được")
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.textMuted.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .card()
                } else {
                    VStack(spacing: 0) {
                        ForEach(viewModel.goals) { goal in
                            GoalRow(goal: goal, onToggle: {
                                viewModel.toggleGoal(goal)
                            }, onEdit: {
                                editingGoal = goal
                            }, onDelete: {
                                viewModel.deleteGoal(goal)
                            })
                            
                            if goal.id != viewModel.goals.last?.id {
                                Divider()
                                    .background(AppColors.lightGray)
                            }
                        }
                    }
                    .card(padding: 0)
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 40)
        }
        .background(AppColors.bgPrimary.ignoresSafeArea())
        .sheet(isPresented: $showingAddRoutine) {
            AddRoutineSheet(name: $newRoutineName) {
                addRoutine()
            }
            .presentationDetents([.height(180)])
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalSheet { name, deadline, isLongTerm in
                addGoal(name: name, deadline: deadline, isLongTerm: isLongTerm)
            }
            .presentationDetents([.height(300)])
        }
        .sheet(item: $editingGoal) { goal in
            EditGoalSheet(goal: goal) { name, deadline, isLongTerm in
                viewModel.updateGoal(goal, name: name, deadline: deadline, isLongTerm: isLongTerm)
                viewModel.fetchData()
            }
            .presentationDetents([.height(300)])
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
        showingAddRoutine = false
        viewModel.fetchData()
    }
    
    func addGoal(name: String, deadline: Date?, isLongTerm: Bool) {
        let goal = Goal(name: name, deadline: deadline, isLongTerm: isLongTerm, order: viewModel.goals.count)
        modelContext.insert(goal)
        showingAddGoal = false
        viewModel.fetchData()
    }
    
    func deleteRoutine(_ routine: Routine) {
        modelContext.delete(routine)
        viewModel.fetchData()
    }
}

// MARK: - Goal Row
struct GoalRow: View {
    let goal: Goal
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button {
                withAnimation(.spring(response: 0.3)) {
                    onToggle()
                }
            } label: {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(goal.isCompleted ? AppColors.green : AppColors.mediumGray.opacity(0.5))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.system(size: 16))
                    .foregroundStyle(goal.isCompleted ? AppColors.textMuted : AppColors.textPrimary)
                    .strikethrough(goal.isCompleted, color: AppColors.textMuted)
                
                // Badge
                if goal.isCompleted {
                    Text("Hoàn thành")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.green)
                } else if goal.isLongTerm {
                    Text("Dài hạn")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.purple)
                } else if let deadline = goal.deadline {
                    let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
                    Text(daysLeft < 0 ? "Quá hạn" : "Còn \(daysLeft) ngày")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(daysLeft < 0 ? .red : (daysLeft <= 3 ? .orange : AppColors.textMuted))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(isHovering ? AppColors.lightGray.opacity(0.5) : Color.clear)
        .onHover { isHovering = $0 }
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Sửa", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Xoá", systemImage: "trash")
            }
        }
    }
}

// MARK: - Routine Row
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
        ("Trái tim", "heart.fill")
    ]
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.green.opacity(0.12))
                    .frame(width: 36, height: 36)
                
                Image(systemName: routine.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.green)
            }
            
            Text(routine.name)
                .font(.system(size: 16))
                .foregroundStyle(routine.isActive ? AppColors.textPrimary : AppColors.textMuted)
            
            Spacer()
            
            Toggle("", isOn: $routine.isActive)
                .toggleStyle(.switch)
                .tint(AppColors.green)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(isHovering ? AppColors.lightGray.opacity(0.5) : Color.clear)
        .onHover { isHovering = $0 }
        .contextMenu {
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
        }
    }
}

// MARK: - Add Routine Sheet
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
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "1D1D1F"))
                .padding(16)
                .background(Color(hex: "F0F0F5"))
                .cornerRadius(12)
            
            HStack {
                Button("Huỷ") { dismiss() }
                    .foregroundStyle(AppColors.textMuted)
                
                Spacer()
                
                Button("Thêm") { onAdd() }
                    .disabled(name.isEmpty)
                    .foregroundStyle(name.isEmpty ? AppColors.textMuted : AppColors.green)
                    .fontWeight(.semibold)
            }
        }
        .padding(24)
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Add Goal Sheet
struct AddGoalSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var hasDeadline = false
    @State private var deadline = Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week default
    @State private var isLongTerm = false
    
    let onAdd: (String, Date?, Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Thêm mục tiêu")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            TextField("Tên mục tiêu", text: $name)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "1D1D1F"))
                .padding(16)
                .background(Color(hex: "F0F0F5"))
                .cornerRadius(12)
            
            // Options - left aligned
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Mục tiêu dài hạn", isOn: $isLongTerm)
                    .toggleStyle(.switch)
                    .tint(AppColors.green)
                    .onChange(of: isLongTerm) { _, newValue in
                        if newValue { hasDeadline = false }
                    }
                
                Toggle("Có deadline", isOn: $hasDeadline)
                    .toggleStyle(.switch)
                    .tint(AppColors.green)
                    .disabled(isLongTerm)
                
                if hasDeadline && !isLongTerm {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                }
            }
            
            Spacer()
            
            HStack {
                Button("Huỷ") { dismiss() }
                    .foregroundStyle(AppColors.textMuted)
                
                Spacer()
                
                Button("Thêm") {
                    onAdd(name, hasDeadline ? deadline : nil, isLongTerm)
                    dismiss()
                }
                .disabled(name.isEmpty)
                .foregroundStyle(name.isEmpty ? AppColors.textMuted : AppColors.green)
                .fontWeight(.semibold)
            }
        }
        .padding(24)
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Edit Goal Sheet
struct EditGoalSheet: View {
    let goal: Goal
    let onSave: (String, Date?, Bool) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var hasDeadline: Bool
    @State private var deadline: Date
    @State private var isLongTerm: Bool
    
    init(goal: Goal, onSave: @escaping (String, Date?, Bool) -> Void) {
        self.goal = goal
        self.onSave = onSave
        _name = State(initialValue: goal.name)
        _hasDeadline = State(initialValue: goal.deadline != nil)
        _deadline = State(initialValue: goal.deadline ?? Date().addingTimeInterval(7 * 24 * 60 * 60))
        _isLongTerm = State(initialValue: goal.isLongTerm)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sửa mục tiêu")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            TextField("Tên mục tiêu", text: $name)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "1D1D1F"))
                .padding(16)
                .background(Color(hex: "F0F0F5"))
                .cornerRadius(12)
            
            // Options - left aligned
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Mục tiêu dài hạn", isOn: $isLongTerm)
                    .toggleStyle(.switch)
                    .tint(AppColors.green)
                    .onChange(of: isLongTerm) { _, newValue in
                        if newValue { hasDeadline = false }
                    }
                
                Toggle("Có deadline", isOn: $hasDeadline)
                    .toggleStyle(.switch)
                    .tint(AppColors.green)
                    .disabled(isLongTerm)
                
                if hasDeadline && !isLongTerm {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                }
            }
            
            Spacer()
            
            HStack {
                Button("Huỷ") { dismiss() }
                    .foregroundStyle(AppColors.textMuted)
                
                Spacer()
                
                Button("Lưu") {
                    onSave(name, hasDeadline ? deadline : nil, isLongTerm)
                    dismiss()
                }
                .disabled(name.isEmpty)
                .foregroundStyle(name.isEmpty ? AppColors.textMuted : AppColors.green)
                .fontWeight(.semibold)
            }
        }
        .padding(24)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    GoalsView()
        .environment(AppViewModel())
}
