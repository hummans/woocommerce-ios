import XCTest
import Yosemite

import protocol Storage.StorageType

@testable import WooCommerce


/// StoresManager Unit Tests
///
final class CrashingResultsControllerUIKitTests: XCTestCase {

    /// Mockup StorageManager
    ///
    private var storageManager: MockupStorageManager!

    /// Mockup TableView
    ///
    private var tableView: MockupTableView!

    /// Sample ResultsController
    ///
    private var resultsController: ResultsController<StorageAccount>!

    private var viewStorage: StorageType {
        storageManager.viewStorage
    }

    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        storageManager = MockupStorageManager()
    }

    override func tearDown() {
        tableView.dataSource = nil
        tableView = nil
        resultsController = nil
        storageManager = nil
        super.tearDown()
    }

    func testMagic() {
        // Given
        let window = UIWindow()
        window.isHidden = false

        resultsController = {
            let viewStorage = storageManager.viewStorage
            let sectionNameKeyPath = "username"
            let descriptor = NSSortDescriptor(keyPath: \StorageAccount.userID, ascending: false)

            return ResultsController<StorageAccount>(
                viewStorage: viewStorage,
                sectionNameKeyPath: sectionNameKeyPath,
                sortedBy: [descriptor]
            )
        }()

        // Add data before performFetch()
        insertAccount(section: "Alpha", userID: 8_900)

        // Simulate a ViewController being added to the stack
        let rootVC = UIViewController()
        tableView = MockupTableView()
        rootVC.view.addSubview(tableView)
        window.rootViewController = rootVC

        tableView.dataSource = self

        // Bind ResultsController with UITableView
        resultsController.startForwardingEvents(to: tableView)
        try! resultsController.performFetch()

        // Adding reloadData after performFetch() fixes the crash
        // tableView.reloadData()

        // When
        insertAccount(section: "Alpha", userID: 8_000)

        saveAndWaitForTableViewOnEndUpdates()

        // Then
        // Boom!
    }
}

// MARK: - UITableViewDataSource

extension CrashingResultsControllerUIKitTests: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        resultsController.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resultsController.sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

// MARK: - Utils

private extension CrashingResultsControllerUIKitTests {
    /// Create an account belonging to a section.
    ///
    /// The `section` is really just the `username`. This is just how we configured it in `setUp()`.
    ///
    @discardableResult
    func insertAccount(section username: String, userID: Int64) -> StorageAccount {
        let account = storageManager.insertSampleAccount()
        account.username = username
        account.userID = userID
        return account
    }

    /// Save the `viewStorage` and wait for `self.tableView`'s `onEndUpdates` (cell animations)
    /// to be called.
    ///
    func saveAndWaitForTableViewOnEndUpdates() {
        let expectOnEndUpdates = self.expectation(description: "wait for onEndUpdates")
        tableView.onEndUpdates = {
            expectOnEndUpdates.fulfill()
        }

        viewStorage.saveIfNeeded()

        wait(for: [expectOnEndUpdates], timeout: Constants.expectationTimeout)
    }
}
