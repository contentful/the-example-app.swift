//
//  Copyright © 2020 Contentful. All rights reserved.
//

/// An enumeration to define what editorial state an entry or asset is in.
///
/// - upToDate: The resource is published: the entry has the exact same data when fetched from CDA as when fetched from CPA.
/// - draft: The resource has not yet been published.
/// - pendingChanges: The resource is published, but there are changes available in the CPA that are not yet available on the CDA.
/// - draftAndPendingChanges: A composite state that a `Lesson` or a `HomeLayout` instance may have if any of it's linked modules has `draft` and `pendingChanges` states.
enum ResourceState {
    case upToDate
    case draft
    case pendingChanges
    case draftAndPendingChanges
}
