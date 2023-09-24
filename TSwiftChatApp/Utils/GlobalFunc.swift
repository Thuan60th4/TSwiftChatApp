//
//  GlobalFunc.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 17/09/2023.
//

import Foundation


func fileNameFrom(_ fileUrl: String) -> String? {
    return fileUrl.components(separatedBy: "_").last?.components(separatedBy: ".jpg").first
}
