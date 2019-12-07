//
//  MainView.swift
//  Minesweeper
//
//  Created by Michael Skiba on 25/11/2019.
//  Copyright © 2019 Atelier Clockwork. All rights reserved.
//

import Mockingbird

struct MainView: View {
    @ObservedObject var state: GameState

    var body: View {
        VStack {
            MinesweeperHeader(remainingMines: state.configuration.mineCount - state.flaggedCount,
                              elapsedTime: state.elapsed,
                              resetAction: state.reset)
            Spacer()
            GameBoard(state: state)
        }
        .padding()
        .font(Font.body)
        .fixedSize()
//        .sheet(isPresented: $state.showSettings) { [state] in
//            PreferencesView(updateConfiguration: { state.configuration = $0 },
//                            dismissAction: { state.showSettings.toggle() })
//        }
    }
}
