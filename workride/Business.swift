//
//  Business.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-07-04.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import CoreLocation

class Business {
    var uid = ""
    var locationid = ""
    var name = ""
    var location = CLLocationCoordinate2D()
    
    var allLocations : [BusinessLocation] = []
}

class BusinessLocation {
    var descriptor = ""
    var locationid = ""
}
