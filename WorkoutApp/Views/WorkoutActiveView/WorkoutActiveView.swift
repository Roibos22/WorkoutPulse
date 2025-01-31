//
//  WorkoutActiveView.swift
//  WorkoutApp
//
//  Created by Leon Grimmeisen on 11.10.23.
//

import SwiftUI

struct WorkoutActiveView: View {
    @ObservedObject var viewModel: WorkoutActiveViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEndAlert = false

    var body: some View {
        ZStack {
            viewModel.isRestActivity ? Color.black : Color.blue
            
            VStack {
                if viewModel.showCompletedView {
                    WorkoutCompletedView(viewModel: viewModel, workout: viewModel.workout, workoutTimeline: viewModel.workoutTimeline)
                } else {
                    VStack {
                        Spacer()
                        ActivityDisplayView(viewModel: viewModel)
                        Spacer()
                        ProgressCircleView(viewModel: viewModel)
                        Spacer()
                        ControlButtonsView(viewModel: viewModel, showEndAlert: $showEndAlert)
                            .padding(.horizontal, 7)
                        ProgressBarView(viewModel: viewModel)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .alert("End Workout", isPresented: $showEndAlert) {
            Button("End Workout") {
                viewModel.resetWorkout()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to end your workout?")
        }
    }
}

struct WorkoutActiveView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutActiveView(viewModel: WorkoutActiveViewModel(workoutViewModel: WorkoutDetailViewModel(appState: AppState()), workout: sampleWorkout, workoutTimeline: sampleWorkoutTimeline, appState: AppState()))
    }
    
    // Sample data for preview
    static var sampleWorkout: Workout = Workout.defaultWorkouts[0]
    static var timelineService = WorkoutTimelineService()
    static var sampleWorkoutTimeline: [Activity] = timelineService.createWorkoutTimeline(workout: sampleWorkout)
}
