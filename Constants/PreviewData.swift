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
        Artist(id: "4", name: "Anna Jameson", sortName: "Anna Jameson"),
        Artist(id: "5", name: "Ron", sortName: "Ron"),
        Artist(id: "6", name: "Ethereal Dreams", sortName: "Ethereal Dreams"),
        Artist(id: "7", name: "Bella and the Whales", sortName: "Bella and the Whales"),
        Artist(id: "8", name: "MJ", sortName: "MJ"),
        Artist(id: "9", name: "Titanium Tigers", sortName: "Titanium Tigers"),
        Artist(id: "10", name: "Oliver Owens Orchestra", sortName: "Oliver Owens Orchestra"),
        Artist(id: "11", name: "Al", sortName: "Al"),
        Artist(id: "12", name: "Flaming Feathers", sortName: "Flaming Feathers"),
        Artist(id: "13", name: "Sarah Simmons & The Silent Seven", sortName: "Sarah Simmons & The Silent Seven"),
        Artist(id: "14", name: "Ix", sortName: "Ix"),
        Artist(id: "15", name: "Echoing Elements", sortName: "Echoing Elements"),
        Artist(id: "16", name: "Xylo", sortName: "Xylo"),
        Artist(id: "17", name: "Percussion Pioneers", sortName: "Percussion Pioneers"),
        Artist(id: "18", name: "Liam's Lyricists", sortName: "Liam's Lyricists"),
        Artist(id: "19", name: "Oz", sortName: "Oz"),
        Artist(id: "20", name: "Jubilant Jammers", sortName: "Jubilant Jammers")
    ]

    static let albums: [Album] = [
        Album(id: "101", name: "Sunrise Waves", sortName: "Sunrise Waves", artistId: "1", isFavorite: true, createdAt: formatter.date(from: "2022/01/05")!),
        Album(id: "102", name: "Moonlit Melodies", sortName: "Moonlit Melodies", artistId: "1", isFavorite: false, createdAt: formatter.date(from: "2022/05/10")!),
        Album(id: "103", name: "Quantum Notes", sortName: "Quantum Notes", artistId: "2", isFavorite: true, createdAt: formatter.date(from: "2023/02/15")!),
        Album(id: "104", name: "Quiet Quarrels", sortName: "Quiet Quarrels", artistId: "2", isFavorite: false, createdAt: formatter.date(from: "2021/07/12")!),
        Album(id: "105", name: "Harmonic Hues", sortName: "Harmonic Hues", artistId: "3", isFavorite: true, createdAt: formatter.date(from: "2022/03/25")!),
        Album(id: "106", name: "An Echoed Euphoria", sortName: "Echoed Euphoria, An", artistId: "4", isFavorite: false, createdAt: formatter.date(from: "2020/08/10")!),
        Album(id: "107", name: "Melodies of Ron", sortName: "Melodies of Ron", artistId: "5", isFavorite: true, createdAt: formatter.date(from: "2023/01/11")!),
        Album(id: "108", name: "Dreamy Delights", sortName: "Dreamy Delights", artistId: "6", isFavorite: false, createdAt: formatter.date(from: "2021/12/05")!),
        Album(id: "109", name: "Oceanic Overtones", sortName: "Oceanic Overtones", artistId: "7", isFavorite: true, createdAt: formatter.date(from: "2020/04/21")!),
        Album(id: "110", name: "Suns' Surprise", sortName: "Suns' Surprise", artistId: "1", isFavorite: false, createdAt: formatter.date(from: "2019/11/17")!),
        Album(id: "111", name: "Spectral Sonnets", sortName: "Spectral Sonnets", artistId: "3", isFavorite: true, createdAt: formatter.date(from: "2022/06/19")!),
        Album(id: "112", name: "Jazzy Jams of Anna", sortName: "Jazzy Jams of Anna", artistId: "4", isFavorite: false, createdAt: formatter.date(from: "2021/09/30")!),
        Album(id: "113", name: "Ron's Rhapsodies", sortName: "Ron's Rhapsodies", artistId: "5", isFavorite: true, createdAt: formatter.date(from: "2022/05/01")!),
        Album(id: "114", name: "Dimensions of Dreams", sortName: "Dimensions of Dreams", artistId: "6", isFavorite: false, createdAt: formatter.date(from: "2019/10/05")!),
        Album(id: "115", name: "Waltz of the Whales", sortName: "Waltz of the Whales", artistId: "7", isFavorite: true, createdAt: formatter.date(from: "2023/03/08")!),
        Album(id: "116", name: "Solar Flares", sortName: "Solar Flares", artistId: "1", isFavorite: false, createdAt: formatter.date(from: "2022/07/15")!),
        Album(id: "117", name: "Quartet Quintessence", sortName: "Quartet Quintessence", artistId: "3", isFavorite: true, createdAt: formatter.date(from: "2021/06/25")!),
        Album(id: "118", name: "Anna's Anthems", sortName: "Anna's Anthems", artistId: "4", isFavorite: true, createdAt: formatter.date(from: "2020/09/14")!),
        Album(id: "119", name: "The Rhythms of Ron", sortName: "Rhythms of Ron, The", artistId: "5", isFavorite: true, createdAt: formatter.date(from: "2021/04/11")!),
        Album(id: "120", name: "Dreamscape Dynamics", sortName: "Dreamscape Dynamics", artistId: "6", isFavorite: false, createdAt: formatter.date(from: "2022/11/22")!)
    ]

    static let songs: [Song] = [
        // Songs for Album with ID 101
        Song(id: "1001", name: "Dawn Rising", isFavorite: true, sortName: "Dawn Rising", index: 1, albumId: "101", artistNames: ["The Blue Suns"], size: 4800000, runtime: 192, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1002", name: "Light's Embrace", isFavorite: false, sortName: "Light's Embrace", index: 2, albumId: "101", artistNames: ["The Blue Suns"], size: 5000000, runtime: 200, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1003", name: "Whispers in the Wind", isFavorite: false, sortName: "Whispers in the Wind", index: 3, albumId: "101", artistNames: ["The Blue Suns"], size: 4950000, runtime: 198, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1004", name: "Celestial Dreams", isFavorite: false, sortName: "Celestial Dreams", index: 4, albumId: "101", artistNames: ["The Blue Suns"], size: 5030000, runtime: 202, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1005", name: "Sonic Waves", isFavorite: false, sortName: "Sonic Waves", index: 5, albumId: "101", artistNames: ["The Blue Suns"], size: 4880000, runtime: 195, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1006", name: "Twilight Tones", isFavorite: true, sortName: "Twilight Tones", index: 6, albumId: "101", artistNames: ["The Blue Suns"], size: 5100000, runtime: 205, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1007", name: "Vivid Visions", isFavorite: false, sortName: "Vivid Visions", index: 7, albumId: "101", artistNames: ["The Blue Suns"], size: 4920000, runtime: 197, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1008", name: "Harmonic Hues", isFavorite: false, sortName: "Harmonic Hues", index: 8, albumId: "101", artistNames: ["The Blue Suns"], size: 5050000, runtime: 203, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1009", name: "Rhythmic Rapture", isFavorite: false, sortName: "Rhythmic Rapture", index: 9, albumId: "101", artistNames: ["The Blue Suns"], size: 4990000, runtime: 200, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1010", name: "Ethereal Echoes", isFavorite: true, sortName: "Ethereal Echoes", index: 10, albumId: "101", artistNames: ["The Blue Suns"], size: 4800000, runtime: 192, albumDisc: 1, fileExtension: "mp3"),

        // Songs for Album with ID 102
        Song(id: "1101", name: "Moon's Caress", isFavorite: true, sortName: "Moon's Caress", index: 1, albumId: "102", artistNames: ["The Blue Suns"], size: 4900000, runtime: 196, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1102", name: "Starlit Sighs", isFavorite: false, sortName: "Starlit Sighs", index: 2, albumId: "102", artistNames: ["The Blue Suns"], size: 5050000, runtime: 202, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1103", name: "Galactic Groove", isFavorite: false, sortName: "Galactic Groove", index: 3, albumId: "102", artistNames: ["The Blue Suns"], size: 5000000, runtime: 200, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1104", name: "Astro Atmosphere", isFavorite: true, sortName: "Astro Atmosphere", index: 4, albumId: "102", artistNames: ["The Blue Suns"], size: 4900000, runtime: 196, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1105", name: "Eclipse Emotions", isFavorite: false, sortName: "Eclipse Emotions", index: 5, albumId: "102", artistNames: ["The Blue Suns"], size: 5100000, runtime: 204, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1106", name: "Stellar Strokes", isFavorite: false, sortName: "Stellar Strokes", index: 6, albumId: "102", artistNames: ["The Blue Suns"], size: 4980000, runtime: 199, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1107", name: "Comet's Cry", isFavorite: true, sortName: "Comet's Cry", index: 7, albumId: "102", artistNames: ["The Blue Suns"], size: 5050000, runtime: 203, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1108", name: "Orbit Odyssey", isFavorite: false, sortName: "Orbit Odyssey", index: 8, albumId: "102", artistNames: ["The Blue Suns"], size: 4950000, runtime: 198, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1109", name: "Nebula Nights", isFavorite: false, sortName: "Nebula Nights", index: 9, albumId: "102", artistNames: ["The Blue Suns"], size: 4850000, runtime: 194, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1110", name: "Meteor Melodies", isFavorite: true, sortName: "Meteor Melodies", index: 10, albumId: "102", artistNames: ["The Blue Suns"], size: 5000000, runtime: 200, albumDisc: 1, fileExtension: "mp3"),

        // Songs for Album with ID 103
        Song(id: "1201", name: "Quantum Quivers", isFavorite: true, sortName: "Quantum Quivers", index: 1, albumId: "103", artistNames: ["Q"], size: 4750000, runtime: 190, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1202", name: "Energetic Entropy", isFavorite: false, sortName: "Energetic Entropy", index: 2, albumId: "103", artistNames: ["Q"], size: 5100000, runtime: 204, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1203", name: "Vortex Vibrations", isFavorite: false, sortName: "Vortex Vibrations", index: 3, albumId: "103", artistNames: ["Q"], size: 4870000, runtime: 195, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1204", name: "Particle Pulse", isFavorite: true, sortName: "Particle Pulse", index: 4, albumId: "103", artistNames: ["Q"], size: 4800000, runtime: 192, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1205", name: "Waveform Wonders", isFavorite: false, sortName: "Waveform Wonders", index: 5, albumId: "103", artistNames: ["Q"], size: 5000000, runtime: 200, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1206", name: "Atomic Aria", isFavorite: false, sortName: "Atomic Aria", index: 6, albumId: "103", artistNames: ["Q"], size: 4850000, runtime: 194, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1207", name: "Molecular Muse", isFavorite: false, sortName: "Molecular Muse", index: 7, albumId: "103", artistNames: ["Q"], size: 5100000, runtime: 204, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1208", name: "Fusion Frequencies", isFavorite: true, sortName: "Fusion Frequencies", index: 8, albumId: "103", artistNames: ["Q"], size: 4900000, runtime: 196, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1209", name: "Elemental Echo", isFavorite: false, sortName: "Elemental Echo", index: 9, albumId: "103", artistNames: ["Q"], size: 5050000, runtime: 203, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1210", name: "Radiation Rhapsody", isFavorite: false, sortName: "Radiation Rhapsody", index: 10, albumId: "103", artistNames: ["Q"], size: 5000000, runtime: 200, albumDisc: 1, fileExtension: "mp3"),

        // Songs for Album with ID 104
        Song(id: "1301", name: "Anna's Arrival", isFavorite: true, sortName: "Anna's Arrival", index: 1, albumId: "104", artistNames: ["Anna Jameson"], size: 4820000, runtime: 193, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1302", name: "Serene Sounds", isFavorite: false, sortName: "Serene Sounds", index: 2, albumId: "104", artistNames: ["Anna Jameson"], size: 4980000, runtime: 199, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1303", name: "Melodic Mornings", isFavorite: false, sortName: "Melodic Mornings", index: 3, albumId: "104", artistNames: ["Anna Jameson"], size: 5030000, runtime: 202, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1304", name: "Harmonious Heart", isFavorite: false, sortName: "Harmonious Heart", index: 4, albumId: "104", artistNames: ["Anna Jameson"], size: 4900000, runtime: 196, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1305", name: "Vocal Visions", isFavorite: true, sortName: "Vocal Visions", index: 5, albumId: "104", artistNames: ["Anna Jameson"], size: 5120000, runtime: 205, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1306", name: "Symphonic Sunset", isFavorite: false, sortName: "Symphonic Sunset", index: 6, albumId: "104", artistNames: ["Anna Jameson"], size: 4850000, runtime: 194, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1307", name: "Lyrical Landscapes", isFavorite: true, sortName: "Lyrical Landscapes", index: 7, albumId: "104", artistNames: ["Anna Jameson"], size: 5000000, runtime: 200, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1308", name: "Tonal Tranquility", isFavorite: false, sortName: "Tonal Tranquility", index: 8, albumId: "104", artistNames: ["Anna Jameson"], size: 5100000, runtime: 204, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1309", name: "Aural Aura", isFavorite: true, sortName: "Aural Aura", index: 9, albumId: "104", artistNames: ["Anna Jameson"], size: 4820000, runtime: 193, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1310", name: "Choral Charm", isFavorite: false, sortName: "Choral Charm", index: 10, albumId: "104", artistNames: ["Anna Jameson"], size: 4950000, runtime: 198, albumDisc: 1, fileExtension: "mp3"),

        // Songs for Album with ID 105
        Song(id: "1401", name: "Chasing Clouds", isFavorite: true, sortName: "Chasing Clouds", index: 1, albumId: "105", artistNames: ["The Harmonics"], size: 4800000, runtime: 192, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1402", name: "Breeze Bliss", isFavorite: false, sortName: "Breeze Bliss", index: 2, albumId: "105", artistNames: ["The Harmonics"], size: 5080000, runtime: 203, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1403", name: "Winds Whisper", isFavorite: true, sortName: "Winds Whisper", index: 3, albumId: "105", artistNames: ["The Harmonics"], size: 4840000, runtime: 194, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1404", name: "Elevated Echoes", isFavorite: false, sortName: "Elevated Echoes", index: 4, albumId: "105", artistNames: ["The Harmonics"], size: 5100000, runtime: 204, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1405", name: "Skyward Sounds", isFavorite: true, sortName: "Skyward Sounds", index: 5, albumId: "105", artistNames: ["The Harmonics"], size: 4800000, runtime: 192, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1406", name: "Celestial Chorus", isFavorite: false, sortName: "Celestial Chorus", index: 6, albumId: "105", artistNames: ["The Harmonics"], size: 5080000, runtime: 203, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1407", name: "Floating Frequencies", isFavorite: true, sortName: "Floating Frequencies", index: 7, albumId: "105", artistNames: ["The Harmonics"], size: 4840000, runtime: 194, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1408", name: "Airy Anthems", isFavorite: false, sortName: "Airy Anthems", index: 8, albumId: "105", artistNames: ["The Harmonics"], size: 5100000, runtime: 204, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1409", name: "Heavenly Harmonies", isFavorite: true, sortName: "Heavenly Harmonies", index: 9, albumId: "105", artistNames: ["The Harmonics"], size: 4800000, runtime: 192, albumDisc: 1, fileExtension: "mp3"),
        Song(id: "1410", name: "Lofty Lullabies", isFavorite: false, sortName: "Lofty Lullabies", index: 10, albumId: "105", artistNames: ["The Harmonics"], size: 5080000, runtime: 203, albumDisc: 1, fileExtension: "mp3")
    ]
}
// swiftlint:enable all
// swiftformat:enable all
