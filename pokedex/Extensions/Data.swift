//
//  Data.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import Foundation

extension Data {
    func parseData(removeString string: String ) -> Data? {
        let dataAsString = String(data: self, encoding: .utf8)
        let parseDataString = dataAsString?.replacingOccurrences(of: string, with: "")
        guard let data = parseDataString?.data(using: .utf8) else {
            return nil }
        return data
    }
}
