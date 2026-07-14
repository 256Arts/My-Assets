import SwiftUI

/// ``NavigationLink`` that opens a ``SymbolPicker``
struct SymbolPickerLink: View {
    
    @Binding var symbol: Symbol?
    
    var body: some View {
        NavigationLink {
            SymbolPicker(selected: Binding(get: {
                symbol ?? .defaultSymbol
            }, set: { newValue in
                symbol = newValue
            }))
            .scenePadding()
        } label: {
            ZStack {
                Circle()
                    .fill((symbol ?? .defaultSymbol).color.gradient)
                Image(systemName: (symbol ?? .defaultSymbol).rawValue)
                    .foregroundStyle(.white)
            }
            .frame(height: 42)
            .symbolVariant(.fill)
            .imageScale(.large)
            .font(.system(size: 17, weight: .medium))
            .frame(idealWidth: .infinity, maxWidth: .infinity)
        }
    }
}

#Preview {
    SymbolPickerLink(symbol: .constant(nil))
}
