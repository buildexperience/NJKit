//
//  ScreenListenerViewModifier.swift
//
//
//  Created by Joe Maghzal on 29/02/2024.
//

import SwiftUI

/// A view modifier for observing screen size changes.
///
/// `ScreenListenerViewModifier` allows observing changes in the screen size and safe area insets. It adjusts the view's behavior based on these changes.
///
/// ```swift
/// struct ContentView: View {
///     @State private var screen = Screen.zero
///     var body: some View {
///         VStack {
///             Text("Hello, World!")
///                 .frame(height: screen.height / 4)
///         }.frame(maxWidth: .infinity, maxHeight: .infinity)
///         .sizeListener($screen) //Updates the screen property
///     }
/// }
/// ```
/// - Warning: Not to be used directly, use either ``func sizeListener() -> some View``, or ``func sizeListener(_ screen: Binding<Screen>) -> some View``.
///
struct ScreenListenerViewModifier: ViewModifier {
//MARK: - Properties
    /// Value indicating whether to bind the screen size changes to a binding property.
    private let bindingScreen: Bool
    
    /// Binding to the current screen size.
    @Binding private var screen: Screen
//MARK: - Initializer
    /// Creates a scren listener modifier using a ``Binding`` to the ``Screen`` object.
    ///
    /// - Parameter screen: The ``Binding`` to the current ``Screen`` object.
    ///
    init(screen: Binding<Screen>) {
        self.bindingScreen = true
        self._screen = screen
    }
    
    /// Creates a scren listener modifier without binding.
    init() {
        self.bindingScreen = false
        self._screen = .constant(.zero)
    }
//MARK: - Body
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let geometryScreen = screen(from: proxy)
            if bindingScreen {
                content
                    .onChange(of: geometryScreen, initial: true) { _, newValue in
                        print(newValue)
                        screen = newValue
                    }
            }else {
                content
                    .environment(\.screen, screen)
            }
        }
    }
//MARK: - Functions
    /// Build a ``Screen`` object from a ``GeometryProxy``.
    ///
    /// - Parameter proxy: The geometry proxy from which the screen size & safe area insets are extracted.
    /// - Returns: A ``Screen`` object representing the screen size and safe area insets.
    ///
    private func screen(from proxy: GeometryProxy) -> Screen {
        return Screen(size: proxy.size, safeAreaInsets: proxy.safeAreaInsets)
    }
}

//MARK: - Modifiers
public extension View {
    /// Adds a listener to a view's size and safe area insets.
    ///
    /// You can access the updated ``Screen`` object using ``EnvironmentValues/screen``.
    ///
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             MyView()
    ///                 .sizeListener() //Propagates the updated Screen object.
    ///         }
    ///     }
    /// }
    ///
    /// struct MyView: View {
    ///     @Environment(\.screen) private var screen //Access the updated Screen object.
    ///     var body: some View {
    ///         Color.blue
    ///             .frame(width: screen.size.width)
    ///     }
    /// }
    /// ```
    ///
    /// - Returns: A view wrapped in a `GeometryReader` that propagates the up-to-date size and safe area insets to the environment.
    ///
    func sizeListener() -> some View {
        modifier(ScreenListenerViewModifier())
    }
    
    /// Adds a listener to a view's size and safe area insets & binds them to a ``Binding`` property.
    ///
    /// You can access the updated ``Screen`` object using the passed ``Binding`` property.
    ///
    /// ```swift
    /// struct MyView: View {
    ///     @State private var screen = Screen.zero
    ///     var body: some View {
    ///         Color.blue
    ///             .sizeListener($screen)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter screen: A ``Binding`` to the current ``Screen`` object.
    /// - Returns: A view wrapped in a ``GeometryReader`` that propagates the up-to-date size and safe area insets to the passed ``Binding``.
    ///
    func sizeListener(_ screen: Binding<Screen>) -> some View {
        modifier(ScreenListenerViewModifier(screen: screen))
    }
}