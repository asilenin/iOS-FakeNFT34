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
    /// Сбрасывает кэш профиля. Вызывать, когда профиль изменён в обход сервиса
    /// (например, после покупки — POST /orders дописывает nfts на сервере).
    func invalidateCache() async
}
