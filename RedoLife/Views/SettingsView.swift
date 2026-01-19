import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("userName") private var userName: String = ""
    @State private var showingResetAlert = false
    @State private var showingResetSuccess = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            Text("Cài đặt")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, 40)
            
            // Profile Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Hồ sơ")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textMuted)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Tên của bạn")
                            .foregroundStyle(AppColors.textPrimary)
                        
                        Spacer()
                        
                        TextField("Nhập tên", text: $userName)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(maxWidth: 200)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
                .card(padding: 0)
            }
            
            // Data Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Dữ liệu")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textMuted)
                
                VStack(spacing: 0) {
                    // Stats Info
                    HStack {
                        Text("Tổng XP")
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Text("\(viewModel.playerStats?.totalXP ?? 0)")
                            .foregroundStyle(AppColors.textMuted)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    
                    Divider()
                    
                    HStack {
                        Text("Chuỗi ngày tốt nhất")
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Text("\(viewModel.playerStats?.bestStreak ?? 0)")
                            .foregroundStyle(AppColors.textMuted)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    
                    Divider()
                    
                    HStack {
                        Text("Số thói quen")
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Text("\(viewModel.routines.count)")
                            .foregroundStyle(AppColors.textMuted)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
                .card(padding: 0)
            }
            
            // Danger Zone
            VStack(alignment: .leading, spacing: 16) {
                Text("Nguy hiểm")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textMuted)
                
                Button {
                    showingResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Xoá tất cả dữ liệu")
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .card(padding: 0)
            }
            
            Spacer()
            
            // App Info
            Text("RedoLife v1.0")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 40)
        .background(AppColors.bgPrimary.ignoresSafeArea())
        .alert("Xoá dữ liệu?", isPresented: $showingResetAlert) {
            Button("Huỷ", role: .cancel) {}
            Button("Xoá tất cả", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("Hành động này sẽ xoá tất cả thói quen, lịch sử và thống kê. Không thể hoàn tác.")
        }
        .alert("Đã xoá!", isPresented: $showingResetSuccess) {
            Button("OK") {}
        } message: {
            Text("Tất cả dữ liệu đã được xoá.")
        }
    }
    
    func resetAllData() {
        // Delete all routines
        for routine in viewModel.routines {
            modelContext.delete(routine)
        }
        
        // Reset player stats
        if let stats = viewModel.playerStats {
            stats.totalXP = 0
            stats.todayXP = 0
            stats.currentStreak = 0
            stats.bestStreak = 0
            stats.level = 1
            stats.lastActiveDate = nil
        }
        
        // Delete all logs
        do {
            try modelContext.delete(model: DailyLog.self)
        } catch {
            print("Failed to delete logs: \(error)")
        }
        
        viewModel.fetchData()
        showingResetSuccess = true
    }
}

#Preview {
    SettingsView()
        .environment(AppViewModel())
}
