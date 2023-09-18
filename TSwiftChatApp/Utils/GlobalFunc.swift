//
//  GlobalFunc.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 17/09/2023.
//

import Foundation


func fileNameFrom(_ fileUrl: String) -> String? {
    let regex = #"_([^_]+)\.jpg"#
    
    if let range = fileUrl.range(of: regex, options: .regularExpression) {
        let result = fileUrl[range].dropFirst()
        return String(result)
    }
    
    return nil
}
