//
//  ConcordAppleDatePickerStyle.swift
//  ConcordUIApple
//
//  Shared Apple date/time picker styling helpers.
//

import ConcordUI
import SwiftUI

/// Compatibility overload used while the Date, Time, and DateTime flavor APIs
/// converge on a shared presentation-flavor type.
///
/// The Core flavor enums all expose the same `.picker` and `.components`
/// semantics. Keeping this helper generic prevents the Apple backend from
/// depending on one concrete flavor enum while that API migration settles.
@MainActor
@ViewBuilder
func styledDatePicker<Flavor, Label: View>(
    _ flavor: Flavor,
    @ViewBuilder content: () -> DatePicker<Label>
) -> some View {
    let usesComponents = String(describing: flavor) == "components"

    #if os(macOS)
    if usesComponents {
        content().datePickerStyle(.stepperField)
    } else {
        content().datePickerStyle(.compact)
    }
    #else
    if usesComponents {
        content().datePickerStyle(.wheel)
    } else {
        content().datePickerStyle(.compact)
    }
    #endif
}
