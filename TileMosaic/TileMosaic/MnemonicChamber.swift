//
//  MnemonicChamber.swift
//  TileMosaic
//
//  Unified memorization and puzzle view controller
//

import UIKit
import SnapKit

class MnemonicChamber: UIViewController {

    private let backgroundImageVessel = UIImageView()
    private let strataLabel = UILabel()
    private let countdownLabel = UILabel()
    private let tilesCollectionView: UICollectionView
    private let puzzleCollectionView: UICollectionView
    private let hintLabel = UILabel()
    private let verificationButton = UIButton(type: .system)

    private let difficulty: ChromaticDifficulty
    var currentStrata: Int = 1
    private var originalTiles: [VestigeTileEntity] = []
    private var puzzleFragments: [TessellationFragment] = []
    private var remainingTime: Int = 0
    private var countdownMechanism: Timer?
    private var isMemorizationPhase = true
    private var selectedFragmentIndex: Int?

    init(difficulty: ChromaticDifficulty) {
        self.difficulty = difficulty

        // Layout for tiles (memorization)
        let tilesLayoutConfiguration = UICollectionViewFlowLayout()
        tilesLayoutConfiguration.minimumInteritemSpacing = 8
        tilesLayoutConfiguration.minimumLineSpacing = 8
        self.tilesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: tilesLayoutConfiguration)

        // Layout for puzzle pieces
        let puzzleLayoutConfiguration = UICollectionViewFlowLayout()
        puzzleLayoutConfiguration.minimumInteritemSpacing = 2
        puzzleLayoutConfiguration.minimumLineSpacing = 2
        self.puzzleCollectionView = UICollectionView(frame: .zero, collectionViewLayout: puzzleLayoutConfiguration)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        orchestrateInterface()
        initiateMemorizationPhase()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownMechanism?.invalidate()
    }

    private func orchestrateInterface() {
        navigationItem.hidesBackButton = true

        // Add home button to navigation bar
        let homeButton = UIBarButtonItem(
            title: "Home",
            style: .plain,
            target: self,
            action: #selector(homeButtonActivated)
        )
        homeButton.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ], for: .normal)
        navigationItem.leftBarButtonItem = homeButton

        // Background
        backgroundImageVessel.image = UIImage(named: "backhrod")
        backgroundImageVessel.contentMode = .scaleAspectFill
        backgroundImageVessel.clipsToBounds = true
        view.addSubview(backgroundImageVessel)

        backgroundImageVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }

        let overlayVessel = UIView()
        overlayVessel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(overlayVessel)

        overlayVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }

        // Level label
        strataLabel.text = "Level \(currentStrata)"
        strataLabel.textAlignment = .center
        strataLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        strataLabel.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)

        view.addSubview(strataLabel)

        strataLabel.snp.makeConstraints { fabricate in
            fabricate.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            fabricate.centerX.equalToSuperview()
        }

        // Countdown label
        countdownLabel.textAlignment = .center
        countdownLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 72, weight: .bold)
        countdownLabel.textColor = UIColor.systemRed
        countdownLabel.layer.shadowColor = UIColor.black.cgColor
        countdownLabel.layer.shadowOpacity = 0.8
        countdownLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        countdownLabel.layer.shadowRadius = 6

        view.addSubview(countdownLabel)

        countdownLabel.snp.makeConstraints { fabricate in
            fabricate.top.equalTo(strataLabel.snp.bottom).offset(10)
            fabricate.centerX.equalToSuperview()
        }

        // Verification button (add first to establish bottom anchor)
        verificationButton.setTitle("Verify Solution", for: .normal)
        verificationButton.backgroundColor = UIColor.systemGreen
        verificationButton.setTitleColor(.white, for: .normal)
        verificationButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        verificationButton.layer.cornerRadius = 14
        verificationButton.layer.shadowColor = UIColor.systemGreen.cgColor
        verificationButton.layer.shadowOpacity = 0.6
        verificationButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        verificationButton.layer.shadowRadius = 8
        verificationButton.addTarget(self, action: #selector(verificationActivated), for: .touchUpInside)
        verificationButton.alpha = 0

        view.addSubview(verificationButton)

        verificationButton.snp.makeConstraints { fabricate in
            fabricate.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            fabricate.centerX.equalToSuperview()
            fabricate.leading.greaterThanOrEqualToSuperview().offset(40)
            fabricate.trailing.lessThanOrEqualToSuperview().offset(-40)
            fabricate.height.equalTo(50)
        }

        // Hint label (placed above verification button)
        hintLabel.text = "Memorize these tiles!"
        hintLabel.textAlignment = .center
        hintLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        hintLabel.textColor = .white
        hintLabel.numberOfLines = 0

        view.addSubview(hintLabel)

        hintLabel.snp.makeConstraints { fabricate in
            fabricate.bottom.equalTo(verificationButton.snp.top).offset(-16)
            fabricate.leading.equalToSuperview().offset(24)
            fabricate.trailing.equalToSuperview().offset(-24)
        }

        // Tiles Collection view (for memorization - showing complete tiles)
        tilesCollectionView.backgroundColor = .clear
        tilesCollectionView.delegate = self
        tilesCollectionView.dataSource = self
        tilesCollectionView.register(CompleteTileCell.self, forCellWithReuseIdentifier: "TileCell")
        tilesCollectionView.isScrollEnabled = false
        tilesCollectionView.alpha = 1

        view.addSubview(tilesCollectionView)

        tilesCollectionView.snp.makeConstraints { fabricate in
            fabricate.centerX.equalToSuperview()
            fabricate.centerY.equalToSuperview().offset(20)
            fabricate.leading.equalToSuperview().offset(40)
            fabricate.trailing.equalToSuperview().offset(-40)
            fabricate.width.lessThanOrEqualTo(500)
            fabricate.height.equalTo(tilesCollectionView.snp.width)
        }

        // Puzzle Collection view (for puzzle phase - showing fragments)
        puzzleCollectionView.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        puzzleCollectionView.layer.cornerRadius = 12
        puzzleCollectionView.layer.borderWidth = 2
        puzzleCollectionView.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.6).cgColor
        puzzleCollectionView.delegate = self
        puzzleCollectionView.dataSource = self
        puzzleCollectionView.register(PuzzleFragmentCell.self, forCellWithReuseIdentifier: "FragmentCell")
        puzzleCollectionView.isScrollEnabled = false
        puzzleCollectionView.alpha = 0

        view.addSubview(puzzleCollectionView)

        puzzleCollectionView.snp.makeConstraints { fabricate in
            fabricate.centerX.equalToSuperview()
            fabricate.centerY.equalToSuperview().offset(20)
            fabricate.leading.equalToSuperview().offset(40)
            fabricate.trailing.equalToSuperview().offset(-40)
            fabricate.width.lessThanOrEqualTo(500)
            fabricate.height.equalTo(puzzleCollectionView.snp.width)
        }
    }

    private func initiateMemorizationPhase() {
        isMemorizationPhase = true
        originalTiles = []
        puzzleFragments = []

        let tilesQuantity = difficulty.gridDimension * difficulty.gridDimension

        // Generate unique tiles (no duplicates)
        var usedIdentifiers = Set<String>()
        while originalTiles.count < tilesQuantity {
            let tile = VestigeTileEntity.generateArbitraryTile()
            if !usedIdentifiers.contains(tile.identifier) {
                usedIdentifiers.insert(tile.identifier)
                originalTiles.append(tile)
            }
        }

        // Show tiles collection, hide puzzle collection
        tilesCollectionView.alpha = 1
        puzzleCollectionView.alpha = 0
        tilesCollectionView.reloadData()

        remainingTime = difficulty.memorizeInterval
        strataLabel.text = "Level \(currentStrata)"
        hintLabel.text = "Memorize these tiles!"
        countdownLabel.alpha = 1
        hintLabel.alpha = 1
        verificationButton.alpha = 0

        updateCountdownDisplay()
        initiateCountdownMechanism()
    }

    private func createFragmentsFromTiles() {
        puzzleFragments = []

        let tilesPerRow = difficulty.gridDimension
        let fragmentsPerTile = 2 // 2x2 fragments per tile

        for (tileIndex, tile) in originalTiles.enumerated() {
            guard let tileImage = UIImage(named: tile.imageDesignation) else { continue }

            let tileFragmentMatrix = FragmentationAlchemy.dissectImageIntoFragments(
                image: tileImage,
                fragmentsPerAxis: fragmentsPerTile
            )

            let tileRow = tileIndex / tilesPerRow
            let tileColumn = tileIndex % tilesPerRow

            for (fragmentRow, rowFragments) in tileFragmentMatrix.enumerated() {
                for (fragmentColumn, fragmentImage) in rowFragments.enumerated() {
                    let globalRow = tileRow * fragmentsPerTile + fragmentRow
                    let globalColumn = tileColumn * fragmentsPerTile + fragmentColumn

                    let fragment = TessellationFragment(
                        fragmentImage: fragmentImage,
                        correctRowPosition: globalRow,
                        correctColumnPosition: globalColumn,
                        currentRowPosition: globalRow,
                        currentColumnPosition: globalColumn,
                        uniqueIdentifier: UUID().uuidString
                    )

                    puzzleFragments.append(fragment)
                }
            }
        }
    }

    private func initiateCountdownMechanism() {
        countdownMechanism = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.remainingTime -= 1
            self.updateCountdownDisplay()

            if self.remainingTime <= 0 {
                self.countdownMechanism?.invalidate()
                self.transitionToPuzzlePhase()
            }
        }
    }

    private func updateCountdownDisplay() {
        countdownLabel.text = "\(remainingTime)"

        UIView.animate(withDuration: 0.2, animations: {
            self.countdownLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.countdownLabel.transform = .identity
            }
        }
    }

    private func transitionToPuzzlePhase() {
        isMemorizationPhase = false

        // Create fragments from tiles
        createFragmentsFromTiles()

        // Shuffle fragments
        puzzleFragments.shuffle()

        // Update current positions
        for (index, _) in puzzleFragments.enumerated() {
            let row = index / difficulty.puzzleFragments
            let column = index % difficulty.puzzleFragments
            puzzleFragments[index].currentRowPosition = row
            puzzleFragments[index].currentColumnPosition = column
        }

        // Animate transition - hide tiles, show puzzle
        UIView.animate(withDuration: 0.3) {
            self.countdownLabel.alpha = 0
            self.hintLabel.alpha = 0
            self.tilesCollectionView.alpha = 0
        } completion: { _ in
            self.puzzleCollectionView.reloadData()
            self.hintLabel.text = "Tap two pieces to swap positions"
            UIView.animate(withDuration: 0.3) {
                self.hintLabel.alpha = 1
                self.puzzleCollectionView.alpha = 1
                self.verificationButton.alpha = 1
            }
        }
    }

    @objc private func verificationActivated() {
        let isCorrect = validatePuzzleSolution()

        if isCorrect {
            displaySuccessDialog()
        } else {
            displayFailureDialog()
        }
    }

    private func validatePuzzleSolution() -> Bool {
        for fragment in puzzleFragments {
            if !fragment.isCorrectlyPositioned {
                return false
            }
        }
        return true
    }

    private func displaySuccessDialog() {
        let dialog = EnigmaticDialog()

        let nextAction = DialogueAction(
            inscription: "Next Level",
            aestheticStyle: .primary,
            executionHandler: { [weak self, weak dialog] in
                dialog?.dismissAnimated()
                self?.proceedToNextStrata()
            },
            uniqueIdentifier: 1
        )

        dialog.manifestWithConfiguration(
            caption: "Success!",
            description: "Congratulations! You've completed Level \(currentStrata)!",
            actions: [nextAction]
        )

        dialog.displayAnimated(on: self)
    }

    private func displayFailureDialog() {
        let dialog = EnigmaticDialog()

        let retryAction = DialogueAction(
            inscription: "Retry",
            aestheticStyle: .secondary,
            executionHandler: { [weak self, weak dialog] in
                dialog?.dismissAnimated()
                self?.navigationController?.popToRootViewController(animated: true)
            },
            uniqueIdentifier: 1
        )

        let quitAction = DialogueAction(
            inscription: "Quit",
            aestheticStyle: .destructive,
            executionHandler: { [weak self, weak dialog] in
                dialog?.dismissAnimated()
                self?.saveRecordAndReturnHome()
            },
            uniqueIdentifier: 2
        )

        dialog.manifestWithConfiguration(
            caption: "Incorrect Solution",
            description: "The puzzle is not solved correctly. You reached Level \(currentStrata).",
            actions: [retryAction, quitAction]
        )

        dialog.displayAnimated(on: self)
    }

    private func proceedToNextStrata() {
        currentStrata += 1
        selectedFragmentIndex = nil
        initiateMemorizationPhase()
    }

    private func saveRecordAndReturnHome() {
        if currentStrata > 1 {
            PersistenceVault.sharedArchive.archiveAccomplishment(mode: difficulty, strata: currentStrata)
        }
        navigationController?.popToRootViewController(animated: true)
    }

    @objc private func homeButtonActivated() {
        // Show confirmation dialog
        let dialog = EnigmaticDialog()

        let confirmAction = DialogueAction(
            inscription: "Yes, Quit",
            aestheticStyle: .destructive,
            executionHandler: { [weak self, weak dialog] in
                dialog?.dismissAnimated()
                self?.saveRecordAndReturnHome()
            },
            uniqueIdentifier: 1
        )

        let cancelAction = DialogueAction(
            inscription: "Cancel",
            aestheticStyle: .secondary,
            executionHandler: { [weak dialog] in
                dialog?.dismissAnimated()
            },
            uniqueIdentifier: 2
        )

        dialog.manifestWithConfiguration(
            caption: "Quit Game?",
            description: "Do you want to quit and return to home? Your progress will be saved.",
            actions: [confirmAction, cancelAction]
        )

        dialog.displayAnimated(on: self)
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension MnemonicChamber: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tilesCollectionView {
            return originalTiles.count
        } else {
            return puzzleFragments.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tilesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TileCell", for: indexPath) as? CompleteTileCell else {
                return UICollectionViewCell()
            }

            let tile = originalTiles[indexPath.item]
            cell.configurateWithTile(tile)
            return cell

        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FragmentCell", for: indexPath) as? PuzzleFragmentCell else {
                return UICollectionViewCell()
            }

            let fragment = puzzleFragments[indexPath.item]
            let isSelected = selectedFragmentIndex == indexPath.item
            cell.configurateWithFragment(fragment, isSelected: isSelected)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tilesCollectionView {
            let tileDimension = difficulty.gridDimension
            let totalSpacing = CGFloat(tileDimension - 1) * 8
            let availableWidth = collectionView.bounds.width - totalSpacing
            let cellWidth = availableWidth / CGFloat(tileDimension)
            return CGSize(width: cellWidth, height: cellWidth)

        } else {
            let puzzleDimension = difficulty.puzzleFragments
            let totalSpacing = CGFloat(puzzleDimension - 1) * 2
            let availableWidth = collectionView.bounds.width - totalSpacing
            let cellWidth = availableWidth / CGFloat(puzzleDimension)
            return CGSize(width: cellWidth, height: cellWidth)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == puzzleCollectionView, !isMemorizationPhase else { return }

        if let firstIndex = selectedFragmentIndex {
            // Swap fragments
            if firstIndex != indexPath.item {
                let tempFragment = puzzleFragments[firstIndex]
                puzzleFragments[firstIndex] = puzzleFragments[indexPath.item]
                puzzleFragments[indexPath.item] = tempFragment

                // Update positions
                for (index, _) in puzzleFragments.enumerated() {
                    let row = index / difficulty.puzzleFragments
                    let column = index % difficulty.puzzleFragments
                    puzzleFragments[index].currentRowPosition = row
                    puzzleFragments[index].currentColumnPosition = column
                }
            }

            selectedFragmentIndex = nil
            collectionView.reloadData()
        } else {
            selectedFragmentIndex = indexPath.item
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - Complete Tile Cell (for memorization phase)
class CompleteTileCell: UICollectionViewCell {

    private let tileImageVessel = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        orchestrateInterface()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func orchestrateInterface() {
        backgroundColor = .clear
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8

        tileImageVessel.contentMode = .scaleAspectFit
        tileImageVessel.clipsToBounds = true
        tileImageVessel.layer.cornerRadius = 8
        tileImageVessel.backgroundColor = UIColor(white: 0.95, alpha: 1.0)

        contentView.addSubview(tileImageVessel)

        tileImageVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }
    }

    func configurateWithTile(_ tile: VestigeTileEntity) {
        tileImageVessel.image = UIImage(named: tile.imageDesignation)
    }
}

// MARK: - Puzzle Fragment Cell (for puzzle phase)
class PuzzleFragmentCell: UICollectionViewCell {

    private let fragmentImageVessel = UIImageView()
    private let selectionIndicator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        orchestrateInterface()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func orchestrateInterface() {
        backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.3).cgColor

        fragmentImageVessel.contentMode = .scaleAspectFill
        fragmentImageVessel.clipsToBounds = true

        contentView.addSubview(fragmentImageVessel)

        fragmentImageVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }

        // Selection indicator
        selectionIndicator.backgroundColor = .clear
        selectionIndicator.layer.borderWidth = 3
        selectionIndicator.layer.borderColor = UIColor.systemYellow.cgColor
        selectionIndicator.layer.cornerRadius = 4
        selectionIndicator.isHidden = true

        contentView.addSubview(selectionIndicator)

        selectionIndicator.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }
    }

    func configurateWithFragment(_ fragment: TessellationFragment, isSelected: Bool) {
        fragmentImageVessel.image = fragment.fragmentImage
        selectionIndicator.isHidden = !isSelected
    }
}
