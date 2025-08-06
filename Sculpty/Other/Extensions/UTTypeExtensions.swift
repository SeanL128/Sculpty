//
//  UTTypeExtensions.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import UniformTypeIdentifiers

extension UTType {
    static var sculptyData: UTType {
        UTType(exportedAs: "app.sculpty.SculptyApp.sculptydata")
    }
}
