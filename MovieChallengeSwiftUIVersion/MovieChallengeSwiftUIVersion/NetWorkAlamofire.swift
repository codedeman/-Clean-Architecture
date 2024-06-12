//
//  NetWorkAlamofire.swift
//  MovieChallengeSwiftUIVersion
//
//  Created by Kevin on 6/10/24.
//

import Foundation
import Alamofire
import Combine
import Security
import CommonCrypto

func certificateFromBase64EncodedString(_ base64String: String) -> SecCertificate? {
    guard let data = Data(base64Encoded: base64String) else { return nil }
    return SecCertificateCreateWithData(nil, data as CFData)
}

func publicKeyFromCertificate(_ certificate: SecCertificate) -> SecKey? {
    var trust: SecTrust?

    let policy = SecPolicyCreateBasicX509()
    let status = SecTrustCreateWithCertificates(certificate, policy, &trust)

    guard status == errSecSuccess, let trust = trust else { return nil }
    return SecTrustCopyKey(trust)

}

func dataFromBase64EncodedString(_ base64String: String) -> Data? {
    return Data(base64Encoded: base64String)
}

func sha256(data: Data) -> Data {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
}

func sha256HashFromBase64EncodedString(_ base64String: String) -> Data? {
    guard let data = Data(base64Encoded: base64String) else { return nil }
    return sha256(data: data)
}

class MyServerTrustManager: ServerTrustManager {
    init() {
        let base64EncodedCertificate = """

                """
        // Convert Base64 encoded strings to SecCertificate and SecKey
        guard let certificate = certificateFromBase64EncodedString(base64EncodedCertificate),
              let publicKey = publicKeyFromCertificate(certificate) else {
            fatalError("Invalid Base64 string")
        }

        let serverTrustPolicies: [String: ServerTrustEvaluating] = [
            "your.server.com": PublicKeysTrustEvaluator(
                keys: [publicKey],
                performDefaultValidation: true,
                validateHost: true
            ),
            "your.server.com": PinnedCertificatesTrustEvaluator(
                certificates: [certificate],
                acceptSelfSignedCertificates: false,
                performDefaultValidation: true,
                validateHost: true
            )
        ]
        super.init(allHostsMustBeEvaluated: false, evaluators: serverTrustPolicies)
    }
}

class NetworkSession {
    static let shared: Session = {
        let serverTrustManager = MyServerTrustManager()
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        return Session(configuration: configuration, serverTrustManager: serverTrustManager)
    }()
}


final class NetworkALaMo: NetWorkLayerProtocol {

    private let publicKeyHash = "a1a84e956b70079354ef4060a95930597923e4c53f81fe7298614a091d130f5a"
    private let evaluator: DBSSLPinningEvaluator
    private let session: Session

    init() {
        evaluator = DBSSLPinningEvaluator(
            localPublicHashKeys: [publicKeyHash]
        )

        // Set up the server trust policies
        let serverTrustPolicies: [String: ServerTrustEvaluating] = [
            "omdbapi.com": evaluator
        ]

        // Initialize the ServerTrustManager
        let serverTrustManager = ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: serverTrustPolicies)

        // Create a custom session with the ServerTrustManager
        session = Session(serverTrustManager: serverTrustManager)
    }


    func searchBooks(matching searchTerm: String) -> AnyPublisher<[SearchModel], Never> {
        let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let rootURL = "https://www.omdbapi.com/?s="
        let key = "&apikey=b831f50c"
        let urlString = rootURL+"Son"+key

        return Future<[SearchModel], Never> { promise in

            self.session.request(urlString, method: .get).response { response in

                if let error = response.error {
                    print("error ===> \(error)")
                    promise(.success([]))
                    return
                }
                guard let data = response.data else {
                    promise(.success([]))
                    return
                }
                if let json = try? JSONDecoder().decode(MovieResponse.self, from: data) {                    promise(.success(json.Search))
                } else {
                    promise(.success([]))
                }
            }

        }
        .eraseToAnyPublisher()

        
    }

}

