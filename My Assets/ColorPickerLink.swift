import SwiftUI

/// ``NavigationLink`` that opens a ``ColorPicker``
struct ColorPickerLink: View {
    
    @Binding var colorName: ColorName?
    
    var body: some View {
        NavigationLink {
            ColorPicker(selected: Binding(get: {
                colorName ?? .gray
            }, set: { newValue in
                colorName = newValue
            }))
            .scenePadding()
        } label: {
            ZStack {
                Circle()
                    .fill((colorName ?? .gray).color)
                Image(systemName: (colorName ?? .gray).rawValue)
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
    ColorPickerLink(colorName: .constant(nil))
}
