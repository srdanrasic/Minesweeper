//
//  MinesweeperHeader.swift
//  Minesweeper
//
//  Created by Michael Skiba on 27/11/2019.
//  Copyright © 2019 Atelier Clockwork. All rights reserved.
//

import Mockingbird

struct MinesweeperHeader: View {
    let remainingMines: Int
    let elapsedTime: Int
    let resetAction: () -> Void

    var body: View {
        HStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Mines")
                        .font(Font.caption)
                        .foregroundColor(Color.gray)
                    Text("\(remainingMines)")
                }
                Spacer()
            }
            Button(action: resetAction) { Text("🔄") }
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Time")
                        .font(Font.caption)
                        .foregroundColor(Color.gray)
                    Text("\(elapsedTime)")
                }
            }
        }
//        .buttonStyle(PlainButtonStyle())
        .font(Font.system(.body).monospacedDigit())
    }
}
