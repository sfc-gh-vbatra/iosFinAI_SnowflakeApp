// FinAI Web App JavaScript
class FinAIApp {
    constructor() {
        this.baseURL = 'http://localhost:5000';
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.checkConnection();
        this.loadSampleData();
    }

    setupEventListeners() {
        // Navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', () => this.switchTab(item.dataset.tab));
        });

        // Forms
        document.getElementById('fraudForm').addEventListener('submit', (e) => this.handleFraudAnalysis(e));
        document.getElementById('marketForm').addEventListener('submit', (e) => this.handleMarketAnalysis(e));
        document.getElementById('riskForm').addEventListener('submit', (e) => this.handleRiskAssessment(e));
        document.getElementById('chatForm').addEventListener('submit', (e) => this.handleChatMessage(e));
    }

    async checkConnection() {
        const statusElement = document.getElementById('connectionStatus');
        try {
            const response = await fetch(`${this.baseURL}/api/health`);
            if (response.ok) {
                const data = await response.json();
                statusElement.innerHTML = '<i class="fas fa-circle"></i> Connected';
                statusElement.className = 'connection-status connected';
                console.log('✅ Backend connected:', data);
            } else {
                throw new Error('Backend not responding');
            }
        } catch (error) {
            statusElement.innerHTML = '<i class="fas fa-circle"></i> Offline';
            statusElement.className = 'connection-status error';
            console.error('❌ Backend connection failed:', error);
        }
    }

    async loadSampleData() {
        try {
            const response = await fetch(`${this.baseURL}/api/demo/sample-data`);
            if (response.ok) {
                const data = await response.json();
                console.log('📊 Sample data loaded:', data);
                this.updateDashboardMetrics(data);
            }
        } catch (error) {
            console.error('Failed to load sample data:', error);
        }
    }

    updateDashboardMetrics(data) {
        // Update dashboard metrics with real data if available
        const metrics = document.querySelectorAll('.metric-value');
        if (data.fraudDetection && data.fraudDetection.length > 0) {
            metrics[0].textContent = `${data.fraudDetection.length} Analyzed`;
        }
        if (data.marketSentiment && data.marketSentiment.length > 0) {
            const avgSentiment = data.marketSentiment[0].sentiment || 'Neutral';
            metrics[1].textContent = avgSentiment;
        }
    }

    switchTab(tabName) {
        // Update navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
        });
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

        // Update content
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.remove('active');
        });
        document.getElementById(tabName).classList.add('active');
    }

    async handleFraudAnalysis(e) {
        e.preventDefault();
        const form = e.target;
        const submitBtn = form.querySelector('button[type="submit"]');
        const resultContainer = document.getElementById('fraudResult');
        const resultContent = document.getElementById('fraudContent');

        // Get form data
        const transactionData = {
            amount: parseFloat(document.getElementById('amount').value),
            merchant: document.getElementById('merchant').value,
            location: document.getElementById('location').value,
            card_type: document.getElementById('cardType').value,
            time: document.getElementById('time').value
        };

        // Show loading state
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<div class="loading"></div> Analyzing...';

        try {
            const response = await fetch(`${this.baseURL}/api/fraud/analyze`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(transactionData)
            });

            const data = await response.json();

            if (response.ok) {
                // Display results
                let riskClass = 'risk-low';
                let riskScore = data.risk_score || 0;
                
                if (riskScore > 70) riskClass = 'risk-high';
                else if (riskScore > 40) riskClass = 'risk-medium';

                resultContent.innerHTML = `
                    <div class="risk-indicator ${riskClass}">
                        Risk Score: ${riskScore}/100 - ${data.risk_level || 'Unknown'}
                    </div>
                    <div style="margin-top: 1rem;">
                        <h4>Analysis Details:</h4>
                        <p>${data.explanation || 'Analysis completed successfully.'}</p>
                    </div>
                `;
                
                resultContainer.style.display = 'block';
                resultContainer.scrollIntoView({ behavior: 'smooth' });
            } else {
                throw new Error(data.error || 'Analysis failed');
            }
        } catch (error) {
            console.error('Fraud analysis error:', error);
            resultContent.innerHTML = `
                <div class="risk-indicator risk-high">
                    Error: ${error.message}
                </div>
            `;
            resultContainer.style.display = 'block';
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fas fa-search"></i> Analyze for Fraud';
        }
    }

    async handleMarketAnalysis(e) {
        e.preventDefault();
        const form = e.target;
        const submitBtn = form.querySelector('button[type="submit"]');
        const resultContainer = document.getElementById('marketResult');
        const resultContent = document.getElementById('marketContent');

        const newsText = document.getElementById('newsText').value;

        submitBtn.disabled = true;
        submitBtn.innerHTML = '<div class="loading"></div> Analyzing...';

        try {
            const response = await fetch(`${this.baseURL}/api/market/sentiment`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ text: newsText })
            });

            const data = await response.json();

            if (response.ok) {
                const sentimentScore = parseFloat(data.sentiment_score || 0);
                const sentiment = sentimentScore > 0.1 ? 'Positive' : sentimentScore < -0.1 ? 'Negative' : 'Neutral';
                const sentimentClass = sentiment.toLowerCase();

                resultContent.innerHTML = `
                    <div class="risk-indicator risk-${sentimentClass === 'positive' ? 'low' : sentimentClass === 'negative' ? 'high' : 'medium'}">
                        Sentiment: ${sentiment} (${sentimentScore.toFixed(3)})
                    </div>
                    <div style="margin-top: 1rem;">
                        <h4>Market Analysis:</h4>
                        <p>${data.market_analysis || 'Analysis completed successfully.'}</p>
                    </div>
                `;
                
                resultContainer.style.display = 'block';
                resultContainer.scrollIntoView({ behavior: 'smooth' });
            } else {
                throw new Error(data.error || 'Analysis failed');
            }
        } catch (error) {
            console.error('Market analysis error:', error);
            resultContent.innerHTML = `
                <div class="risk-indicator risk-high">
                    Error: ${error.message}
                </div>
            `;
            resultContainer.style.display = 'block';
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fas fa-chart-line"></i> Analyze Sentiment';
        }
    }

    async handleRiskAssessment(e) {
        e.preventDefault();
        const form = e.target;
        const submitBtn = form.querySelector('button[type="submit"]');
        const resultContainer = document.getElementById('riskResult');
        const resultContent = document.getElementById('riskContent');

        const customerData = {
            customer_id: document.getElementById('customerId').value,
            credit_score: parseInt(document.getElementById('creditScore').value) || 0,
            annual_income: parseFloat(document.getElementById('annualIncome').value),
            employment_years: parseInt(document.getElementById('employmentYears').value) || 0,
            debt_to_income_ratio: parseFloat(document.getElementById('debtRatio').value) || 0
        };

        submitBtn.disabled = true;
        submitBtn.innerHTML = '<div class="loading"></div> Assessing...';

        try {
            const response = await fetch(`${this.baseURL}/api/risk/assess`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(customerData)
            });

            const data = await response.json();

            if (response.ok) {
                const creditScore = data.credit_score || 0;
                const riskCategory = data.risk_category || 'Unknown';
                let riskClass = 'risk-medium';
                
                if (riskCategory.toLowerCase() === 'low') riskClass = 'risk-low';
                else if (riskCategory.toLowerCase() === 'high') riskClass = 'risk-high';

                resultContent.innerHTML = `
                    <div class="risk-indicator ${riskClass}">
                        Credit Score: ${creditScore} - ${riskCategory} Risk
                    </div>
                    <div style="margin-top: 1rem;">
                        <h4>Risk Assessment:</h4>
                        <p>${data.analysis || 'Assessment completed successfully.'}</p>
                    </div>
                `;
                
                resultContainer.style.display = 'block';
                resultContainer.scrollIntoView({ behavior: 'smooth' });
            } else {
                throw new Error(data.error || 'Assessment failed');
            }
        } catch (error) {
            console.error('Risk assessment error:', error);
            resultContent.innerHTML = `
                <div class="risk-indicator risk-high">
                    Error: ${error.message}
                </div>
            `;
            resultContainer.style.display = 'block';
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fas fa-calculator"></i> Assess Credit Risk';
        }
    }

    async handleChatMessage(e) {
        e.preventDefault();
        const input = document.getElementById('chatInput');
        const question = input.value.trim();
        
        if (!question) return;

        this.addChatMessage(question, 'user');
        input.value = '';

        // Show typing indicator
        const typingId = this.addChatMessage('AI is thinking...', 'bot', true);

        try {
            const response = await fetch(`${this.baseURL}/api/chat/financial`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ 
                    question: question,
                    context: 'User is asking about financial topics'
                })
            });

            const data = await response.json();

            // Remove typing indicator
            document.getElementById(typingId).remove();

            if (response.ok) {
                this.addChatMessage(data.response, 'bot');
            } else {
                throw new Error(data.error || 'Chat failed');
            }
        } catch (error) {
            console.error('Chat error:', error);
            document.getElementById(typingId).remove();
            this.addChatMessage(`Sorry, I encountered an error: ${error.message}`, 'bot');
        }
    }

    addChatMessage(message, sender, isTyping = false) {
        const chatMessages = document.getElementById('chatMessages');
        const messageId = `msg-${Date.now()}`;
        
        const messageDiv = document.createElement('div');
        messageDiv.id = messageId;
        messageDiv.className = `message ${sender}-message`;
        
        const avatar = sender === 'bot' ? '<i class="fas fa-robot"></i>' : '<i class="fas fa-user"></i>';
        
        messageDiv.innerHTML = `
            <div class="message-avatar">
                ${avatar}
            </div>
            <div class="message-content">
                <p>${isTyping ? '<div class="loading"></div> ' + message : message}</p>
            </div>
        `;
        
        chatMessages.appendChild(messageDiv);
        chatMessages.scrollTop = chatMessages.scrollHeight;
        
        return messageId;
    }

    loadSampleNews(type) {
        const newsText = document.getElementById('newsText');
        const samples = {
            bull: "Tech stocks surge as Apple and Microsoft report record quarterly earnings, beating analyst expectations. The NASDAQ rises 3.2% with strong momentum in AI and cloud computing sectors.",
            bear: "Market volatility increases as inflation concerns mount. Federal Reserve hints at potential interest rate hikes, causing uncertainty in financial markets and tech stock decline.",
            neutral: "Federal Reserve maintains current interest rates at 5.25-5.50% range. Officials cite balanced approach between controlling inflation and supporting economic growth."
        };
        
        newsText.value = samples[type] || samples.neutral;
    }

    askQuickQuestion(question) {
        document.getElementById('chatInput').value = question;
        document.getElementById('chatForm').dispatchEvent(new Event('submit'));
    }
}

// Global functions for HTML onclick handlers
function switchTab(tabName) {
    window.finaiApp.switchTab(tabName);
}

function loadSampleNews(type) {
    window.finaiApp.loadSampleNews(type);
}

function askQuickQuestion(question) {
    window.finaiApp.askQuickQuestion(question);
}

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.finaiApp = new FinAIApp();
});
