//
//  GetDistance.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-07-13.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import CoreLocation


func GetDistance(_ locationA: CLLocationCoordinate2D, locationB: CLLocationCoordinate2D) -> Double {
    
    
    let phi1 = convertToRadianAngle(Double(locationA.latitude))
    let phi2 = convertToRadianAngle(Double(locationB.latitude))
    let deltaPhi = convertToRadianAngle(Double(locationA.latitude - locationB.latitude))
    let deltaLambda = convertToRadianAngle(Double(locationA.longitude - locationB.longitude))
    
    let a = sin(deltaPhi / 2.0) * sin(deltaPhi / 2.0) + cos(phi1) * cos(phi2) * sin(deltaLambda / 2.0) * sin(deltaLambda / 2.0)
    
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    
    let distance = 6_371_000 * c
    
    return distance
}

func convertToRadianAngle(_ angleInDegrees: Double) -> Double {
    return angleInDegrees * 3.1416 / 180.0
}
