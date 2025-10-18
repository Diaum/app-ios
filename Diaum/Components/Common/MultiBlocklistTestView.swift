import SwiftUI

// Exemplo atualizado para múltiplos arquivos de blocklist
struct MultiBlocklistTestView: View {
    @StateObject private var blocklistManager = BlocklistManager.shared
    @State private var testURL = "https://example.com"
    @State private var testResult = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Status da blocklist
            VStack(alignment: .leading, spacing: 8) {
                Text("MULTI-BLOCKLIST STATUS")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                
                if blocklistManager.isLoaded {
                    Text("✅ Bloom Filters carregados com sucesso")
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundColor(.green)
                    
                    Text("📁 Arquivos: blocklist.bloom, blocklist1.bloom, blocklist2.bloom, blocklist3.bloom")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary)
                } else {
                    Text("❌ Bloom Filters não carregados")
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
                    "https://xhamster.com",
                    "https://google.com",
                    "https://facebook.com",
                    "https://apple.com",
                    "https://redtube.com",
                    "https://youporn.com"
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
            
            // Informações sobre os arquivos
            VStack(alignment: .leading, spacing: 8) {
                Text("ARQUIVOS DE BLOCKLIST")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                
                let blocklistFiles = [
                    "blocklist.bloom",
                    "blocklist1.bloom", 
                    "blocklist2.bloom",
                    "blocklist3.bloom"
                ]
                
                ForEach(blocklistFiles, id: \.self) { fileName in
                    HStack {
                        Text(fileName)
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("📁")
                            .font(.system(size: 16))
                    }
                    .padding(.vertical, 2)
                }
                
                Text("Todos os arquivos são carregados e combinados automaticamente")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            .padding()
            .background(Color.white)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Multi-Blocklist Test")
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
        MultiBlocklistTestView()
    }
}
