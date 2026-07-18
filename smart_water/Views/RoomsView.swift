//
//  RoomsView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct RoomsView: View {
    @State private var isShowingAddRoom = false
    @StateObject private var viewModel = RoomsViewModel(
        api: SmartWaterAPI(
            baseURL: URL(string: "http://192.168.68.64:8000")!
        )
    )
    
    let columns = [
        GridItem(.flexible(), spacing: 32),
        GridItem(.flexible(), spacing: 32)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 0) {
                ScrollView {
                    if viewModel.isLoading && viewModel.rooms.isEmpty {
                        ProgressView("Loading rooms...")
                    }
                    else {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(viewModel.rooms) { room in
                                NavigationLink() {
                                    RoomView(room: room)
                                } label: {
                                    RoomCardView(room: room)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 42)
                        Spacer()
                    }
                }
                .sheet(isPresented: $isShowingAddRoom) {
                    AddRoomView { name in
                        try await viewModel.createRoom(name: name)
                    }
                }
                .task {
                    await viewModel.loadRooms()
                }
                .refreshable {
                    await viewModel.loadRooms()
                }
            }
            .navigationTitle("Rooms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddRoom = true
                    } label: {
                        Label("Add Room", systemImage: "plus")
                    }
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 32)
            .background(Color.white)
        }
    }
}

#Preview {
    RoomsView()
}
