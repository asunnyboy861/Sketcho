import Combine
import Foundation
import Security

enum KeychainHelper {
    static func save(_ data: Data, service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        var attributes = query
        attributes[kSecValueData as String] = data
        SecItemAdd(attributes as CFDictionary, nil)
    }

    static func read(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }

    static func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    static func saveString(_ value: String, service: String, account: String) {
        guard let data = value.data(using: .utf8) else { return }
        save(data, service: service, account: account)
    }

    static func readString(service: String, account: String) -> String? {
        guard let data = read(service: service, account: account) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

@MainActor
final class QuotaService: ObservableObject {
    static let shared = QuotaService()

    static let dailyFreeHD = 3
    static let trialDuration: TimeInterval = 72 * 3600

    @Published private(set) var hdUsedToday: Int = 0
    @Published private(set) var trialActive: Bool = true
    @Published private(set) var trialHoursRemaining: Int = 0

    private let usedKey = "sketcho.hdUsedToday"
    private let dateKey = "sketcho.quotaDate"
    private let launchKey = "sketcho.firstLaunch"

    private init() {
        registerFirstLaunch()
        refresh()
    }

    private func registerFirstLaunch() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: launchKey) == nil {
            defaults.set(Date(), forKey: launchKey)
        }
    }

    func refresh() {
        let defaults = UserDefaults.standard
        let today = Self.dayString(Date())
        if defaults.string(forKey: dateKey) != today {
            defaults.set(0, forKey: usedKey)
            defaults.set(today, forKey: dateKey)
        }
        hdUsedToday = defaults.integer(forKey: usedKey)

        let first = defaults.object(forKey: launchKey) as? Date ?? Date()
        let elapsed = Date().timeIntervalSince(first)
        trialActive = elapsed < Self.trialDuration
        trialHoursRemaining = max(0, Int(ceil((Self.trialDuration - elapsed) / 3600)))
    }

    var hdRemainingToday: Int { max(0, Self.dailyFreeHD - hdUsedToday) }

    func canUseFreeHD() -> Bool { hdRemainingToday > 0 }

    func consumeHD() {
        let defaults = UserDefaults.standard
        defaults.set(hdUsedToday + 1, forKey: usedKey)
        refresh()
    }

    private static func dayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
