//
//  ToolbarItemVisibilityPriority+.swift
//  My Assets
//

import SwiftUI

extension ToolbarItemVisibilityPriority {

    /// Keeps a primary action in the toolbar, overflowing it last when space is tight.
    /// Falls back to `.automatic` on platforms where `.high` is unavailable (visionOS).
    static var primaryAction: ToolbarItemVisibilityPriority {
        #if os(visionOS)
        .automatic
        #else
        .high
        #endif
    }

}
