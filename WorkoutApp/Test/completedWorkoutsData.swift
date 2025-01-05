//
//  completedWorkoutsData.swift
//  WorkoutPulse
//
//  Created by Leon Grimmeisen on 19.08.24.
//

import Foundation

// generates test data for completed workouts to simulate workout scenarios and streaks

func generateTestData() -> [CompletedWorkout] {
    let calendar = Calendar.current
    let now = Date()
    
    let pushUps = Exercise(title: "Push-ups", duration: 30, rest: 10)
    let sitUps = Exercise(title: "Sit-ups", duration: 30, rest: 10)
    let squats = Exercise(title: "Squats", duration: 30, rest: 10)
    let lunges = Exercise(title: "Lunges", duration: 30, rest: 10)
    let plank = Exercise(title: "Plank", duration: 60, rest: 20)

    let workout1 = Workout(title: "Quick HIIT", cycles: 3, cycleRestTime: 60, exercises: [pushUps, sitUps, squats])
    let workout2 = Workout(title: "Core Strength", cycles: 4, cycleRestTime: 90, exercises: [sitUps, plank])
    let workout3 = Workout(title: "Leg Day", cycles: 3, cycleRestTime: 60, exercises: [squats, lunges])
    let workout4 = Workout(title: "Full Body", cycles: 2, cycleRestTime: 120, exercises: [pushUps, sitUps, squats, lunges, plank])
    let workout5 = Workout(title: "Upper Body", cycles: 4, cycleRestTime: 60, exercises: [pushUps, plank])

    var completedWorkouts: [CompletedWorkout] = []

    for day in 0..<100 {
        if day % 2 == 0 { // Every other day
            let date = calendar.date(byAdding: .day, value: -day, to: now)!
            let workout = [workout1, workout2, workout3, workout4, workout5].randomElement()!
            completedWorkouts.append(CompletedWorkout(workout: workout, timestamp: date))
        }
    }

    let earlyBirdDate = calendar.date(bySettingHour: 5, minute: 30, second: 0, of: now)!
    completedWorkouts.append(CompletedWorkout(workout: workout1, timestamp: earlyBirdDate))

    // 7-day streak
    for day in 0..<7 {
        let date = calendar.date(byAdding: .day, value: -day, to: now)!
        completedWorkouts.append(CompletedWorkout(workout: workout2, timestamp: date))
    }

    // 14-day streak (continues from the 7-day streak)
    for day in 7..<14 {
        let date = calendar.date(byAdding: .day, value: -day, to: now)!
        completedWorkouts.append(CompletedWorkout(workout: workout3, timestamp: date))
    }

    // 30-day streak (continues from the 14-day streak)
    for day in 14..<30 {
        let date = calendar.date(byAdding: .day, value: -day, to: now)!
        completedWorkouts.append(CompletedWorkout(workout: workout4, timestamp: date))
    }

    // Add more workouts to reach 100 total
    while completedWorkouts.count < 100 {
        let daysAgo = completedWorkouts.count - 59 // Start 30 days after the last workout
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
        let workout = [workout1, workout2, workout3, workout4, workout5].randomElement()!
        completedWorkouts.append(CompletedWorkout(workout: workout, timestamp: date))
    }

    return completedWorkouts
}

func generateStreakTestData() -> [CompletedWorkout] {
    let calendar = Calendar.current
    let now = Date()
    
    let exercises = [
        Exercise(title: "Push-ups", duration: 30, rest: 10),
        Exercise(title: "Sit-ups", duration: 30, rest: 10),
        Exercise(title: "Squats", duration: 30, rest: 10)
    ]
    let sampleWorkout = Workout(title: "Test Workout", cycles: 3, cycleRestTime: 60, exercises: exercises)
    var completedWorkouts: [CompletedWorkout] = []

    func addWorkout(daysAgo: Int) {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
        completedWorkouts.append(CompletedWorkout(workout: sampleWorkout, timestamp: date))
    }

    // Test case 1: 1-day streak (Kickoff)
    addWorkout(daysAgo: 0)
    addWorkout(daysAgo: 1)
    addWorkout(daysAgo: 2)

    // Test case 2: 3-day streak (Tripler)
    for day in 10...12 {
        addWorkout(daysAgo: day)
    }

    // Test case 3: 7-day streak (Weeklong)
    for day in 20...26 {
        addWorkout(daysAgo: day)
    }

    // Test case 4: 14-day streak (Fortnight)
    for day in 40...53 {
        addWorkout(daysAgo: day)
    }

    // Test case 5: 30-day streak (Monthly)
    for day in 70...99 {
        addWorkout(daysAgo: day)
    }
    for day in 70...99 {
        addWorkout(daysAgo: day)
    }
    for day in 70...99 {
        addWorkout(daysAgo: day)
    }

    // Test case 6: 90-day streak (Eternity)
    //    for day in 150...239 {
    //        addWorkout(daysAgo: day)
    //    }

    // Test case 7: Broken streaks
    addWorkout(daysAgo: 300)
    addWorkout(daysAgo: 301)
    addWorkout(daysAgo: 303) // One day gap
    addWorkout(daysAgo: 304)
    addWorkout(daysAgo: 305)

    // Test case 8: Multiple workouts in a day (should still count as one day for streak)
    let multipleDayDate = calendar.date(byAdding: .day, value: -400, to: now)!
    completedWorkouts.append(CompletedWorkout(workout: sampleWorkout, timestamp: multipleDayDate))
    completedWorkouts.append(CompletedWorkout(workout: sampleWorkout, timestamp: multipleDayDate.addingTimeInterval(3600))) // 1 hour later

    return completedWorkouts
}
