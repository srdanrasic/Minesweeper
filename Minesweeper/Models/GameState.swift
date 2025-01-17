//
//  GameState.swift
//  Minesweeper
//
//  Created by Michael Skiba on 26/11/2019.
//  Copyright © 2019 Atelier Clockwork. All rights reserved.
//

import Foundation
import ReactiveKit

typealias Published = ReactiveKit.Published
typealias ObservableObject = ReactiveKit.ObservableObject

class GameState: ObservableObject {
    @Published var configuration: Minefield.Configuration
    @Published private(set) var elapsed: Int
    @Published private(set) var status: Status = .active
    @Published private var minefield: Minefield?
    @Published var showSettings: Bool = false
    private var timer: AnyCancellable?
    private var cancellales = Set<AnyCancellable>()

    var flaggedCount: Int {
        switch status {
        case .win:
            return configuration.mineCount
        case .active, .loss, .unstarted:
            return minefield?.flaggedCount ?? 0
        }
    }

    subscript(_ point: Point) -> GridState {
        return minefield?[point] ?? GridState(state: .unmarked, info: .empty)
    }

    func reveal(_ point: Point) {
        if minefield == nil {
            minefield = Minefield(initialPoint: point, configuration: configuration)
        }
        guard minefield?[point].state == .unmarked else { return }
        minefield?[point].state = .revealed
        revealSurrounding(point: point, alreadyChecked: [])
    }

    func toggleFlag(_ point: Point) {
        if minefield == nil {
            minefield = Minefield(initialPoint: nil, configuration: configuration)
        }
        switch minefield?[point].state {
        case .flagged:
            minefield?[point].state = .unmarked
        case .unmarked:
            minefield?[point].state = .flagged
        case .none, .probed, .revealed, .unknown:
            break
        }
    }

    func probe(_ point: Point) {
        guard minefield != nil,
            let status = minefield?[point],
            status.state == .revealed,
            case .count(let mineCount) = status.info,
            let points = minefield?.pointsSurrounding(point) else { return }
        let flaggedCount = points
            .compactMap { minefield?[$0] }
            .filter { $0.state == .flagged }
            .count
        guard flaggedCount == mineCount else { return }
        for point in points {
            reveal(point)
        }
    }

    func reset() {
        timer = nil
        elapsed = 0
        minefield = nil
    }

    private func revealSurrounding(point: Point, alreadyChecked: Set<Point>) {
        minefield?[point].state = .revealed
        guard let gridPoint = minefield?[point], gridPoint.info == .empty  else { return }
        let surrounding = Set(minefield?.pointsSurrounding(point) ?? [])
            .subtracting(alreadyChecked)
        for point in surrounding where minefield?[point].state != .flagged {
            let alreadyChecked = alreadyChecked.union(surrounding).union(alreadyChecked).union([point])
            revealSurrounding(point: point, alreadyChecked: alreadyChecked)
        }
    }

    init(configuration: Minefield.Configuration) {
        self.elapsed = 0
        self.configuration = configuration
        prepareBindings()
    }

    private func prepareBindings() {
        $configuration
            .map { _ in () }
            .sink(receiveValue: reset)
            .store(in: &cancellales)
        $minefield
            .combineLatest(with: $configuration.map { $0.mineCount })
            .map { minefield, mineCount -> GameState.Status in
                minefield?.status(mineCount: mineCount) ?? .unstarted
            }
            .assign(to: \.status, on: self)
            .store(in: &cancellales)
        $status
            .map { $0 == .active }
            .removeDuplicates()
            .map { $0 ? self.prepareTimer() : nil }
            .assign(to: \.timer, on: self)
            .store(in: &cancellales)
    }

    private func prepareTimer() -> AnyCancellable {
        Signal(sequence: 0..., interval: 1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.elapsed += 1 }
    }
}

private extension Minefield {
    func status(mineCount: Int) -> GameState.Status {
        if revealed.contains(.mine) {
            return .loss
        } else if unrevealed.count == mineCount {
            return .win
        } else {
            return .active
        }
    }
}
