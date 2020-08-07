//
//  Copyright © 2020 Contentful. All rights reserved.
//

import Contentful

/// A resource which has it's state.
protocol StatefulResource: class {
    var state: ResourceState { get set }
}
