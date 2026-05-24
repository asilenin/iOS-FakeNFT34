//
//  EditProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 14.05.2026.
//

import SwiftUI

struct EditProfileView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var viewModel: EditProfileViewModel
    @State private var isShowingExitAlert = false
    @State private var isShowingPhotoDialog = false
    @State private var isShowingPhotoLinkAlert = false
    @State private var avatarDraft = ""

    // MARK: - Properties

    private let onSaved: (Profile) -> Void

    // MARK: - Initializers

    init(
        profile: Profile,
        profileService: ProfileServiceProtocol,
        onSaved: @escaping (Profile) -> Void
    ) {
        _viewModel = State(
            initialValue: EditProfileViewModel(
                profile: profile,
                profileService: profileService
            )
        )
        self.onSaved = onSaved
    }

    // MARK: - Body

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                backButton
                    .padding(.top, 20)

                avatarEditor
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)

                VStack(alignment: .leading, spacing: 24) {
                    editField(
                        title: String(localized: "Profile.Edit.name"),
                        text: $viewModel.name
                    )

                    editDescription(text: $viewModel.description)

                    editField(
                        title: String(localized: "Profile.Edit.website"),
                        text: $viewModel.website,
                        keyboardType: .URL
                    )

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.regular13)
                            .foregroundStyle(Color.ypRedUniversal)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom) {
            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .background(Color.ypWhite)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(
            String(localized: "Profile.Edit.photo.title"),
            isPresented: $isShowingPhotoDialog,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Profile.Edit.photo.change")) {
                avatarDraft = viewModel.avatar
                isShowingPhotoLinkAlert = true
            }

            Button(String(localized: "Profile.Edit.photo.delete"), role: .destructive) {
                viewModel.deleteAvatar()
            }

            Button(String(localized: "Error.cancel"), role: .cancel) {}
        }
        .alert(
            String(localized: "Profile.Edit.photo.linkTitle"),
            isPresented: $isShowingPhotoLinkAlert
        ) {
            TextField(String(localized: "Profile.Edit.photo.linkPlaceholder"), text: $avatarDraft)

            Button(String(localized: "Error.cancel"), role: .cancel) {}

            Button(String(localized: "Profile.Edit.save")) {
                viewModel.updateAvatar(avatarDraft)
            }
        }
        .alert(
            String(localized: "Profile.Edit.exit.title"),
            isPresented: $isShowingExitAlert
        ) {
            Button(String(localized: "Profile.Edit.exit.stay"), role: .cancel) {}

            Button(String(localized: "Profile.Edit.exit.leave")) {
                dismiss()
            }
        }
    }

    // MARK: - Content

    private var backButton: some View {
        Button {
            isShowingExitAlert = true
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color.ypBlack)
                .frame(width: 24, height: 24, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving)
    }

    private var avatarEditor: some View {
        Button {
            isShowingPhotoDialog = true
        } label: {
            ZStack(alignment: .bottomTrailing) {
                ProfileAvatarView(avatar: viewModel.avatar)

                ZStack {
                    Circle()
                        .fill(Color.ypGrayLight)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.ypBlack)
                }
                .frame(width: 22.56, height: 22.56)
                .offset(x: 4, y: 2)
            }
            .frame(width: 70, height: 70)
        }
        .buttonStyle(.plain)
    }

    private func editField(
        title: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.bold22)
                .foregroundStyle(Color.ypBlack)

            TextField(title, text: text)
                .font(.regular17)
                .textInputAutocapitalization(.never)
                .keyboardType(keyboardType)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Color.ypGrayLight)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func editDescription(text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "Profile.Edit.description"))
                .font(.bold22)
                .foregroundStyle(Color.ypBlack)

            TextEditor(text: text)
                .font(.regular17)
                .frame(minHeight: 164)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.ypGrayLight)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var saveButton: some View {
        Button {
            Task {
                await saveProfile()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.ypBlack)

                if viewModel.isSaving {
                    LoadingSpinner(size: .medium, tint: .ypWhite)
                } else {
                    Text(String(localized: "Profile.Edit.save"))
                        .font(.bold17)
                        .foregroundStyle(Color.ypWhite)
                }
            }
            .frame(height: 60)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving)
    }

    // MARK: - Actions

    private func saveProfile() async {
        guard let updatedProfile = await viewModel.saveProfile() else {
            return
        }

        onSaved(updatedProfile)
        dismiss()
    }
}

#Preview {
    EditProfileView(
        profile: Profile(
            id: "1",
            name: "Joaquin Phoenix",
            description: "Дизайнер из Казани",
            website: "https://example.com",
            avatar: "https://example.com/avatar.png",
            nfts: [],
            likes: []
        ),
        profileService: ProfileService(networkClient: DefaultNetworkClient()),
        onSaved: { _ in }
    )
}
