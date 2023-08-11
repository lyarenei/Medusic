import Foundation

// swiftlint:disable all
// swiftformat:disable all
struct PreviewData {
    private static let formatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        return df
    }()

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

    static let albums: [Album] = [
        Album(id: "101", name: "Sunrise Waves", artistId: "1", artistName: "The Blue Suns", isFavorite: true, createdAt: formatter.date(from: "2022/01/05")!),
        Album(id: "102", name: "Moonlit Melodies", artistId: "1", artistName: "The Blue Suns", isFavorite: false, createdAt: formatter.date(from: "2022/05/10")!),
        Album(id: "103", name: "Quantum Notes", artistId: "2", artistName: "Q", isFavorite: true, createdAt: formatter.date(from: "2023/02/15")!),
        Album(id: "104", name: "Quiet Quarrels", artistId: "2", artistName: "Q", isFavorite: false, createdAt: formatter.date(from: "2021/07/12")!),
        Album(id: "105", name: "Harmonic Hues", artistId: "3", artistName: "Mellifluous Quartet", isFavorite: true, createdAt: formatter.date(from: "2022/03/25")!),
        Album(id: "106", name: "Echoed Euphoria", artistId: "4", artistName: "Anna Jameson", isFavorite: false, createdAt: formatter.date(from: "2020/08/10")!),
        Album(id: "107", name: "Melodies of Ron", artistId: "5", artistName: "Ron", isFavorite: true, createdAt: formatter.date(from: "2023/01/11")!),
        Album(id: "108", name: "Dreamy Delights", artistId: "6", artistName: "Ethereal Dreams", isFavorite: false, createdAt: formatter.date(from: "2021/12/05")!),
        Album(id: "109", name: "Oceanic Overtones", artistId: "7", artistName: "Bella and the Whales", isFavorite: true, createdAt: formatter.date(from: "2020/04/21")!),
        Album(id: "110", name: "Suns' Surprise", artistId: "1", artistName: "The Blue Suns", isFavorite: false, createdAt: formatter.date(from: "2019/11/17")!),
        Album(id: "111", name: "Spectral Sonnets", artistId: "3", artistName: "Mellifluous Quartet", isFavorite: true, createdAt: formatter.date(from: "2022/06/19")!),
        Album(id: "112", name: "Jazzy Jams of Anna", artistId: "4", artistName: "Anna Jameson", isFavorite: false, createdAt: formatter.date(from: "2021/09/30")!),
        Album(id: "113", name: "Ron's Rhapsodies", artistId: "5", artistName: "Ron", isFavorite: true, createdAt: formatter.date(from: "2022/05/01")!),
        Album(id: "114", name: "Dimensions of Dreams", artistId: "6", artistName: "Ethereal Dreams", isFavorite: false, createdAt: formatter.date(from: "2019/10/05")!),
        Album(id: "115", name: "Waltz of the Whales", artistId: "7", artistName: "Bella and the Whales", isFavorite: true, createdAt: formatter.date(from: "2023/03/08")!),
        Album(id: "116", name: "Harbor Hymns", artistId: "1", artistName: "The Blue Suns", isFavorite: false, createdAt: formatter.date(from: "2022/11/14")!),
        Album(id: "117", name: "Quantum Quintessence", artistId: "2", artistName: "Q", isFavorite: true, createdAt: formatter.date(from: "2020/07/10")!),
        Album(id: "118", name: "Anna's Acoustics", artistId: "4", artistName: "Anna Jameson", isFavorite: false, createdAt: formatter.date(from: "2021/04/15")!),
        Album(id: "119", name: "Rhythms of Ron", artistId: "5", artistName: "Ron", isFavorite: true, createdAt: formatter.date(from: "2021/02/20")!),
        Album(id: "120", name: "Dances of the Deep", artistId: "7", artistName: "Bella and the Whales", isFavorite: false, createdAt: formatter.date(from: "2019/06/24")!)
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
