import Foundation

// MARK: - Transaction Model
struct Transaction: Codable, Identifiable {
    let id: String
    let amount: Double
    let merchant: String
    let location: String
    let timestamp: String
    let cardType: String
    let customerID: String
    
    enum CodingKeys: String, CodingKey {
        case id, amount, merchant, location, timestamp
        case cardType = "card_type"
        case customerID = "customer_id"
    }
}

// MARK: - Customer Model
struct Customer: Codable, Identifiable {
    let customerID: String
    let income: Double
    let creditHistory: Int
    let debtRatio: Double
    let employment: String
    let defaults: Int
    let utilization: Double
    
    var id: String { customerID }
    
    enum CodingKeys: String, CodingKey {
        case customerID = "customer_id"
        case income
        case creditHistory = "credit_history"
        case debtRatio = "debt_ratio"
        case employment, defaults, utilization
    }
}

// MARK: - News Model
struct NewsItem: Codable, Identifiable {
    let headline: String
    let content: String
    
    var id: String { headline }
}

// MARK: - Sample Data Model
struct SampleData: Codable {
    let transactions: [Transaction]
    let customers: [Customer]
    let news: [NewsItem]
}

// MARK: - Fraud Analysis Model
struct FraudAnalysis: Codable {
    let riskScore: Int
    let riskLevel: String
    let explanation: String
    
    enum CodingKeys: String, CodingKey {
        case riskScore = "risk_score"
        case riskLevel = "risk_level"
        case explanation
    }
}

// MARK: - Market Analysis Model
struct MarketAnalysis: Codable {
    let sentimentScore: Double
    let sentiment: String?
    let marketImpact: String?
    let sectorsAffected: [String]?
    let investmentRecommendation: String?
    
    enum CodingKeys: String, CodingKey {
        case sentimentScore = "sentiment_score"
        case sentiment
        case marketImpact = "market_impact"
        case sectorsAffected = "sectors_affected"
        case investmentRecommendation = "investment_recommendation"
    }
}

// MARK: - Credit Risk Assessment Model
struct CreditRiskAssessment: Codable {
    let creditScore: Int
    let riskCategory: String
    let approvalRecommendation: String?
    let analysis: String
    
    enum CodingKeys: String, CodingKey {
        case creditScore = "credit_score"
        case riskCategory = "risk_category"
        case approvalRecommendation = "approval_recommendation"
        case analysis
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

// MARK: - Chat Response Model
struct ChatResponse: Codable {
    let response: String
}

// MARK: - API Error Model
struct APIError: Codable {
    let error: String
}

// MARK: - API Response Models
struct FraudAnalysisResponse: Codable {
    let riskScore: Int?
    let riskLevel: String?
    let explanation: String?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case riskScore = "risk_score"
        case riskLevel = "risk_level"
        case explanation, error
    }
    
    func toFraudAnalysis() -> FraudAnalysis? {
        guard let riskScore = riskScore,
              let riskLevel = riskLevel,
              let explanation = explanation else {
            return nil
        }
        return FraudAnalysis(riskScore: riskScore, riskLevel: riskLevel, explanation: explanation)
    }
}

struct MarketAnalysisResponse: Codable {
    let sentimentScore: Double?
    let marketAnalysis: MarketAnalysisData?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case sentimentScore = "sentiment_score"
        case marketAnalysis = "market_analysis"
        case error
    }
}

struct MarketAnalysisData: Codable {
    let sentiment: String?
    let marketImpact: String?
    let sectorsAffected: [String]?
    let investmentRecommendation: String?
    
    enum CodingKeys: String, CodingKey {
        case sentiment
        case marketImpact = "market_impact"
        case sectorsAffected = "sectors_affected"
        case investmentRecommendation = "investment_recommendation"
    }
}
