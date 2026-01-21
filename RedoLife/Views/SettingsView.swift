import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("morningReminderHour") private var morningHour: Int = 9
    @AppStorage("eveningReminderHour") private var eveningHour: Int = 21
    @AppStorage("quoteIntervalHours") private var quoteIntervalHours: Int = 1
    
    @State private var showingResetAlert = false
    @State private var showingResetSuccess = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
                
                // Notification Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Thông báo")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textMuted)
                    
                    VStack(spacing: 0) {
                        // Toggle
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(AppColors.green)
                            Text("Bật thông báo")
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            Toggle("", isOn: $notificationsEnabled)
                                .toggleStyle(.switch)
                                .tint(AppColors.green)
                                .onChange(of: notificationsEnabled) { _, newValue in
                                    updateNotifications()
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        
                        if notificationsEnabled {
                            Divider()
                            
                            // Morning time
                            HStack {
                                Image(systemName: "sunrise.fill")
                                    .foregroundStyle(.orange)
                                Text("Nhắc buổi sáng")
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Picker("", selection: $morningHour) {
                                    ForEach(5..<12) { hour in
                                        Text("\(hour):00").tag(hour)
                                    }
                                }
                                .pickerStyle(.menu)
                                .onChange(of: morningHour) { _, _ in
                                    updateNotifications()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            
                            Divider()
                            
                            // Evening time
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundStyle(.purple)
                                Text("Nhắc buổi tối")
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Picker("", selection: $eveningHour) {
                                    ForEach(18..<24) { hour in
                                        Text("\(hour):00").tag(hour)
                                    }
                                }
                                .pickerStyle(.menu)
                                .onChange(of: eveningHour) { _, _ in
                                    updateNotifications()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            // Quote Frequency
                            Divider()
                            
                            HStack {
                                Image(systemName: "quote.bubble.fill")
                                    .foregroundStyle(AppColors.green)
                                Text("Tần suất Quotes")
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Picker("", selection: $quoteIntervalHours) {
                                    Text("1 giờ").tag(1)
                                    Text("2 giờ").tag(2)
                                    Text("3 giờ").tag(3)
                                    Text("4 giờ").tag(4)
                                }
                                .pickerStyle(.menu)
                                .onChange(of: quoteIntervalHours) { _, _ in
                                    updateNotifications()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                    }
                    .card(padding: 0)
                .animation(.easeInOut(duration: 0.2), value: notificationsEnabled)
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
            
            // App Info
            Text("FixMyLife v1.1 | Developed by @yun.khngn")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            
            // Dev Tools (Temporary)
            if true {
                VStack(spacing: 12) {
                    Text("Developer Tools")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Button {
                            viewModel.injectSampleData()
                        } label: {
                            HStack {
                                Image(systemName: "hammer.fill")
                                Text("Inject")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange)
                            .cornerRadius(8)
                        }
                        
                        Button {
                            viewModel.deleteSampleData()
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Clean")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.red)
                            .cornerRadius(8)
                        }
                        
                        Button {
                            viewModel.exportData()
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Backup")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 40)
        }
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
    
    func updateNotifications() {
        if notificationsEnabled {
            NotificationManager.shared.scheduleReminders(
                morningHour: morningHour,
                eveningHour: eveningHour,
                quoteInterval: quoteIntervalHours
            )
        } else {
            NotificationManager.shared.cancelAllNotifications()
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
