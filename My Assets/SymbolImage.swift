import SwiftUI

struct SymbolImage: View {
    
    let symbol: Symbol
    
    var body: some View {
        Image(systemName: symbol.rawValue)
            .symbolVariant(.fill)
            .foregroundStyle(symbol.color)
            .font(.system(size: 17, weight: .medium))
            .frame(width: 32)
    }
}

#Preview {
    SymbolImage(symbol: .defaultSymbol)
}
