//
//  StringExtension.swift
//  STTR
//
//  Created by Brady  on 4/23/21.
//

import Foundation

//string extension used to replace some html tags with nothing
extension String{
    var withoutHTMLTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
