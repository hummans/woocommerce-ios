import Foundation
import UIKit
import Yosemite


/// Abstracts the datasource used to render the Product Review list
protocol ReviewsDataSource: UITableViewDataSource, UITableViewDelegate {

    /// Boolean indicating if there are reviews
    ///
    var isEmpty: Bool { get }

    /// Identifiers of the Products mentioned in the reviews.
    /// Guaranteed to be uniqued (does not contain duplicates)
    ///
    var reviewsProductsIDs: [Int] { get }

    /// Initializes observers for incoming reviews
    ///
    func observeReviews() throws

    /// Starts forwarding events to the tableview
    ///
    func startForwardingEvents(to tableView: UITableView)

    /// Cancels forwarding events to any previously registered table view
    ///
    func stopForwardingEvents()
}