import SwiftUI

struct PlayerSelectionView: View {
    let players: [Player]
    @Binding var selectedPlayer: Player?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(players) { player in
                    Button {
                        selectedPlayer = player
                    } label: {
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(selectedPlayer?.id == player.id ? .blue : .gray)
                            
                            Text(player.name)
                                .font(.subheadline)
                                .foregroundColor(selectedPlayer?.id == player.id ? .blue : .primary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPlayer?.id == player.id ? Color.blue.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let context = CoreDataStack.preview.viewContext
    let player1 = Player(context: context)
    player1.id = UUID()
    player1.name = "Player 1"
    
    let player2 = Player(context: context)
    player2.id = UUID()
    player2.name = "Player 2"
    
    return PlayerSelectionView(
        players: [player1, player2],
        selectedPlayer: .constant(player1)
    )
    .environment(\.managedObjectContext, context)
} 