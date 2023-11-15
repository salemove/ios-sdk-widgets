import Foundation

@propertyWrapper struct UserDefaultsStored<Value> {
    var wrappedValue: Value {
        get {
            coder.decode(
                userDefaults.value(forKey: key)
            ) ?? defaultValue
        }
        set {
            userDefaults.set(
                coder.encode(newValue),
                forKey: key
            )
        }
    }

    init(
        key: String,
        defaultValue: Value,
        coder: Coder<Value> = .casting(),
        userDefaults: UserDefaults = .standard
    ) {
        self.key = key
        self.userDefaults = userDefaults
        self.defaultValue = defaultValue
        self.coder = coder
    }

    // MARK: - Private

    private var coder: Coder<Value>
    private let defaultValue: Value
    private let key: String
    private let userDefaults: UserDefaults
}

extension UserDefaultsStored {
    struct Coder<CoderValue> {
        var decode: (Any?) -> CoderValue?
        var encode: (CoderValue?) -> Any?
    }
}

extension UserDefaultsStored.Coder {
    static func casting() -> UserDefaultsStored.Coder<Value> {
        UserDefaultsStored.Coder { $0 as? Value }
            encode: {
                $0
            }
    }
    
    static func jsonCoding() -> UserDefaultsStored.Coder<Value> where Value: Codable {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        return UserDefaultsStored.Coder(
            decode: { try? decoder.decode(Value.self, from: ($0 as? Data) ?? Data()) },
            encode: { try? encoder.encode($0) }
        )
    }

    static func rawRepresentable() -> UserDefaultsStored.Coder<Value> where Value: RawRepresentable {
        UserDefaultsStored.Coder {
            guard let rawValue = $0 as? Value.RawValue else { return nil }
            return Value(rawValue: rawValue)
        } encode: {
            $0?.rawValue
        }
    }
}
