import UIKit

// TODO: add description

class FeatureIntroductionViewController: CollapsableHeaderViewController {

    // MARK: - Properties

    private let scrollView: UIScrollView

    // View added to scrollView that contains specific Feature Introduction content.
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    // MARK: - Init

    init() {
        scrollView = {
            let scrollView = UIScrollView()
            scrollView.showsVerticalScrollIndicator = false
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            return scrollView
        }()

        super.init(
            scrollableView: scrollView,
            mainTitle: Strings.headerTitle,
            prompt: Strings.headerSubtitle,
            // TODO: update the button titles once the buttons are customized for Feature Introduction.
            primaryActionTitle: "",
            defaultActionTitle: Strings.primaryActionTitle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func navigationController() -> UINavigationController {
        let controller = FeatureIntroductionViewController()
        let navController = UINavigationController(rootViewController: controller)
        return navController
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

}

private extension FeatureIntroductionViewController {

    func configureView() {
        navigationItem.rightBarButtonItem = CollapsableHeaderViewController.closeButton(target: self, action: #selector(closeButtonTapped))
        scrollView.addSubview(contentView)
        scrollView.pinSubviewToAllEdges(contentView)
    }

    @IBAction func closeButtonTapped() {
        dismiss(animated: true)
    }

    enum Strings {
        static let headerTitle: String = NSLocalizedString("Introducing Prompts", comment: "Title displayed on the feature introduction view.")
        static let headerSubtitle: String = NSLocalizedString("The best way to become a better writer is to build a writing habit and share with others - that’s where Prompts come in!", comment: "Subtitle displayed on the feature introduction view.")
        static let primaryActionTitle: String = NSLocalizedString("Try it now", comment: "Primary button title on the feature introduction view.")
    }

}
