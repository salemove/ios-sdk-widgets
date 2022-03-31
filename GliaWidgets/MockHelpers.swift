#if DEBUG
import Foundation

func jsonField(_ key: String, value: String) -> String {
    """
    "\(key)": "\(value)"
    """
}

func jsonField(_ key: String, value: Bool) -> String {
    """
    "\(key)": \(value)
    """
}

func jsonField<T: Numeric>(_ key: String, value: T) -> String {
    """
    "\(key)": \(value)
    """
}

func jsonFields(_ keysValues: [String]) -> String {
    """
    {
        \(keysValues.joined(separator: ",\n"))
    }
    """
}

// If the only available interface is the one that
// uses decoding, then in order to get desired mock,
// we create JSON on the fly and decode it
func mockFromJSONString<T: Decodable>(
    _ jsonString: String,
    type: T.Type = T.self,
    funcName: StaticString = #function,
    line: UInt = #line
) throws -> T {
    guard let data = jsonString.data(using: .utf8) else {
        throw NSError(
            domain: "mockFromJSONString",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "function: '\(funcName)', line: '\(line)' - \(jsonString).data(using: .utf8) is nil"
            ]
        )
    }

    return try JSONDecoder().decode(type, from: data)
}
#endif
