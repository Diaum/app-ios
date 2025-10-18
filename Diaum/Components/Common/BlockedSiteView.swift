import SwiftUI
import WebKit

struct BlockedSiteView: View {
    let blockedURL: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Ícone de bloqueio
            Image(systemName: "shield.fill")
                .font(.system(size: 64))
                .foregroundColor(.red)
            
            // Título
            Text("Site Bloqueado")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
            
            // Mensagem explicativa
            VStack(spacing: 12) {
                Text("Este site não é permitido")
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .foregroundColor(.black)
                
                Text("O conteúdo deste site pode não ser adequado para todos os públicos.")
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // URL bloqueada
            Text(blockedURL)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            // Botão de ação
            Button(action: {
                // Aqui você pode implementar ações como voltar, ir para home, etc.
            }) {
                Text("Voltar")
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 32)
        }
        .padding(32)
        .background(Color.white)
    }
}

// WebView com bloqueio automático
struct BlockedWebView: UIViewRepresentable {
    let url: String
    @Binding var isBlocked: Bool
    @Binding var blockedURL: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: url) else { return }
        
        // Verificar se URL deve ser bloqueada
        if BlocklistManager.shared.shouldBlock(url: url.absoluteString) {
            isBlocked = true
            blockedURL = url.absoluteString
        } else {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: BlockedWebView
        
        init(_ parent: BlockedWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            // Verificar se URL deve ser bloqueada
            if BlocklistManager.shared.shouldBlock(url: url.absoluteString) {
                DispatchQueue.main.async {
                    self.parent.isBlocked = true
                    self.parent.blockedURL = url.absoluteString
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}

// View principal que gerencia WebView e bloqueios
struct SafeWebView: View {
    let initialURL: String
    @State private var isBlocked = false
    @State private var blockedURL = ""
    @State private var currentURL = ""
    
    var body: some View {
        ZStack {
            if isBlocked {
                BlockedSiteView(blockedURL: blockedURL)
            } else {
                BlockedWebView(
                    url: initialURL,
                    isBlocked: $isBlocked,
                    blockedURL: $blockedURL
                )
            }
        }
        .onAppear {
            currentURL = initialURL
        }
    }
}
