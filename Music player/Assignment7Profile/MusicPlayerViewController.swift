import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController,
                                 AVAudioPlayerDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!

    @IBOutlet weak var progressSlider: UISlider?
    @IBOutlet weak var elapsedTimeLabel: UILabel?
    @IBOutlet weak var remainingTimeLabel: UILabel?

    private var progressTimer: Timer?

    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0
    private var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Now Playing"
        loadTrack(autoplay: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressTimer?.invalidate()
        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
        progressTimer = timer
        RunLoop.main.add(timer, forMode: .common)
        updateProgress()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressTimer?.invalidate()
        progressTimer = nil
    }

    deinit {
        progressTimer?.invalidate()
    }

    private func loadTrack(autoplay: Bool) {
        guard !tracks.isEmpty else {
            print("Библиотека треков пустая")
            return
        }

        player?.stop()
        player = nil

        let track = tracks[currentIndex]

        trackTitleLabel.text = track.title
        artistLabel.text = track.artist
        UIView.transition(with: coverImageView, duration: 0.25,
                          options: .transitionCrossDissolve) {
            self.coverImageView.image = UIImage(named: track.coverImageName)
        }
        updateProgress()

        let file = track.fileName as NSString
        let name = file.deletingPathExtension
        let ext = file.pathExtension

        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: ext
        ) else {
            print("Аудиофайл не найден: \(track.fileName)")
            updatePlayButton()
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()

            if autoplay {
                startPlayback()
            }
        } catch {
            print("Ошибка загрузки \(track.fileName): \(error)")
        }

        updatePlayButton()
        updateProgress()
    }

    private func startPlayback() {
        guard let player = player else {
            print("Трек не загружен")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            if !player.play() {
                print("Не удалось начать воспроизведение")
            }
        } catch {
            print("Ошибка аудиосессии: \(error)")
        }

        updatePlayButton()
    }

    private func updatePlayButton() {
        let isPlaying = player?.isPlaying ?? false
        let symbol = isPlaying ? "pause.fill" : "play.fill"

        playPauseButton.setImage(
            UIImage(systemName: symbol),
            for: .normal
        )
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        animatePress(sender)
        guard let player = player else {
            loadTrack(autoplay: true)
            return
        }

        if player.isPlaying {
            player.pause()
            updatePlayButton()
        } else {
            startPlayback()
        }
    }

    @IBAction func seekChanged(_ sender: UISlider) {
        guard let player = player, player.duration > 0 else { return }
        player.currentTime = min(max(Double(sender.value), 0), player.duration)
        updateProgress()
    }

    private func updateProgress() {
        let duration = player?.duration ?? 0
        let current = player?.currentTime ?? 0
        progressSlider?.isEnabled = duration > 0
        progressSlider?.minimumValue = 0
        progressSlider?.maximumValue = max(Float(duration), 0.01)
        if progressSlider?.isTracking != true {
            progressSlider?.setValue(Float(current), animated: player?.isPlaying ?? false)
        }
        elapsedTimeLabel?.text = timeString(current)
        remainingTimeLabel?.text = "−" + timeString(max(duration - current, 0))
    }

    private func timeString(_ interval: TimeInterval) -> String {
        guard interval.isFinite else { return "0:00" }
        let seconds = max(Int(interval), 0)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func animatePress(_ button: UIButton) {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 0,
                           usingSpringWithDamping: 0.65,
                           initialSpringVelocity: 0,
                           options: [.allowUserInteraction, .beginFromCurrentState],
                           animations: {
                button.transform = .identity
            })
        }
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        changeTrack(by: 1)
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        changeTrack(by: -1)
    }

    private func changeTrack(by offset: Int) {
        guard !tracks.isEmpty else { return }

        let wasPlaying = player?.isPlaying ?? false

        currentIndex = (
            currentIndex + offset + tracks.count
        ) % tracks.count

        loadTrack(autoplay: wasPlaying)
    }

    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        guard flag, !tracks.isEmpty else {
            updatePlayButton()
            return
        }

        currentIndex = (currentIndex + 1) % tracks.count
        loadTrack(autoplay: true)
    }

    func audioPlayerDecodeErrorDidOccur(
        _ player: AVAudioPlayer,
        error: Error?
    ) {
        player.stop()
        print("Ошибка декодирования аудио: \(String(describing: error))")
        updatePlayButton()
    }
}
