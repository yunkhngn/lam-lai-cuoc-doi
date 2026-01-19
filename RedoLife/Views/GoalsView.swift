import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var newRoutineName: String = ""
    @State private var isAddingNew = false
    
    var body: some View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Mục tiêu & Thói quen")
                        .roundedFont(.largeTitle, weight: .bold)
                    Spacer()
                    Button {
                        withAnimation {
                            isAddingNew.toggle()
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(AppColors.neonBlue)
                            .shadow(radius: 5)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Add New Section (Floating Bubble)
                if isAddingNew {
                    GlassCard {
                        HStack {
                            TextField("Tên thói quen mới", text: $newRoutineName)
                                .textFieldStyle(.plain)
                                .roundedFont(.body)
                                .onSubmit {
                                    addNewRoutine()
                                }
                            
                            Button("Thêm") {
                                addNewRoutine()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AppColors.neonBlue)
                            .disabled(newRoutineName.isEmpty)
                        }
                    }
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity).combined(with: .move(edge: .top)))
                }
                
                // Active Routines
                VStack(alignment: .leading, spacing: 16) {
                    Text("Đang thực hiện")
                        .roundedFont(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.routines.filter { $0.isActive }) { routine in
                        GlassCard(padding: 12) {
                            RoutineEditRow(routine: routine)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Archived Routines
                if !viewModel.routines.filter({ !$0.isActive }).isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Đã lưu trữ")
                            .roundedFont(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.routines.filter { !$0.isActive }) { routine in
                            GlassCard(padding: 12) {
                                RoutineEditRow(routine: routine)
                                    .opacity(0.6)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .padding(.bottom, 80)
        }
    }
        .onAppear {
            // Ensure data is refreshed
            viewModel.fetchData()
        }
    }
    
    func addNewRoutine() {
        guard !newRoutineName.isEmpty else { return }
        
        let routine = Routine(name: newRoutineName, order: viewModel.routines.count)
        modelContext.insert(routine)
        
        newRoutineName = ""
        isAddingNew = false
        
        // Refresh
        viewModel.fetchData()
    }
    
    func deleteActiveRoutines(at offsets: IndexSet) {
        let active = viewModel.routines.filter { $0.isActive }
        for index in offsets {
            let routine = active[index]
            modelContext.delete(routine)
        }
        viewModel.fetchData()
    }
    
    func deleteInactiveRoutines(at offsets: IndexSet) {
        let inactive = viewModel.routines.filter { !$0.isActive }
        for index in offsets {
            let routine = inactive[index]
            modelContext.delete(routine)
        }
        viewModel.fetchData()
    }
    
    // Simplistic Reorder
    func moveActiveRoutines(from source: IndexSet, to destination: Int) {
        var active = viewModel.routines.filter { $0.isActive }
        active.move(fromOffsets: source, toOffset: destination)
        
        // Update order
        for (index, routine) in active.enumerated() {
            routine.order = index
        }
        
        // Save handled by autosave usually, but explicit save might be safer
        viewModel.fetchData()
    }
}

struct RoutineEditRow: View {
    @Bindable var routine: Routine
    
    let icons = ["star.fill", "flame.fill", "book.fill", "figure.run", "bed.double.fill", "drop.fill", "leaf.fill", "heart.fill"]
    
    var body: some View {
        HStack {
            Menu {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        routine.icon = icon
                    } label: {
                        Label("Chọn", systemImage: icon)
                    }
                }
            } label: {
                Image(systemName: routine.icon)
                    .frame(width: 24)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 32)
            
            TextField("Tên", text: $routine.name)
                .textFieldStyle(.plain)
            
            Spacer()
            
            Toggle("Kích hoạt", isOn: $routine.isActive)
                .labelsHidden()
                .toggleStyle(.switch)
                .scaleEffect(0.8)
        }
        .padding(.vertical, 4)
    }
}
