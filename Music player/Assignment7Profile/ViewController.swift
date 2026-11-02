import UIKit

class ViewController: UIViewController {
    private var isFollowing = false

    @IBAction func followTapped(_ sender: UIButton) {
        isFollowing.toggle()
        UIView.transition(with: sender, duration: 0.2,
                          options: [.transitionCrossDissolve, .allowUserInteraction]) {
            sender.setTitle(self.isFollowing ? "Following ▾" : "Follow", for: .normal)
            sender.setBackgroundImage(
                self.isFollowing ? nil : UIImage(named: "FollowGradient"),
                for: .normal
            )
            sender.backgroundColor = self.isFollowing
                ? UIColor(red: 40 / 255.0, green: 46 / 255.0, blue: 51 / 255.0, alpha: 1)
                : .clear
            sender.setTitleColor(.white, for: .normal)
            sender.layer.borderWidth = 0
        }
    }
}
