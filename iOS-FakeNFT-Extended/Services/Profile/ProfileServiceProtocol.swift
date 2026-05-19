//
//  ProfileServiceProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 07.05.2026.
//

import Foundation

protocol ProfileServiceProtocol: Sendable {
    func loadProfile() async throws -> Profile
    func updateProfile(_ profile: Profile) async throws -> Profile
}
