//
//  StringExtension.swift
//  STTR
//
//  Created by Brady  on 4/23/21.
//

import Foundation

extension String{
    var withoutHTMLTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
