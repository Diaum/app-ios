import Foundation
import SwiftData
import FamilyControls

// Extensão para BlockedProfiles para incluir bloqueio automático
extension BlockedProfiles {
    
    // Criar perfil com bloqueio automático da blocklist
    static func createProfileWithAutoBlocklist(
        in context: ModelContext,
        name: String,
        selection: FamilyActivitySelection,
        blockingStrategyId: String = ManualBlockingStrategy.id,
        enableLiveActivity: Bool = true,
        reminderTimeInSeconds: UInt32? = nil,
        customReminderMessage: String? = nil,
        enableBreaks: Bool = false,
        enableStrictMode: Bool = false,
        enableAllowMode: Bool = false,
        enableAllowModeDomains: Bool = false,
        domains: [String] = [],
        physicalUnblockNFCTagId: String? = nil,
        physicalUnblockQRCodeId: String? = nil,
        schedule: BlockedProfileSchedule? = nil,
        disableBackgroundStops: Bool = false
    ) throws -> BlockedProfiles {
        
        // Carregar domínios da blocklist automaticamente
        let autoBlockedDomains = loadAutoBlockedDomains()
        
        // Combinar domínios fornecidos com domínios da blocklist
        let allDomains = Set(domains + autoBlockedDomains)
        
        let profile = BlockedProfiles(
            name: name,
            selectedActivity: selection,
            blockingStrategyId: blockingStrategyId,
            enableLiveActivity: enableLiveActivity,
            reminderTimeInSeconds: reminderTimeInSeconds,
            customReminderMessage: customReminderMessage,
            enableBreaks: enableBreaks,
            enableStrictMode: enableStrictMode,
            enableAllowMode: enableAllowMode,
            enableAllowModeDomains: enableAllowModeDomains,
            domains: Array(allDomains),
            physicalUnblockNFCTagId: physicalUnblockNFCTagId,
            physicalUnblockQRCodeId: physicalUnblockQRCodeId,
            schedule: schedule ?? BlockedProfileSchedule(
                days: [],
                startHour: 9,
                startMinute: 0,
                endHour: 17,
                endMinute: 0,
                updatedAt: Date()
            ),
            disableBackgroundStops: disableBackgroundStops
        )
        
        context.insert(profile)
        try context.save()
        
        print("✅ Perfil '\(name)' criado com \(autoBlockedDomains.count) domínios bloqueados automaticamente")
        
        return profile
    }
    
    // Carregar domínios da blocklist automaticamente
    private static func loadAutoBlockedDomains() -> [String] {
        // Lista de domínios conhecidos que devem ser bloqueados por padrão
        // Esta lista pode ser expandida ou carregada de um arquivo
        let defaultBlockedDomains = [
            "pornhub.com",
            "xvideos.com",
            "xhamster.com",
            "redtube.com",
            "youporn.com",
            "tube8.com",
            "beeg.com",
            "tnaflix.com",
            "nuvid.com",
            "slutload.com",
            "empflix.com",
            "xtube.com",
            "drtuber.com",
            "sunporno.com",
            "porn.com",
            "pornhd.com",
            "pornoxo.com",
            "pornotube.com",
            "chaturbate.com",
            "livejasmin.com",
            "myfreecams.com",
            "cam4.com",
            "bongacams.com",
            "stripchat.com",
            "camsoda.com",
            "imlive.com",
            "flirt4free.com",
            "livejasmine.com",
            "cams.com",
            "onlyfans.com",
            "fansly.com",
            "manyvids.com",
            "clips4sale.com",
            "modelhub.com",
            "amateur.tv"
        ]
        
        return defaultBlockedDomains
    }
}

// Manager para verificação de URLs em tempo real
class URLBlockingManager: ObservableObject {
    static let shared = URLBlockingManager()
    
    @Published var isBlocklistLoaded = false
    
    private init() {
        // Verificar se blocklist está carregada
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isBlocklistLoaded = BlocklistManager.shared.isLoaded
        }
    }
    
    // Verificar se URL deve ser bloqueada
    func shouldBlockURL(_ urlString: String) -> Bool {
        return BlocklistManager.shared.shouldBlock(url: urlString)
    }
    
    // Verificar se domínio deve ser bloqueado
    func shouldBlockDomain(_ domain: String) -> Bool {
        return BlocklistManager.shared.shouldBlockDomain(domain)
    }
    
    // Obter estatísticas da blocklist
    func getBlocklistStats() -> (isLoaded: Bool, error: String?) {
        let manager = BlocklistManager.shared
        return (isLoaded: manager.isLoaded, error: manager.loadError)
    }
}

// Extensão para FamilyActivitySelection para incluir bloqueio automático
extension FamilyActivitySelection {
    
    // Criar seleção com bloqueio automático de domínios
    static func createWithAutoBlocklist() -> FamilyActivitySelection {
        let selection = FamilyActivitySelection()
        
        // Aqui você pode adicionar lógica para incluir automaticamente
        // domínios da blocklist na seleção de atividades
        
        return selection
    }
}
