import SwiftUI

/// A type that selects the visible borders on a Markdown table.
///
/// You use a table border selector to select the visible borders when creating a ``TableBorderStyle``.
public struct TableBorderSelector {
  var rectangles: (_ tableBounds: TableBounds, _ borderWidth: CGFloat) -> [CGRect]
}

extension TableBorderSelector {
  /// A table border selector that selects the outside borders of a table.
  public static var outsideBorders: TableBorderSelector {
    TableBorderSelector { tableBounds, borderWidth in
      [tableBounds.bounds]
    }
  }

  /// A table border selector that selects the inside borders of a table.
  public static var insideBorders: TableBorderSelector {
    TableBorderSelector { tableBounds, borderWidth in
      var rects = [CGRect]()

      for row in 0..<tableBounds.rowCount {
        for column in 0..<tableBounds.columnCount {
          let bounds = tableBounds.bounds(forRow: row, column: column).insetBy(dx: -borderWidth, dy: -borderWidth)

          if hasHorizontalBorder(row: row, column: column, tableBounds: tableBounds) {
            let horizontalBorder = CGRect(
              origin: CGPoint(x: bounds.minX, y: bounds.maxY - borderWidth),
              size: CGSize(width: bounds.width, height: borderWidth)
            )
            rects.append(horizontalBorder)
          }

          if hasVerticalBorder(row: row, column: column, tableBounds: tableBounds) {
            let verticalBorder = CGRect(
              origin: CGPoint(x: bounds.maxX - borderWidth, y: bounds.minY),
              size: CGSize(width: borderWidth, height: bounds.height)
            )
            rects.append(verticalBorder)
          }
        }
      }

      return rects
    }
  }

  static func hasHorizontalBorder(row: Int, column: Int, tableBounds: TableBounds) -> Bool {
    guard row < tableBounds.rowCount - 1 else { return false }
    
    let currentCellHasBorder = tableBounds.hasBorder(forRow: row, column: column)
    let nextRowExists = row + 1 <= tableBounds.rowCount - 1
    let nextCellHasBorder = nextRowExists && tableBounds.hasBorder(forRow: row + 1, column: column)

    return currentCellHasBorder || nextCellHasBorder
  }

  static func hasVerticalBorder(row: Int, column: Int, tableBounds: TableBounds) -> Bool {
    guard column < tableBounds.columnCount - 1 else { return false }

    let currentCellHasBorder = tableBounds.hasBorder(forRow: row, column: column)
    let nextColumnExists = column + 1 <= tableBounds.columnCount - 1
    let nextCellHasBorder = nextColumnExists && tableBounds.hasBorder(forRow: row, column: column + 1)

    return currentCellHasBorder || nextCellHasBorder
  }

  /// A table border selector that selects all the borders of a table.
  public static var allBorders: TableBorderSelector {
    TableBorderSelector { tableBounds, borderWidth in
      Self.insideBorders.rectangles(tableBounds, borderWidth)
        + Self.outsideBorders.rectangles(tableBounds, borderWidth)
    }
  }
}

extension TableBorderSelector {
  fileprivate static var outsideHorizontalBorders: TableBorderSelector {
    TableBorderSelector { tableBounds, borderWidth in
      [
        CGRect(
          origin: .init(x: tableBounds.bounds.minX, y: tableBounds.bounds.minY),
          size: .init(width: tableBounds.bounds.width, height: borderWidth)
        ),
        CGRect(
          origin: .init(x: tableBounds.bounds.minX, y: tableBounds.bounds.maxY - borderWidth),
          size: .init(width: tableBounds.bounds.width, height: borderWidth)
        ),
      ]
    }
  }
}
