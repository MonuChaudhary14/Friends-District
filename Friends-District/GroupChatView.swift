//
//  GroupChatView.swift
//  Friends-District
//
//  Created by somil jain on 18/07/26.
//

import SwiftUI
internal import Combine

// MARK: - Models
struct RoomMessage: Codable, Identifiable {
    let id: Int
    let content: String
    let created_at: String
    let external_event_id: String?
    let external_event_type: String?
    let room_id: Int
    let sender_id: Int
}

// MARK: - View Model
@MainActor
class GroupChatViewModel: ObservableObject {
    @Published var messages: [RoomMessage] = []
    @Published var isLoading = true
    @Published var errorMessage: String? = nil

    func fetchMessages(roomId: Int) async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://district.monu14.me/api/v1/rooms/\(roomId)/messages") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Failed to load messages."
                isLoading = false
                return
            }
            
            let decodedMessages = try JSONDecoder().decode([RoomMessage].self, from: data)
            self.messages = decodedMessages
        } catch {
            print("Failed to decode messages: \(error)")
            self.errorMessage = "Something went wrong."
        }
        
        isLoading = false
    }
}

// MARK: - View
struct GroupChatView: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = GroupChatViewModel()
    @State private var messageText = ""
    @State private var showGroupInfo = false

    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar

            Divider()
                .overlay(Color.white.opacity(0.1))

            ScrollView {
                VStack(spacing: 24) {
                    Text("Group Space created · plan your outing here")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .padding(.top, 20)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.top, 40)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundStyle(.red.opacity(0.8))
                            .padding(.top, 40)
                    } else {
                        // Display fetched messages
                        ForEach(viewModel.messages) { message in
                            let senderDetails = getSenderDetails(for: message.sender_id)
                            
                            userMessageRow(
                                initials: senderDetails.initials,
                                name: senderDetails.name,
                                avatarColor: senderDetails.color,
                                content: Text(message.content)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }

            bottomInputBar
        }
        .background(Color(red: 0.08, green: 0.08, blue: 0.09).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showGroupInfo) {
            GroupInfoView(room: room, memberCount: 4)
        }
        .task {
            // Fetch messages when the view appears
            await viewModel.fetchMessages(roomId: room.id)
        }
    }

    private var topNavigationBar: some View {
        HStack(spacing: 14) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundStyle(.white.opacity(0.8))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(room.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Text("4 members · Group Space")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
                .padding(8)
                .background(Circle().fill(Color.white.opacity(0.05)))

            Button {
                showGroupInfo = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.05)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func userMessageRow(initials: String, name: String, avatarColor: Color, content: some View) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.leading, 50)

            HStack(alignment: .bottom, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(avatarColor)
                        .frame(width: 30, height: 30)

                    Text(initials)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }

                content
                Spacer()
            }
        }
    }
    
    // MARK: - Helpers
    /// Deterministically assigns a color and a generic name based on the `sender_id`.
    private func getSenderDetails(for senderId: Int) -> (name: String, initials: String, color: Color) {
        let colors: [Color] = [
            Color(red: 0.42, green: 0.20, blue: 0.83), // Purple
            Color(red: 0.60, green: 0.10, blue: 0.40), // Maroon
            Color(red: 0.20, green: 0.50, blue: 0.80), // Blue
            Color(red: 0.10, green: 0.60, blue: 0.30), // Green
            Color(red: 0.80, green: 0.40, blue: 0.10)  // Orange
        ]
        
        let color = colors[abs(senderId) % colors.count]
        return ("User \(senderId)", "U\(senderId)", color)
    }

    private var bottomInputBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button { } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                    Text("Ask @Planner")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(red: 0.65, green: 0.40, blue: 1.0))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(red: 0.20, green: 0.10, blue: 0.35))
                .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                TextField("Message or @Planner...", text: $messageText)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())

                Button { } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 48, height: 48)
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(Color(red: 0.08, green: 0.08, blue: 0.09))
    }
}

#Preview {
    GroupsView()
}
