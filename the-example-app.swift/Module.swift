
import Foundation
import Contentful

class Module: Resource, StatefulResource {

    let sys: Sys

    init(sys: Sys) {
        self.sys = sys
    }
    
    var state = ResourceState.upToDate
}
