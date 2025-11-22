//
//  PedagogicalManifesto.swift
//  TileMosaic
//
//  Game instructions view controller
//

import UIKit
import SnapKit

class PedagogicalManifesto: UIViewController {

    private let backgroundImageVessel = UIImageView()
    private let scrollVessel = UIScrollView()
    private let contentVessel = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        orchestrateInterface()
    }

    private func orchestrateInterface() {
        title = "How to Play"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]

        // Background
        backgroundImageVessel.image = UIImage(named: "backhrod")
        backgroundImageVessel.contentMode = .scaleAspectFill
        backgroundImageVessel.clipsToBounds = true
        view.addSubview(backgroundImageVessel)

        backgroundImageVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }

        let overlayVessel = UIView()
        overlayVessel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(overlayVessel)

        overlayVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }

        // Scroll view
        view.addSubview(scrollVessel)
        scrollVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollVessel.addSubview(contentVessel)
        contentVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
            fabricate.width.equalToSuperview()
        }

        // Content
        var previousElement: UIView?

        // Novice mode section
        let noviceCaption = createCaptionLabel(text: "Novice Mode")
        contentVessel.addSubview(noviceCaption)
        noviceCaption.snp.makeConstraints { fabricate in
            fabricate.top.equalToSuperview().offset(24)
            fabricate.leading.equalToSuperview().offset(24)
            fabricate.trailing.equalToSuperview().offset(-24)
        }
        previousElement = noviceCaption

        let noviceInstructions = [
            "1. Memorize 4 mahjong tiles displayed in a 2x2 grid within 5 seconds.",
            "2. After the countdown, the tiles disappear and a 4x4 puzzle grid appears.",
            "3. Each tile is split into 4 pieces, creating 16 puzzle fragments.",
            "4. Drag and drop the fragments to reconstruct each tile in the correct position.",
            "5. Tap 'Verify' to check your solution.",
            "6. Complete correctly to advance to the next level!",
            "7. Fail and you'll restart from Level 1."
        ]

        for instruction in noviceInstructions {
            let label = createDescriptionLabel(text: instruction)
            contentVessel.addSubview(label)
            label.snp.makeConstraints { fabricate in
                fabricate.top.equalTo(previousElement!.snp.bottom).offset(12)
                fabricate.leading.equalToSuperview().offset(24)
                fabricate.trailing.equalToSuperview().offset(-24)
            }
            previousElement = label
        }

        // Virtuoso mode section
        let virtuosoCaption = createCaptionLabel(text: "Virtuoso Mode")
        contentVessel.addSubview(virtuosoCaption)
        virtuosoCaption.snp.makeConstraints { fabricate in
            fabricate.top.equalTo(previousElement!.snp.bottom).offset(32)
            fabricate.leading.equalToSuperview().offset(24)
            fabricate.trailing.equalToSuperview().offset(-24)
        }
        previousElement = virtuosoCaption

        let virtuosoInstructions = [
            "1. Memorize 9 mahjong tiles displayed in a 3x3 grid within 10 seconds.",
            "2. After the countdown, the tiles disappear and a 6x6 puzzle grid appears.",
            "3. Each tile is split into 4 pieces, creating 36 puzzle fragments.",
            "4. Drag and drop the fragments to reconstruct each tile in the correct position.",
            "5. Tap 'Verify' to check your solution.",
            "6. Complete correctly to advance to the next level!",
            "7. Fail and you'll restart from Level 1."
        ]

        for instruction in virtuosoInstructions {
            let label = createDescriptionLabel(text: instruction)
            contentVessel.addSubview(label)
            label.snp.makeConstraints { fabricate in
                fabricate.top.equalTo(previousElement!.snp.bottom).offset(12)
                fabricate.leading.equalToSuperview().offset(24)
                fabricate.trailing.equalToSuperview().offset(-24)
            }
            previousElement = label
        }

        // Tips section
        let tipsCaption = createCaptionLabel(text: "Tips")
        contentVessel.addSubview(tipsCaption)
        tipsCaption.snp.makeConstraints { fabricate in
            fabricate.top.equalTo(previousElement!.snp.bottom).offset(32)
            fabricate.leading.equalToSuperview().offset(24)
            fabricate.trailing.equalToSuperview().offset(-24)
        }
        previousElement = tipsCaption

        let tips = [
            "• Focus on memorizing the position and pattern of each tile.",
            "• Look for distinctive features in each tile to help remember them.",
            "• Work systematically - complete one tile at a time.",
            "• Your high scores are saved in the leaderboard!"
        ]

        for tip in tips {
            let label = createDescriptionLabel(text: tip)
            contentVessel.addSubview(label)
            label.snp.makeConstraints { fabricate in
                fabricate.top.equalTo(previousElement!.snp.bottom).offset(12)
                fabricate.leading.equalToSuperview().offset(24)
                fabricate.trailing.equalToSuperview().offset(-24)
            }
            previousElement = label
        }

        // Bottom padding
        previousElement?.snp.makeConstraints { fabricate in
            fabricate.bottom.equalToSuperview().offset(-24)
        }
    }

    private func createCaptionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)
        label.numberOfLines = 0
        return label
    }

    private func createDescriptionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(white: 0.95, alpha: 1.0)
        label.numberOfLines = 0
        return label
    }
}
