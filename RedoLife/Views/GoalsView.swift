import SwiftUI
import SwiftData
import UniformTypeIdentifiers

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
                    let activeRoutines = viewModel.routines.filter { $0.isActive }
                    let archivedRoutines = viewModel.routines.filter { !$0.isActive }
                    
                    if !activeRoutines.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(activeRoutines) { routine in
                                RoutineRow(routine: routine, onDelete: {
                                    deleteRoutine(routine)
                                })
                                .onDrag {
                                    return NSItemProvider(object: routine.id.uuidString as NSString)
                                }
                                .onDrop(of: [.text], delegate: RoutineDropDelegate(item: routine, viewModel: viewModel))
                                
                                if routine.id != activeRoutines.last?.id {
                                    Divider()
                                        .background(AppColors.lightGray)
                                }
                            }
                        }
                        .card(padding: 0)
                    }
                    
                    // Archived Section
                    if !archivedRoutines.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Đã lưu trữ")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppColors.textMuted)
                                .padding(.top, 8)
                            
                            VStack(spacing: 0) {
                                ForEach(archivedRoutines) { routine in
                                    RoutineRow(routine: routine, onDelete: {
                                        deleteRoutine(routine)
                                    })
                                    
                                    if routine.id != archivedRoutines.last?.id {
                                        Divider()
                                            .background(AppColors.lightGray)
                                    }
                                }
                            }
                            .card(padding: 0)
                            .opacity(0.6)
                        }
                        .padding(.top, 16)
                    }
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
                    // Calculate progress based on ACTIVE goals only? Or ALL?
                    // Usually "Progress" implies active tasks. 
                    // Let's filter for active goals to match the list above.
                    let activeGoals = viewModel.goals.filter { $0.isActive }
                    let completedActive = activeGoals.filter { $0.isCompleted }.count
                    let progress = activeGoals.isEmpty ? 0 : Double(completedActive) / Double(activeGoals.count)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(completedActive)/\(activeGoals.count) hoàn thành")
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.textMuted)
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppColors.green)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                // Background Track - Ensure distinct color
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2)) // Slightly darker for visibility
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppColors.green.gradient)
                                    .frame(width: geo.size.width * progress, height: 8)
                                    .animation(.spring(duration: 0.5), value: progress)
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
                    let activeGoals = viewModel.goals.filter { $0.isActive }
                    let archivedGoals = viewModel.goals.filter { !$0.isActive }
                    
                    if !activeGoals.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(activeGoals) { goal in
                                GoalRow(goal: goal, onToggle: {
                                    viewModel.toggleGoal(goal)
                                }, onEdit: {
                                    editingGoal = goal
                                }, onDelete: {
                                    viewModel.deleteGoal(goal)
                                })
                                
                                if goal.id != activeGoals.last?.id {
                                    Divider()
                                        .background(AppColors.lightGray)
                                }
                            }
                        }
                        .card(padding: 0)
                    }
                    
                    // Archived Goals Section
                    if !archivedGoals.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mục tiêu đã lưu trữ")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppColors.textMuted)
                                .padding(.top, 8)
                            
                            VStack(spacing: 0) {
                                ForEach(archivedGoals) { goal in
                                    GoalRow(goal: goal, onToggle: {
                                        viewModel.toggleGoal(goal)
                                    }, onEdit: {
                                        editingGoal = goal
                                    }, onDelete: {
                                        viewModel.deleteGoal(goal)
                                    })
                                    
                                    if goal.id != archivedGoals.last?.id {
                                        Divider()
                                            .background(AppColors.lightGray)
                                    }
                                }
                            }
                            .card(padding: 0)
                            .opacity(0.6)
                        }
                        .padding(.top, 16)
                    }
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
            
            if goal.isActive {
                Button {
                    withAnimation {
                        goal.isActive = false
                        goal.archivedAt = Date()
                    }
                } label: {
                    Label("Lưu trữ", systemImage: "archivebox")
                }
            } else {
                Button {
                    withAnimation {
                        goal.isActive = true
                        goal.archivedAt = nil
                    }
                } label: {
                    Label("Khôi phục", systemImage: "arrow.uturn.backward")
                }
            }
            
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
    
    func colorForIcon(_ icon: String) -> Color {
        switch icon {
        case "star.fill": return .yellow
        case "flame.fill": return .orange
        case "book.fill": return .brown
        case "figure.run": return .blue
        case "bed.double.fill": return .indigo
        case "drop.fill": return .cyan
        case "leaf.fill": return .green
        case "heart.fill": return .red
        default: return AppColors.green
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            let iconColor = colorForIcon(routine.icon)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: routine.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
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
            
            if routine.isActive {
                Button {
                    withAnimation {
                        routine.isActive = false
                        routine.archivedAt = Date()
                    }
                } label: {
                    Label("Lưu trữ", systemImage: "archivebox")
                }
            } else {
                Button {
                    withAnimation {
                        routine.isActive = true
                        routine.archivedAt = nil
                    }
                } label: {
                    Label("Khôi phục", systemImage: "arrow.uturn.backward")
                }
            }
            
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

struct RoutineDropDelegate: DropDelegate {
    let item: Routine
    var viewModel: AppViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return }
        
        itemProvider.loadObject(ofClass: NSString.self) { string, _ in
            guard let fromIdString = string as? String,
                  let fromId = UUID(uuidString: fromIdString) else { return }
            
            DispatchQueue.main.async {
                guard fromId != item.id else { return }
                
                // Find indices
                let activeRoutines = viewModel.routines.filter { $0.isActive }.sorted { $0.order < $1.order }
                guard let fromIndex = activeRoutines.firstIndex(where: { $0.id == fromId }),
                      let toIndex = activeRoutines.firstIndex(where: { $0.id == item.id }) else { return }
                
                // Move in ViewModel
                withAnimation {
                   viewModel.moveRoutine(from: IndexSet(integer: fromIndex), to: toIndex > fromIndex ? toIndex + 1 : toIndex)
                }
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
 
#Preview {
    GoalsView()
        .environment(AppViewModel())
}
