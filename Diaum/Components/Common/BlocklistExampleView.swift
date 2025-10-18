import SwiftUI
import WebKit

// Exemplo de uso do sistema de bloqueio
struct BlocklistExampleView: View {
    @StateObject private var blocklistManager = BlocklistManager.shared
    @StateObject private var urlManager = URLBlockingManager.shared
    @State private var testURL = "https://example.com"
    @State private var testResult = ""
    @State private var showingWebView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Status da blocklist
                VStack(alignment: .leading, spacing: 8) {
                    Text("BLOCKLIST STATUS")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                    
                    if blocklistManager.isLoaded {
                        Text("✅ Bloom Filter carregado com sucesso")
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundColor(.green)
                    } else {
                        Text("❌ Bloom Filter não carregado")
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundColor(.red)
                        
                        if let error = blocklistManager.loadError {
                            Text("Erro: \(error)")
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Teste de URL
                VStack(alignment: .leading, spacing: 12) {
                    Text("TESTE DE BLOQUEIO")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                    
                    TextField("Digite uma URL para testar", text: $testURL)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Testar URL") {
                        testURLBlocking()
                    }
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .cornerRadius(8)
                    
                    if !testResult.isEmpty {
                        Text(testResult)
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundColor(testResult.contains("bloqueada") ? .red : .green)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.white)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                .cornerRadius(8)
                
                // Botão para abrir WebView
                Button("Abrir WebView com Bloqueio") {
                    showingWebView = true
                }
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Blocklist Test")
            .sheet(isPresented: $showingWebView) {
                SafeWebView(initialURL: testURL)
            }
        }
    }
    
    private func testURLBlocking() {
        let shouldBlock = blocklistManager.shouldBlock(url: testURL)
        
        if shouldBlock {
            testResult = "🚫 URL bloqueada: \(testURL)"
        } else {
            testResult = "✅ URL permitida: \(testURL)"
        }
    }
}

// Exemplo de URLs para testar
struct TestURLsView: View {
    let testURLs = [
        "https://pornhub.com",
        "https://xvideos.com",
        "https://google.com",
        "https://facebook.com",
        "https://xhamster.com",
        "https://apple.com"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("URLs DE TESTE")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
            
            ForEach(testURLs, id: \.self) { url in
                HStack {
                    Text(url)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    if BlocklistManager.shared.shouldBlock(url: url) {
                        Text("🚫")
                            .font(.system(size: 16))
                    } else {
                        Text("✅")
                            .font(.system(size: 16))
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.white)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
        .cornerRadius(8)
    }
}

#Preview {
    BlocklistExampleView()
}
