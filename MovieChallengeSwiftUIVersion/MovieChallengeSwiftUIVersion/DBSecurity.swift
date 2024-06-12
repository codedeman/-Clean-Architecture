//
//  DBSecurity.swift
//  MovieChallengeSwiftUIVersion
//
//  Created by Kevin on 6/12/24.
//

import Foundation

import Alamofire
import CommonCrypto

public final class DBSSLPinningEvaluator: ServerTrustEvaluating {
    private let localPublicHashKeys: Set<String>

//    private let rsa2048Asn1Header: [UInt8] = [
//        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
//        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00,
//    ]
    let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    public init(localPublicHashKeys: Set<String>) {
        self.localPublicHashKeys = localPublicHashKeys
    }

    private func sha256(data: Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(keyWithHeader.count), &hash)
        }

        return Data(hash).base64EncodedString()
    }

    public func evaluate(_ trust: SecTrust, forHost host: String) throws {
        let serverHashKeys: [String] = trust.af.publicKeys.compactMap { secKey in
            guard let serverPublicKeyData = SecKeyCopyExternalRepresentation(secKey, nil) else {
                return nil
            }
            return sha256(data: serverPublicKeyData as Data)
        }

        guard !serverHashKeys.isEmpty else {
            print("SSL pinning failed due to no server public keys found, host: \(host)")
            throw AFError.serverTrustEvaluationFailed(reason: .noPublicKeysFound)
        }

        if !isSSLPinned(
            withLocalHashKeys: localPublicHashKeys,
            compareToServerHashKeys: serverHashKeys
        ) {
            print("SSL pinning failed due to keys not matching, host: \(host), server hash keys: \(serverHashKeys)")
            throw AFError.serverTrustEvaluationFailed(reason: .trustEvaluationFailed(error: nil))
        }
    }

    private func isSSLPinned(
        withLocalHashKeys localPublicHashKeys: Set<String>,
        compareToServerHashKeys serverHashKeys: [String]
    ) -> Bool {
        return localPublicHashKeys.first { serverHashKeys.contains($0) } != nil
    }
}
