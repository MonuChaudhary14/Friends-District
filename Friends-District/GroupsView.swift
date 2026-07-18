//
//  GroupsView.swift
//  Friends-District
//
//  Created by somil jain on 18/07/26.
//

import SwiftUI

struct GroupsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Grab the stored phone from ProfileSetupView
    @AppStorage("profilePhone") private var storedPhone = ""
    
    @State private var rooms: [Room] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    topBar
                    
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else if rooms.isEmpty {
                        Text("You haven't joined any groups yet.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else {
                        Text("\(rooms.count) groups")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(.white.opacity(0.45))
                            .padding(.top, 8)
                        
                        VStack(spacing: 0) {
                            ForEach(rooms) { room in
                                GroupRow(room: room)
                                
                                if room.id != rooms.last?.id {
                                    Divider()
                                        .overlay(Color.white.opacity(0.08))
                                        .padding(.leading, 84)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                        )
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await fetchRooms()
        }
    }
    
    private var topBar: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            
            Text("Groups")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Button {
                // create group action
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                    Text("Create")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .frame(height: 40)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color(red: 0.52, green: 0.22, blue: 0.95))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - API Call
    private func fetchRooms() async {
        guard var components = URLComponents(string: "https://district.monu14.me/api/v1/rooms") else { return }
        
        // URL encode the phone number (handles the + and spaces securely)
        components.queryItems = [
            URLQueryItem(name: "user_phone", value: storedPhone)
        ]
        
        guard let url = components.url else { return }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                await MainActor.run {
                    self.errorMessage = "Failed to load groups."
                    self.isLoading = false
                }
                return
            }
            
            let decodedRooms = try JSONDecoder().decode([Room].self, from: data)
            
            await MainActor.run {
                self.rooms = decodedRooms
                self.isLoading = false
            }
        } catch {
            print("Failed to fetch rooms: \(error)")
            await MainActor.run {
                self.errorMessage = "Network error occurred."
                self.isLoading = false
            }
        }
    }
}

// MARK: - Models

struct Room: Identifiable, Codable {
    let id: Int
    let name: String
    let created_at: String
    let updated_at: String
    
    // Helper to get the first letter of the room
    var initial: String {
        String(name.prefix(1)).uppercased()
    }
    
    // Helper to assign a deterministic color based on the ID so it's consistent
    var themeColor: Color {
        let colors: [Color] = [
            Color(red: 0.42, green: 0.20, blue: 0.83), // Purple
            Color(red: 0.05, green: 0.48, blue: 0.36), // Green
            Color(red: 0.75, green: 0.11, blue: 0.38), // Red/Pink
            Color(red: 0.14, green: 0.33, blue: 0.87)  // Blue
        ]
        return colors[id % colors.count]
    }
}

// MARK: - Subviews

struct GroupRow: View {
    let room: Room
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(room.themeColor)
                    .frame(width: 64, height: 64)
                
                Text(room.initial)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(room.name)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                
                // Fallback subtitle since API doesn't provide member count
                Text("Active recently")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white.opacity(0.25))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
    }
}

#Preview {
    GroupsView()
}
