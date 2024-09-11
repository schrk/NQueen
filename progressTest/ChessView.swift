//
//  ChessView.swift
//
//
//  Created by Enzo Luigi Schork on 04/08/24.
//

import SwiftUI

struct Chess: View {

    // MARK: - Properties
    @State var size = 4

    // MARK: - View
    var body: some View {
        NavigationView {
            VStack(spacing: 200) {
                Picker("Selecione um tamanho", selection: $size) {
                    ForEach(4...12, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                .padding(.horizontal, 80)
                .background(
                    Color.white
                        .clipShape(Capsule())
                        .padding(.horizontal, 80)
                )

                NavigationLink(destination: ChessView(size: size)) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Go to Chess View")
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.white.clipShape(Capsule()))
                }
                .foregroundColor(.white)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Subviews
extension Chess {

    struct ChessView: View {

        let size: Int

        var counter = 0
        var generalCounter = 0
        var positions: [[Int]] = []
        var boards: [Int: [[Int]]] = [:]

        var isColumnEmpty: [Int: Bool] = [:]
        var isPrimaryEmpty: [Int: Bool] = [:]
        var isSecondaryEmpty: [Int: Bool] = [:]

        init(size: Int) {
            self.size = size
            self.boards = totalNQueens(size)
        }

        var body: some View {
            ScrollView {
                LazyVStack(spacing: 20) {
                    Text("Tabuleiros \(size)x\(size)")
                        .font(.largeTitle)

                    ForEach(Array(boards.keys.sorted().enumerated()), id: \.offset) { idx, key in
                        Text("Tabuleiro \(idx+1)")
                            .font(.headline)

                        Text("\(boards[key]!)")
                            .font(.subheadline)

                        ChessBoard(size: size, positions: boards[key]!)
                    }
                }
                .padding()
            }
            .preferredColorScheme(.dark)
        }

        struct ChessBoard: View {

            let size: Int
            let positions: [[Int]]

            // cor de cada quadrado
            func colorForSquare(row: Int, col: Int) -> Color {
                return (row + col) % 2 == 0 ? .white : Color(uiColor: .systemGray2)
            }

            // peça caso seja posicao correta
            func pieceAtPosition(row: Int, col: Int) -> Image? {
                if positions.contains([row, col]) {
                    return Image(systemName: "crown.fill")
                }

                return nil
            }

            // colunas do Grid
            var columns: [GridItem] {
                Array(repeating: GridItem(.fixed(30), spacing: 2), count: size)
            }

            var body: some View {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(0..<size * size, id: \.self) { idx in
                        let row = idx / size
                        let col = idx % size

                        Rectangle()
                            .fill(colorForSquare(row: row, col: col))
                            .frame(width: 30, height: 30)
                            .overlay(
                                pieceAtPosition(row: row, col: col)?
                                    .foregroundColor(Color(uiColor: .systemBlue))
                            )
                    }
                }
                .background(Color.black)
                .cornerRadius(8)
            }
        }

        // MARK: - Methods
        mutating func saveQueenPositions(_ board: [[Int]]) -> [[Int]] {
            var queenPositions: [[Int]] = []

            for idx in 0..<size * size {
                let row = idx / size
                let col = idx % size

                if board[row][col] == 1 {
                    queenPositions.append([row, col])
                }
            }

            return queenPositions
        }

        mutating func totalNQueens(_ n: Int) -> [Int: [[Int]]] {
            var board = Array(repeating: Array(repeating: 0, count: n), count: n)
            NQueen(&board, 0, n)
            return boards
        }


        mutating func NQueen(_ board: inout [[Int]],_ row: Int,_ n: Int) {
            if row == n {
                boards[counter] = saveQueenPositions(board)
                counter += 1
            }

            for col in 0..<n {
                if check(board, row, col, n) {
                    board[row][col] = 1
                    setEmptys(row, col, false)
                    positions.append([row, col])

                    NQueen(&board, row + 1, n)

                    // backtracking
                    board[row][col] = 0
                    setEmptys(row, col, true)
                    if !positions.isEmpty {
                        positions.removeLast()
                    }
                }
            }
        }

        mutating func setEmptys(_ row: Int, _ col: Int, _ boolean: Bool) {
            isColumnEmpty[col] = boolean
            isPrimaryEmpty[row-col] = boolean
            isSecondaryEmpty[row+col] = boolean
        }

        func check(_ board: [[Int]],_ row: Int,_ col: Int,_ n: Int) -> Bool {
            if isColumnEmpty[col] == false {
                return false
            }

            if isPrimaryEmpty[row-col] == false {
                return false
            }

            if isSecondaryEmpty[row+col] == false {
                return false
            }

            return true
        }
    }
}

// MARK: - Preview
#Preview {
    Chess()
}
