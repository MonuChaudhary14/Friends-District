//
//  FriendListView.swift
//  Friends-District
//
//  Created by somil jain on 18/07/26.
//

import SwiftUI

struct FriendListView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let friends: [FriendItem] = [
        .init(name: "Arjun Sharma", subtitle: "3 mutual friends", initials: "A", color: Color(red: 0.42, green: 0.20, blue: 0.83)),
        .init(name: "Priya Mehta", subtitle: "1 mutual friend", initials: "P", color: Color(red: 0.74, green: 0.11, blue: 0.34)),
        .init(name: "Rahul Verma", subtitle: "5 mutual friends", initials: "R", color: Color(red: 0.14, green: 0.33, blue: 0.87)),
        .init(name: "Sneha Kapoor", subtitle: "2 mutual friends", initials: "S", color: Color(red: 0.05, green: 0.50, blue: 0.36)),
        .init(name: "Vikram Nair", subtitle: "On District", initials: "V", color: Color(red: 0.72, green: 0.33, blue: 0.06))
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    topBar
                    
                    Text("Friend List")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.top, 6)
                    
                    VStack(spacing: 0) {
                        ForEach(friends) { friend in
                            FriendRow(friend: friend)
                            
                            if friend.id != friends.last?.id {
                                Divider()
                                    .overlay(Color.white.opacity(0.08))
                                    .padding(.leading, 72)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
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
            
            Text("Friend List")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
}

struct FriendItem: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let initials: String
    let color: Color
}

struct FriendRow: View {
    let friend: FriendItem
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(friend.color)
                    .frame(width: 54, height: 54)
                
                Text(friend.initials)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                
                Text(friend.subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            Button {
                // open friend details or chat
            } label: {
                Text("View")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 36)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.52, green: 0.22, blue: 0.95))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}

#Preview {
    FriendListView()
}
