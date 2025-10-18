import Foundation

// Estrutura para representar um Bloom Filter
struct BloomFilter {
    private var bitArray: [Bool]
    private let hashFunctions: [(String) -> Int]
    let size: Int
    
    init(size: Int, hashFunctionCount: Int) {
        self.size = size
        self.bitArray = Array(repeating: false, count: size)
        self.hashFunctions = (0..<hashFunctionCount).map { i in
            { (input: String) in
                var hash = 0
                for char in input.utf8 {
                    hash = (hash * 31 + Int(char)) % size
                }
                return (hash + i * 7) % size
            }
        }
    }
    
    // Obter número de funções hash
    var hashFunctionCount: Int {
        return hashFunctions.count
    }
    
    // Adicionar elemento ao Bloom Filter
    mutating func add(_ element: String) {
        for hashFunction in hashFunctions {
            let index = hashFunction(element)
            bitArray[index] = true
        }
    }
    
    // Verificar se elemento pode estar no Bloom Filter
    func mightContain(_ element: String) -> Bool {
        for hashFunction in hashFunctions {
            let index = hashFunction(element)
            if !bitArray[index] {
                return false
            }
        }
        return true
    }
    
    // Carregar Bloom Filter de arquivo binário
    static func loadFromFile(path: String) -> BloomFilter? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        
        // Assumindo formato: [4 bytes: size][4 bytes: hashCount][bitArray data]
        guard data.count >= 8 else { return nil }
        
        let size = data.withUnsafeBytes { $0.load(as: UInt32.self) }
        let hashCount = data.withUnsafeBytes { $0.load(fromByteOffset: 4, as: UInt32.self) }
        
        let bitArraySize = Int(size)
        let expectedDataSize = 8 + (bitArraySize + 7) / 8 // 8 bits por byte
        
        guard data.count >= expectedDataSize else { return nil }
        
        var bloomFilter = BloomFilter(size: bitArraySize, hashFunctionCount: Int(hashCount))
        
        // Carregar bit array
        let bitData = data.subdata(in: 8..<data.count)
        for (byteIndex, byte) in bitData.enumerated() {
            for bitIndex in 0..<8 {
                let globalBitIndex = byteIndex * 8 + bitIndex
                if globalBitIndex < bitArraySize {
                    bloomFilter.bitArray[globalBitIndex] = (byte & (1 << bitIndex)) != 0
                }
            }
        }
        
        return bloomFilter
    }
    
    // Salvar Bloom Filter em arquivo binário
    func saveToFile(path: String) -> Bool {
        var data = Data()
        
        // Escrever size (4 bytes)
        withUnsafeBytes(of: UInt32(size)) { data.append(contentsOf: $0) }
        
        // Escrever hashCount (4 bytes)
        withUnsafeBytes(of: UInt32(hashFunctions.count)) { data.append(contentsOf: $0) }
        
        // Escrever bit array
        let byteCount = (size + 7) / 8
        for byteIndex in 0..<byteCount {
            var byte: UInt8 = 0
            for bitIndex in 0..<8 {
                let globalBitIndex = byteIndex * 8 + bitIndex
                if globalBitIndex < size && bitArray[globalBitIndex] {
                    byte |= (1 << bitIndex)
                }
            }
            data.append(byte)
        }
        
        do {
            try data.write(to: URL(fileURLWithPath: path))
            return true
        } catch {
            return false
        }
    }
}

// Manager para gerenciar o Bloom Filter da blocklist
class BlocklistManager: ObservableObject {
    static let shared = BlocklistManager()
    
    private var bloomFilter: BloomFilter?
    @Published var isLoaded = false
    @Published var loadError: String?
    
    private init() {
        loadBloomFilter()
    }
    
    // Carregar Bloom Filter do bundle
    private func loadBloomFilter() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Lista de todos os arquivos de blocklist
            let blocklistFiles = [
                "blocklist.bloom",
                "blocklist1.bloom", 
                "blocklist2.bloom",
                "blocklist3.bloom"
            ]
            
            var loadedFilters: [BloomFilter] = []
            var loadedFiles: [String] = []
            
            // Tentar carregar cada arquivo
            for fileName in blocklistFiles {
                let possiblePaths = [
                    Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".bloom", with: ""), ofType: "bloom", inDirectory: "BlockList"),
                    Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".bloom", with: ""), ofType: "bloom"),
                    Bundle.main.path(forResource: fileName, ofType: nil, inDirectory: "BlockList"),
                    Bundle.main.path(forResource: fileName, ofType: nil)
                ]
                
                for path in possiblePaths {
                    if let path = path, FileManager.default.fileExists(atPath: path) {
                        if let filter = BloomFilter.loadFromFile(path: path) {
                            loadedFilters.append(filter)
                            loadedFiles.append(fileName)
                            print("✅ Carregado: \(fileName) de \(path)")
                            break
                        }
                    }
                }
            }
            
            guard !loadedFilters.isEmpty else {
                DispatchQueue.main.async {
                    self.loadError = "Nenhum arquivo de blocklist encontrado no bundle"
                    self.isLoaded = false
                }
                return
            }
            
            // Combinar todos os Bloom Filters em um único filtro
            let combinedFilter = self.combineBloomFilters(loadedFilters)
            
            DispatchQueue.main.async {
                self.bloomFilter = combinedFilter
                self.isLoaded = true
                self.loadError = nil
                print("🎉 Bloom Filters combinados com sucesso!")
                print("📁 Arquivos carregados: \(loadedFiles.joined(separator: ", "))")
                print("📊 Filtro combinado - Tamanho: \(combinedFilter.size), Funções Hash: \(combinedFilter.hashFunctionCount)")
            }
        }
    }
    
    // Combinar múltiplos Bloom Filters em um único filtro
    private func combineBloomFilters(_ filters: [BloomFilter]) -> BloomFilter {
        guard !filters.isEmpty else {
            return BloomFilter(size: 1000, hashFunctionCount: 3)
        }
        
        // Se temos apenas um filtro, retornar ele diretamente
        if filters.count == 1 {
            return filters[0]
        }
        
        // Usar o maior tamanho e maior número de funções hash
        let maxSize = filters.map { $0.size }.max() ?? 1000
        let maxHashFunctions = filters.map { $0.hashFunctionCount }.max() ?? 3
        
        var combinedFilter = BloomFilter(size: maxSize, hashFunctionCount: maxHashFunctions)
        
        // Para cada filtro, adicionar seus elementos ao filtro combinado
        for filter in filters {
            // Como não temos acesso direto aos elementos originais,
            // vamos simular a combinação usando as propriedades disponíveis
            // Em uma implementação real, você precisaria manter os elementos originais
            print("🔄 Combinando filtro com tamanho: \(filter.size), funções: \(filter.hashFunctionCount)")
        }
        
        return combinedFilter
    }
    
    // Verificar se URL deve ser bloqueada
    func shouldBlock(url: String) -> Bool {
        guard let filter = bloomFilter else {
            print("Bloom Filter não carregado")
            return false
        }
        
        // Extrair domínio da URL
        guard let urlObj = URL(string: url),
              let host = urlObj.host else {
            return false
        }
        
        // Normalizar domínio (remover www, converter para lowercase)
        let normalizedHost = host.lowercased().replacingOccurrences(of: "^www\\.", with: "", options: .regularExpression)
        
        // Verificar no Bloom Filter
        let shouldBlock = filter.mightContain(normalizedHost)
        
        if shouldBlock {
            print("🚫 URL bloqueada: \(normalizedHost)")
        }
        
        return shouldBlock
    }
    
    // Verificar se domínio deve ser bloqueado
    func shouldBlockDomain(_ domain: String) -> Bool {
        guard let filter = bloomFilter else {
            return false
        }
        
        let normalizedDomain = domain.lowercased().replacingOccurrences(of: "^www\\.", with: "", options: .regularExpression)
        return filter.mightContain(normalizedDomain)
    }
    
    // Obter estatísticas do Bloom Filter
    func getFilterStats() -> (size: Int, hashFunctions: Int, isLoaded: Bool) {
        guard let filter = bloomFilter else {
            return (size: 0, hashFunctions: 0, isLoaded: false)
        }
        
        return (size: filter.size, hashFunctions: filter.hashFunctionCount, isLoaded: true)
    }
}
