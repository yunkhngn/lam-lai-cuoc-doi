import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var newRoutineName = ""
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Mục tiêu & Thói quen")
                    .roundedFont(.largeTitle, weight: .bold)
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
                
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppColors.forest)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            // Active Routines
            List {
                Section {
                    ForEach(viewModel.routines.filter { $0.isActive }) { routine in
                        RoutineRow(routine: routine)
                    }
                    .onDelete(perform: deleteRoutines)
                } header: {
                    Text("Đang thực hiện")
                        .roundedFont(.subheadline, weight: .semibold)
                        .foregroundStyle(AppColors.textMuted)
                }
                
                if !viewModel.routines.filter({ !$0.isActive }).isEmpty {
                    Section {
                        ForEach(viewModel.routines.filter { !$0.isActive }) { routine in
                            RoutineRow(routine: routine)
                                .opacity(0.6)
                        }
                    } header: {
                        Text("Đã lưu trữ")
                            .roundedFont(.subheadline, weight: .semibold)
                            .foregroundStyle(AppColors.textMuted)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(AppColors.bgPrimary.ignoresSafeArea())
        .sheet(isPresented: $showingAddSheet) {
            AddRoutineSheet(name: $newRoutineName) {
                addRoutine()
            }
            .presentationDetents([.height(200)])
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
    
    func deleteRoutines(at offsets: IndexSet) {
        let active = viewModel.routines.filter { $0.isActive }
        for index in offsets {
            modelContext.delete(active[index])
        }
        viewModel.fetchData()
    }
}

// MARK: - Routine Row
struct RoutineRow: View {
    @Bindable var routine: Routine
    
    let icons = ["star.fill", "flame.fill", "book.fill", "figure.run", "bed.double.fill", "drop.fill", "leaf.fill", "heart.fill"]
    
    var body: some View {
        HStack {
            Menu {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        routine.icon = icon
                    } label: {
                        Label(icon, systemImage: icon)
                    }
                }
            } label: {
                Image(systemName: routine.icon)
                    .font(.title3)
                    .foregroundStyle(AppColors.forest)
                    .frame(width: 32)
            }
            .menuStyle(.borderlessButton)
            
            TextField("Tên", text: $routine.name)
                .roundedFont(.body)
                .foregroundStyle(AppColors.textPrimary)
            
            Toggle("", isOn: $routine.isActive)
                .toggleStyle(.switch)
                .tint(AppColors.forest)
        }
        .padding(.vertical, 4)
        .listRowBackground(AppColors.bgCard)
    }
}

// MARK: - Add Sheet
struct AddRoutineSheet: View {
    @Binding var name: String
    let onAdd: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Thêm thói quen mới")
                .roundedFont(.headline, weight: .bold)
                .foregroundStyle(AppColors.textPrimary)
            
            TextField("Tên thói quen", text: $name)
                .textFieldStyle(.plain)
                .padding()
                .background(AppColors.cream)
                .cornerRadius(12)
            
            HStack {
                Button("Huỷ") { dismiss() }
                    .foregroundStyle(AppColors.textMuted)
                
                Spacer()
                
                Button("Thêm") {
                    onAdd()
                }
                .disabled(name.isEmpty)
                .foregroundStyle(name.isEmpty ? AppColors.textMuted : AppColors.forest)
            }
        }
        .padding()
        .background(AppColors.bgPrimary.ignoresSafeArea())
    }
}

#Preview {
    GoalsView()
        .environment(AppViewModel())
}
