// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// Powered by
  public static let poweredBy = L10n.tr("Localizable", "poweredBy")

  public enum Alert {
    public enum Action {
      /// No
      public static let no = L10n.tr("Localizable", "alert.action.no")
      /// Yes
      public static let yes = L10n.tr("Localizable", "alert.action.yes")
    }
    public enum ApiError {
      /// {message}
      public static let message = L10n.tr("Localizable", "alert.apiError.message")
      /// We're sorry, there has been an error.
      public static let title = L10n.tr("Localizable", "alert.apiError.title")
    }
    public enum EndEngagement {
      /// 
      public static let message = L10n.tr("Localizable", "alert.endEngagement.message")
      /// Are you sure you want to leave?
      public static let title = L10n.tr("Localizable", "alert.endEngagement.title")
    }
    public enum LeaveQueue {
      /// You will lose your place in the queue.
      public static let message = L10n.tr("Localizable", "alert.leaveQueue.message")
      /// Are you sure you want to leave?
      public static let title = L10n.tr("Localizable", "alert.leaveQueue.title")
    }
    public enum OperatorsUnavailable {
      /// Operators are no longer available.\nPlease try again later.
      public static let message = L10n.tr("Localizable", "alert.operatorsUnavailable.message")
      /// We’re sorry
      public static let title = L10n.tr("Localizable", "alert.operatorsUnavailable.title")
    }
    public enum Unexpected {
      /// Please try again later.
      public static let message = L10n.tr("Localizable", "alert.unexpected.message")
      /// We're sorry, there has been an unexpected error.
      public static let title = L10n.tr("Localizable", "alert.unexpected.title")
    }
  }

  public enum Chat {
    /// Chat
    public static let title = L10n.tr("Localizable", "chat.title")
    public enum EndButton {
      /// End
      public static let title = L10n.tr("Localizable", "chat.endButton.title")
    }
    public enum Message {
      /// Enter Message
      public static let placeholder = L10n.tr("Localizable", "chat.message.placeholder")
    }
  }

  public enum Queue {
    public enum Connected {
      /// {operatorName}
      public static let text1 = L10n.tr("Localizable", "queue.connected.text1")
      /// {operatorName} has joined the conversation.
      public static let text2 = L10n.tr("Localizable", "queue.connected.text2")
    }
    public enum Connecting {
      /// Connecting with operator
      public static let text1 = L10n.tr("Localizable", "queue.connecting.text1")
      /// 
      public static let text2 = L10n.tr("Localizable", "queue.connecting.text2")
    }
    public enum Waiting {
      /// CompanyName
      public static let text1 = L10n.tr("Localizable", "queue.waiting.text1")
      /// An MSR will be with you shortly.
      public static let text2 = L10n.tr("Localizable", "queue.waiting.text2")
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
