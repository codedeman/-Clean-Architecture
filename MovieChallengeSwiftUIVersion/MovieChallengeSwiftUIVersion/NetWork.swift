//
//  NetWork.swift
//  MovieChallengeSwiftUIVersion
//
//  Created by Kevin on 4/4/24.
//

import Foundation
import Combine
import CommonCrypto
import Security
import CommonCrypto


protocol NetWorkLayerProtocol {
     func searchBooks(matching searchTerm: String) -> AnyPublisher<[SearchModel], Never>
}

final class NetWork: NSObject, NetWorkLayerProtocol {

    private var pinnedPublicKeyHash = "a1a84e956b70079354ef4060a95930597923e4c53f81fe7298614a091d130f5a"
    private var pinnedCertificateHash = "08dc3114fd05a6f12a48f76a76a4f43d5fe7c3be171d9ec0d303375a5d18c82c"
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]


    private func sha256(data: Data) -> String {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).map { String(format: "%02hhx", $0) }.joined()
    }


    func searchBooks(matching searchTerm: String) -> AnyPublisher<[SearchModel], Never> {
        let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let rootURL = "https://www.omdbapi.com/?s="
        let key = "&apikey=b831f50c"
        let urlString = rootURL + "Rrr" + key
        let url = URL(string: urlString)!

        return session.dataTaskPublisher(for: url)
          .map { ouput in
              return ouput.data
          }
          .decode(type: MovieResponse.self, decoder: JSONDecoder())
          .map(\.Search)
          .replaceError(with: [SearchModel]())
          .eraseToAnyPublisher()

    }

}

extension NetWork: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {

            var error: CFError?
            if SecTrustEvaluateWithError(serverTrust, &error) {
                if let certificateChain = SecTrustCopyCertificateChain(serverTrust) {
                    for index in 0..<CFArrayGetCount(certificateChain) {
                        if let certificate = CFArrayGetValueAtIndex(certificateChain, index) {
                            let certRef = Unmanaged<SecCertificate>.fromOpaque(certificate).takeUnretainedValue()
                            let serverPublicKey = SecCertificateCopyKey(certRef)
                            let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )! as Data
                            let keyHash = sha256(data: serverPublicKeyData)
                            if keyHash == pinnedPublicKeyHash {
                                // Success! This is our server
                                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                                return
                            } else {
                                print("Error detected")
                            }
                        }
                    }
                } else {
                    print("Error getting certificate chain")
                }
            } else {
                if let error = error {
                    print("Error evaluating server trust: \(error)")
                } else {
                    print("Error evaluating server trust")
                }
            }
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
    }

}
