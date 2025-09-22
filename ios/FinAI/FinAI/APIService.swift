import Foundation
import Combine

class APIService: ObservableObject {
    private let baseURL: String
    private let session = URLSession.shared
    
    init(baseURL: String = "http://localhost:5000") {
        self.baseURL = baseURL
    }
    
    // MARK: - Generic API Request Method
    private func makeRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, APIServiceError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Check for API errors first
            if httpResponse.statusCode >= 400 {
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    completion(.failure(.apiError(apiError.error)))
                } else {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }
    
    // MARK: - Health Check
    func healthCheck(completion: @escaping (Result<[String: Any], APIServiceError>) -> Void) {
        makeRequest(
            endpoint: "/api/health",
            responseType: [String: String].self
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response as [String: Any]))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Sample Data
    func getSampleData(completion: @escaping (Result<SampleData, APIServiceError>) -> Void) {
        makeRequest(
            endpoint: "/api/demo/sample-data",
            responseType: SampleData.self,
            completion: completion
        )
    }
    
    // MARK: - Fraud Detection
    func analyzeFraud(transaction: Transaction, completion: @escaping (Result<FraudAnalysis, APIServiceError>) -> Void) {
        do {
            let requestBody = try JSONEncoder().encode(transaction)
            
            makeRequest(
                endpoint: "/api/fraud/analyze",
                method: .POST,
                body: requestBody,
                responseType: FraudAnalysisResponse.self
            ) { result in
                switch result {
                case .success(let response):
                    if let fraudAnalysis = response.toFraudAnalysis() {
                        completion(.success(fraudAnalysis))
                    } else if let error = response.error {
                        completion(.failure(.apiError(error)))
                    } else {
                        completion(.failure(.apiError("Invalid fraud analysis response")))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(.encodingError(error.localizedDescription)))
        }
    }
    
    // MARK: - Market Sentiment Analysis
    func analyzeMarketSentiment(text: String, completion: @escaping (Result<MarketAnalysis, APIServiceError>) -> Void) {
        let requestBody = ["text": text]
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            
            makeRequest(
                endpoint: "/api/market/sentiment",
                method: .POST,
                body: jsonData,
                responseType: MarketAnalysisResponse.self
            ) { result in
                switch result {
                case .success(let response):
                    if let error = response.error {
                        completion(.failure(.apiError(error)))
                    } else {
                        let analysis = MarketAnalysis(
                            sentimentScore: response.sentimentScore ?? 0.0,
                            sentiment: response.marketAnalysis?.sentiment,
                            marketImpact: response.marketAnalysis?.marketImpact,
                            sectorsAffected: response.marketAnalysis?.sectorsAffected,
                            investmentRecommendation: response.marketAnalysis?.investmentRecommendation
                        )
                        completion(.success(analysis))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(.encodingError(error.localizedDescription)))
        }
    }
    
    // MARK: - Credit Risk Assessment
    func assessCreditRisk(customer: Customer, completion: @escaping (Result<CreditRiskAssessment, APIServiceError>) -> Void) {
        do {
            let requestBody = try JSONEncoder().encode(customer)
            
            makeRequest(
                endpoint: "/api/risk/assess",
                method: .POST,
                body: requestBody,
                responseType: CreditRiskAssessment.self,
                completion: completion
            )
        } catch {
            completion(.failure(.encodingError(error.localizedDescription)))
        }
    }
    
    // MARK: - Financial Chat
    func sendChatMessage(question: String, context: String? = nil, completion: @escaping (Result<String, APIServiceError>) -> Void) {
        var requestBody: [String: Any] = ["question": question]
        if let context = context {
            requestBody["context"] = context
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            
            makeRequest(
                endpoint: "/api/chat/financial",
                method: .POST,
                body: jsonData,
                responseType: ChatResponse.self
            ) { result in
                switch result {
                case .success(let response):
                    completion(.success(response.response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(.encodingError(error.localizedDescription)))
        }
    }
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - API Service Errors
enum APIServiceError: Error, LocalizedError {
    case invalidURL
    case networkError(String)
    case invalidResponse
    case noData
    case httpError(Int)
    case apiError(String)
    case decodingError(String)
    case encodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response"
        case .noData:
            return "No data received"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .encodingError(let message):
            return "Encoding error: \(message)"
        }
    }
}
