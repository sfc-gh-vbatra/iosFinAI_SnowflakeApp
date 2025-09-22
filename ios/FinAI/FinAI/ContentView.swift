import SwiftUI

struct ContentView: View {
    @StateObject private var apiService = APIService()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Dashboard")
                }
                .tag(0)
            
            FraudDetectionView()
                .tabItem {
                    Image(systemName: "shield.checkerboard")
                    Text("Fraud Detection")
                }
                .tag(1)
            
            MarketAnalysisView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Market")
                }
                .tag(2)
            
            RiskAssessmentView()
                .tabItem {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                    Text("Risk")
                }
                .tag(3)
            
            ChatView()
                .tabItem {
                    Image(systemName: "message.circle")
                    Text("AI Chat")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .environmentObject(apiService)
    }
}

struct DashboardView: View {
    @EnvironmentObject var apiService: APIService
    @State private var sampleData: SampleData?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading) {
                        Text("FinAI Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Powered by Snowflake Cortex AI")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Key Metrics Cards
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        MetricCard(title: "Fraud Alerts", value: "3", icon: "exclamationmark.triangle.fill", color: .red)
                        MetricCard(title: "Risk Score", value: "Low", icon: "shield.fill", color: .green)
                        MetricCard(title: "Market Sentiment", value: "Positive", icon: "chart.line.uptrend.xyaxis", color: .blue)
                        MetricCard(title: "Active Users", value: "1,234", icon: "person.3.fill", color: .purple)
                    }
                    .padding(.horizontal)
                    
                    // Recent Transactions
                    VStack(alignment: .leading) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if let transactions = sampleData?.transactions {
                            ForEach(transactions, id: \.id) { transaction in
                                TransactionCard(transaction: transaction)
                                    .padding(.horizontal)
                            }
                        } else {
                            ProgressView("Loading transactions...")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadSampleData()
            }
        }
    }
    
    private func loadSampleData() {
        apiService.getSampleData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.sampleData = data
                case .failure(let error):
                    print("Failed to load sample data: \(error)")
                }
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TransactionCard: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.merchant)
                        .font(.headline)
                    Text(transaction.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("$\(String(format: "%.2f", transaction.amount))")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(transaction.cardType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(formatDate(transaction.timestamp))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct FraudDetectionView: View {
    @EnvironmentObject var apiService: APIService
    @State private var selectedTransaction: Transaction?
    @State private var fraudAnalysis: FraudAnalysis?
    @State private var isAnalyzing = false
    @State private var sampleData: SampleData?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Fraud Detection")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                if let transactions = sampleData?.transactions {
                    Text("Select a transaction to analyze:")
                        .font(.headline)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(transactions, id: \.id) { transaction in
                                Button(action: {
                                    analyzeTransaction(transaction)
                                }) {
                                    TransactionCard(transaction: transaction)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ProgressView("Loading transactions...")
                        .onAppear {
                            loadSampleData()
                        }
                }
                
                if isAnalyzing {
                    VStack {
                        ProgressView()
                        Text("Analyzing with Cortex AI...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                if let analysis = fraudAnalysis {
                    FraudAnalysisCard(analysis: analysis)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func loadSampleData() {
        apiService.getSampleData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.sampleData = data
                case .failure(let error):
                    print("Failed to load sample data: \(error)")
                }
            }
        }
    }
    
    private func analyzeTransaction(_ transaction: Transaction) {
        isAnalyzing = true
        selectedTransaction = transaction
        
        apiService.analyzeFraud(transaction: transaction) { result in
            DispatchQueue.main.async {
                self.isAnalyzing = false
                switch result {
                case .success(let analysis):
                    self.fraudAnalysis = analysis
                case .failure(let error):
                    print("Fraud analysis failed: \(error)")
                }
            }
        }
    }
}

struct FraudAnalysisCard: View {
    let analysis: FraudAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fraud Analysis Result")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                Text("Risk Score:")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(analysis.riskScore)/100")
                    .fontWeight(.bold)
                    .foregroundColor(riskColor)
            }
            
            HStack {
                Text("Risk Level:")
                    .fontWeight(.semibold)
                Spacer()
                Text(analysis.riskLevel)
                    .fontWeight(.bold)
                    .foregroundColor(riskColor)
            }
            
            Text("Analysis:")
                .fontWeight(.semibold)
            Text(analysis.explanation)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var riskColor: Color {
        switch analysis.riskLevel.lowercased() {
        case "low":
            return .green
        case "medium":
            return .orange
        case "high":
            return .red
        default:
            return .primary
        }
    }
}

struct MarketAnalysisView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Market Analysis")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Coming Soon...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct RiskAssessmentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Risk Assessment")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Coming Soon...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct ChatView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("AI Financial Assistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Coming Soon...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
