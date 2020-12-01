// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {

  public enum Chat {
    /// Chat
    public static let title = L10n.tr("Localizable", "chat.title")
    public enum Operator {
      public enum Connected {
        /// {operatorName}
        public static let text1 = L10n.tr("Localizable", "chat.operator.connected.text1")
        /// {operatorName} has joined the conversation.
        public static let text2 = L10n.tr("Localizable", "chat.operator.connected.text2")
      }
      public enum Connecting {
        /// Connecting with {operatorName}
        public static let text1 = L10n.tr("Localizable", "chat.operator.connecting.text1")
        /// 
        public static let text2 = L10n.tr("Localizable", "chat.operator.connecting.text2")
      }
      public enum Enqueued {
        /// CompanyName
        public static let text1 = L10n.tr("Localizable", "chat.operator.enqueued.text1")
        /// An MSR will be with you shortly.
        public static let text2 = L10n.tr("Localizable", "chat.operator.enqueued.text2")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
