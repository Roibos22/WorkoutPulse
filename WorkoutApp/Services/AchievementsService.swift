//
//  File.swift
//  WorkoutPulse
//
//  Created by Leon Grimmeisen on 19.08.24.
//

import Foundation

class AchievementsService {
    private let dataManager: DataManager
    var completedWorkouts: [CompletedWorkout]
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        self.completedWorkouts = dataManager.loadCompletedWorkouts()
    }
    
    func fetchAchievements() -> [AchievementGroup] {
        updateAchievements()
        return dataManager.loadAchievements()
    }
    
    func saveAchievements(achievements: [AchievementGroup]) {
        return dataManager.saveAchievements(achievements)
    }
    
    func getCurrentStreak() -> (length: Int, startDate: Date) {
        let completedWorkouts = dataManager.loadCompletedWorkouts()
        let workoutDates = Set(completedWorkouts.map { Calendar.current.startOfDay(for: $0.timestamp) })
        guard var latestDate = workoutDates.max() else { return (0, Date()) }
        var currentStreak = 0
        
        while workoutDates.contains(latestDate) {
            currentStreak += 1
            guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: latestDate) else { break }
            latestDate = previousDate
        }
        let streakStartDate = Calendar.current.date(byAdding: .day, value: -(currentStreak - 2), to: latestDate) ?? latestDate
        
        return (currentStreak, streakStartDate)
    }

    func getLongestStreak() -> (length: Int, startDate: Date) {
        let completedWorkouts = dataManager.loadCompletedWorkouts()
        let calendar = Calendar.current
        let workoutDates = Set(completedWorkouts.map { calendar.startOfDay(for: $0.timestamp) }).sorted()
        
        var longestStreak = 0
        var currentStreak = 0
        var longestStreakStartDate = workoutDates.first ?? Date()
        var streakStartDate = longestStreakStartDate
        
        for (index, date) in workoutDates.enumerated() {
            if index > 0 && calendar.dateComponents([.day], from: workoutDates[index - 1], to: date).day == 1 {
                currentStreak += 1
            } else {
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                    longestStreakStartDate = streakStartDate
                }
                currentStreak = 1
                streakStartDate = date
            }
        }
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
            longestStreakStartDate = streakStartDate
        }
        
        return (longestStreak, longestStreakStartDate)
    }
    
    func updateAchievements() {
        updateStreaksAchievements()
        updateCompletionsAchievements()
        updateDurationsAchievements()
        updateMiscAchievements()
        print("Achievements updated")
    }
    
    func updateStreaksAchievements() {
        var achievements = dataManager.loadAchievements()
        var streakAchievements = achievements[0].achievements
        var longestStreak = 0
        var currentStreak = 0
        
        let completedWorkouts = dataManager.loadCompletedWorkouts()
        let workoutDates = Set(completedWorkouts.map { Calendar.current.startOfDay(for: $0.timestamp) })
        
        guard let earliestDate = workoutDates.min(),
              let latestDate = workoutDates.max() else { return }
        
        var currentDate = earliestDate
        while currentDate <= latestDate {
            if workoutDates.contains(currentDate) {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        //print("Longest streak in days: \(longestStreak)")
        for i in 0..<streakAchievements.count {
            switch i {
                case 0: streakAchievements[i].achieved = longestStreak >= streakAchievements[i].value
                case 1: streakAchievements[i].achieved = longestStreak >= streakAchievements[i].value
                case 2: streakAchievements[i].achieved = longestStreak >= streakAchievements[i].value
                case 3: streakAchievements[i].achieved = longestStreak >= streakAchievements[i].value
                case 4: streakAchievements[i].achieved = longestStreak >= streakAchievements[i].value
                case 5: streakAchievements[i].achieved = longestStreak >= streakAchievements[i].value
                default: break
            }
        }
        
        achievements[0].achievements = streakAchievements
        dataManager.saveAchievements(achievements)
    }
    
    func updateCompletionsAchievements() {
        var achievements = dataManager.loadAchievements()
        var completionAchievements = achievements[1].achievements
        
        let completedWorkouts = dataManager.loadCompletedWorkouts()
        let totalWorkouts = completedWorkouts.count
        
        for i in 0..<completionAchievements.count {
            switch i {
            case 0: completionAchievements[i].achieved = totalWorkouts >= completionAchievements[i].value
            case 1: completionAchievements[i].achieved = totalWorkouts >= completionAchievements[i].value
            case 2: completionAchievements[i].achieved = totalWorkouts >= completionAchievements[i].value
            case 3: completionAchievements[i].achieved = totalWorkouts >= completionAchievements[i].value
            case 4: completionAchievements[i].achieved = totalWorkouts >= completionAchievements[i].value
            case 5: completionAchievements[i].achieved = totalWorkouts >= completionAchievements[i].value
            default: break
            }
        }
        
        achievements[1].achievements = completionAchievements
        dataManager.saveAchievements(achievements)
    }

    func updateDurationsAchievements() {
        let completedWorkouts = dataManager.loadCompletedWorkouts()
        var achievements = dataManager.loadAchievements()
        var durationAchievements = achievements[2].achievements
        
        let totalDurationHours = completedWorkouts.reduce(0.0) { total, workout in
            total + (workout.workout.duration / 3600.0)  // Convert seconds to hours
        }
        
        //print(totalDurationHours)
        
        for i in 0..<durationAchievements.count {
            switch i {
            case 0: durationAchievements[i].achieved = totalDurationHours >= Double(durationAchievements[i].value)
            case 1: durationAchievements[i].achieved = totalDurationHours >= Double(durationAchievements[i].value)
            case 2: durationAchievements[i].achieved = totalDurationHours >= Double(durationAchievements[i].value)
            case 3: durationAchievements[i].achieved = totalDurationHours >= Double(durationAchievements[i].value)
            case 4: durationAchievements[i].achieved = totalDurationHours >= Double(durationAchievements[i].value)
            case 5: durationAchievements[i].achieved = totalDurationHours >= Double(durationAchievements[i].value)
            default: break
            }
        }
        
        achievements[2].achievements = durationAchievements
        dataManager.saveAchievements(achievements)
    }
    
    func updateMiscAchievements() {
        var achievements = dataManager.loadAchievements()
        var miscAchievements = achievements[3].achievements
        
        let completedWorkouts = dataManager.loadCompletedWorkouts()
        let uniqueWorkoutsCount = Set(completedWorkouts.map { $0.workout.id }).count
        
        miscAchievements[0].achieved = uniqueWorkoutsCount >= miscAchievements[0].value
        miscAchievements[1].achieved = uniqueWorkoutsCount >= miscAchievements[1].value
        miscAchievements[2].achieved = uniqueWorkoutsCount >= miscAchievements[2].value
        miscAchievements[3].achieved = UserDefaults.standard.hasCreatedCustomWorkout
        miscAchievements[4].achieved = UserDefaults.standard.hasSavedTemplateWorkout
        miscAchievements[5].achieved = checkEarlyBirdAchievement(completedWorkouts: completedWorkouts)

        achievements[3].achievements = miscAchievements
        dataManager.saveAchievements(achievements)
    }
    
    func checkEarlyBirdAchievement(completedWorkouts: [CompletedWorkout]) -> Bool {
        let earlyMorningCutoff = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date())!
        return completedWorkouts.contains { workout in
            Calendar.current.compare(workout.timestamp, to: earlyMorningCutoff, toGranularity: .hour) == .orderedAscending
        }
    }


}


extension UserDefaults {
    private enum Keys {
        static let hasCreatedCustomWorkout = "hasCreatedCustomWorkout"
        static let hasSavedTemplateWorkout = "hasSavedTemplateWorkout"
    }
    
    var hasCreatedCustomWorkout: Bool {
        get { bool(forKey: Keys.hasCreatedCustomWorkout) }
        set { set(newValue, forKey: Keys.hasCreatedCustomWorkout) }
    }
    
    var hasSavedTemplateWorkout: Bool {
        get { bool(forKey: Keys.hasSavedTemplateWorkout) }
        set { set(newValue, forKey: Keys.hasSavedTemplateWorkout) }
    }
}


func onCustomWorkoutCreated() {
    UserDefaults.standard.hasCreatedCustomWorkout = true
}

