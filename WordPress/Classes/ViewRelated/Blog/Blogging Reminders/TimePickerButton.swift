import UIKit

class TimePickerButton: UIButton {

    private(set) var selectedTime: String {
        didSet {
            timeLabel.text = selectedTime
        }
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .divider : .basicBackground
            setNeedsDisplay()
        }
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .horizontal
        return stackView
    }()

    private lazy var pickerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.text = Constants.title
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.text = selectedTime
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var chevron: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.gridicon(.chevronRight)
        imageView.tintColor = .divider
        return imageView
    }()

    private lazy var chavronStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubviews([UIView(), chevron, UIView()])
        return stackView
    }()

    private func configureStackView() {
        stackView.addArrangedSubviews([pickerTitleLabel, UIView(), timeLabel, chavronStackView])
    }

    init(selectedTime: String) {
        self.selectedTime = selectedTime
        super.init(frame: .zero)
        configureStackView()
        addSubview(stackView)
        pinSubviewToAllEdges(stackView, insets: Constants.insets)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelectedTime(_ selectedTime: String) {
        self.selectedTime = selectedTime
    }

    enum Constants {
        static let title = NSLocalizedString("Notification time", comment: "Title for the time picker button in Blogging Reminders.")
        static let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
