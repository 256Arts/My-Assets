import SwiftUI

extension ShapeStyle where Self == AnyShapeStyle {

    /// Matches a grouped list row's background, for tiles laid out in a clear list row.
    /// visionOS rows are a material over the window glass, not an opaque color.
    static var groupedRowBackground: AnyShapeStyle {
        #if os(visionOS)
        AnyShapeStyle(.regularMaterial)
        #elseif canImport(UIKit)
        AnyShapeStyle(Color(UIColor.secondarySystemGroupedBackground))
        #else
        AnyShapeStyle(Color(NSColor.secondarySystemFill))
        #endif
    }
}
