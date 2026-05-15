//
//  EditProfileViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 14.05.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class EditProfileViewModel {

    // MARK: - State

    var name: String
    var description: String
    var website: String
    var avatar: String
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    var hasChanges: Bool {
        name != (profile.name ?? "") ||
        description != (profile.description ?? "") ||
        website != (profile.website ?? "") ||
        avatar != (profile.avatar ?? "")
    }

    // MARK: - Dependencies

    private let profile: Profile
    private let profileService: ProfileServiceProtocol

    // MARK: - Initializers

    init(profile: Profile, profileService: ProfileServiceProtocol) {
        self.profile = profile
        self.profileService = profileService
        name = profile.name ?? ""
        description = profile.description ?? ""
        website = profile.website ?? ""
        avatar = profile.avatar ?? ""
    }

    // MARK: - Public Methods

    func saveProfile() async -> Profile? {
        guard !isSaving else { return nil }
        guard validateFields() else { return nil }

        isSaving = true
        errorMessage = nil

        do {
            let updatedProfile = try await profileService.updateProfile(makeUpdatedProfile())
            isSaving = false
            return updatedProfile
        } catch {
            isSaving = false
            errorMessage = String(
                format: String(localized: "Profile.Edit.error.save"),
                error.localizedDescription
            )
            return nil
        }
    }

    func updateAvatar(_ avatar: String) {
        self.avatar = avatar.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func deleteAvatar() {
        avatar = ""
    }

    // MARK: - Private Methods

    private func validateFields() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWebsite = website.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = String(localized: "Profile.Edit.error.emptyName")
            return false
        }

        guard !trimmedWebsite.isEmpty else {
            errorMessage = String(localized: "Profile.Edit.error.emptyWebsite")
            return false
        }

        guard let url = URL(string: trimmedWebsite),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme),
              url.host() != nil else {
            errorMessage = String(localized: "Profile.Edit.error.invalidWebsite")
            return false
        }

        errorMessage = nil
        return true
    }

    private func makeUpdatedProfile() -> Profile {
        Profile(
            id: profile.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            website: website.trimmingCharacters(in: .whitespacesAndNewlines),
            avatar: avatar.trimmingCharacters(in: .whitespacesAndNewlines),
            nfts: profile.nfts ?? [],
            likes: profile.likes ?? []
        )
    }
}
