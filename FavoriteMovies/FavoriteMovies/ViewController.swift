import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var favoritesHeadingLabel: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel?
    @IBOutlet weak var movieDescription: UILabel?
    @IBOutlet weak var movieCard: UIView!
    @IBOutlet weak var movieRatingLabel: UILabel?
    @IBOutlet weak var posterGlow: UIView!

    let movies = MovieLibrary.movies
    private var currentIndex = 0
    private var shuffleQueue = MovieShuffleQueue(
        count: MovieLibrary.movies.count, initiallyShown: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesHeadingLabel.layer.shadowColor = UIColor(red: 0.914, green: 0.737, blue: 0.467, alpha: 1).cgColor
        favoritesHeadingLabel.layer.shadowOpacity = 0.85
        favoritesHeadingLabel.layer.shadowRadius = 12
        favoritesHeadingLabel.layer.shadowOffset = .zero
        favoritesHeadingLabel.clipsToBounds = false
        favoritesTableView.dataSource = self
        favoritesTableView.backgroundColor = .clear
        favoritesTableView.contentInset = .zero
        favoritesTableView.reloadData()
        posterGlow.layer.cornerRadius = 12
        posterGlow.layer.shadowOpacity = 0.85
        posterGlow.layer.shadowRadius = 28
        posterGlow.layer.shadowOffset = .zero
        showMovie()
    }

    private func showMovie() {
        guard movies.indices.contains(currentIndex) else { return }
        let movie = movies[currentIndex]
        movieTitle?.text = movie.title
        movieDescription?.text = movie.description
        movieImage.image = UIImage(named: movie.image)
        let rating = min(max(movie.rating, 0), 5)
        movieRatingLabel?.text = String(repeating: "★", count: rating)
            + String(repeating: "☆", count: 5 - rating)
            + "  \(rating) / 5"
        movieRatingLabel?.accessibilityLabel = "Personal rating: \(rating) out of 5"
        let hex = movie.glowHex
        let color = UIColor(
            red: CGFloat((hex >> 16) & 255) / 255,
            green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255, alpha: 1
        )
        posterGlow.backgroundColor = color
        posterGlow.layer.shadowColor = color.cgColor
    }

    @IBAction func randomButtonTapped(_ sender: UIButton) {
        guard let next = shuffleQueue.next(after: currentIndex) else { return }
        currentIndex = next
        showMovie()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }
}
