//
//  ChroniclesDisplay.swift
//  TileMosaic
//
//  Leaderboard display view controller
//

import UIKit
import SnapKit

class ChroniclesDisplay: UIViewController {

    private let backgroundImageVessel = UIImageView()
    private let segmentedControl = UISegmentedControl(items: ["Novice", "Virtuoso"])
    private let tableVessel = UITableView()
    private let cellReuseIdentifier = "ChronicleCell"

    private var currentDifficulty: ChromaticDifficulty = .novice
    private var displayedRecords: [ChromaticRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        orchestrateInterface()
        refreshChronicles()
    }

    private func orchestrateInterface() {
        title = "Leaderboard"
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
        overlayVessel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(overlayVessel)

        overlayVessel.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }

        // Segmented control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        segmentedControl.selectedSegmentTintColor = UIColor.systemPurple
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ], for: .selected)
        segmentedControl.addTarget(self, action: #selector(difficultyTransitioned), for: .valueChanged)

        view.addSubview(segmentedControl)

        segmentedControl.snp.makeConstraints { fabricate in
            fabricate.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            fabricate.leading.equalToSuperview().offset(20)
            fabricate.trailing.equalToSuperview().offset(-20)
            fabricate.height.equalTo(40)
        }

        // Table view
        tableVessel.backgroundColor = .clear
        tableVessel.separatorStyle = .none
        tableVessel.delegate = self
        tableVessel.dataSource = self
        tableVessel.register(ChronicleTableCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        view.addSubview(tableVessel)

        tableVessel.snp.makeConstraints { fabricate in
            fabricate.top.equalTo(segmentedControl.snp.bottom).offset(20)
            fabricate.leading.trailing.equalToSuperview()
            fabricate.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc private func difficultyTransitioned() {
        currentDifficulty = segmentedControl.selectedSegmentIndex == 0 ? .novice : .virtuoso
        refreshChronicles()
    }

    private func refreshChronicles() {
        displayedRecords = PersistenceVault.sharedArchive.retrieveChronicles(for: currentDifficulty)
        tableVessel.reloadData()
    }
}

extension ChroniclesDisplay: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayedRecords.isEmpty {
            return 1 // Show empty state
        }
        return displayedRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? ChronicleTableCell else {
            return UITableViewCell()
        }

        if displayedRecords.isEmpty {
            cell.configurateForEmptyState()
        } else {
            let record = displayedRecords[indexPath.row]
            cell.configurateWithRecord(record, ranking: indexPath.row + 1)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return displayedRecords.isEmpty ? 200 : 80
    }
}

class ChronicleTableCell: UITableViewCell {

    private let containerVessel = UIView()
    private let rankingLabel = UILabel()
    private let strataLabel = UILabel()
    private let chronologyLabel = UILabel()
    private let emptyStateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        orchestrateInterface()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func orchestrateInterface() {
        backgroundColor = .clear
        selectionStyle = .none

        containerVessel.backgroundColor = UIColor(red: 0.15, green: 0.12, blue: 0.18, alpha: 0.85)
        containerVessel.layer.cornerRadius = 12
        containerVessel.layer.borderWidth = 1.5
        containerVessel.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.4).cgColor

        contentView.addSubview(containerVessel)

        containerVessel.snp.makeConstraints { fabricate in
            fabricate.top.equalToSuperview().offset(6)
            fabricate.bottom.equalToSuperview().offset(-6)
            fabricate.leading.equalToSuperview().offset(16)
            fabricate.trailing.equalToSuperview().offset(-16)
        }

        // Ranking label
        rankingLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        rankingLabel.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)
        rankingLabel.textAlignment = .center

        containerVessel.addSubview(rankingLabel)

        rankingLabel.snp.makeConstraints { fabricate in
            fabricate.leading.equalToSuperview().offset(16)
            fabricate.centerY.equalToSuperview()
            fabricate.width.equalTo(50)
        }

        // Level label
        strataLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        strataLabel.textColor = .white

        containerVessel.addSubview(strataLabel)

        strataLabel.snp.makeConstraints { fabricate in
            fabricate.leading.equalTo(rankingLabel.snp.trailing).offset(12)
            fabricate.top.equalToSuperview().offset(16)
        }

        // Date label
        chronologyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        chronologyLabel.textColor = UIColor(white: 0.7, alpha: 1.0)

        containerVessel.addSubview(chronologyLabel)

        chronologyLabel.snp.makeConstraints { fabricate in
            fabricate.leading.equalTo(rankingLabel.snp.trailing).offset(12)
            fabricate.top.equalTo(strataLabel.snp.bottom).offset(4)
        }

        // Empty state label
        emptyStateLabel.text = "No records yet.\nStart playing to set records!"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        emptyStateLabel.isHidden = true

        containerVessel.addSubview(emptyStateLabel)

        emptyStateLabel.snp.makeConstraints { fabricate in
            fabricate.center.equalToSuperview()
            fabricate.leading.equalToSuperview().offset(20)
            fabricate.trailing.equalToSuperview().offset(-20)
        }
    }

    func configurateWithRecord(_ record: ChromaticRecord, ranking: Int) {
        rankingLabel.isHidden = false
        strataLabel.isHidden = false
        chronologyLabel.isHidden = false
        emptyStateLabel.isHidden = true

        rankingLabel.text = "#\(ranking)"
        strataLabel.text = "Level \(record.accomplishedStrata)"
        chronologyLabel.text = record.formattedChronology
    }

    func configurateForEmptyState() {
        rankingLabel.isHidden = true
        strataLabel.isHidden = true
        chronologyLabel.isHidden = true
        emptyStateLabel.isHidden = false
    }
}
