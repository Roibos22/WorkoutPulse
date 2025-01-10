//
//  WorkoutListViewModel.swift
//  WorkoutApp
//
//  Created by Leon Grimmeisen on 02.08.24.
//

import Foundation
import Combine
import SwiftUI

class WorkoutListViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var selectedLanguage: Language = .englishUS
    private var cancellables = Set<AnyCancellable>()
    private let appState: AppState
    
    var language: Binding<Language> {
        Binding(
            get: { self.appState.language },
            set: { self.appState.setLanguage($0) }
        )
    }
    
    init(appState: AppState) {
        self.appState = appState
            
        appState.$workouts
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workouts in
                self?.workouts = workouts
            }
            .store(in: &cancellables)
    }
    
    func deleteWorkout(_ workout: Workout) {
        appState.deleteWorkout(workout)
    }
    
    func moveWorkout(at offsets: IndexSet, to destination: Int) {
        appState.moveWorkout(at: offsets, to: destination)
    }
    
    func deleteWorkoutIndexSet(at offsets: IndexSet) {
        let workoutsToDelete = offsets.map { workouts[$0] }
        if let workout = workoutsToDelete.first {
            appState.deleteWorkout(workout)
        }
    }
    
    func getCurrentStreak() -> (length: Int, startDate: Date, doneToday: Bool) {
        return (appState.getCurrentStreak())
    }
    
    func getAppState() -> AppState {
        return appState
    }
    
}
