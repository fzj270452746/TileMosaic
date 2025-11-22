//
//  TessellationAssembly.swift
//  TileMosaic
//
//  Puzzle assembly view controller with drag & drop
//

import UIKit
import SnapKit

class TessellationAssembly: UIViewController {

    private let backgroundImageVessel = UIImageView()
    private let strataLabel = UILabel()
    private let puzzleCollectionView: UICollectionView
    private let verificationButton = UIButton(type: .system)

    private let difficulty: ChromaticDifficulty
    private let originalTiles: [VestigeTileEntity]
    private let currentStrata: Int

    private var puzzleFragments: [[TessellationFragment]] = []
    private var fragmentsFlattened: [TessellationFragment] = []

    init(difficulty: ChromaticDifficulty, tiles: [VestigeTileEntity], strata: Int) {
        self.difficulty = difficulty
        self.originalTiles = tiles
        self.currentStrata = strata

        let layoutConfiguration = UICollectionViewFlowLayout()
        layoutConfiguration.minimumInteritemSpacing = 2
        layoutConfiguration.minimumLineSpacing = 2
        self.puzzleCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutConfiguration)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        orchestrateInterface()
        generatePuzzleFragments()
    }

    private func orchestrateInterface() {
        navigationItem.hidesBackButton = true

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
            fabricate.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            fabricate.centerX.equalToSuperview()
        }

        // Collection view
        puzzleCollectionView.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        puzzleCollectionView.layer.cornerRadius = 12
        puzzleCollectionView.layer.borderWidth = 2
        puzzleCollectionView.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.6).cgColor
        puzzleCollectionView.delegate = self
        puzzleCollectionView.dataSource = self
        puzzleCollectionView.register(FragmentDisplayCell.self, forCellWithReuseIdentifier: "FragmentCell")
        puzzleCollectionView.isScrollEnabled = false
        puzzleCollectionView.dragDelegate = self
        puzzleCollectionView.dropDelegate = self
        puzzleCollectionView.dragInteractionEnabled = true

        view.addSubview(puzzleCollectionView)

        let puzzleDimension = difficulty.puzzleFragments
        let cellSize: CGFloat = (UIScreen.main.bounds.width - 80 - CGFloat(puzzleDimension - 1) * 2) / CGFloat(puzzleDimension)
        let totalHeight = cellSize * CGFloat(puzzleDimension) + 2 * CGFloat(puzzleDimension - 1)

        puzzleCollectionView.snp.makeConstraints { fabricate in
            fabricate.center.equalToSuperview()
            fabricate.leading.equalToSuperview().offset(40)
            fabricate.trailing.equalToSuperview().offset(-40)
            fabricate.height.equalTo(totalHeight)
        }

        // Verification button
        verificationButton.setTitle("Verify Solution", for: .normal)
        verificationButton.backgroundColor = UIColor.systemGreen
        verificationButton.setTitleColor(.white, for: .normal)
        verificationButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        verificationButton.layer.cornerRadius = 16
        verificationButton.layer.shadowColor = UIColor.systemGreen.cgColor
        verificationButton.layer.shadowOpacity = 0.6
        verificationButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        verificationButton.layer.shadowRadius = 12
        verificationButton.addTarget(self, action: #selector(verificationActivated), for: .touchUpInside)

        view.addSubview(verificationButton)

        verificationButton.snp.makeConstraints { fabricate in
            fabricate.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            fabricate.centerX.equalToSuperview()
            fabricate.width.equalTo(280)
            fabricate.height.equalTo(60)
        }
    }

    private func generatePuzzleFragments() {
        puzzleFragments = []
        fragmentsFlattened = []

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

                    fragmentsFlattened.append(fragment)
                }
            }
        }

        // Shuffle fragments
        fragmentsFlattened.shuffle()

        // Update current positions
        for (index, _) in fragmentsFlattened.enumerated() {
            let row = index / difficulty.puzzleFragments
            let column = index % difficulty.puzzleFragments
            fragmentsFlattened[index].currentRowPosition = row
            fragmentsFlattened[index].currentColumnPosition = column
        }

        puzzleCollectionView.reloadData()
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
        for fragment in fragmentsFlattened {
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
        let nextStrata = currentStrata + 1
        let memorizationPortal = MnemonicChamber(difficulty: difficulty)
        memorizationPortal.currentStrata = nextStrata

        // Replace current view controllers
        if let navController = navigationController {
            var viewControllers = navController.viewControllers
            // Keep only the root (home) view controller
            if viewControllers.count > 0 {
                viewControllers = [viewControllers[0], memorizationPortal]
                navController.setViewControllers(viewControllers, animated: true)
            }
        }
    }

    private func saveRecordAndReturnHome() {
        if currentStrata > 1 {
            PersistenceVault.sharedArchive.archiveAccomplishment(mode: difficulty, strata: currentStrata)
        }
        navigationController?.popToRootViewController(animated: true)
    }
}

extension TessellationAssembly: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fragmentsFlattened.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FragmentCell", for: indexPath) as? FragmentDisplayCell else {
            return UICollectionViewCell()
        }

        let fragment = fragmentsFlattened[indexPath.item]
        cell.configurateWithFragment(fragment)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let puzzleDimension = difficulty.puzzleFragments
        let totalSpacing = CGFloat(puzzleDimension - 1) * 2
        let availableWidth = collectionView.bounds.width - totalSpacing
        let cellWidth = availableWidth / CGFloat(puzzleDimension)

        return CGSize(width: cellWidth, height: cellWidth)
    }
}

// MARK: - Drag & Drop Support
extension TessellationAssembly: UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let fragment = fragmentsFlattened[indexPath.item]
        let itemProvider = NSItemProvider(object: fragment.uniqueIdentifier as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = fragment
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath else {
            return
        }

        collectionView.performBatchUpdates({
            let movedFragment = fragmentsFlattened.remove(at: sourceIndexPath.item)
            fragmentsFlattened.insert(movedFragment, at: destinationIndexPath.item)

            // Update current positions
            for (index, _) in fragmentsFlattened.enumerated() {
                let row = index / difficulty.puzzleFragments
                let column = index % difficulty.puzzleFragments
                fragmentsFlattened[index].currentRowPosition = row
                fragmentsFlattened[index].currentColumnPosition = column
            }

            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        })

        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }
}

class FragmentDisplayCell: UICollectionViewCell {

    private let fragmentImageVessel = UIImageView()

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
    }

    func configurateWithFragment(_ fragment: TessellationFragment) {
        fragmentImageVessel.image = fragment.fragmentImage
    }
}

