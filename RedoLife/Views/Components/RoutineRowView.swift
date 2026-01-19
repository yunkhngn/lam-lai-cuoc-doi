import SwiftUI

struct RoutineRowView: View {
    var routine: Routine
    var isDone: Bool
    var onToggle: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: routine.icon)
                .font(.title2)
                .frame(width: 32)
                .foregroundStyle(isDone ? .primary : .secondary)
            
            Text(routine.name)
                .font(.body)
                .strikethrough(isDone)
                .foregroundStyle(isDone ? .secondary : .primary)
            
            Spacer()
            
            Button(action: onToggle) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundStyle(isDone ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Material.regular)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .onTapGesture {
            onToggle()
        }
    }
}
