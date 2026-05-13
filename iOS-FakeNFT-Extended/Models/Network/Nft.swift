import Foundation
/// NFT в каталоге или деталях.
///
/// Соответствует ответу `/api/v1/nft/{id}` mock-сервера Practicum.
/// Используется как value-объект в каталоге и деталях NFT.
/// Помечена `Sendable` для безопасной передачи между actor-сервисами
/// и `@MainActor` ViewModel.
struct Nft: Sendable, Decodable, Identifiable, Equatable {
    let id: String
    let createdAt: String
    let name: String
    let images: [URL]
    let rating: Int
    let description: String
    let price: Float
    let author: String
    let website: String
}
