//
//  StreaksView.swift
//  WorkoutPulse
//
//  Created by Leon Grimmeisen on 13.08.24.
//

import SwiftUI

struct StreaksView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var streakAchievements: AchievementGroup
    @State private var completionAchievements: AchievementGroup
    @State private var durationAchievements: AchievementGroup
    @State private var miscAchievements: AchievementGroup
    @State private var currentStreak: Int = 0
    @State private var workoutDoneToday: Bool = false
    @State private var latestDayCurrentStreak: Date = Date.now
    
    init(appState: AppState) {
        self.appState = appState
        streakAchievements = appState.getAchievements()[0]
        completionAchievements = appState.getAchievements()[1]
        durationAchievements = appState.getAchievements()[2]
        miscAchievements = appState.getAchievements()[3]
    }
    
    var body: some View {
        ScrollView {
            VStack {
                
                HStack(spacing: 20) {
                    ZStack {
                        VStack {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(workoutDoneToday ? .red : .gray)
                                Text("\(String(currentStreak))")
                                    .foregroundColor(.black)
                            }
                            .bold()
                            .font(.system(size: 36))
                            .padding()
                                Text("Current Streak")
                                    .font(.callout)
                                    .bold()
                            if appState.getCurrentStreak().length > 0 {
                                Text("\(latestDayCurrentStreak.formatDDMMMYYYY())")
                                    .font(.callout)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    
                    ZStack {
                        VStack {
                            HStack {
                                Image(systemName: "flame.fill")
                                Text("\(String(appState.getLongestStreak().length))")
                                    .foregroundColor(.black)
                            }
                            .foregroundColor(.orange)
                            .bold()
                            .font(.system(size: 36))
                            .padding()
                            
                            Text("Longest Streak")
                                .font(.callout)
                                .bold()
                            if appState.getLongestStreak().length > 0 {
                                Text("\(appState.getLongestStreak().startDate.formatDDMMMYYYY())")
                                    .font(.callout)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                }
                .padding()
                
                achievementsScrollView(appState: appState, title: "Streaks", achievements: streakAchievements)
                achievementsScrollView(appState: appState, title: "Completions", achievements: completionAchievements)
                achievementsScrollView(appState: appState, title: "Duration", achievements: durationAchievements)
                achievementsScrollView(appState: appState, title: "More Achievements", achievements: miscAchievements)
                
            }
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            appState.updateAchievements()
            loadAchievements()
            (currentStreak, latestDayCurrentStreak , workoutDoneToday) = appState.getCurrentStreak()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .bold()
                        Text("Achievements")
                            .font(.title)
                            .bold()
                            .foregroundStyle(.black)
                        Spacer()
                    }
                }
            }
        }
    }
    
    func loadAchievements() {
        streakAchievements = appState.getAchievements()[0]
        completionAchievements = appState.getAchievements()[1]
        durationAchievements = appState.getAchievements()[2]
        miscAchievements = appState.getAchievements()[3]
    }
}

struct achievementsScrollView: View {
    @ObservedObject var appState: AppState
    let title: LocalizedStringResource
    let achievements: AchievementGroup
    
    var totalAchievements: Int {
        achievements.achievements.count
    }
    
    var achievedCount: Int {
        achievements.achievements.filter { $0.achieved }.count
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title) (\(achievedCount)/\(totalAchievements))")
                .font(.title2)
                .bold()
            if achievements.type == .completions {
                if appState.getTotalCompletionsString() == 1 {
                    Text("\(appState.getTotalCompletionsString()) completed workout")
                } else {
                    Text("\(appState.getTotalCompletionsString()) completed workouts")
                }
            }
            if achievements.type == .duration {
                Text("\(appState.getTotalDurationString().asHoursMinutesSeconds()) worked out")
            }
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    ForEach(achievements.achievements) { achievement in
                        AchievementView(achievement: achievement)
                            .frame(width: 150, height: 150)
                            .background(achievement.achieved ? Color.gray.opacity(0.15) : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 20)
    }
}

struct AchievementView: View {
    let achievement: Achievement
    @State private var showingInfo = false

    var body: some View {
        ZStack {
            VStack {
                achievementCard
                Text(LocalizedStringKey(achievement.title))
                    .font(.title3)
                    .bold()
                    .padding(.bottom)
            }
            .overlay(
                Group {
                    if showingInfo {
                        infoPopup
                    }
                }
            )
        }
    }
    
    private var achievementCard: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .opacity(achievement.achieved ? 1 : 0)
                        .bold()
                    Spacer()
                    Button {
                        withAnimation { showingInfo.toggle() }
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .bold()
                    }
                }
                .padding(10)
                Spacer()
            }
            Image(systemName: achievement.achieved ? achievement.icon : "questionmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(achievement.achieved ? achievement.iconColor : .gray)
                .frame(width: 150, height: 60)
                .padding(.top, 15)
        }
    }
    
    private var infoPopup: some View {
        VStack {
            Button {
                withAnimation {
                    showingInfo = false
                }
            } label: {
                Text(LocalizedStringKey(achievement.caption))
                    .padding()
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.top, 5)
        }
        .transition(.scale.combined(with: .opacity))
        .zIndex(1)
    }
}


#Preview {
    NavigationView {
        StreaksView(appState: AppState())
    }
}
