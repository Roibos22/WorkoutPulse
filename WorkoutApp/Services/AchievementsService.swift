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
    
    func getCurrentStreak() -> (length: Int, startDate: Date, doneToday: Bool) {
        let completedWorkouts = dataManager.loadCompletedWorkouts()
        var currentStreak = 0
        var doneToday = false

        let workoutDates = Set(completedWorkouts.map { Calendar.current.startOfDay(for: $0.timestamp) })
        guard var latestDate = workoutDates.max() else { return (0, Date(), false) }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
        
        doneToday = calendar.isDate(latestDate, inSameDayAs: today) ? true : false
        if !(doneToday || calendar.isDate(latestDate, inSameDayAs: yesterday!)) {
            return (0, Date.now, false)
        }
        
        while workoutDates.contains(latestDate) {
            currentStreak += 1
            guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: latestDate) else { break }
            latestDate = previousDate
        }
        let streakStartDate = Calendar.current.date(byAdding: .day, value: -(currentStreak - (doneToday ? 1 : 0)), to: Date.now) ?? latestDate

        return (currentStreak, streakStartDate, doneToday)
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
    
    func getTotalCompletions() -> Int {
        let completedWorkouts = dataManager.loadCompletedWorkouts()
        return completedWorkouts.count
    }
    
    func getTotalDuration() -> Double {
        let completedWorkouts = dataManager.loadCompletedWorkouts()
        let totalDurationSeconds = completedWorkouts.reduce(0.0) { total, workout in
            total + (workout.workout.duration)
        }
        return totalDurationSeconds
    }
    
    func updateAchievements() {
        updateStreaksAchievements()
        updateCompletionsAchievements()
        updateDurationsAchievements()
        updateMiscAchievements()
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
        
        for i in 0..<streakAchievements.count {
            streakAchievements[i].achieved = longestStreak >= streakAchievements[i].value
        }
        
        achievements[0].achievements = streakAchievements
        dataManager.saveAchievements(achievements)
    }
    
    func updateCompletionsAchievements() {
        var achievements = dataManager.loadAchievements()
        var completionAchievements = achievements[1].achievements
        let totalWorkouts = getTotalCompletions()
        
        for i in 0..<completionAchievements.count {
            completionAchievements[i].achieved = totalWorkouts >= completionAchievements[i].value
        }
        
        achievements[1].achievements = completionAchievements
        dataManager.saveAchievements(achievements)
    }

    func updateDurationsAchievements() {
        var achievements = dataManager.loadAchievements()
        var durationAchievements = achievements[2].achievements
        let totalDurationHours = getTotalDuration() / 3600
        for i in 0..<durationAchievements.count {
            durationAchievements[i].achieved = Int(totalDurationHours) >= durationAchievements[i].value
        }
        
        achievements[2].achievements = durationAchievements
        dataManager.saveAchievements(achievements)
    }
    
    func updateMiscAchievements() {
        var achievements = dataManager.loadAchievements()
        var miscAchievements = achievements[3].achievements
        
        let completedWorkouts = dataManager.loadCompletedWorkouts()
        let uniqueWorkoutsCount = Set(completedWorkouts.map { $0.workout.id }).count
        
        miscAchievements[0].achieved = UserDefaults.standard.hasCreatedCustomWorkout
        miscAchievements[1].achieved = UserDefaults.standard.hasSavedTemplateWorkout
        miscAchievements[2].achieved = uniqueWorkoutsCount >= miscAchievements[2].value
        miscAchievements[3].achieved = uniqueWorkoutsCount >= miscAchievements[3].value
        miscAchievements[4].achieved = uniqueWorkoutsCount >= miscAchievements[4].value
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



