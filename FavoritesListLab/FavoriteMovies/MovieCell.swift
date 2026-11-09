import UIKit

final class MovieCell: UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet var ratingImageViews: [UIImageView]!
    private var accentColor = UIColor.systemBlue

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false
        titleLabel.backgroundColor = .clear
        subtitleLabel.backgroundColor = .clear
        titleLabel.isOpaque = false
        subtitleLabel.isOpaque = false
        layer.shadowRadius = 14
        layer.shadowOffset = .zero
        let press = UILongPressGestureRecognizer(target: self, action: #selector(posterPressed(_:)))
        press.minimumPressDuration = 0
        press.cancelsTouchesInView = false
        contentView.addGestureRecognizer(press)
        contentView.addGestureRecognizer(UIHoverGestureRecognizer(target: self, action: #selector(posterHovered(_:))))
    }

    func configure(with movie: Movie) {
        posterImageView.transform = .identity
        titleLabel.transform = .identity
        layer.shadowOpacity = 0
        posterImageView.layer.borderWidth = 0
        let hex = movie.glowHex
        accentColor = UIColor(red: CGFloat((hex >> 16) & 255) / 255,
                              green: CGFloat((hex >> 8) & 255) / 255,
                              blue: CGFloat(hex & 255) / 255, alpha: 1)
        layer.shadowColor = accentColor.cgColor
        posterImageView.layer.borderColor = accentColor.cgColor
        posterImageView.image = UIImage(named: movie.image)
        titleLabel.text = movie.title
        subtitleLabel.text = movie.subtitle
        for (index, star) in ratingImageViews.sorted(by: { $0.tag < $1.tag }).enumerated() {
            star.image = UIImage(systemName: index < movie.rating ? "star.fill" : "star")
        }
        accessibilityLabel = "\(movie.title), \(movie.subtitle), \(movie.rating) out of 5"
    }

    @objc private func posterPressed(_ gesture: UILongPressGestureRecognizer) {
        animatePoster(expanded: gesture.state == .began || gesture.state == .changed)
    }

    @objc private func posterHovered(_ gesture: UIHoverGestureRecognizer) {
        animatePoster(expanded: gesture.state == .began || gesture.state == .changed)
    }

    private func animatePoster(expanded: Bool) {
        let posterRect = posterImageView.convert(posterImageView.bounds, to: self)
        layer.shadowPath = UIBezierPath(roundedRect: posterRect, cornerRadius: 10).cgPath
        layer.shadowOpacity = expanded ? 0.85 : 0
        posterImageView.layer.borderWidth = expanded ? 2 : 0
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
            self.posterImageView.transform = expanded ? CGAffineTransform(scaleX: 1.15, y: 1.15) : .identity
            self.titleLabel.transform = expanded ? CGAffineTransform(scaleX: 1.10, y: 1.10) : .identity
        }
    }
}
