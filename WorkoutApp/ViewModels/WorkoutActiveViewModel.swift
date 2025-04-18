//
//  WorkoutActiveViewModel.swift
//  WorkoutApp
//
//  Created by Leon Grimmeisen on 05.08.24.
//
import Foundation
import SwiftUI
import Combine
import ActivityKit
import AVFoundation
import UIKit

class WorkoutActiveViewModel: ObservableObject {
    @Published var workout: Workout
    let workoutViewModel: WorkoutDetailViewModel
    private let appState: AppState
    private var audioPlayer: AVAudioPlayer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    // STATE
    @Published var isPaused = false
    @Published var isRunning = false
    @Published var circleProgress = 0.0
    @Published var barProgress = 0.0
    @Published var showCompletedView = false
    @Published var celebrationSoundPlayed = false
    private var countdownPlayed = false
    // TIMER
    @Published var workoutTimeline: [Activity]
    @Published var activityIndex = 0
    @Published var workoutTimeLeft: Double
    @Published var currentActivityTimeLeft: Double
    private var cancellables = Set<AnyCancellable>()
    
    init(workoutViewModel: WorkoutDetailViewModel, workout: Workout, workoutTimeline: [Activity], appState: AppState) {
        self.workoutViewModel = workoutViewModel
        self.workout = workout
        self.workoutTimeline = workoutTimeline
        self.workoutTimeLeft = workout.duration
        self.currentActivityTimeLeft = workoutTimeline[0].duration
        self.appState = appState

        setupTimerSubscription()
        setupBackgroundHandling()
        setupAudioSession()
        //startLiveActivity()
    }

    var currentActivity: Activity { workoutTimeline[activityIndex] }
    var isRestActivity: Bool { currentActivity.title == "Rest" }
    var nextExerciseActivity: Activity? {
        return workoutTimeline.dropFirst(activityIndex + 1).first(where: { $0.type == .exercise })
    }
    
    private func setupTimerSubscription() {
        Timer
            .publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.isRunning {
                    self.updateTimers()
                    self.checkActivityCompletion()
                    self.updateProgress()
                }
            }
            .store(in: &cancellables)
    }

    private func updateTimers() {
        currentActivityTimeLeft -= 0.1
        workoutTimeLeft = calculateRemainingActivitiesDuration() + currentActivityTimeLeft

        if !countdownPlayed {
            handleNextActivityAnnouncement()
            handleCountdownSound()
        }
    }

    private func calculateRemainingActivitiesDuration() -> Double {
        guard activityIndex + 1 < workoutTimeline.count else { return 0 }
        return workoutTimeline[(activityIndex + 1)...].reduce(0) { $0 + $1.duration }
    }

    private func handleNextActivityAnnouncement() {
        if currentActivityTimeLeft < 4.3 && currentActivityTimeLeft >= 4.2 {
            if getSoundsEnabled() && activityIndex + 1 < workoutTimeline.count {
                let nextActivity = workoutTimeline[activityIndex + 1]
                announceWorkoutActivity(activity: nextActivity)
            }
        }
    }

    private func handleCountdownSound() {
        if currentActivityTimeLeft < 3 {
            if getSoundsEnabled() {
                DispatchQueue.main.async {
                    SoundManager.instance.playSound(sound: .countdown)
                }
            }
            countdownPlayed = true
        }
    }


    
    private func updateProgress() {
        circleProgress = 1 - (currentActivityTimeLeft / currentActivity.duration)
        barProgress = (workout.duration - workoutTimeLeft) / workout.duration
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func setupBackgroundHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func appMovedToBackground() {
        guard isRunning else { return }
        startBackgroundAudio()
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    @objc private func appMovedToForeground() {
        stopBackgroundAudio()
        endBackgroundTask()
    }

    private func startBackgroundAudio() {
        guard audioPlayer == nil else { return }
        
        guard let audioURL = Bundle.main.url(forResource: "silence", withExtension: "mp3") else {
            print("Silent audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 0.01 // Set volume very low
            audioPlayer?.play()
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }

    private func stopBackgroundAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }

//    func startLiveActivity() {
//        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
//        
//        let attributes = WorkoutAttributes(workoutEndTime: Date().addingTimeInterval(TimeInterval(workout.duration) + 1))
//        let contentState = WorkoutAttributes.ContentState(
//            endTime: Date().addingTimeInterval(TimeInterval(currentActivityTimeLeft + 1)),
//            startTime: Date(),
//            activitiyName: currentActivity.title,
//            activityDuration: currentActivity.duration
//        )
//        
//        do {
//            let activity = try ActivityKit.Activity.request(
//                attributes: attributes,
//                content: .init(state: contentState, staleDate: nil),
//                pushType: nil
//            )
//            print("Requested a Live Activity \(activity.id)")
//        } catch {
//            print("Error requesting Live Activity: \(error.localizedDescription)")
//        }
//    }
//    
//    func updateLiveActivity() {
//        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
//        print("updated activity")
//        print("new activity: \(currentActivity.title)")
//
//        let updatedContentState = WorkoutAttributes.ContentState(
//            endTime: Date().addingTimeInterval(TimeInterval(currentActivityTimeLeft)),
//            startTime: Date(),
//            activitiyName: currentActivity.title,
//            activityDuration: currentActivity.duration
//        )
//        
//        Task {
//            for activity in ActivityKit.Activity<WorkoutAttributes>.activities {
//                await activity.update(ActivityContent(state: updatedContentState, staleDate: nil))
//            }
//        }
//    }
//
//    func endLiveActivity() {
//        Task {
//            for activity in ActivityKit.Activity<WorkoutAttributes>.activities {
//                await activity.end(ActivityContent(state: activity.content.state, staleDate: nil), dismissalPolicy: .immediate)
//            }
//        }
//    }
    
    func getSoundsEnabled() -> Bool {
        return UserDefaults.standard.hasSoundsEnabled
    }
    
    func resetWorkout() {
        isRunning = false
        isPaused = false
        activityIndex = 0
        workoutTimeLeft = workout.duration
        currentActivityTimeLeft = currentActivity.duration
        celebrationSoundPlayed = false
        stopBackgroundAudio()
        endBackgroundTask()
    }

    func skipActivity() {
        if activityIndex == workoutTimeline.count - 2 {
            finishWorkoutToCompletedView()
        } else {
            workoutTimeLeft -= currentActivityTimeLeft
            activityIndex += 1
            currentActivityTimeLeft = currentActivity.duration
            countdownPlayed = false // Reset countdown flag to allow for new countdown

            if getSoundsEnabled() {
                SoundManager.instance.stopSound()
            }
        }
    }

    func togglePause() {
        isPaused.toggle()
        isRunning = !isPaused
        if isPaused {
            stopBackgroundAudio()
            if getSoundsEnabled() {
                SoundManager.instance.pauseSound()
            }
        } else {
            if UIApplication.shared.applicationState == .background {
                startBackgroundAudio()
            }
            if getSoundsEnabled() {
                SoundManager.instance.resumeSound()
            }
        }
    }

    func finishWorkoutToCompletedView() {
        isRunning = false
        showCompletedView = true
        stopBackgroundAudio()
        endBackgroundTask()
        appState.saveCompletedWorkoutSession(workout)
        workoutViewModel.workout.completions += 1
        workoutViewModel.saveWorkout()
    }
    
    func finishWorkoutFinal() {
        resetWorkout()
        showCompletedView = false
    }

    private func checkActivityCompletion() {
        if currentActivityTimeLeft <= 0 {
            if activityIndex == workoutTimeline.count - 2 {
                finishWorkoutToCompletedView()
                //endLiveActivity()
            } else {
                activityIndex += 1
                currentActivityTimeLeft = currentActivity.duration
                countdownPlayed = false
                //updateLiveActivity()
            }
        }
    }
    
    private func announceWorkoutActivity(activity: Activity) {
        if getSoundsEnabled() {
            let text = "\(activity.title)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                SoundManager.instance.speakText(text: text)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
