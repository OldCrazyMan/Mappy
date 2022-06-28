//
//  Extension + String.swift
//  Mappy
//
//  Created by Тim Akhm on 27.06.2022.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
