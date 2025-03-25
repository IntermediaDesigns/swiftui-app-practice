//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Lynjai Jimenez on 3/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var countries = [
        "Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland",
        "Russia", "Spain", "UK",
    ].shuffled()
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var score = 0
    @State private var correctAnswer = Int.random(in: 0...2)

    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 5
        } else {
            scoreTitle = "Wrong, try again!"
            score -= 3
        }
        showingScore = true
    }

    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }

    func resetGame() {
        score = 0
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue, .black], startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    VStack(spacing: 5) {
                        Text("Tap the flag of")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        Text(countries[correctAnswer])
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 140)

                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            Image(countries[number])
                                .renderingMode(.original)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.black, lineWidth: 1)
                                )
                                .shadow(color: .black, radius: 2)
                        }
                        .padding(.vertical, 5)
                    }

                    Spacer()

                    Text("Total Score: \(score)")
                        .foregroundColor(.white)
                        .fontWeight(.black)
                        .font(.title)
                        .padding()
                }
                .padding()
                .alert(scoreTitle, isPresented: $showingScore) {
                    Button("Continue", action: askQuestion)
                } message: {
                    Text("Your score is \(score)")
                }
            }
            .navigationTitle("GUESS THE FLAG")

            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 10) {
                        Image("flaglogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 5)
                            .padding(.top, 200)
                            .padding(.leading, 70)

                        Text("GUESS THE FLAG")
                            .font(.largeTitle.bold())
                            .lineLimit(nil)
                            .fixedSize(horizontal: true , vertical: false)
                            .foregroundColor(.orange)
                            .shadow(radius: 5)
                            .padding(.bottom, 60)
                            .padding(.leading, 70)
                    }

                }
                ToolbarItem(
                    placement:

                        .topBarTrailing
                ) {
                    HStack(spacing: 10) {
                        Button(action: resetGame) {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                                .frame(width: 50, height: 50)
                                .contentShape(Rectangle())
                                .background(Color.orange)
                                .clipShape(Circle())
                                
                        }
                        
                       
                    }
                }
            }
        }
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 20)
        }
    }
}
#Preview {
    ContentView()
}
