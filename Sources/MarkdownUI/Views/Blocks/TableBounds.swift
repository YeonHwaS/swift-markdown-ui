import SwiftUI

struct TableBounds {
  var rowCount: Int {
    self.rows.count
  }

  var columnCount: Int {
    self.columns.count
  }

  let bounds: CGRect
  let tableRows: [RawTableRow]

  private let rows: [(minY: CGFloat, height: CGFloat)]
  private let columns: [(minX: CGFloat, width: CGFloat)]

  fileprivate init(
    rowCount: Int,
    columnCount: Int,
    tableRows: [RawTableRow],
    anchors: [TableCellIndex: Anchor<CGRect>],
    proxy: GeometryProxy
  ) {
    var rows = Array(
      repeating: (minY: CGFloat.greatestFiniteMagnitude, height: CGFloat(0)),
      count: rowCount
    )
    var columns = Array(
      repeating: (minX: CGFloat.greatestFiniteMagnitude, width: CGFloat(0)),
      count: columnCount
    )

    for row in 0..<rowCount {
      for column in 0..<columnCount {
        guard let anchor = anchors[TableCellIndex(row: row, column: column)] else {
          continue
        }

        let bounds = proxy[anchor]

        rows[row].minY = min(rows[row].minY, bounds.minY)
        rows[row].height = max(rows[row].height, bounds.height)

        columns[column].minX = min(columns[column].minX, bounds.minX)
        columns[column].width = max(columns[column].width, bounds.width)
      }
    }

    self.bounds = proxy.frame(in: .local)
    self.rows = rows
    self.columns = columns
    self.tableRows = tableRows
  }

  func bounds(forRow row: Int, column: Int) -> CGRect {
    CGRect(
      origin: .init(x: self.columns[column].minX, y: self.rows[row].minY),
      size: .init(width: self.columns[column].width, height: self.rows[row].height)
    )
  }

  func bounds(forRow row: Int) -> CGRect {
    (0..<self.columnCount)
      .map { self.bounds(forRow: row, column: $0) }
      .reduce(.null, CGRectUnion)
  }

  func bounds(forColumn column: Int) -> CGRect {
    (0..<self.rowCount)
      .map { self.bounds(forRow: $0, column: column) }
      .reduce(.null, CGRectUnion)
  }

  func hasBackground(forRow row: Int, column: Int) -> Bool {
    let colspan = self.tableRows[row].cells[column].colspan
    let rowspan = self.tableRows[row].cells[column].rowspan
    return colspan > 0 && rowspan > 0
  }

  func hasBorder(forRow row: Int, column: Int) -> Bool {
    let colspan = self.tableRows[row].cells[column].colspan
    let rowspan = self.tableRows[row].cells[column].rowspan
    return colspan == 1 && rowspan == 1
  }
}

extension View {
  func tableCellBounds(forRow row: Int, column: Int) -> some View {
    self.anchorPreference(key: TableCellBoundsPreference.self, value: .bounds) { anchor in
      [TableCellIndex(row: row, column: column): anchor]
    }
  }

  func tableDecoration<Background, Overlay>(
    rowCount: Int,
    columnCount: Int,
    rows: [RawTableRow],
    background: @escaping (TableBounds) -> Background,
    overlay: @escaping (TableBounds) -> Overlay
  ) -> some View where Background: View, Overlay: View {
    self
      .backgroundPreferenceValue(TableCellBoundsPreference.self) { anchors in
        GeometryReader { proxy in
          background(
            .init(
              rowCount: rowCount,
              columnCount: columnCount,
              tableRows: rows,
              anchors: anchors,
              proxy: proxy
            )
          )
        }
      }
      .overlayPreferenceValue(TableCellBoundsPreference.self) { anchors in
        GeometryReader { proxy in
          overlay(
            .init(
              rowCount: rowCount,
              columnCount: columnCount,
              tableRows: rows,
              anchors: anchors,
              proxy: proxy
            )
          )
        }
      }
  }
}

private struct TableCellIndex: Hashable {
  var row: Int
  var column: Int
}

private struct TableCellBoundsPreference: PreferenceKey {
  static let defaultValue: [TableCellIndex: Anchor<CGRect>] = [:]

  static func reduce(
    value: inout [TableCellIndex: Anchor<CGRect>],
    nextValue: () -> [TableCellIndex: Anchor<CGRect>]
  ) {
    value.merge(nextValue()) { $1 }
  }
}
