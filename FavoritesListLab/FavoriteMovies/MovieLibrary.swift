import Foundation

struct Movie {
    let title: String
    let description: String
    let image: String
    let subtitle: String
    let rating: Int
}

enum MovieLibrary {
    // Personal ratings out of 5. Change these values to your own scores.
    static let movies: [Movie] = [
        Movie(
            title: "Interstellar",
            description: "A team of astronauts travels beyond the solar system to find a future for humanity.",
            image: "movie1",
            subtitle: "Space & emotion",
            rating: 4
        ),
        Movie(
            title: "Cruella",
            description: "An ambitious young designer challenges a powerful fashion icon in London.",
            image: "movie2",
            subtitle: "Fashion & rebellion",
            rating: 4
        ),
        Movie(
            title: "Avatar",
            description: "A former soldier discovers Pandora and forms a bond with its people.",
            image: "movie3",
            subtitle: "Fantasy adventure",
            rating: 4
        ),
        Movie(
            title: "Titanic",
            description: "Two passengers from different worlds fall in love aboard the Titanic.",
            image: "movie4",
            subtitle: "Epic romance",
            rating: 4
        ),
        Movie(
            title: "The Dark Knight Rises",
            description: "Bruce Wayne returns as Batman when a new enemy threatens Gotham.",
            image: "movie5",
            subtitle: "Gotham after dark",
            rating: 4
        ),
        Movie(
            title: "Joker",
            description: "An isolated performer in Gotham struggles to find his place in the world.",
            image: "movie6",
            subtitle: "Dark drama",
            rating: 4
        ),
        Movie(
            title: "Catwoman",
            description: "A woman gains feline abilities and uncovers a dangerous corporate secret.",
            image: "movie7",
            subtitle: "Feline & mysterious",
            rating: 4
        ),
        Movie(
            title: "Shrek",
            description: "An ogre and a talkative donkey set out to rescue a princess.",
            image: "movie8",
            subtitle: "Fairytale chaos",
            rating: 4
        ),
        Movie(
            title: "Puss in Boots",
            description: "A fearless cat joins a daring quest with old friends and new allies.",
            image: "movie9",
            subtitle: "Fairytale adventure",
            rating: 4
        ),
        Movie(
            title: "Oppenheimer",
            description: "A physicist leads a secret wartime project and faces its lasting consequences.",
            image: "movie10",
            subtitle: "Historical drama",
            rating: 4
        ),
        Movie(
            title: "Legally Blonde",
            description: "Elle Woods enters Harvard Law School and discovers her own strengths.",
            image: "movie11",
            subtitle: "Pink & confidence",
            rating: 4
        ),
        Movie(
            title: "Mean Girls",
            description: "A new student navigates friendship, popularity and rivalry at high school.",
            image: "movie12",
            subtitle: "School drama",
            rating: 4
        ),
        Movie(
            title: "The Devil Wears Prada",
            description: "A young assistant enters the demanding world of a powerful fashion editor.",
            image: "movie13",
            subtitle: "Fashion & ambition",
            rating: 4
        ),
        Movie(
            title: "The Princess Diaries",
            description: "A shy teenager discovers that she is the heir to a European throne.",
            image: "movie14",
            subtitle: "Royal makeover",
            rating: 4
        ),
        Movie(
            title: "Home Alone",
            description: "A boy accidentally left home for Christmas protects his house from two burglars.",
            image: "movie15",
            subtitle: "Christmas chaos",
            rating: 4
        ),
        Movie(
            title: "Home Alone 2: Lost in New York",
            description: "Kevin finds himself alone in New York and encounters two familiar burglars.",
            image: "movie16",
            subtitle: "New York Christmas",
            rating: 4
        ),
        Movie(
            title: "Harry Potter and the Philosopher's Stone",
            description: "A young wizard discovers Hogwarts, new friendships and a dangerous mystery.",
            image: "movie17",
            subtitle: "Magic & winter comfort",
            rating: 4
        ),
        Movie(
            title: "Last Christmas",
            description: "A London Christmas shop worker meets a mysterious man who changes her outlook.",
            image: "movie18",
            subtitle: "Christmas romance",
            rating: 4
        ),
        Movie(
            title: "The Grinch",
            description: "A grumpy green recluse plans to steal Christmas from the people of Who-ville.",
            image: "movie19",
            subtitle: "Mischievous Christmas",
            rating: 4
        ),
        Movie(
            title: "The Addams Family",
            description: "An eccentric family welcomes a visitor who claims to be their long-lost relative.",
            image: "movie20",
            subtitle: "Spooky family",
            rating: 4
        )
    ]
}

// Accent colors are presentation metadata shared by both screens.
extension Movie {
    var glowHex: UInt32 {
        switch image {
        case "movie1": return 0x518CFF
        case "movie2": return 0xE33A52
        case "movie3": return 0x24B1C9
        case "movie4": return 0x5A96D4
        case "movie5": return 0x6484D1
        case "movie6": return 0x5DAA70
        case "movie7": return 0x38A3C9
        case "movie8": return 0x89C849
        case "movie9": return 0xEAA64B
        case "movie10": return 0xE48743
        case "movie11": return 0xEE74B1
        case "movie12": return 0xDF76B3
        case "movie13": return 0xDF4D5D
        case "movie14": return 0xDDA87C
        case "movie15": return 0xE06055
        case "movie16": return 0x56A8C4
        case "movie17": return 0x438FEB
        case "movie18": return 0x5CB1B2
        case "movie19": return 0x91C83E
        case "movie20": return 0x9A6DCF
        default: return 0x7658D6
        }
    }
}

// Every movie appears once per cycle. The initial movie counts as already shown.
struct MovieShuffleQueue {
    private let count: Int
    private var remaining: [Int]

    init(count: Int, initiallyShown: Int) {
        self.count = max(count, 0)
        remaining = Array(0..<max(count, 0))
            .filter { $0 != initiallyShown }.shuffled()
    }

    mutating func next(after current: Int) -> Int? {
        guard count > 0 else { return nil }
        if remaining.isEmpty {
            remaining = Array(0..<count).shuffled()
            if count > 1, remaining.last == current,
               let different = remaining.firstIndex(where: { $0 != current }) {
                remaining.swapAt(different, remaining.count - 1)
            }
        }
        return remaining.popLast()
    }
}
