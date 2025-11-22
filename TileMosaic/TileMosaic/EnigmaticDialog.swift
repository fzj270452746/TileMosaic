//
//  EnigmaticDialog.swift
//  TileMosaic
//
//  Custom alert dialog with modern design
//

import UIKit
import SnapKit

class EnigmaticDialog: UIView {

    private let containerVessel = UIView()
    private let captionLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let actionStackView = UIStackView()

    private var dismissalCallback: (() -> Void)?
    private var actionHandlers: [Int: () -> Void] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        orchestrateInterface()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func orchestrateInterface() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        alpha = 0

        // Container styling
        containerVessel.backgroundColor = UIColor(red: 0.15, green: 0.12, blue: 0.18, alpha: 0.98)
        containerVessel.layer.cornerRadius = 20
        containerVessel.layer.shadowColor = UIColor.systemPurple.cgColor
        containerVessel.layer.shadowOpacity = 0.6
        containerVessel.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerVessel.layer.shadowRadius = 16
        containerVessel.layer.borderWidth = 2
        containerVessel.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.3).cgColor

        addSubview(containerVessel)

        // Title label styling
        captionLabel.textAlignment = .center
        captionLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        captionLabel.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)
        captionLabel.numberOfLines = 0

        containerVessel.addSubview(captionLabel)

        // Description label styling
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = UIColor(white: 0.9, alpha: 1.0)
        descriptionLabel.numberOfLines = 0

        containerVessel.addSubview(descriptionLabel)

        // Action stack view
        actionStackView.axis = .horizontal
        actionStackView.spacing = 12
        actionStackView.distribution = .fillEqually

        containerVessel.addSubview(actionStackView)

        // Layout
        containerVessel.snp.makeConstraints { fabricate in
            fabricate.center.equalToSuperview()
            fabricate.leading.equalToSuperview().offset(40)
            fabricate.trailing.equalToSuperview().offset(-40)
        }

        captionLabel.snp.makeConstraints { fabricate in
            fabricate.top.equalToSuperview().offset(28)
            fabricate.leading.equalToSuperview().offset(24)
            fabricate.trailing.equalToSuperview().offset(-24)
        }

        descriptionLabel.snp.makeConstraints { fabricate in
            fabricate.top.equalTo(captionLabel.snp.bottom).offset(16)
            fabricate.leading.equalToSuperview().offset(24)
            fabricate.trailing.equalToSuperview().offset(-24)
        }

        actionStackView.snp.makeConstraints { fabricate in
            fabricate.top.equalTo(descriptionLabel.snp.bottom).offset(28)
            fabricate.leading.equalToSuperview().offset(24)
            fabricate.trailing.equalToSuperview().offset(-24)
            fabricate.bottom.equalToSuperview().offset(-24)
            fabricate.height.equalTo(50)
        }
    }

    func manifestWithConfiguration(caption: String, description: String, actions: [DialogueAction]) {
        captionLabel.text = caption
        descriptionLabel.text = description

        actionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        actionHandlers.removeAll()

        for action in actions {
            actionHandlers[action.uniqueIdentifier] = action.executionHandler
            let buttonElement = createStylizedButton(action: action)
            actionStackView.addArrangedSubview(buttonElement)
        }
    }

    private func createStylizedButton(action: DialogueAction) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(action.inscription, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12

        switch action.aestheticStyle {
        case .primary:
            button.backgroundColor = UIColor.systemPurple
            button.setTitleColor(.white, for: .normal)
            button.layer.shadowColor = UIColor.systemPurple.cgColor
            button.layer.shadowOpacity = 0.4
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.shadowRadius = 8
        case .secondary:
            button.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
            button.setTitleColor(UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0), for: .normal)
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.5).cgColor
        case .destructive:
            button.backgroundColor = UIColor.systemRed
            button.setTitleColor(.white, for: .normal)
            button.layer.shadowColor = UIColor.systemRed.cgColor
            button.layer.shadowOpacity = 0.4
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.shadowRadius = 8
        }

        button.addTarget(self, action: #selector(buttonActivated(_:)), for: .touchUpInside)
        button.tag = action.uniqueIdentifier

        return button
    }

    @objc private func buttonActivated(_ sender: UIButton) {
        let handler = actionHandlers[sender.tag]
        handler?()
    }

    func displayAnimated(on viewController: UIViewController) {
        guard let window = viewController.view.window else { return }

        window.addSubview(self)
        self.snp.makeConstraints { fabricate in
            fabricate.edges.equalToSuperview()
        }

        containerVessel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.alpha = 1.0
            self.containerVessel.transform = .identity
        }
    }

    func dismissAnimated() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.containerVessel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
            self.dismissalCallback?()
        }
    }

    func onDismissalExecute(_ callback: @escaping () -> Void) {
        dismissalCallback = callback
    }
}

// Dialog action configuration
struct DialogueAction {
    let inscription: String
    let aestheticStyle: ActionAesthetic
    let executionHandler: () -> Void
    let uniqueIdentifier: Int

    enum ActionAesthetic {
        case primary
        case secondary
        case destructive
    }
}
