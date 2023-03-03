import SwiftUI

// MARK: - ___FILEBASENAME___

/// A coordinator that handles navigation
///
final class ___FILEBASENAME___: <#Coordinator#> {
    // MARK: Properties

    /// The module used by the coordinator to create its objects.
    private let module: <#Module#>

    /// The navigator managed by this coordinator.
    private weak var navigator: <#StackNavigator#>

    /// The services used by this coordinator.
    private let services: <#Services#>

    // MARK: Initialization

    /// Initializes a `ExploreCoordinator`.
    ///
    /// - Parameters:
    ///   - module: The module used by the coordinator to create its objects.
    ///   - navigator: The navigator managed by this coordinator.
    ///   - services: The services used by this coordinator.
    init(
        module: <#Module#>,
        navigator: <#StackNavigator?#>,
        services: <#Services#>
    ) {
        self.module = module
        self.navigator = navigator
        self.services = services
    }

    // MARK: Coordinator

    func start() {}

    func navigate(to route: <#Route#>, context: AnyObject?) {
        switch route {
        default:
            break
        }
    }
}
