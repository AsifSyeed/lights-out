//
//  ReactionTimeGameViewModel.swift
//  lights out
//
//  Created by Asif Reddot on 11/10/24.
//

import SwiftUI
import Combine

enum GameState {
    case waiting
    case countdown
    case react
    case result
    case jumpStart
}

class ReactionTimeGameViewModel: ObservableObject {
    @Published var gameState: GameState = .waiting
    @Published var reactionTime: TimeInterval = 0
    @Published var buttonText: String = "Start Game"
    @Published var lightStates: [Bool] = [false, false, false, false, false]
    
    private var startTime: Date?
    private var endTime: Date?
    private var countdownTasks: [DispatchWorkItem] = []
    
    var gameStateMessage: String {
        switch gameState {
            case .waiting:
                return "Tap 'Start Game' to Begin"
            case .countdown:
                return "Get Ready!"
            case .react:
                return "Tap Now!"
            case .result:
                return "Your Reaction Time"
            case .jumpStart:
                return "Jump Start. Please try again"
        }
    }
    
    func startGame() {
        resetLights()
        cancelCountdownTasks()
        gameState = .countdown
        buttonText = "Get Ready!"
        
        for i in stride(from: lightStates.count - 1, through: 0, by: -1) {
            let task = DispatchWorkItem { [weak self] in
                self?.lightStates[i] = true
            }
            countdownTasks.append(task)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(lightStates.count - 1 - i), execute: task)
        }
        
        let startReactionTask = DispatchWorkItem { [weak self] in
            self?.startReactionPhase()
        }
        countdownTasks.append(startReactionTask)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(lightStates.count), execute: startReactionTask)
    }
    
    private func startReactionPhase() {
        startTime = Date()
        resetLights()
        gameState = .react
        buttonText = "Lights out!"
    }
    
    func recordReactionTime() {
        if gameState == .countdown {
            triggerJumpStart()
            return
        }
        
        guard gameState == .react else { return }
        
        endTime = Date()
        reactionTime = endTime?.timeIntervalSince(startTime ?? Date()) ?? 0
        gameState = .result
        buttonText = "Play Again"
    }
    
    func triggerJumpStart() {
        cancelCountdownTasks()
        gameState = .jumpStart
        buttonText = "Play Again"
    }
    
    func resetGame() {
        gameState = .waiting
        reactionTime = 0
        startTime = nil
        endTime = nil
        resetLights()
        buttonText = "Start Game"
        cancelCountdownTasks()
    }
    
    private func resetLights() {
        lightStates = [false, false, false, false, false]
    }
    
    private func cancelCountdownTasks() {
        for task in countdownTasks {
            task.cancel()
        }
        countdownTasks.removeAll()
    }
}
