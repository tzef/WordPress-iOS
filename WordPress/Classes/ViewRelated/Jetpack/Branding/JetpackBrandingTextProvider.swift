import Foundation

struct JetpackBrandingTextProvider {

    // MARK: Private Variables

    private let featureFlagStore: RemoteFeatureFlagStore

    private var phase: JetpackFeaturesRemovalCoordinator.GeneralPhase {
        return JetpackFeaturesRemovalCoordinator.generalPhase(featureFlagStore: featureFlagStore)
    }

    // MARK: Initializer

    init(featureFlagStore: RemoteFeatureFlagStore = RemoteFeatureFlagStore()) {
        self.featureFlagStore = featureFlagStore
    }

    // MARK: Public Functions

    func brandingText() -> String {
        switch phase {
        case .two:
            return Strings.phaseTwoText
        default:
            return Strings.defaultText
        }
    }
}

private extension JetpackBrandingTextProvider {
    enum Strings {
        static let defaultText = NSLocalizedString("jetpack.branding.badge_banner.title",
                                                   value: "Jetpack powered",
                                                   comment: "Title of the Jetpack powered badge.")
        static let phaseTwoText = NSLocalizedString("jetpack.branding.badge_banner.title.phase2",
                                                    value: "Get the Jetpack app",
                                                    comment: "Title of the Jetpack powered badge.")
    }
}
