import SwiftUI

struct TableView: View {
  @Environment(\.theme.table) private var table
  @Environment(\.tableBorderStyle.strokeStyle.lineWidth) private var borderWidth

  private let columnAlignments: [RawTableColumnAlignment]
  private let rows: [RawTableRow]

  init(columnAlignments: [RawTableColumnAlignment], rows: [RawTableRow]) {
    self.columnAlignments = columnAlignments
    self.rows = rows
  }

  var body: some View {
    self.table.makeBody(
      configuration: .init(
        label: .init(self.label),
        content: .init(block: .table(columnAlignments: self.columnAlignments, rows: self.rows))
      )
    )
  }

  private var label: some View {
    let tracks: [GridTrack] = (0 ..< self.rowCount).map { _ in .fit }

    return ScrollView(.horizontal) {
      Grid(tracks: tracks, spacing: [self.borderWidth, self.borderWidth]) {
        ForEach(0..<self.columnCount, id: \.self) { column in
          ForEach(0..<self.rowCount, id: \.self) { row in
            let colspan = self.rows[row].cells[column].colspan
            let rowspan = self.rows[row].cells[column].rowspan
            if colspan > 0 && rowspan > 0 {
              let alignment: GridAlignment? = switch self.columnAlignments[column] {
              case .none: .leading
              case .left: .leading
              case .center: .center
              case .right: .trailing
              }

              TableCell(row: row, column: column, cell: self.rows[row].cells[column])
                .gridItemAlignment(alignment)
                .gridSpan(column: colspan, row: rowspan)
            }
          }
        }
      }
      .gridContentMode(.scroll)
      .gridFlow(.columns)
      .tableDecoration(
        rowCount: self.rowCount,
        columnCount: self.columnCount,
        rows: self.rows,
        background: TableBackgroundView.init,
        overlay: TableBorderView.init
      )
    }
  }

  private var rowCount: Int {
    self.rows.count
  }

  private var columnCount: Int {
    self.columnAlignments.count
  }
}

extension HorizontalAlignment {
  fileprivate init(_ rawTableColumnAlignment: RawTableColumnAlignment) {
    switch rawTableColumnAlignment {
    case .none, .left:
      self = .leading
    case .center:
      self = .center
    case .right:
      self = .trailing
    }
  }
}
