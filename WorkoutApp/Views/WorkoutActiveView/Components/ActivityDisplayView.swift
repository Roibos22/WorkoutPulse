//
//  ActivityDisplayView.swift
//  WorkoutApp
//
//  Created by Leon Grimmeisen on 05.08.24.
//

import SwiftUI

struct ActivityDisplayView: View {
    @ObservedObject var viewModel: WorkoutActiveViewModel

    var body: some View {
        VStack(spacing: 15) {
            Text(viewModel.currentActivity.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(viewModel.isRestActivity ? Color.blue : Color.black, lineWidth: 6)
                )
            
            if let nextActivity = viewModel.nextExerciseActivity {
                Text("Next: \(nextActivity.title)")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(viewModel.isRestActivity ? .blue : .black)
    }
}

struct ActivityDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutActiveView(viewModel: WorkoutActiveViewModel(workoutViewModel: WorkoutDetailViewModel(appState: AppState()), workout: sampleWorkout, workoutTimeline: sampleWorkoutTimeline, appState: AppState()))
    }
    
    // Sample data for preview
    static var sampleWorkout: Workout = Workout.defaultWorkouts[0]
    static var timelineService = WorkoutTimelineService()
    static var sampleWorkoutTimeline: [Activity] = timelineService.createWorkoutTimeline(workout: sampleWorkout)
}
