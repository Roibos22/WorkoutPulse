//
//  WorkoutCompletedView.swift
//  WorkoutApp
//
//  Created by Leon Grimmeisen on 19.12.23.
//

import SwiftUI
import ConfettiSwiftUI

struct WorkoutCompletedView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WorkoutActiveViewModel

    let workout: Workout
    let workoutTimeline: [Activity]
    
    @State private var counter = 0
    @State private var colorSwitchedCounter: Int = 0
    @State private var oppositeColor: Bool = true
    
    private let confettiCount = 100
    private let confettiOpeningAngle = Angle.degrees(30)
    private let confettiClosingAngle = Angle.degrees(150)
    private let timerInterval = 0.2
    
    private var totalExercises: Int { workout.exercises.count * workout.cycles }
    private var mainColor: Color { .blue }
    private var accentColor: Color { .black }
    private var totalTime: Double {
        workoutTimeline.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView
                
                VStack {
                    Spacer()
                    congratulationsMessage
                    Spacer()
                    workoutSummary
                    Spacer()
                    confettiButton
                    Spacer()
                    endWorkoutButton
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .confettiCannon(
            counter: $counter,
            num: confettiCount,
            openingAngle: confettiOpeningAngle,
            closingAngle: confettiClosingAngle
        )
        .onAppear {
            startConfetti()
            if viewModel.isFirstWorkoutCompletion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    viewModel.requestAppStoreReview()
                }
            }
        }
    }
    
    private var backgroundView: some View {
        oppositeColor ? accentColor : mainColor
    }
    
    private var congratulationsMessage: some View {
        VStack {
            Text("Congratulations!")
                .font(.system(size: 35))
                .padding(5)
            Text("You just finished another Workout")
                .font(.callout)
        }
        .foregroundColor(oppositeColor ? mainColor : accentColor)
        .bold()
    }
    
    private var workoutSummary: some View {
        VStack(spacing: 10) {
            Text(workout.title)
                .font(.title)
            HStack {
                Image(systemName: "clock.fill")
                Text("Total Duration:")
                Text("\(totalTime.asMinutes())")
            }
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Exercises completed:")
                Text("\(totalExercises)")
            }
        }
        .font(.title3)
        .foregroundColor(oppositeColor ? mainColor : accentColor)
        .bold()
    }
    
    private var confettiButton: some View {
        Button {
            counter += 1
        } label: {
            Text(String("🎉"))
                .font(.system(size: 70))
        }
    }
    
    private var endWorkoutButton: some View {
        Button {
            viewModel.finishWorkoutFinal()
            dismiss()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: .infinity)
                    .foregroundColor(oppositeColor ? mainColor : .black)
                Text("End Workout")
                    .foregroundColor(oppositeColor ? accentColor : .white)
                    .bold()
                    .font(.title2)
            }
            .frame(width: 200, height: 75)
        }
    }
    
    private func startConfetti() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if viewModel.getSoundsEnabled() && !viewModel.celebrationSoundPlayed {
                SoundManager.instance.playSound(sound: .jubilant)
                viewModel.celebrationSoundPlayed = true
             }
             self.counter += 1
        }
        
        // Start color switching
        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
            if colorSwitchedCounter < 10 {
                colorSwitchedCounter += 1
                oppositeColor.toggle()
            } else {
                timer.invalidate()
                colorSwitchedCounter = 0
            }
        }
    }
}
