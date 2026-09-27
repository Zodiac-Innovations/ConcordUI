import Combine
import ConcordUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class ConcordApplePlatform: ConcordPlatform, ObservableObject {
    @Published public private(set) var currentPresentation: ConcordPresentation?
    @Published public private(set) var refreshRevision: UInt = 0

    public init() {}

    public func displayPresentation(_ presentation: ConcordPresentation) {
        currentPresentation = presentation
        refreshRevision &+= 1
    }

    public func refreshPresentation(_ presentation: ConcordPresentation) {
        guard currentPresentation === presentation else { return }
        refreshRevision &+= 1
    }
}

// MARK: - Root View

@MainActor
public struct ConcordAppleRootView: View {
    @ObservedObject private var platform: ConcordApplePlatform

    public init(platform: ConcordApplePlatform) {
        self.platform = platform
    }

    public var body: some View {
        let revision = platform.refreshRevision

        GeometryReader { geometry in
            ScrollView(.vertical) {
                Group {
                    if let presentation = platform.currentPresentation {
                        #if os(macOS)
                        if let workStack = presentation.root as? ConcordWorkStack {
                            // A desktop WorkStack owns its interior padding so its footer
                            // can extend all the way to the presentation window edges.
                            ConcordAppleRenderer.render(workStack, revision: revision)
                        } else if let rootStack = presentation.root as? ConcordVStack,
                                  rootStack.elements.count == 1,
                                  let workStack = rootStack.elements.first as? ConcordWorkStack {
                            ConcordAppleRenderer.render(workStack, revision: revision)
                        } else {
                            ConcordAppleRenderer.render(presentation.root, revision: revision)
                                .padding(.horizontal, 10)
                        }
                        #else
                        ConcordAppleRenderer.render(presentation.root, revision: revision)
                            .padding(.horizontal, 10)
                        #endif
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    minHeight: geometry.size.height,
                    alignment: .topLeading
                )
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
    }
}

// MARK: - Shared Apple Presentation Helpers

@MainActor
private func appleColor(_ color: ConcordColor) -> Color {
    switch color {
    case .rgba(let red, let green, let blue, let alpha):
        return Color(red: red, green: green, blue: blue, opacity: alpha)

    case .semantic(let semantic):
        switch semantic {
        case .primary:
            return .primary
        case .secondary:
            return .secondary
        case .accent:
            return .accentColor
        case .error:
            return .red
        case .warning:
            return .orange
        case .success:
            return .green
        case .background:
            #if canImport(UIKit)
            return Color(uiColor: .systemBackground)
            #elseif canImport(AppKit)
            return Color(nsColor: .windowBackgroundColor)
            #else
            return .clear
            #endif
        }
    }
}

@MainActor
private func appleMaterialColor(_ material: ConcordMaterial) -> Color {
    appleColor(ConcordMaterial.resolvedColor(material))
}

@MainActor
@ViewBuilder
private func appleMaterialBackground(_ material: ConcordMaterial) -> some View {
    let resolved = ConcordMaterialRegistry.shared.resolve(material)
    switch resolved.type {
    case .color(let color):
        appleColor(color)
    case .image(let name):
        Image(name).resizable().scaledToFill()
    case .registered:
        appleColor(.black)
    }
}

@MainActor
private func validationState(_ element: ConcordElement) -> ConcordValidationState {
    (element as? any ConcordValidatable)?.validationState ?? .unvalidated
}

@MainActor
@ViewBuilder
private func validationLabel(_ label: String, element: ConcordElement) -> some View {
    HStack(spacing: 0) {
        Text(label)
        if element.isRequired && element.requiredIndicator == .redAsterisk {
            Text(" *").foregroundColor(appleMaterialColor(.requiredIndicator))
        }
    }
}

@MainActor
private func showsInvalidBorder(_ element: ConcordElement) -> Bool {
    guard validationState(element) == .invalid else { return false }
    return element.invalidIndicator == .redBorder || element.invalidIndicator == .redBorderAndErrorText
}

@MainActor
private func showsInvalidError(_ element: ConcordElement) -> Bool {
    guard validationState(element) == .invalid else { return false }
    return element.invalidIndicator == .errorText || element.invalidIndicator == .redBorderAndErrorText
}

@MainActor
@ViewBuilder
private func validationMetadata(_ element: ConcordElement) -> some View {
    if element.isRequired && element.requiredIndicator == .requiredText {
        Text(ConcordString.required).font(.caption)
    }

    if let help = element.helpText, !help.isEmpty {
        Text(help).font(.caption)
    }

    if showsInvalidError(element), let error = element.errorText, !error.isEmpty {
        Text(error).font(.caption).foregroundColor(appleMaterialColor(.invalidIndicator))
    }
}

@MainActor
@ViewBuilder
private func styledDatePicker<Label: View>(
    components: Bool,
    @ViewBuilder content: () -> DatePicker<Label>
) -> some View {
    #if os(macOS)
    if components {
        content().datePickerStyle(.stepperField)
    } else {
        content().datePickerStyle(.compact)
    }
    #else
    if components {
        content().datePickerStyle(.wheel)
    } else {
        content().datePickerStyle(.compact)
    }
    #endif
}

// MARK: - Editable Element Views

@MainActor
private struct ConcordAppleTextElementView: View {
    let element: ConcordTextElement
    let revision: UInt

    @FocusState private var isFocused: Bool

    private var binding: Binding<String> {
        Binding(
            get: {
                _ = revision
                return element.value ?? ""
            },
            set: { element.userChangedValue(to: $0) }
        )
    }

    /// Editable text should always present a visible touch/edit target.
    /// Validation red takes priority; an explicit element foreground color is next;
    /// otherwise ConcordUI uses a light gray field frame.
    private var fieldFrameColor: Color {
        if showsInvalidBorder(element) {
            return appleMaterialColor(.invalidIndicator)
        }
        if let foreground = element.foregroundColor {
            return appleColor(foreground)
        }
        return appleMaterialColor(.fieldFrame)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !element.label.isEmpty {
                validationLabel(element.label, element: element)
            }

            Group {
                if element.flavor == .password {
                    SecureField(element.placeholder ?? "", text: binding)
                        .textFieldStyle(.plain)
                } else {
                    TextField(element.placeholder ?? "", text: binding)
                        .textFieldStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .foregroundColor(element.resolvedTextColor.map(appleColor))
            .focused($isFocused)
            .contentShape(Rectangle())
            .onTapGesture {
                if element.isEnabled && !element.isReadOnly {
                    isFocused = true
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(fieldFrameColor, lineWidth: 1)
            }

            validationMetadata(element)
        }
        .disabled(!element.isEnabled || element.isReadOnly)
    }
}

@MainActor
private struct ConcordAppleIntElementView: View {
    let element: ConcordIntElement
    let revision: UInt

    private var value: ConcordInt? {
        _ = revision
        return element.value
    }

    private var textBinding: Binding<String> {
        Binding(
            get: { value.map { String($0) } ?? "" },
            set: { text in
                if text.isEmpty {
                    element.userChangedValue(to: nil)
                } else if let number = ConcordInt(text) {
                    element.userChangedValue(to: number)
                }
            }
        )
    }

    private var concreteBinding: Binding<ConcordInt> {
        Binding(
            get: { value ?? element.range?.lowerBound ?? 0 },
            set: { element.userChangedValue(to: $0) }
        )
    }

    private var sliderBinding: Binding<Double> {
        Binding(
            get: { Double(value ?? element.effectiveRange.lowerBound) },
            set: { element.userChangedValue(to: ConcordInt($0.rounded())) }
        )
    }

    private var displayLabel: String {
        let display = value.map { String($0) } ?? ConcordString.nilValue
        return element.label.isEmpty ? display : "\(element.label): \(display)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if element.flavor == .input || element.flavor == .combo {
                VStack(alignment: .leading, spacing: 4) {
                    if !element.label.isEmpty {
                        validationLabel(element.label, element: element)
                    }

                    TextField(element.placeholder ?? "", text: textBinding)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(element.resolvedTextColor.map(appleColor))
                }
            }

            if element.flavor == .slider || element.flavor == .combo {
                let range = element.effectiveRange
                validationLabel(displayLabel, element: element)
                Slider(
                    value: sliderBinding,
                    in: Double(range.lowerBound)...Double(range.upperBound),
                    step: Double(element.step)
                )
            }

            if element.flavor == .stepper || element.flavor == .combo {
                let stride = Int(clamping: element.step)
                if let range = element.range {
                    Stepper(value: concreteBinding, in: range, step: stride) {
                        validationLabel(displayLabel, element: element)
                    }
                } else {
                    Stepper(value: concreteBinding, step: stride) {
                        validationLabel(displayLabel, element: element)
                    }
                }
            }

            validationMetadata(element)
        }
        .padding(showsInvalidBorder(element) ? 3 : 0)
        .overlay {
            if showsInvalidBorder(element) {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(appleMaterialColor(.invalidIndicator), lineWidth: 1)
            }
        }
        .disabled(!element.isEnabled || element.isReadOnly)
    }
}

@MainActor
private struct ConcordAppleFloatElementView: View {
    let element: ConcordFloatElement
    let revision: UInt

    private var value: ConcordFloat? {
        _ = revision
        return element.value
    }

    private var textBinding: Binding<String> {
        Binding(
            get: { value.map { String($0) } ?? "" },
            set: { text in
                if text.isEmpty {
                    element.userChangedValue(to: nil)
                } else if let number = ConcordFloat(text) {
                    element.userChangedValue(to: number)
                }
            }
        )
    }

    private var concreteBinding: Binding<ConcordFloat> {
        Binding(
            get: { value ?? element.range?.lowerBound ?? 0 },
            set: { element.userChangedValue(to: $0) }
        )
    }

    private var displayLabel: String {
        let display = value.map { String($0) } ?? ConcordString.nilValue
        return element.label.isEmpty ? display : "\(element.label): \(display)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if element.flavor == .input || element.flavor == .combo {
                VStack(alignment: .leading, spacing: 4) {
                    if !element.label.isEmpty {
                        validationLabel(element.label, element: element)
                    }

                    TextField(element.placeholder ?? "", text: textBinding)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(element.resolvedTextColor.map(appleColor))
                }
            }

            if element.flavor == .slider || element.flavor == .combo {
                let range = element.effectiveRange
                validationLabel(displayLabel, element: element)
                Slider(value: concreteBinding, in: range, step: element.step)
            }

            if element.flavor == .stepper || element.flavor == .combo {
                if let range = element.range {
                    Stepper(value: concreteBinding, in: range, step: element.step) {
                        validationLabel(displayLabel, element: element)
                    }
                } else {
                    Stepper(value: concreteBinding, step: element.step) {
                        validationLabel(displayLabel, element: element)
                    }
                }
            }

            validationMetadata(element)
        }
        .padding(showsInvalidBorder(element) ? 3 : 0)
        .overlay {
            if showsInvalidBorder(element) {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(appleMaterialColor(.invalidIndicator), lineWidth: 1)
            }
        }
        .disabled(!element.isEnabled || element.isReadOnly)
    }
}

@MainActor
private struct ConcordAppleDateElementView: View {
    let element: ConcordDateElement
    let revision: UInt

    private var value: Date? {
        _ = revision
        return element.value
    }

    private var binding: Binding<Date> {
        Binding(
            get: { value ?? Date() },
            set: { element.userChangedValue(to: $0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if element.isReadOnly {
                HStack {
                    if !element.label.isEmpty {
                        validationLabel(element.label, element: element)
                    }
                    if let value {
                        Text(value, style: .date)
                    } else {
                        Text(ConcordString.unavailableValue)
                    }
                }
            } else if let lower = element.minimumDate, let upper = element.maximumDate {
                styledDatePicker(components: element.flavor == .components) {
                    DatePicker(selection: binding, in: lower...upper, displayedComponents: .date) {
                        validationLabel(element.label, element: element)
                    }
                }
            } else if let lower = element.minimumDate {
                styledDatePicker(components: element.flavor == .components) {
                    DatePicker(selection: binding, in: lower..., displayedComponents: .date) {
                        validationLabel(element.label, element: element)
                    }
                }
            } else if let upper = element.maximumDate {
                styledDatePicker(components: element.flavor == .components) {
                    DatePicker(selection: binding, in: ...upper, displayedComponents: .date) {
                        validationLabel(element.label, element: element)
                    }
                }
            } else {
                styledDatePicker(components: element.flavor == .components) {
                    DatePicker(selection: binding, displayedComponents: .date) {
                        validationLabel(element.label, element: element)
                    }
                }
            }

            validationMetadata(element)
        }
        .disabled(!element.isEnabled)
    }
}

@MainActor
private struct ConcordAppleTimeElementView: View {
    let element: ConcordTimeElement
    let revision: UInt

    private var value: Date? {
        _ = revision
        return element.value
    }

    private var binding: Binding<Date> {
        Binding(
            get: { value ?? Date() },
            set: { element.userChangedValue(to: $0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if element.isReadOnly {
                HStack {
                    if !element.label.isEmpty {
                        validationLabel(element.label, element: element)
                    }
                    if let value {
                        Text(value, style: .time)
                    } else {
                        Text(ConcordString.unavailableValue)
                    }
                }
            } else {
                styledDatePicker(components: element.flavor == .components) {
                    DatePicker(selection: binding, displayedComponents: .hourAndMinute) {
                        validationLabel(element.label, element: element)
                    }
                }
            }

            validationMetadata(element)
        }
        .disabled(!element.isEnabled)
    }
}

@MainActor
private struct ConcordAppleDateTimeElementView: View {
    let element: ConcordDateTimeElement
    let revision: UInt

    private var value: Date? {
        _ = revision
        return element.value
    }

    private var binding: Binding<Date> {
        Binding(
            get: { value ?? Date() },
            set: { element.userChangedValue(to: $0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if element.isReadOnly {
                HStack {
                    if !element.label.isEmpty {
                        validationLabel(element.label, element: element)
                    }
                    if let value {
                        Text(value, style: .date)
                        Text(value, style: .time)
                    } else {
                        Text(ConcordString.unavailableValue)
                    }
                }
            } else {
                styledDatePicker(components: element.flavor == .components) {
                    DatePicker(selection: binding, displayedComponents: [.date, .hourAndMinute]) {
                        validationLabel(element.label, element: element)
                    }
                }
            }

            validationMetadata(element)
        }
        .disabled(!element.isEnabled)
    }
}

@MainActor
private struct ConcordAppleSelectionElementView: View {
    let selection: any ConcordSelectionPresenting
    let element: ConcordElement
    let revision: UInt

    private var indexBinding: Binding<Int> {
        Binding(
            get: {
                _ = revision
                return selection.selectedIndex ?? -1
            },
            set: {
                if $0 >= 0 {
                    selection.userSelected(index: $0)
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !selection.label.isEmpty {
                validationLabel(selection.label, element: element)
            }
            control
            validationMetadata(element)
        }
        .disabled(!element.isEnabled || element.isReadOnly)
    }

    @ViewBuilder
    private var control: some View {
        switch selection.flavor {
        case .popup:
            Picker("", selection: indexBinding) {
                ForEach(0..<selection.itemCount, id: \.self) { index in
                    Text(selection.displayText(at: index)).tag(index)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)

        case .spinner:
            #if os(macOS)
            Picker("", selection: indexBinding) {
                ForEach(0..<selection.itemCount, id: \.self) { index in
                    Text(selection.displayText(at: index)).tag(index)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            #else
            Picker("", selection: indexBinding) {
                ForEach(0..<selection.itemCount, id: \.self) { index in
                    Text(selection.displayText(at: index)).tag(index)
                }
            }
            .labelsHidden()
            .pickerStyle(.wheel)
            #endif

        case .segmented:
            Picker("", selection: indexBinding) {
                ForEach(0..<selection.itemCount, id: \.self) { index in
                    Text(selection.displayText(at: index)).tag(index)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)

        case .radio:
            VStack(alignment: .leading, spacing: 4) {
                ForEach(0..<selection.itemCount, id: \.self) { index in
                    Button {
                        selection.userSelected(index: index)
                    } label: {
                        Label(
                            selection.displayText(at: index),
                            systemImage: selection.selectedIndex == index ? "largecircle.fill.circle" : "circle"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

        case .list:
            VStack(alignment: .leading, spacing: 2) {
                ForEach(0..<selection.itemCount, id: \.self) { index in
                    Button {
                        selection.userSelected(index: index)
                    } label: {
                        HStack {
                            Text(selection.displayText(at: index))
                            Spacer()
                            if selection.selectedIndex == index {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 3)

                    if index + 1 < selection.itemCount {
                        Divider()
                    }
                }
            }
        }
    }
}

// MARK: - Renderer

@MainActor
private enum ConcordAppleRenderer {
    static func render(_ element: ConcordElement, revision: UInt) -> AnyView {
        guard element.isVisible else {
            return AnyView(EmptyView())
        }

        let rendered: AnyView

        if let label = element as? ConcordLabel {
            rendered = renderLabel(label)
        } else if let button = element as? ConcordButton {
            rendered = renderButton(button)
        } else if let bool = element as? ConcordBoolElement {
            rendered = renderBoolElement(bool)
        } else if let text = element as? ConcordTextElement {
            rendered = AnyView(ConcordAppleTextElementView(element: text, revision: revision))
        } else if let int = element as? ConcordIntElement {
            rendered = AnyView(ConcordAppleIntElementView(element: int, revision: revision))
        } else if let float = element as? ConcordFloatElement {
            rendered = AnyView(ConcordAppleFloatElementView(element: float, revision: revision))
        } else if let date = element as? ConcordDateElement {
            rendered = AnyView(ConcordAppleDateElementView(element: date, revision: revision))
        } else if let time = element as? ConcordTimeElement {
            rendered = AnyView(ConcordAppleTimeElementView(element: time, revision: revision))
        } else if let dateTime = element as? ConcordDateTimeElement {
            rendered = AnyView(ConcordAppleDateTimeElementView(element: dateTime, revision: revision))
        } else if let raster = element as? ConcordRasterElement {
            rendered = renderRasterElement(raster)
        } else if let image = element as? ConcordImage {
            let imageView = renderImageElement(image)
            rendered = image.fillsSquare
                ? AnyView(imageView.aspectRatio(1, contentMode: .fit))
                : imageView
        } else if let progress = element as? ConcordProgressElement {
            rendered = renderProgressElement(progress)
        } else if let selection = element as? any ConcordSelectionPresenting {
            rendered = AnyView(
                ConcordAppleSelectionElementView(
                    selection: selection,
                    element: element,
                    revision: revision
                )
            )
        } else if let titleActions = element as? ConcordTitleActionElement {
            rendered = renderTitleActions(titleActions, revision: revision)
        } else if let actionGroup = element as? ConcordActionGroupButton {
            rendered = renderActionGroupButton(actionGroup)
        } else if let expander = element as? ConcordExpander {
            rendered = renderExpander(expander, revision: revision)
        } else if let abStack = element as? ConcordABStack {
            rendered = AnyView(
                ConcordAppleABStackView(element: abStack, revision: revision)
            )
        } else if let workStack = element as? ConcordWorkStack {
            #if os(macOS)
            rendered = AnyView(
                VStack(alignment: .leading, spacing: 0) {
                    render(workStack.main, revision: revision)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(appleMaterialBackground(workStack.upperBackgroundMaterial))
                    render(workStack.bottom, revision: revision)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: workStack.bottomHeight,
                            maxHeight: workStack.bottomHeight,
                            alignment: .trailing
                        )
                        .background(appleMaterialBackground(workStack.lowerBackgroundMaterial))
                }
            )
            #else
            let bottomAlignment: Alignment
            switch workStack.bottom.horizontalJustification {
            case .center:
                bottomAlignment = .center
            case .right:
                bottomAlignment = .trailing
            default:
                bottomAlignment = .leading
            }
            rendered = AnyView(
                VStack(alignment: .leading, spacing: workStack.bottom.spacing) {
                    render(workStack.main, revision: revision)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    ForEach(Array(workStack.bottom.elements.enumerated()), id: \.element.id) { _, child in
                        render(child, revision: revision)
                            .frame(maxWidth: .infinity, alignment: bottomAlignment)
                    }
                }
                .padding(workStack.bottom.edge)
                .frame(maxWidth: .infinity, alignment: .leading)
            )
            #endif
        } else if let vstack = element as? ConcordVStack {
            rendered = AnyView(
                VStack(alignment: .leading, spacing: vstack.spacing) {
                    ForEach(Array(vstack.elements.enumerated()), id: \.element.id) { _, child in
                        render(child, revision: revision)
                    }
                }
                .padding(vstack.edge)
            )
        } else if let hstack = element as? ConcordHStack {
            rendered = AnyView(
                HStack(alignment: .center, spacing: hstack.spacing) {
                    ForEach(Array(hstack.elements.enumerated()), id: \.element.id) { _, child in
                        render(child, revision: revision)
                    }
                }
                .padding(hstack.edge)
            )
        } else if element is ConcordLine {
            rendered = AnyView(Divider())
        } else if element is ConcordSpacer {
            rendered = AnyView(Spacer())
        } else if element is ConcordDivider {
            rendered = AnyView(Divider())
        } else {
            rendered = AnyView(EmptyView())
        }

        return applyElementPresentation(to: rendered, element: element)
    }

    private static func renderActionGroupButton(
        _ element: ConcordActionGroupButton
    ) -> AnyView {
        guard let group = element.resolvedActionGroup(),
              !group.actions.isEmpty else {
            return AnyView(EmptyView())
        }

        return AnyView(
            Menu {
                ForEach(Array(group.actions.enumerated()), id: \.offset) { _, action in
                    Button(action.title) {
                        action.invoke()
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    if let image = element.image {
                        renderTitleActionImage(image)
                            .frame(width: 20, height: 20)
                    }
                    Text(element.resolvedTitle())
                }
            }
            .disabled(!element.isEnabled)
        )
    }

    private static func renderTitleActions(
        _ element: ConcordTitleActionElement,
        revision: UInt
    ) -> AnyView {
        switch element.flavor {
        case .vlist:
            return AnyView(
                VStack(alignment: .leading, spacing: element.spacing) {
                    ForEach(Array(element.elements.enumerated()), id: \.element.id) { _, child in
                        render(child, revision: revision)
                    }
                }
                .disabled(!element.isEnabled)
                .padding(element.edge)
            )

        case .stack:
            return AnyView(
                HStack(alignment: .center, spacing: element.spacing) {
                    ForEach(Array(element.elements.enumerated()), id: \.element.id) { _, child in
                        render(child, revision: revision)
                    }
                }
                .disabled(!element.isEnabled)
                .padding(element.edge)
            )

        case .popup:
            return AnyView(
                Menu {
                    ForEach(Array(element.actions.enumerated()), id: \.offset) { index, item in
                        Button(item.title) {
                            element.activateAction(at: index)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        if let image = element.image {
                            renderTitleActionImage(image)
                                .frame(width: 20, height: 20)
                        }
                        if let label = element.label, !label.isEmpty {
                            Text(label)
                        }
                    }
                }
                .disabled(!element.isEnabled)
                .padding(element.edge)
            )
        }
    }

    private static func renderTitleActionImage(_ image: ConcordImageData) -> AnyView {
        switch image {
        case .asset(let name):
            return renderAssetImage(named: name)
        case .icon(let icon):
            return AnyView(
                Image(systemName: appleSystemName(icon))
                    .resizable()
                    .scaledToFit()
            )
        }
    }

    private static func renderButton(_ element: ConcordButton) -> AnyView {
        let disabled = !element.isEnabled || element.isReadOnly
        let rendered: AnyView

        switch element.flavor {
        case .text:
            #if os(macOS)
            if let accessButton = element as? ConcordAccessButton,
               accessButton.presentation == .button {
                rendered = AnyView(
                    Button(element.title) { element.activate() }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(appleMaterialColor(.buttonBackground))
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(appleMaterialColor(.buttonFrame), lineWidth: 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .disabled(disabled)
                )
            } else {
                rendered = AnyView(
                    Button(element.title) { element.activate() }
                        .buttonStyle(.plain)
                        .disabled(disabled)
                )
            }
            #else
            rendered = AnyView(
                Button(element.title) { element.activate() }
                    .disabled(disabled)
            )
            #endif

        case .roundedRectangle:
            if #available(iOS 15.0, macOS 12.0, *) {
                rendered = AnyView(
                    Button(element.title) { element.activate() }
                        .buttonStyle(.borderedProminent)
                        .disabled(disabled)
                )
            } else {
                rendered = AnyView(
                    Button(element.title) { element.activate() }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(appleMaterialColor(.buttonBackground))
                        .foregroundColor(appleMaterialColor(.buttonForeground))
                        .cornerRadius(8)
                        .disabled(disabled)
                )
            }

        case .icon:
            let icon = element.icon ?? .information
            rendered = AnyView(
                Button {
                    element.activate()
                } label: {
                    Image(systemName: appleSystemName(icon))
                        .imageScale(.large)
                        .accessibilityLabel(Text(element.accessibilityText ?? element.title))
                }
                .buttonStyle(.plain)
                .disabled(disabled)
            )

        case .textIcon:
            let icon = element.icon ?? .information
            rendered = AnyView(
                Button {
                    element.activate()
                } label: {
                    HStack(spacing: 6) {
                        Text(element.title)
                        Image(systemName: appleSystemName(icon))
                            .imageScale(.medium)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text(element.accessibilityText ?? element.title))
                }
                .buttonStyle(.plain)
                .disabled(disabled)
            )
        }

        switch element.role {
        case .normal:
            return rendered
        case .defaultAction:
            if #available(iOS 14.0, macOS 11.0, *) {
                return AnyView(rendered.keyboardShortcut(.defaultAction))
            }
            return rendered
        case .cancel:
            if #available(iOS 14.0, macOS 11.0, *) {
                return AnyView(rendered.keyboardShortcut(.cancelAction))
            }
            return rendered
        case .destructive:
            if #available(iOS 15.0, macOS 12.0, *) {
                return AnyView(rendered.tint(appleMaterialColor(.destructiveAction)))
            }
            return AnyView(rendered.foregroundColor(appleMaterialColor(.destructiveAction)))
        }
    }

    private static func renderLabel(_ element: ConcordLabel) -> AnyView {
        var text = Text(element.label.map { "\($0): \(element.text)" } ?? element.text)

        if let style = element.textStyle {
            if style.isBold { text = text.bold() }
            if style.isItalic { text = text.italic() }
            if style.isUnderlined { text = text.underline() }
        }

        return AnyView(text)
    }

    private static func renderRasterElement(_ element: ConcordRasterElement) -> AnyView {
        AnyView(
            GeometryReader { geometry in
                let displayedSize = ConcordSize(
                    width: ConcordFloat(geometry.size.width),
                    height: ConcordFloat(geometry.size.height)
                )
                let commands = element.imageCommands(in: displayedSize)

                ZStack(alignment: .topLeading) {
                    ForEach(Array(commands.enumerated()), id: \.offset) { _, command in
                        let rect = command.rect
                        rasterImage(command)
                            .frame(
                                width: CGFloat(rect.size.width),
                                height: CGFloat(rect.size.height)
                            )
                            .clipped()
                            .position(
                                x: CGFloat(rect.origin.x + rect.size.width / 2),
                                y: CGFloat(rect.origin.y + rect.size.height / 2)
                            )
                            .zIndex(Double(command.zOrder))
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        )
    }

    private static func rasterImage(_ command: ConcordRasterImageCommand) -> AnyView {
        let image: AnyView
        switch command.imageData {
        case .asset(let name):
            image = renderAssetImage(named: name)
        case .icon(let icon):
            image = AnyView(Image(systemName: appleSystemName(icon)).resizable())
        }

        switch command.contentMode {
        case .fit:
            return AnyView(image.aspectRatio(contentMode: .fit))
        case .fill:
            return AnyView(image.aspectRatio(contentMode: .fill))
        case .stretch:
            return image
        case .original:
            return image
        }
    }

    private static func renderImageElement(_ element: ConcordImage) -> AnyView {
        switch element.imageData {
        case .asset(let name):
            return renderAssetImage(named: name)
        case .icon(let icon):
            let image = Image(systemName: appleSystemName(icon))
            if element.structure?.width != nil || element.structure?.height != nil {
                return AnyView(image.resizable().scaledToFit())
            }
            return AnyView(image.imageScale(.large))
        }
    }

    private static func renderAssetImage(named name: String) -> AnyView {
        #if canImport(UIKit)
        if let image = UIImage(named: name) {
            return AnyView(Image(uiImage: image).resizable().scaledToFit())
        }
        if let url = Bundle.main.url(forResource: name, withExtension: nil),
           let image = UIImage(contentsOfFile: url.path) {
            return AnyView(Image(uiImage: image).resizable().scaledToFit())
        }
        let subdirectories: [String?] = [nil, "Icons", "Files", "Image", "Resources/Image"]
        for fileExtension in ["png", "jpg", "jpeg", "avif"] {
            for subdirectory in subdirectories {
                if let url = Bundle.main.url(
                    forResource: name,
                    withExtension: fileExtension,
                    subdirectory: subdirectory
                ),
                let image = UIImage(contentsOfFile: url.path) {
                    return AnyView(Image(uiImage: image).resizable().scaledToFit())
                }
            }
        }
        if name == "concordui-alt-256",
           let url = Bundle.module.url(forResource: name, withExtension: "png"),
           let image = UIImage(contentsOfFile: url.path) {
            return AnyView(Image(uiImage: image).resizable().scaledToFit())
        }
        return AnyView(Image(name).resizable().scaledToFit())
        #elseif canImport(AppKit)
        let configuredIconNames = [
            Bundle.main.object(forInfoDictionaryKey: "CFBundleIconName") as? String,
            Bundle.main.object(forInfoDictionaryKey: "CFBundleIconFile") as? String
        ]
        .compactMap { $0 }

        if configuredIconNames.contains(where: {
            $0 == name || ($0 as NSString).deletingPathExtension == (name as NSString).deletingPathExtension
        }) {
            return AnyView(
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .scaledToFit()
            )
        }
        if let image = NSImage(named: NSImage.Name(name)) {
            return AnyView(Image(nsImage: image).resizable().scaledToFit())
        }
        if let url = Bundle.main.url(forResource: name, withExtension: nil),
           let image = NSImage(contentsOf: url) {
            return AnyView(Image(nsImage: image).resizable().scaledToFit())
        }
        let subdirectories: [String?] = [nil, "Icons", "Files", "Image", "Resources/Image"]
        for fileExtension in ["png", "jpg", "jpeg", "avif"] {
            for subdirectory in subdirectories {
                if let url = Bundle.main.url(
                    forResource: name,
                    withExtension: fileExtension,
                    subdirectory: subdirectory
                ),
                let image = NSImage(contentsOf: url) {
                    return AnyView(Image(nsImage: image).resizable().scaledToFit())
                }
            }
        }
        if name == "concordui-alt-256",
           let url = Bundle.module.url(forResource: name, withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            return AnyView(Image(nsImage: image).resizable().scaledToFit())
        }
        return AnyView(Image(name).resizable().scaledToFit())
        #else
        return AnyView(Image(name).resizable().scaledToFit())
        #endif
    }

    private static func appleSystemName(_ icon: ConcordStandardIcon) -> String {
        switch icon {
        case .app: return "app"
        case .home: return "house"
        case .settings: return "gearshape"
        case .information: return "info.circle"
        case .welcome: return "hand.wave"
        case .getStarted: return "play.circle"
        case .whatsNew: return "sparkles"
        case .faq: return "questionmark.circle"
        case .help: return "lifepreserver"
        case .search: return "magnifyingglass"
        case .add: return "plus"
        case .remove: return "minus"
        case .check: return "checkmark.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        }
    }

    private static func renderProgressElement(_ element: ConcordProgressElement) -> AnyView {
        switch element.flavor {
        case .bar:
            if element.label.isEmpty {
                return AnyView(ProgressView(value: element.value))
            }
            return AnyView(ProgressView(element.label, value: element.value))

        case .spinner:
            if element.label.isEmpty {
                return AnyView(ProgressView())
            }
            return AnyView(ProgressView(element.label))
        }
    }

    private static func renderExpander(_ element: ConcordExpander, revision: UInt) -> AnyView {
        let symbol: String
        switch element.flavor {
        case .triangle:
            symbol = element.isExpanded ? "chevron.down" : "chevron.right"
        case .checkbox:
            symbol = element.isExpanded ? "checkmark.square" : "square"
        }

        let control = Button {
            element.toggleExpanded()
        } label: {
            Image(systemName: symbol)
        }
        .buttonStyle(.plain)

        let header = HStack {
            if !element.onRight { control }
            Text(element.label)
                .fontWeight(element.labelIsBold ? .bold : .regular)
            if element.onRight {
                Spacer()
                control
            }
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 4) {
                header
                if element.isExpanded {
                    VStack(alignment: .leading) {
                        ForEach(Array(element.elements.enumerated()), id: \.element.id) { _, child in
                            render(child, revision: revision)
                        }
                    }
                    .padding(.leading, element.edge)
                }
            }
        )
    }

    private static func renderBoolElement(_ element: ConcordBoolElement) -> AnyView {
        let disabled = !element.isEnabled || element.isReadOnly
        let control: AnyView

        switch element.flavor {
        case .toggle:
            let binding = Binding(
                get: { element.value ?? false },
                set: { element.userChangedValue(to: $0) }
            )
            if element.isControlOnRight == false {
                control = AnyView(
                    HStack {
                        Toggle("", isOn: binding).labelsHidden()
                        validationLabel(element.label, element: element)
                        if element.value == nil {
                            Text(ConcordString.undecided).italic()
                        }
                    }
                )
            } else {
                control = AnyView(
                    HStack {
                        Toggle(isOn: binding) {
                            validationLabel(element.label, element: element)
                        }
                        if element.value == nil {
                            Text(ConcordString.undecided).italic()
                        }
                    }
                )
            }

        case .checkbox:
            let symbol = element.value == true
                ? "checkmark.square"
                : (element.value == false ? "square" : "minus.square")

            control = AnyView(
                Button {
                    element.userChangedValue(to: element.value != true)
                } label: {
                    HStack {
                        if element.isControlOnRight == true {
                            validationLabel(element.label, element: element)
                            Spacer()
                            Image(systemName: symbol)
                        } else {
                            Image(systemName: symbol)
                            validationLabel(element.label, element: element)
                        }
                    }
                    .frame(maxWidth: element.isControlOnRight == true ? .infinity : nil)
                }
                .buttonStyle(.plain)
            )

        case .radio:
            control = AnyView(
                VStack(alignment: .leading, spacing: 2) {
                    if !element.label.isEmpty {
                        validationLabel(element.label, element: element)
                    }
                    HStack {
                        Button {
                            element.userChangedValue(to: true)
                        } label: {
                            Label(
                                element.trueName,
                                systemImage: element.value == true ? "largecircle.fill.circle" : "circle"
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            element.userChangedValue(to: false)
                        } label: {
                            Label(
                                element.falseName,
                                systemImage: element.value == false ? "largecircle.fill.circle" : "circle"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            )
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 2) {
                control
                validationMetadata(element)
            }
            .disabled(disabled)
            .accessibilityValue(Text(element.valueName ?? ConcordString.undecided))
        )
    }

    private static func applyElementPresentation(
        to rendered: AnyView,
        element: ConcordElement
    ) -> AnyView {
        var view = rendered

        let size = max(element.resolvedFontSize, 1)
        switch element.resolvedFont {
        case .system:
            view = AnyView(view.font(.system(size: size)))
        case .monospaced:
            view = AnyView(view.font(.system(size: size, design: .monospaced)))
        }

        if let foreground = element.resolvedForegroundColor {
            view = AnyView(view.foregroundColor(appleColor(foreground)))
        }

        if let width = element.structure?.width {
            switch width {
            case .content:
                break
            case .fixed(let value):
                view = AnyView(view.frame(width: value, alignment: .leading))
            case .fill:
                let alignment: Alignment
                switch element.horizontalJustification {
                case .center:
                    alignment = .center
                case .right:
                    alignment = .trailing
                default:
                    alignment = .leading
                }
                view = AnyView(view.frame(maxWidth: .infinity, alignment: alignment))
            }
        }

        if let height = element.structure?.height {
            switch height {
            case .content:
                break
            case .fixed(let value):
                view = AnyView(view.frame(height: value, alignment: .topLeading))
            case .fill:
                view = AnyView(view.frame(maxHeight: .infinity, alignment: .top))
            }
        }

        if let background = element.resolvedBackgroundColor {
            view = AnyView(view.background(appleColor(background)))
        }

        if let box = element.boxStyle {
            let padded = view.padding(box.padding)
            if let frame = element.resolvedFrameColor {
                view = AnyView(
                    padded.overlay(
                        RoundedRectangle(cornerRadius: box.cornerRadius)
                            .stroke(appleColor(frame), lineWidth: box.width)
                    )
                )
            } else {
                view = AnyView(
                    padded.overlay(
                        RoundedRectangle(cornerRadius: box.cornerRadius)
                            .stroke(lineWidth: box.width)
                    )
                )
            }
        }

        let ownsMetadata = element is ConcordTextElement
            || element is ConcordIntElement
            || element is ConcordFloatElement
            || element is ConcordBoolElement
            || element is ConcordDateElement
            || element is ConcordTimeElement
            || element is ConcordDateTimeElement
            || element is any ConcordSelectionPresenting

        if !ownsMetadata, element.helpText != nil || element.errorText != nil {
            view = AnyView(
                VStack(alignment: .leading, spacing: 2) {
                    view
                    if let help = element.helpText, !help.isEmpty {
                        Text(help).font(.caption)
                    }
                    if let error = element.errorText, !error.isEmpty {
                        Text(error).font(.caption).foregroundColor(appleMaterialColor(.invalidIndicator))
                    }
                }
            )
        }

        if let accessibility = element.accessibilityText, !accessibility.isEmpty {
            view = AnyView(view.accessibilityLabel(Text(accessibility)))
        }

        if let justification = element.horizontalJustification {
            switch justification {
            case .left:
                view = AnyView(view.frame(maxWidth: .infinity, alignment: .leading))
            case .center:
                view = AnyView(view.frame(maxWidth: .infinity, alignment: .center))
            case .right:
                view = AnyView(view.frame(maxWidth: .infinity, alignment: .trailing))
            }
        }

        return view
    }
}

@MainActor
private struct ConcordAppleABStackView: View {
    let element: ConcordABStack
    let revision: UInt

    #if os(iOS)
    @State private var orientation = UIDevice.current.orientation
    #endif

    var body: some View {
        Group {
            if usesHorizontalLayout {
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                    ConcordAppleABHorizontalLayout(
                        aFraction: element.aFraction,
                        spacing: CGFloat(element.spacing)
                    ) {
                        ConcordAppleRenderer.render(element.a, revision: revision)
                        ConcordAppleRenderer.render(element.b, revision: revision)
                    }
                } else {
                    HStack(alignment: .top, spacing: element.spacing) {
                        ConcordAppleRenderer.render(element.a, revision: revision)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        ConcordAppleRenderer.render(element.b, revision: revision)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: element.spacing) {
                    ConcordAppleRenderer.render(element.a, revision: revision)
                    ConcordAppleRenderer.render(element.b, revision: revision)
                }
            }
        }
        .padding(element.edge)
        #if os(iOS)
        .onAppear {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        .onDisappear {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
        #endif
    }

    private var usesHorizontalLayout: Bool {
        #if os(iOS)
        if orientation.isLandscape { return true }
        if orientation.isPortrait { return false }
        return UIScreen.main.bounds.width > UIScreen.main.bounds.height
        #else
        return true
        #endif
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct ConcordAppleABHorizontalLayout: Layout {
    let aFraction: Double
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let widths = columnWidths(total: proposal.width ?? 600)
        let aHeight = subviews[0].sizeThatFits(ProposedViewSize(width: widths.a, height: nil)).height
        let bHeight = subviews[1].sizeThatFits(ProposedViewSize(width: widths.b, height: nil)).height
        return CGSize(width: proposal.width ?? widths.a + spacing + widths.b, height: max(aHeight, bHeight))
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let widths = columnWidths(total: bounds.width)
        subviews[0].place(
            at: bounds.origin,
            proposal: ProposedViewSize(width: widths.a, height: bounds.height)
        )
        subviews[1].place(
            at: CGPoint(x: bounds.minX + widths.a + spacing, y: bounds.minY),
            proposal: ProposedViewSize(width: widths.b, height: bounds.height)
        )
    }

    private func columnWidths(total: CGFloat) -> (a: CGFloat, b: CGFloat) {
        let available = max(0, total - spacing)
        let a = available * CGFloat(aFraction)
        return (a, available - a)
    }
}
