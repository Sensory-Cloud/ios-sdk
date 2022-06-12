//
//  HexUtils.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/10/22.
//

import Foundation

extension StringProtocol {
    var hexData: Data { .init(hexa) }
    var hexBytes: [UInt8] { .init(hexa) }

    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

extension Data {
    func toHexString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
