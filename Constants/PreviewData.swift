import Foundation

// swiftlint:disable all
// swiftformat:disable all
struct PreviewData {
    static let artists = [
        Artist(id: "1", name: "The Blue Suns", sortName: "Blue Suns, The"),
        Artist(id: "2", name: "Q", sortName: "Q"),
        Artist(id: "3", name: "Mellifluous Quartet", sortName: "Mellifluous Quartet"),
        Artist(id: "4", name: "Anna Jameson", sortName: "Jameson, Anna"),
        Artist(id: "5", name: "Ron", sortName: "Ron"),
        Artist(id: "6", name: "Ethereal Dreams", sortName: "Dreams, Ethereal"),
        Artist(id: "7", name: "Bella and the Whales", sortName: "Bella and the Whales"),
        Artist(id: "8", name: "MJ", sortName: "MJ"),
        Artist(id: "9", name: "Titanium Tigers", sortName: "Tigers, Titanium"),
        Artist(id: "10", name: "Oliver Owens Orchestra", sortName: "Orchestra, Oliver Owens"),
        Artist(id: "11", name: "Al", sortName: "Al"),
        Artist(id: "12", name: "Flaming Feathers", sortName: "Feathers, Flaming"),
        Artist(id: "13", name: "Sarah Simmons & The Silent Seven", sortName: "Sarah Simmons & The Silent Seven"),
        Artist(id: "14", name: "Ix", sortName: "Ix"),
        Artist(id: "15", name: "Echoing Elements", sortName: "Elements, Echoing"),
        Artist(id: "16", name: "Xylo", sortName: "Xylo"),
        Artist(id: "17", name: "Percussion Pioneers", sortName: "Pioneers, Percussion"),
        Artist(id: "18", name: "Liam's Lyricists", sortName: "Lyricists, Liam's"),
        Artist(id: "19", name: "Oz", sortName: "Oz"),
        Artist(id: "20", name: "Jubilant Jammers", sortName: "Jammers, Jubilant")
    ]

    static let albums = [
        Album(
            id: "1",
            name: "Nice album name",
            artistName: "Album artist",
            isFavorite: true
        ),
        Album(
            id: "2",
            name: "Album with very long name that one gets tired reading it",
            artistName: "Unamusing artist",
            isFavorite: false
        ),
        Album(
            id: "3",
            name: "Very long album name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
            artistName: "Very long artist name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
            isFavorite: true
        ),
    ]

    static let songs = [
        // Songs for album 1
        Song(
            id: "1",
            index: 1,
            name: "Song name 1",
            parentId: "1",
            isFavorite: false,
            runtime: 123,
            albumDisc: 1,
            fileExtension: "flac"
        ),
        Song(
            id: "2",
            index: 1,
            name: "Song name 2 but this one has very long name",
            parentId: "1",
            isFavorite: false,
            runtime: 123,
            albumDisc: 2,
            fileExtension: "flac"
        ),
        // Songs for album 2
        Song(
            id: "3",
            index: 1,
            name: "Song name 3",
            parentId: "2",
            isFavorite: false,
            runtime: 123,
            fileExtension: "flac"
        ),
        Song(
            id: "4",
            index: 2,
            name: "Song name 4 but this one has very long name",
            parentId: "2",
            isFavorite: false,
            runtime: 123,
            fileExtension: "flac"
        ),
        Song(
            id: "5",
            index: 1,
            name: "Very long song name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
            parentId: "3",
            isFavorite: false,
            runtime: 123,
            fileExtension: "flac"
        ),
    ]
}
// swiftlint:enable all
// swiftformat:enable all
