//
//  AppState.swift
//  WorkoutApp
//
//  Created by Leon Grimmeisen on 02.08.24.
//

import Foundation

class AppState: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var completedWorkouts: [CompletedWorkout] = []
    @Published var achievements: [AchievementGroup] = []
    @Published var soundsEnabled: Bool = true
    
    @Published var language: Language {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "AppLanguage")
        }
    }
    
    private let dataManager = DataManager()
    private let workoutService: WorkoutDataService
    private let historyService: HistoryDataService
    private let timelineService: WorkoutTimelineService
    private let achievemetnsService: AchievementsService

    init() {
        workoutService = WorkoutDataService(dataManager: dataManager)
        historyService = HistoryDataService(dataManager: dataManager)
        timelineService = WorkoutTimelineService()
        achievemetnsService = AchievementsService(dataManager: dataManager)
        let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? "EN"
        self.language = Language(rawValue: savedLanguage) ?? .englishUS
        loadData()
    }
       
    func setLanguage(_ newLanguage: Language) {
        self.language = newLanguage
    }
    
    func loadData() {
        workouts = workoutService.fetchWorkouts()
        completedWorkouts = historyService.fetchWorkoutHistory()
    }
    
    func loadCompletedWorkout() {
        completedWorkouts = historyService.fetchWorkoutHistory()
    }
    
    func generateNewWorkout() -> Workout {
        return workoutService.generateNewWorkout()
    }
    
    func saveWorkout(_ workout: Workout, notifyObservers: Bool = false, type: WorkoutType) {
        workoutService.saveWorkout(workout, notifyObservers: notifyObservers, type: type)
        if notifyObservers {
            self.workouts = workoutService.fetchWorkouts()
        }
    }
    
    func deleteWorkout(_ workout: Workout) {
        workoutService.deleteWorkout(workout)
        loadData()  // Reload data to reflect changes
    }
    
    func moveWorkout(at offsets: IndexSet, to destination: Int) {
        workoutService.moveWorkout(at: offsets, to: destination)
        loadData()  // Reload data to reflect changes
    }
    
    func moveExercise(workout: Workout, at offsets: IndexSet, to destination: Int) {
        workoutService.moveExercise(workout: workout, at: offsets, to: destination)
        //loadData()  // Reload data to reflect changes
    }
    
    func createWorkoutTimeline(workout: Workout) -> [Activity] {
        return timelineService.createWorkoutTimeline(workout: workout)
    }
    
    func createCycleimeline(workout: Workout) -> [Cycle] {
        return timelineService.createCycleTimeline(workout: workout)
    }
    
    func getWorkoutsHistory() -> [CompletedWorkout] {
        historyService.fetchWorkoutHistory()
    }
    
    func saveCompletedWorkoutSession(_ workout: Workout) {
        let session = CompletedWorkout(workout: workout, timestamp: Date())
        historyService.saveCompletedWorkoutSession(session)
    }
    
    func updateTitleCompletedWorkouts(workout: Workout, title: String) {
        let completedWorkouts = getWorkoutsHistory()
        var updatedCompletedWorkouts: [CompletedWorkout] = []
        
        for completedWorkout in completedWorkouts {
            if completedWorkout.workout.id == workout.id {
                let updatedCompletedWorkout = CompletedWorkout(
                    id: completedWorkout.id,
                    workout: Workout(id: workout.id, title: "\(title)", cycles: workout.cycles, cycleRestTime: workout.cycleRestTime, exercises: workout.exercises),
                    timestamp: completedWorkout.timestamp
                )
                updatedCompletedWorkouts.append(updatedCompletedWorkout)
            } else {
                updatedCompletedWorkouts.append(completedWorkout)
            }
        }
        
       // completedWorkouts = updatedCompletedWorkouts
        historyService.saveWorkoutHistory(workouts: updatedCompletedWorkouts)
    }
    
    func getCurrentStreak() -> (length: Int, startDate: Date, doneToday: Bool) {
        return achievemetnsService.getCurrentStreak()
    }
    
    func getLongestStreak() -> (length: Int, startDate: Date) {
        return achievemetnsService.getLongestStreak()
    }
    
    func getAchievements() -> [AchievementGroup] {
        return achievemetnsService.fetchAchievements()
    }
    
    func updateAchievements() {
        achievemetnsService.updateAchievements()
    }

    func getTotalDurationString() -> Double {
        return achievemetnsService.getTotalDuration()
    }
    
    func getTotalCompletionsString() -> Int {
        return achievemetnsService.getTotalCompletions()
    }
}
