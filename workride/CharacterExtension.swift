//
//  CharacterExtension.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-05-30.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

extension Character
{
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}
