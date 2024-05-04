//
//  HexColorMacro.swift
//  
//
//  Created by Joe Maghzal on 04/05/2024.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics


/// Macro for expanding hexadecimal color strings into SwiftUI ``Color`` expressions.
///
/// This macro enables the expansion of hexadecimal color strings into ``Color`` expressions. It abstracts away the conversion process and provides a convenient way to include colors in Swift code using hexadecimal notation with compiler validations.
///
/// **Supported validations:**
///  - **Length**: The following error will be thrown when the length of the provided hex is invalid: `The hex "123456789" must be exactly 6 or 8 characters long`.
///  - **Characters**: The following error will be thrown when the provided hex contains invalid characters: `The hex "LKJHG9" contains invalid characters: L, K, J, H, G`.
///  - **Decoding Failure**: The following error will be thrown when the provided hex could not be decoded: `The hex "999999" could not be decoded`.
///
/// **Supported hex formats:**
///  - 6 digits, the opacity component will always be 1:
///  ```swift
///  #color("ff0000") // // Color(red: 255 / 255, green: 0 / 255, blue: 0 / 255, opacity: 255 / 255)
///  ```
///  - 8 digits, decodes the opacity component:
///  ```swift
///  #color("ff000080") // Color(red: 255 / 255, green: 0 / 255, blue: 0 / 255, opacity: 128 / 255)
///  ```
///
/// - Note: Adding the '#' is optional & won't affect the decoding proccess.
///
public struct HexColorMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression,
              let argumentSegment = argument.as(StringLiteralExprSyntax.self)?.segments.first,
              case .stringSegment(let argumentString) = argumentSegment
        else {
            throw HexColorMacroError.missingHex
        }
        let hex = argumentString.content.text
        let decodingResult = HexColorDecoder.decode(hex)
        switch decodingResult {
            case .success((let red, let green, let blue, let opacity)):
                return "Color(red: \(raw: red)/255, green: \(raw: green)/255, blue: \(raw: blue)/255, opacity: \(raw: opacity)/255)"
                
            case .failure(let error):
               throw error
        }
    }
}
