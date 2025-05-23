//
//  WorkoutDetailViewModel.swift
//  WorkoutApp
//
//  Created by Leon Grimmeisen on 03.08.24.
//

import Foundation

class WorkoutDetailViewModel: ObservableObject {
    @Published var workout: Workout
    @Published var completions: Int = 0
    @Published var showDeleteNotPossibleAlert = false
    private let appState: AppState
    let isNewWorkout: Bool

    init(workout: Workout? = nil, appState: AppState) {
        self.appState = appState
        self.isNewWorkout = workout == nil
        self.workout = workout ?? appState.generateNewWorkout()
    }
    
    func saveWorkout(notifyObservers: Bool = false) {
        appState.saveWorkout(workout, notifyObservers: notifyObservers, type: .custom)
    }
    
    func savePresetWorkout(notifyObservers: Bool = false) {
        var newWorkout = workout.duplicatWithNewId()
    
        var newTitle = newWorkout.title
        var counter = 1
        while appState.workouts.contains(where: { $0.id != workout.id && $0.title == newTitle }) {
            counter += 1
            newTitle = "\(newWorkout.title) \(counter)"
        }
        newWorkout.title = newTitle
        appState.saveWorkout(newWorkout, notifyObservers: notifyObservers, type: .preset)
    }
    
    func deleteExercise(_ exercise: Exercise) {
        workout.exercises.removeAll { $0.id == exercise.id }
        saveWorkout(notifyObservers: false)
    }
    
    func deleteExerciseIndexSet(at offsets: IndexSet) {
        if workout.exercises.count == 1 {
            showDeleteNotPossibleAlert = true
        } else {
            workout.exercises.remove(atOffsets: offsets)
            saveWorkout(notifyObservers: false)
        }
    }
    
    func addExercise(_ exercise: Exercise) {
        workout.exercises.append(exercise)
        saveWorkout(notifyObservers: false)
    }
    
    func moveExercise(at offsets: IndexSet, to destination: Int) {
        workout.exercises.move(fromOffsets: offsets, toOffset: destination)
        saveWorkout(notifyObservers: false)
    }
    
    func deleteWorkout() {
        appState.deleteWorkout(workout)
    }

    func updateTitle(_ title: String) {
        var newTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        var counter = 1
        
        while appState.workouts.contains(where: { $0.id != workout.id && $0.title == newTitle }) {
            counter += 1
            newTitle = "\(title) \(counter)"
        }
        
        appState.updateTitleCompletedWorkouts(workout: workout, title: "\(workout.title)")

        workout.title = "\(newTitle)"
        saveWorkout()
    }
    
    func createCycleTimeline() -> [Cycle] {
        return appState.createCycleimeline(workout: workout)
    }
}
