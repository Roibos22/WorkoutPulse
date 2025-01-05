//
//  WorkoutTimelineService.swift
//  WorkoutApp
//
//  Created by Leon Grimmeisen on 03.08.24.
//

import Foundation

class WorkoutTimelineService {
    private let preparationDuration: Double = 10.0
    
    func createWorkoutTimeline(workout: Workout) -> [Activity] {
        guard !workout.exercises.isEmpty else { return [] }
        
        var activities: [Activity] = []
        var startTime: Double = 0.0
        
        activities.append(createPreparationActivity(startTime: startTime))
        startTime += preparationDuration
        
        for cycleNo in 1...workout.cycles {
            activities.append(contentsOf: createCycleActivities(workout: workout, cycleNo: cycleNo, startTime: &startTime))
            
            if cycleNo < workout.cycles {
                activities.append(createCycleRestActivity(workout: workout, cycleNo: cycleNo, startTime: &startTime))
            }
        }
        
        activities.append(createDoneActivity(workout: workout, startTime: startTime))
        
        return activities
    }
    
    func createCycleTimeline(workout: Workout) -> [Cycle] {
        guard !workout.exercises.isEmpty else { return [] }
        
        var cycles: [Cycle] = []
        var startTime: Double = 0.0
        
        cycles.append(createPreparationCycle(startTime: &startTime))
        
        for cycleNo in 1...workout.cycles {
            cycles.append(createWorkoutCycle(workout: workout, cycleNo: cycleNo, startTime: &startTime))
            
            if cycleNo < workout.cycles {
                cycles.append(createRestCycle(workout: workout, cycleNo: cycleNo, startTime: &startTime))
            }
        }
        
        return cycles
    }
    
    // MARK: - Private Helper Methods
    
    private func createPreparationActivity(startTime: Double) -> Activity {
        return Activity(title: "Preparation", type: .countdown, duration: preparationDuration, timeLeft: preparationDuration, startingTime: startTime, cycleNo: 0, activityNo: 0)
    }
    
    private func createCycleActivities(workout: Workout, cycleNo: Int, startTime: inout Double) -> [Activity] {
        var activities: [Activity] = []
        
        for (index, exercise) in workout.exercises.enumerated() {
            activities.append(createExerciseActivity(exercise: exercise, cycleNo: cycleNo, activityNo: index + 1, startTime: &startTime))
            
            if index < workout.exercises.count - 1 {
                activities.append(createRestActivity(exercise: exercise, cycleNo: cycleNo, activityNo: index + 1, startTime: &startTime))
            }
        }
        
        return activities
    }
    
    private func createExerciseActivity(exercise: Exercise, cycleNo: Int, activityNo: Int, startTime: inout Double) -> Activity {
        let activity = Activity(title: "\(exercise.title)", type: .exercise, duration: exercise.duration, timeLeft: exercise.duration, startingTime: startTime, cycleNo: cycleNo, activityNo: activityNo)
        startTime += exercise.duration
        return activity
    }
    
    private func createRestActivity(exercise: Exercise, cycleNo: Int, activityNo: Int, startTime: inout Double) -> Activity {
        let activity = Activity(title: "Rest", type: .rest, duration: exercise.rest, timeLeft: exercise.rest, startingTime: startTime, cycleNo: cycleNo, activityNo: activityNo)
        startTime += exercise.rest
        return activity
    }
    
    private func createCycleRestActivity(workout: Workout, cycleNo: Int, startTime: inout Double) -> Activity {
        let activity = Activity(title: "Rest", type: .rest, duration: workout.cycleRestTime, timeLeft: workout.cycleRestTime, startingTime: startTime, cycleNo: cycleNo, activityNo: 0)
        startTime += workout.cycleRestTime
        return activity
    }
    
    private func createDoneActivity(workout: Workout, startTime: Double) -> Activity {
        return Activity(title: "Done", type: .done, duration: 0, timeLeft: 0, startingTime: startTime, cycleNo: workout.cycles, activityNo: workout.exercises.count)
    }
    
    private func createPreparationCycle(startTime: inout Double) -> Cycle {
        let activity = createPreparationActivity(startTime: startTime)
        startTime += preparationDuration
        return Cycle(title: "Preparation cycle", duration: preparationDuration, startingTime: 0.0, activities: [activity], cycleNumber: 0)
    }
    
    private func createWorkoutCycle(workout: Workout, cycleNo: Int, startTime: inout Double) -> Cycle {
        var cycle = Cycle(title: "Cycle \(cycleNo)", duration: 0.0, startingTime: startTime, activities: [], cycleNumber: cycleNo)
        let cycleActivities = createCycleActivities(workout: workout, cycleNo: cycleNo, startTime: &startTime)
        cycle.activities = cycleActivities
        cycle.duration = cycleActivities.reduce(0) { $0 + $1.duration }
        return cycle
    }
    
    private func createRestCycle(workout: Workout, cycleNo: Int, startTime: inout Double) -> Cycle {
        let activity = createCycleRestActivity(workout: workout, cycleNo: cycleNo, startTime: &startTime)
        return Cycle(title: "Recovery cycle", duration: workout.cycleRestTime, startingTime: startTime - workout.cycleRestTime, activities: [activity], cycleNumber: 0)
    }
}
