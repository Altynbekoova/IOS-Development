import Foundation

enum TrackLibrary {

    static let tracks: [Track] = [
        makeTrack("Never Gonna Give You Up"),
        makeTrack("Together Forever"),
        makeTrack("Cry For Help"),
        makeTrack("Giant"),
        makeTrack("Just Good Friends"),
        makeTrack("Love This Christmas"),
        makeTrack("Take Me To Your Heart"),
        makeTrack("When I Fall In Love"),

        makeTrack(
            "She Wants To Dance With Me",
            fileName: "Rick Astley - She Wants To Dance With Me"
                + String(repeating: " ", count: 5)
                + ".mp3"
        ),

        makeTrack(
            "Whenever You Need Somebody",
            fileName: "Rick Astley - Whenever You Need Sombody.mp3"
        )
    ]

    private static func makeTrack(
        _ title: String,
        fileName: String? = nil
    ) -> Track {
        Track(
            title: title,
            artist: "Rick Astley",
            fileName: fileName ?? "Rick Astley - \(title).mp3",
            coverImageName: "IMG_2067"
        )
    }
}
