import SwiftUI

// Exemplo simples de uso do Bloom Filter
struct SimpleBlocklistTestView: View {
    @StateObject private var blocklistManager = BlocklistManager.shared
    @State private var testURL = "https://example.com"
    @State private var testResult = ""
    
    var body: some View {
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
            
            // URLs de exemplo para testar
            VStack(alignment: .leading, spacing: 8) {
                Text("URLs DE EXEMPLO")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                
                let exampleURLs = [
                    "https://pornhub.com",
                    "https://xvideos.com", 
                    "https://google.com",
                    "https://facebook.com",
                    "https://xhamster.com"
                ]
                
                ForEach(exampleURLs, id: \.self) { url in
                    HStack {
                        Text(url)
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        if blocklistManager.shouldBlock(url: url) {
                            Text("🚫")
                                .font(.system(size: 16))
                        } else {
                            Text("✅")
                                .font(.system(size: 16))
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding()
            .background(Color.white)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Blocklist Test")
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

#Preview {
    NavigationView {
        SimpleBlocklistTestView()
    }
}
