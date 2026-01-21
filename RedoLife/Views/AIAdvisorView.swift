import SwiftUI
import SwiftData

struct AIAdvisorView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: AITab
    
    init(initialTab: AITab = .coach) {
        _selectedTab = State(initialValue: initialTab)
    }
    
    // Coach State
    @State private var problemInput: String = ""
    @State private var suggestedRoutines: [SuggestedRoutine] = []
    @State private var isAnalyzing: Bool = false
    @State private var errorMessage: String?
    
    // Analysis State
    @State private var analysisResult: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Trợ lý Gemini")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                
                Spacer()
                
                Picker("", selection: $selectedTab) {
                    Text("Tư vấn").tag(AITab.coach)
                    Text("Phân tích").tag(AITab.analysis)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.gray.opacity(0.5))
                }
                .buttonStyle(.plain)
                .padding(.leading, 12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
            .padding(.bottom, 24)
            
            ScrollView {
                VStack(spacing: 24) {
                    if selectedTab == .coach {
                        coachView
                    } else {
                        analysisView
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .background(AppColors.bgPrimary.ignoresSafeArea())
    }
    
    // MARK: - Coach View
    var coachView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Input Card
            VStack(alignment: .leading, spacing: 16) {
                Text("Bạn đang gặp vấn đề gì?")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                
                TextField("Ví dụ: Tôi hay ngủ muộn, khó tập trung, lười đọc sách...", text: $problemInput, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(3...6)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.lightGray, lineWidth: 1)
                    )
                
                HStack {
                    if isAnalyzing {
                        ProgressView()
                            .controlSize(.small)
                        Text("Gemini đang suy nghĩ...")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        askGemini()
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Gợi ý giải pháp")
                        }
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(problemInput.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(problemInput.isEmpty || isAnalyzing)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
            
            if let error = errorMessage {
                Text("Lỗi: \(error)")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            // Results
            if !suggestedRoutines.isEmpty {
                Text("Gợi ý cho bạn")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.textPrimary)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 16) {
                    ForEach(suggestedRoutines) { routine in
                        SuggestedRoutineCard(routine: routine) {
                            addRoutine(from: routine)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Analysis View
    var analysisView: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Phân tích thói quen tháng này")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("AI sẽ phân tích dữ liệu hoàn thành thói quen của bạn để đưa ra nhận xét và lời khuyên giúp bạn tiến bộ hơn.")
                    .foregroundStyle(AppColors.textMuted)
                    .font(.subheadline)
                
                Button {
                    analyzeData()
                } label: {
                    HStack {
                        if isAnalyzing {
                            ProgressView().controlSize(.small)
                        } else {
                            Image(systemName: "chart.bar.doc.horizontal.fill")
                        }
                        Text(isAnalyzing ? "Đang phân tích..." : "Phân tích ngay")
                    }
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(isAnalyzing ? Color.gray.opacity(0.3) : Color.purple)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(isAnalyzing)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
            
            if !analysisResult.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "quote.opening")
                            .foregroundStyle(.purple)
                        Text("Nhận xét từ Gemini")
                            .font(.headline)
                            .foregroundStyle(.purple)
                    }
                    
                    Text(analysisResult)
                        .font(.system(size: 16))
                        .lineSpacing(6) // Approx 1.6 line height logic
                        .foregroundStyle(AppColors.textPrimary)
                        .textSelection(.enabled)
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
            }
        }
    }
    
    // MARK: - Actions
    func askGemini() {
        guard !problemInput.isEmpty else { return }
        isAnalyzing = true
        errorMessage = nil
        
        GeminiManager.shared.suggestHabits(problem: problemInput) { result in
            DispatchQueue.main.async {
                isAnalyzing = false
                switch result {
                case .success(let routines):
                    withAnimation {
                        self.suggestedRoutines = routines
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func analyzeData() {
        isAnalyzing = true
        // Flatten daily logs to array
        let allLogs = viewModel.monthlyLogs.values.flatMap { $0.values }
        
        GeminiManager.shared.analyzeData(routines: viewModel.routines, logs: allLogs) { result in
            DispatchQueue.main.async {
                isAnalyzing = false
                switch result {
                case .success(let text):
                    withAnimation {
                        self.analysisResult = text
                    }
                case .failure(let error):
                    self.analysisResult = "Lỗi phân tích: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func addRoutine(from suggestion: SuggestedRoutine) {
        let safeIcons = [
            "star.fill", "flame.fill", "book.fill", "figure.run",
            "bed.double.fill", "drop.fill", "leaf.fill", "heart.fill"
        ]
        
        var icon = suggestion.icon
        if !safeIcons.contains(icon) {
            // Map common keywords
            let lowerName = suggestion.name.lowercased()
            if lowerName.contains("chạy") || lowerName.contains("bộ") { icon = "figure.run" }
            else if lowerName.contains("sách") || lowerName.contains("học") { icon = "book.fill" }
            else if lowerName.contains("ngủ") || lowerName.contains("nghỉ") { icon = "bed.double.fill" }
            else if lowerName.contains("nước") || lowerName.contains("uống") { icon = "drop.fill" }
            else if lowerName.contains("gym") || lowerName.contains("tập") { icon = "flame.fill" }
            else if lowerName.contains("thiền") || lowerName.contains("thở") { icon = "leaf.fill" }
            else {
                // Randomly pick one to add variety instead of default green
                icon = safeIcons.randomElement() ?? "star.fill"
            }
        }
        
        let newRoutine = Routine(
            name: suggestion.name,
            icon: icon,
            order: viewModel.routines.count
        )
        modelContext.insert(newRoutine)
        viewModel.fetchData()
    }
}

enum AITab {
    case coach, analysis
}

struct SuggestedRoutineCard: View {
    let routine: SuggestedRoutine
    let onAdd: () -> Void
    @State private var isAdded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: routine.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text(routine.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
            }
            
            Text(routine.reason)
                .font(.subheadline)
                .foregroundStyle(AppColors.textMuted)
                .fixedSize(horizontal: false, vertical: true)
            
            Button {
                onAdd()
                isAdded = true
            } label: {
                Text(isAdded ? "Đã thêm" : "Thêm thói quen")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isAdded ? .green : .blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isAdded ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(isAdded)
        }
        .padding(16)
        .background(Color(hex: "F8F9FA"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}
