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

protocol NetWorkLayerProtocol {
     func searchBooks(matching searchTerm: String) -> AnyPublisher<[SearchModel], Never>
}

final class NetWork: NSObject, NetWorkLayerProtocol {
    private var pinnedPublicKeyHash = "a50c7e04770731cbbd299617d138a632642a9eb3f1ebd019394f80f84890d21b"
    private var pinnedCertificateHash = "5b691efcacf47bbe0095fb906cdbe44caf2751ea0ea464f4c46608ee46e8bff2"
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]


    private func sha256(data : Data) -> String {
         var keyWithHeader = Data(bytes: rsa2048Asn1Header)
         keyWithHeader.append(data)
         var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))

         keyWithHeader.withUnsafeBytes {
             _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
         }

         return Data(hash).base64EncodedString()
     }

    func searchBooks(matching searchTerm: String) -> AnyPublisher<[SearchModel], Never> {
        let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let rootURL = "https://www.omdbapi.com/?s="
        let key = "&apikey=b831f50c"
        let urlString = rootURL + escapedSearchTer + key
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

    private lazy var certificates: [Data] = {
        let url = Bundle.main.url(forResource: "omdbapi.com", withExtension: "cer")!
        let data = try! Data(contentsOf: url)
        return [data]
    }()

    
}

extension NetWork: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
                    if let serverTrust = challenge.protectionSpace.serverTrust {
                        var secresult = SecTrustResultType.invalid
                        let status = SecTrustEvaluate(serverTrust, &secresult)

                        if(errSecSuccess == status) {
                            print(SecTrustGetCertificateCount(serverTrust))
                            if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {

                                // Public key pinning
                                let serverPublicKey = SecCertificateCopyPublicKey(serverCertificate)
                                let serverPublicKeyData:NSData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
                                let keyHash = sha256(data: serverPublicKeyData as Data)
                                if (keyHash == pinnedPublicKeyHash) {
                                    // Success! This is our server
                                    completionHandler(.useCredential, URLCredential(trust:serverTrust))
                                    return
                                } else {
                                    print("error detected")
                                }

                            }
                        }
                    }
                }

       completionHandler(.cancelAuthenticationChallenge, nil)
     }
}
