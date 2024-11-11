//
//  ReactionTimeGameView.swift
//  lights out
//
//  Created by Asif Reddot on 11/10/24.
//

import SwiftUI

struct ReactionTimeGameView: View {
    @StateObject private var viewModel = ReactionTimeGameViewModel()
    
    var body: some View {
        VStack(spacing: 10) { // Reduced vertical spacing in VStack
            // Top rectangle with F1 logo
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.black)
                    .frame(width: 300, height: 80) // F1 logo board
                
                Image("logo_f1") // F1 logo image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50) // Logo size
            }
            
            // Traffic light row with double-stacked lights
            HStack(spacing: 20) {
                ForEach(0..<viewModel.lightStates.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black)
                            .frame(width: 60, height: 160) // Light column frame
                        
                        VStack(spacing: 10) {
                            // Top light (always gray, does not light up)
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                            
                            // Bottom light (only this row glows)
                            Circle()
                                .fill(viewModel.lightStates[index] ? Color.f1Red : Color.gray)
                                .frame(width: 40, height: 40)
                        }
                    }
                }
            }
            .padding(.top, 5) // Reduced top padding for lights
            
            if viewModel.gameState == .result {
                Text("Reaction Time: \(viewModel.reactionTime, specifier: "%.3f") seconds")
                    .font(.headline)
                    .padding()
            } else if viewModel.gameState == .jumpStart {
                Text("Jump Start! 5s penalty")
                    .font(.headline)
                    .padding()
            }
            
            Spacer() // Pushes the button area to the bottom
            
            // Full-width button with black text only
            Button(action: handleButtonTap) {
                Text(viewModel.buttonText)
                    .font(.title)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: 60)
            }
            .padding(.bottom, 10) // Optional bottom padding
        }
        .padding(.top, 5) // Reduced overall top padding for the VStack
    }
    
    private func handleButtonTap() {
        switch viewModel.gameState {
            case .waiting:
                viewModel.startGame() // Start the game if in waiting state
            case .countdown:
                viewModel.triggerJumpStart() // Trigger jump start if tapped during countdown
            case .react:
                viewModel.recordReactionTime() // Record reaction time if tapped during react state
            case .result, .jumpStart:
                viewModel.resetGame() // Reset game if in result or jump start state
        }
    }
}

#Preview {
    ReactionTimeGameView()
}
