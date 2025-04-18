//
//  WorkoutListView.swift
//  WorkoutApp
//
//  Created by Leon Grimmeisen on 03.08.24.
//

import SwiftUI

struct WorkoutListView: View {
    @ObservedObject var viewModel: WorkoutListViewModel
    @EnvironmentObject var appState: AppState
    @State private var currentStreak: Int = 0
    @State private var workoutDoneToday: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    workoutsList
                    addWorkoutButton
                        .padding(.bottom, 25)
                    
                    HStack {
                        Text("Discover Workouts")
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    ForEach(Workout.sampleWorkouts) { workout in
                        ZStack {
                            NavigationLink(destination: WorkoutDetailView(
                                viewModel: WorkoutDetailViewModel(workout: workout, appState: appState), 
                                workoutType: .preset
                            )) {
                                WorkoutCardView(viewModel: WorkoutDetailViewModel(workout: workout, appState: appState), workout: workout, workoutType: .preset)
                                    .foregroundColor(.black)
                                    .contentShape(Rectangle())
                            }
                        }
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .onAppear {
                (currentStreak, _ , workoutDoneToday) = viewModel.getCurrentStreak()
            }
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    settingsButton
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    historyButton
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    editWorkoutsButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    streaksButton
                }

            }
        }
    }
    
    private var workoutsList: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Your Workouts")
                    .font(.title)
                    .bold()
                Spacer()
            }
            ForEach(viewModel.workouts) { workout in
                ZStack {
                    NavigationLink(destination: WorkoutDetailView(
                        viewModel: WorkoutDetailViewModel(workout: workout, appState: appState), workoutType: .custom
                    )) {
                        WorkoutCardView(viewModel: WorkoutDetailViewModel(workout: workout, appState: appState), workout: workout, workoutType: .custom)
                            .foregroundColor(.black)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
    }
    
    private var editWorkoutsButton: some View {
        NavigationLink(destination: EditWorkoutsView(viewModel: viewModel)) {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundColor(.primary)
                .font(.title2)
                .bold()
        }
    }
    
    private var settingsButton: some View {
        NavigationLink(destination: SettingsView(viewModel: viewModel)) {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.primary)
                .font(.title2)
                .bold()
        }
    }
    
    private var historyButton: some View {
        NavigationLink(destination: WorkoutHistoryView(appState: appState)) {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(.primary)
                .font(.title2)
                .bold()
        }
    }
    
    private var streaksButton: some View {
        NavigationLink(destination: StreaksView(appState: viewModel.getAppState())) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(workoutDoneToday ? .red : .gray)
                Text("\(String(currentStreak))")
            }
            .foregroundColor(.primary)
            .font(.title2)
            .bold()
        }
    }
    
    private var addWorkoutButton: some View {
        NavigationLink(destination: WorkoutDetailView(
            viewModel: WorkoutDetailViewModel(workout: nil, appState: appState), workoutType: .custom
        )) {
            ZStack {
                RoundedRectangle(cornerRadius: 50)
                    .frame(width: 130, height: 50)
                    .foregroundColor(Color.blue)
                HStack {
                    Text("+")
                        .font(.title)
                        .foregroundColor(.white)
                        .offset(CGSize(width: 0, height: -1))
                    Text("New")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
            }
        }
    }
}

#Preview {
    let appState = AppState()
    return WorkoutListView(viewModel: WorkoutListViewModel(appState: appState))
        .environmentObject(appState)
}
