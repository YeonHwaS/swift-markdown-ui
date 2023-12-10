import SwiftUI

struct TableView: View {
  @Environment(\.theme.table) private var table
  @Environment(\.tableBorderStyle) private var tableBorderStyle
  @Environment(\.tableBackgroundStyle) private var tableBackgroundStyle
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

    return Grid(tracks: tracks, spacing: [self.borderWidth, self.borderWidth]) {
      ForEach(0..<self.columnCount, id: \.self) { column in
        ForEach(0..<self.rowCount, id: \.self) { row in

          let alignment: GridAlignment? = switch self.columnAlignments[column] {
          case .none: nil
          case .left: .leading
          case .center: .center
          case .right: .trailing
          }

          TableCell(row: row, column: column, cell: self.rows[row].cells[column])
            .gridItemAlignment(alignment)
            .gridCellBackground { content in
              Rectangle()
                .fill(self.tableBackgroundStyle.background(row, column))
//                .offset(x: content?.minX ?? .zero, y: content?.minY ?? .zero)
                .frame(width: content?.width ?? .zero, height: content?.height ?? .zero)
            }
            .gridCellOverlay { content in
              Rectangle()
                .strokeBorder(self.tableBorderStyle.color, style: self.tableBorderStyle.strokeStyle)
//                .offset(x: content?.minX ?? .zero, y: content?.minY ?? .zero)
                .frame(width: content?.width ?? .zero, height: content?.height ?? .zero)
            }
        }
      }
    }
    .gridContentMode(.scroll)
    .gridFlow(.columns)
//    .gridCache(.noCache)
//    .tableDecoration(
//      rowCount: self.rowCount,
//      columnCount: self.columnCount,
//      background: TableBackgroundView.init,
//      overlay: TableBorderView.init
//    )



//        if #available(iOS 16.0, *) {
//          return Grid(horizontalSpacing: self.borderWidth, verticalSpacing: self.borderWidth) {
//            ForEach(0..<self.rowCount, id: \.self) { row in
//              GridRow {
//                ForEach(0..<self.columnCount, id: \.self) { column in
//                  TableCell(row: row, column: column, cell: self.rows[row].cells[column])
//                    .gridColumnAlignment(.init(self.columnAlignments[column]))
//                }
//              }
//            }
//          }
//          .padding(self.borderWidth)
//          .tableDecoration(
//            rowCount: self.rowCount,
//            columnCount: self.columnCount,
//            background: TableBackgroundView.init,
//            overlay: TableBorderView.init
//          )
//        } else {
//          return Text("")
//        }
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
