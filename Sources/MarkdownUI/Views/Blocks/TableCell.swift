import SwiftUI

struct TableCell: View {
  @Environment(\.theme.tableCell) private var tableCell

  private let row: Int
  private let column: Int
  private let cell: RawTableCell

  init(row: Int, column: Int, cell: RawTableCell) {
    self.row = row
    self.column = column
    self.cell = cell
  }

  var body: some View {
    self.tableCell.makeBody(
      configuration: .init(
        row: self.row,
        column: self.column,
        label: .init(self.label),
        content: .init(block: .paragraph(content: cell.content))
      )
    )
    .fixedSize()
    .tableCellBounds(forRow: self.row, column: self.column)
  }

  @ViewBuilder private var label: some View {
//    if let imageFlow = ImageFlow(self.cell.content) {
//      imageFlow
//    } else {
//      InlineText(self.cell.content)
//    }
    InlineText(self.cell.content)
  }
}
