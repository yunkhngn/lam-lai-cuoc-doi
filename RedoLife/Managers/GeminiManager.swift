import Foundation
import SwiftUI
import Combine

class GeminiManager: ObservableObject {
    static let shared = GeminiManager()
    
    @Published var apiKey: String = UserDefaults.standard.string(forKey: "gemini_api_key") ?? "" {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "gemini_api_key")
        }
    }
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro:generateContent"
    
    func suggestHabits(problem: String, completion: @escaping (Result<[SuggestedRoutine], Error>) -> Void) {
        let prompt = """
        Bạn là một chuyên gia về phát triển bản thân và Coach xây dựng thói quen.
        Người dùng đang gặp vấn đề: "\(problem)".
        
        Hãy gợi ý 3-5 hành động CỤ THỂ, CÓ THỂ ĐO LƯỜNG (quantifiable) và thực hiện được HẰNG NGÀY trong thời gian ngắn (Micro-habits).
        TRÁNH các lời khuyên chung chung như "ngủ sớm", "bớt ăn vặt".
        HÃY dùng động từ mạnh và con số cụ thể.
        
        Ví dụ TỐT: "Đọc 2 trang sách", "Plank 1 phút", "Uống 1 ly nước ấm", "Viết 3 điều biết ơn", "Đi bộ 10 phút".
        Ví dụ XẤU: "Đọc sách", "Tập thể dục", "Uống nước", "Suy nghĩ tích cực".
        
        Trả về kết quả dưới dạng JSON Array thuần tuý field "name", "icon" (SF Symbols), "reason".
        """
        
        generate(prompt: prompt) { result in
            switch result {
            case .success(let text):
                // Clean markdown code blocks aggressively
                var cleanText = text
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```JSON", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Sometimes Gemini adds unexpected text before/after
                if let startIndex = cleanText.firstIndex(of: "["),
                   let endIndex = cleanText.lastIndex(of: "]") {
                    cleanText = String(cleanText[startIndex...endIndex])
                }
                
                print("[Gemini] Cleaned Response: \(cleanText)") // Debug log
                
                guard let data = cleanText.data(using: .utf8) else {
                    completion(.failure(URLError(.cannotDecodeContentData)))
                    return
                }
                
                do {
                    let routines = try JSONDecoder().decode([SuggestedRoutine].self, from: data)
                    completion(.success(routines))
                } catch {
                    print("[Gemini] JSON Decode Error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func analyzeData(routines: [Routine], logs: [DailyLog], completion: @escaping (Result<String, Error>) -> Void) {
        // Construct simple data summary
        let completedCount = logs.filter { $0.isDone }.count
        let totalLogs = logs.count // This might be raw logs count
        let completionRate = totalLogs > 0 ? Double(completedCount) / Double(totalLogs) : 0
        
        // Detailed routine performance
        var routineSummary = ""
        for routine in routines where routine.isActive {
            let routineLogs = logs.filter { $0.routine?.id == routine.id }
            let done = routineLogs.filter { $0.isDone }.count
            routineSummary += "- \(routine.name): Hoàn thành \(done) lần.\n"
        }
        
        let prompt = """
        Bạn là AI phân tích dữ liệu cuộc sống (Life Analyst). Dưới đây là dữ liệu thói quen của người dùng trong tháng qua:
        - Tổng số lần hoàn thành: \(completedCount)
        - Tỉ lệ chung: \(Int(completionRate * 100))%
        - Chi tiết từng thói quen:
        \(routineSummary)
        
        Hãy đưa ra nhận xét:
        1. Khen ngợi điểm tốt.
        2. Chỉ ra điểm cần cải thiện (những thói quen ít làm).
        3. Lời khuyên động viên ngắn gọn, chân thành, giọng văn thân thiện như một người bạn.
        Viết ngắn gọn dưới 150 từ.
        """
        
        generate(prompt: prompt, completion: completion)
    }
    
    private func generate(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(NSError(domain: "Gemini", code: 401, userInfo: [NSLocalizedDescriptionKey: "Chưa nhập API Key"])))
            return
        }
        
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let content = candidates.first?["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    DispatchQueue.main.async {
                        completion(.success(text))
                    }
                } else {
                    completion(.failure(URLError(.cannotDecodeContentData)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct SuggestedRoutine: Codable, Identifiable {
    var id = UUID()
    let name: String
    let icon: String
    let reason: String
    
    enum CodingKeys: String, CodingKey {
        case name, icon, reason
    }
}
