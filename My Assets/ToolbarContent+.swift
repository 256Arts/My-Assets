import SwiftUI

extension ToolbarContent {

    /// Keeps a primary action in the toolbar, overflowing it last when space is tight.
    /// No-op before OS 27, which has no toolbar item visibility priority, and on
    /// visionOS, where `.high` is unavailable.
    @ToolbarContentBuilder
    func primaryActionVisibilityPriority() -> some ToolbarContent {
        #if os(visionOS)
        self
        #else
        if #available(iOS 27, macOS 27, watchOS 27, *) {
            self.visibilityPriority(.high)
        } else {
            self
        }
        #endif
    }

}
