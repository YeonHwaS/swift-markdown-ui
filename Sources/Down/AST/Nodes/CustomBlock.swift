//
//  CustomBlock.swift
//  Down
//
//  Created by John Nguyen on 09.04.19.
//

import Foundation
import cmark_gfm

public class CustomBlock: BaseNode {

    // MARK: - Properfies

    /// The custom content, if present.

    public private(set) lazy var literal: String? = cmarkNode.literal

}

// MARK: - Debug

extension CustomBlock: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Custom Block - \(literal ?? "nil")"
    }

}
