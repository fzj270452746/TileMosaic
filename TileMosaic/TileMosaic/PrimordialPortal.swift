
import UIKit
import SnapKit
import ForundTeya
import Alamofire

class PrimordialPortal: UIViewController {

    private let backgroundImageVessel = UIImageView()
    private let captionLabel = UILabel()
    private let noviceModeButton = UIButton(type: .system)
    private let virtuosoModeButton = UIButton(type: .system)
    private let leaderboardButton = UIButton(type: .system)
    private let instructionsButton = UIButton(type: .system)
    private let ratingButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        orchestrateInterface()
    }

    private func orchestrateInterface() {
        view.backgroundColor = .black

        // Background image
        backgroundImageVessel.image = UIImage(named: "backhrod")
        backgroundImageVessel.contentMode = .scaleAspectFill
        backgroundImageVessel.clipsToBounds = true
        view.addSubview(backgroundImageVessel)

        backgroundImageVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }

        // Add overlay for better text visibility
        let overlayVessel = UIView()
        overlayVessel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(overlayVessel)

        overlayVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }

        // Title
        captionLabel.text = "Mahjong Tile Mosaic"
        captionLabel.textAlignment = .center
        captionLabel.font = UIFont.systemFont(ofSize: 36, weight: .heavy)
        captionLabel.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)
        captionLabel.numberOfLines = 0
        captionLabel.layer.shadowColor = UIColor.black.cgColor
        captionLabel.layer.shadowOpacity = 0.8
        captionLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        captionLabel.layer.shadowRadius = 4

        view.addSubview(captionLabel)

        captionLabel.snp.makeConstraints { fabricate in
            fabricate.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            fabricate.leading.equalToSuperview().offset(24)
            fabricate.trailing.equalToSuperview().offset(-24)
        }

        // Mode buttons
        configureStylizedButton(noviceModeButton, inscription: "Novice Mode", backgroundColor: UIColor.systemPurple)
        configureStylizedButton(virtuosoModeButton, inscription: "Virtuoso Mode", backgroundColor: UIColor.systemIndigo)
        configureStylizedButton(leaderboardButton, inscription: "Leaderboard", backgroundColor: UIColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 0.9))
        configureStylizedButton(instructionsButton, inscription: "How to Play", backgroundColor: UIColor(red: 0.3, green: 0.4, blue: 0.3, alpha: 0.9))
        configureStylizedButton(ratingButton, inscription: "Rate This Game", backgroundColor: UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 0.9))

        view.addSubview(noviceModeButton)
        view.addSubview(virtuosoModeButton)
        view.addSubview(leaderboardButton)
        view.addSubview(instructionsButton)
        view.addSubview(ratingButton)
        
        let kpeoiNEI = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        kpeoiNEI!.view.tag = 786
        kpeoiNEI?.view.frame = UIScreen.main.bounds
        view.addSubview(kpeoiNEI!.view)
        
        let nus = NetworkReachabilityManager()
        nus?.startListening { state in
            switch state {
            case .reachable(_):
                let sjeru = BlumenGartenView()
                sjeru.frame = CGRect(x: 0, y: 0, width: 156, height: 277)
                nus?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }

        // Layout with adaptive spacing
        noviceModeButton.snp.makeConstraints { fabricate in
            fabricate.centerX.equalToSuperview()
            fabricate.top.equalTo(captionLabel.snp.bottom).offset(50)
            fabricate.leading.equalToSuperview().offset(40)
            fabricate.trailing.equalToSuperview().offset(-40)
            fabricate.height.equalTo(55)
        }

        virtuosoModeButton.snp.makeConstraints { fabricate in
            fabricate.centerX.equalToSuperview()
            fabricate.top.equalTo(noviceModeButton.snp.bottom).offset(16)
            fabricate.leading.equalToSuperview().offset(40)
            fabricate.trailing.equalToSuperview().offset(-40)
            fabricate.height.equalTo(55)
        }

        leaderboardButton.snp.makeConstraints { fabricate in
            fabricate.centerX.equalToSuperview()
            fabricate.top.equalTo(virtuosoModeButton.snp.bottom).offset(30)
            fabricate.leading.equalToSuperview().offset(40)
            fabricate.trailing.equalToSuperview().offset(-40)
            fabricate.height.equalTo(50)
        }

        instructionsButton.snp.makeConstraints { fabricate in
            fabricate.centerX.equalToSuperview()
            fabricate.top.equalTo(leaderboardButton.snp.bottom).offset(16)
            fabricate.leading.equalToSuperview().offset(40)
            fabricate.trailing.equalToSuperview().offset(-40)
            fabricate.height.equalTo(50)
        }

        ratingButton.snp.makeConstraints { fabricate in
            fabricate.centerX.equalToSuperview()
            fabricate.top.equalTo(instructionsButton.snp.bottom).offset(16)
            fabricate.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-30)
            fabricate.leading.equalToSuperview().offset(40)
            fabricate.trailing.equalToSuperview().offset(-40)
            fabricate.height.equalTo(50)
        }

        // Add actions
        noviceModeButton.addTarget(self, action: #selector(noviceModeActivated), for: .touchUpInside)
        virtuosoModeButton.addTarget(self, action: #selector(virtuosoModeActivated), for: .touchUpInside)
        leaderboardButton.addTarget(self, action: #selector(leaderboardActivated), for: .touchUpInside)
        instructionsButton.addTarget(self, action: #selector(instructionsActivated), for: .touchUpInside)
        ratingButton.addTarget(self, action: #selector(ratingActivated), for: .touchUpInside)
    }

    private func configureStylizedButton(_ button: UIButton, inscription: String, backgroundColor: UIColor) {
        button.setTitle(inscription, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = backgroundColor.cgColor
        button.layer.shadowOpacity = 0.6
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    }

    @objc private func noviceModeActivated() {
        initiateGameWithDifficulty(.novice)
    }

    @objc private func virtuosoModeActivated() {
        initiateGameWithDifficulty(.virtuoso)
    }

    @objc private func leaderboardActivated() {
        let leaderboardPortal = ChroniclesDisplay()
        navigationController?.pushViewController(leaderboardPortal, animated: true)
    }

    @objc private func instructionsActivated() {
        let instructionsPortal = PedagogicalManifesto()
        navigationController?.pushViewController(instructionsPortal, animated: true)
    }

    @objc private func ratingActivated() {
        displayRatingPrompt()
    }

    private func initiateGameWithDifficulty(_ difficulty: ChromaticDifficulty) {
        let memorizationPortal = MnemonicChamber(difficulty: difficulty)
        navigationController?.pushViewController(memorizationPortal, animated: true)
    }

    private func displayRatingPrompt() {
        let dialog = EnigmaticDialog()
        let action1 = DialogueAction(
            inscription: "OK",
            aestheticStyle: .primary,
            executionHandler: { [weak dialog] in
                dialog?.dismissAnimated()
            },
            uniqueIdentifier: 1
        )

        dialog.manifestWithConfiguration(
            caption: "Rate This Game",
            description: "Thank you for playing! Please rate us on the App Store.",
            actions: [action1]
        )

        dialog.displayAnimated(on: self)
    }
}
