//
//  CustomInline.swift
//  Down
//
//  Created by John Nguyen on 09.04.19.
//

import Foundation
import cmark_gfm

public class CustomInline: BaseNode {

    // MARK: - Properties

    /// The custom content, if present.

    public private(set) lazy var literal: String? = cmarkNode.literal
}

// MARK: - Debug

extension CustomInline: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Custom Inline - \(literal ?? "nil")"
    }

}
