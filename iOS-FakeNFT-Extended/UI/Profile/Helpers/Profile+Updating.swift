import Foundation

extension Profile {
    func updatingLikes(_ likes: [String]) -> Profile {
        Profile(
            id: id,
            name: name,
            description: description,
            website: website,
            avatar: avatar,
            nfts: nfts ?? [],
            likes: likes
        )
    }

    func updatingNFTs(_ nfts: [String]) -> Profile {
        Profile(
            id: id,
            name: name,
            description: description,
            website: website,
            avatar: avatar,
            nfts: nfts,
            likes: likes ?? []
        )
    }
}
