// MARK: - ___VARIABLE_productName:identifier___Processor

/// The `___VARIABLE_productName:identifier___Processor` receives `___VARIABLE_productName:identifier___Action`
/// values from a view, and makes appropriate changes to the `___VARIABLE_productName:identifier___State`.
///  <#Describe the feature, it's roll, and location within the app.#>
final class ___VARIABLE_productName:identifier___Processor: StateProcessor<___VARIABLE_productName:identifier___Action, ___VARIABLE_productName:identifier___State, ___VARIABLE_productName:identifier___Effect> {
    typealias Services =
        <#Service Types#>

    // MARK: Properties

    /// The coordinator used for navigation.
    private let coordinator: AnyCoordinator<<#Route#>>

    /// The services used by the processor.
    private let services: Services

    /// Initializes an `___VARIABLE_productName:identifier___Processor`.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator used for navigation.
    ///   - services: The services used by the processor.
    init(
        coordinator: AnyCoordinator<<#Route#>>,
        services: Services
    ) {
        self.coordinator = coordinator
        self.services = services

        <#Super.init with the State here if needed#>
    }

    override func perform(_ effect: ___VARIABLE_productName:identifier___Effect) async {
        switch effect {
        default: break
        }
    }

    override func receive(_ action: ___VARIABLE_productName:identifier___Action) {
        switch action {
        default: break
        }
    }
}
