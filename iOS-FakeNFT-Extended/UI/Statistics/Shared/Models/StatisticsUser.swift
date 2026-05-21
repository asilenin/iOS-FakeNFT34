//
//  StatisticsUser.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 12.05.2026.
//

import Foundation

/// Пользователь в таблице рейтинга на экране «Статистика».
struct StatisticsUser: Sendable, Hashable, Identifiable {
    /// Уникальный идентификатор пользователя.
    let id: String
    /// Отображаемое имя.
    let name: String
    /// Прямая ссылка на аватар; `nil` — плейсхолдер в UI.
    let avatarURL: URL?
    /// Количество NFT у пользователя (для сортировки и отображения).
    let nftsCount: Int
    /// Условный рейтинг для сортировки «по рейтингу».
    let rating: Int
}
