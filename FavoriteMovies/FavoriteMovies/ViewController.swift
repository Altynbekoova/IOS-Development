
import UIKit

struct Movie {
    let title: String
    let description: String
    let image: String
}

class ViewController: UIViewController {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDescription: UILabel!

    // Connect this to the card View in Storyboard
    @IBOutlet weak var movieCard: UIView!

    let movies: [Movie] = [
        Movie(
            title: "Interstellar",
            description: "Astronauts travel through space to find a new home for humanity. A story about love, time, and survival.",
            image: "movie1"
        ),
        Movie(
            title: "Inception",
            description: "A skilled thief enters people's dreams to steal secrets. One final mission could change his life forever.",
            image: "movie2"
        ),
        Movie(
            title: "Avatar",
            description: "A former soldier visits Pandora, a beautiful alien world. He must choose between following orders and protecting its people.",
            image: "movie3"
        ),
        Movie(
            title: "Titanic",
            description: "Two young people fall in love aboard a famous ship. Their journey becomes a fight for survival.",
            image: "movie4"
        ),
        Movie(
            title: "The Dark Knight Rises",
            description: "Batman returns to protect Gotham City from a dangerous enemy who threatens to destroy everything.",
            image: "movie5"
        ),
        Movie(
            title: "Joker",
            description: "A lonely man struggles with society and slowly becomes one of Gotham City's most dangerous villains.",
            image: "movie6"
        ),
        Movie(
            title: "The Matrix",
            description: "A hacker discovers that his world is not what it seems. He must fight to learn the truth.",
            image: "movie7"
        ),
        Movie(
            title: "Gladiator",
            description: "A Roman general loses everything and becomes a gladiator. He fights for justice and freedom.",
            image: "movie8"
        ),
        Movie(
            title: "Dune",
            description: "A young man travels to a dangerous desert planet. The future of his family depends on his choices.",
            image: "movie9"
        ),
        Movie(
            title: "Oppenheimer",
            description: "A brilliant scientist helps create the atomic bomb and faces the consequences of his work.",
            image: "movie10"
        )
    ]

    var currentIndex = 0
    private let backgroundGradient = CAGradientLayer()
    private let posterGlow = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupCard()
        setupPoster()
        setupText()
        showMovie()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundGradient.frame = view.bounds
        posterGlow.frame = movieImage.frame
    }

    func setupBackground() {
        backgroundGradient.colors = [
            UIColor(red: 0.04, green: 0.07, blue: 0.15, alpha: 1).cgColor,
            UIColor(red: 0.12, green: 0.14, blue: 0.28, alpha: 1).cgColor,
            UIColor(red: 0.22, green: 0.13, blue: 0.19, alpha: 1).cgColor
        ]

        backgroundGradient.locations = [0, 0.55, 1]
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    func setupCard() {
        movieCard.backgroundColor = UIColor(
            red: 0.12, green: 0.16, blue: 0.25, alpha: 0.95
        )

        movieCard.layer.cornerRadius = 22
        movieCard.layer.masksToBounds = true
    }

    
    func setupPoster() {
        movieImage.contentMode = .scaleAspectFill
        movieImage.layer.cornerRadius = 8
        movieImage.clipsToBounds = true
        movieImage.layer.borderWidth = 0

        posterGlow.backgroundColor = UIColor(
            red: 0.45,
            green: 0.38,
            blue: 0.85,
            alpha: 1
        )

        posterGlow.layer.cornerRadius = 12

        posterGlow.layer.shadowColor = UIColor(
            red: 0.55,
            green: 0.45,
            blue: 1.0,
            alpha: 1
        ).cgColor

        posterGlow.layer.shadowOpacity = 0.9
        posterGlow.layer.shadowRadius = 28
        posterGlow.layer.shadowOffset = .zero

        posterGlow.isUserInteractionEnabled = false

        movieImage.superview?.insertSubview(
            posterGlow,
            belowSubview: movieImage
        )
    }

    func setupText() {
        movieTitle.font = .systemFont(ofSize: 23, weight: .semibold)
        movieTitle.textColor = .white
        movieTitle.numberOfLines = 0
        movieTitle.lineBreakMode = .byWordWrapping

        movieDescription.font = .systemFont(ofSize: 14)
        movieDescription.textColor = UIColor(
            red: 0.82, green: 0.84, blue: 0.90, alpha: 1
        )
        movieDescription.numberOfLines = 0
        movieDescription.lineBreakMode = .byWordWrapping
    }

    func showMovie() {
        let movie = movies[currentIndex]
        movieTitle.text = movie.title
        movieDescription.text = movie.description
        movieImage.image = UIImage(named: movie.image)
    }

    @IBAction func randomButtonTapped(_ sender: UIButton) {
        guard movies.count > 1 else { return }

        var newIndex: Int

        repeat {
            newIndex = Int.random(in: 0..<movies.count)
        } while newIndex == currentIndex

        currentIndex = newIndex
        showMovie()
    }
}
