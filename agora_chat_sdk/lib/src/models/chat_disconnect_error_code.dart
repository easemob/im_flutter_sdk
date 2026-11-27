// ignore_for_file: constant_identifier_names

/// ~english
/// The reason codes carried by [ConnectionEventHandler.onDisconnected].
///
/// The values are identical to the platform SDK error codes, and the SDK passes
/// them through unchanged, so a code that is not listed here may still be received.
///
/// The reasons fall into two groups:
/// - Logout reasons: the local login state is no longer valid and the user has to log in again.
/// - Connection reasons: the connection broke while the user stays logged in, and the SDK reconnects automatically.
///
/// Note: an expired token does not trigger [ConnectionEventHandler.onDisconnected];
/// it is reported by [ConnectionEventHandler.onTokenDidExpire] instead.
/// ~end
///
/// ~chinese
/// [ConnectionEventHandler.onDisconnected] 携带的断开原因码。
///
/// 数值与平台 SDK 的错误码一致，SDK 原样透传，因此这里未列出的原因码也可能收到。
///
/// 原因分为两类：
/// - 退出原因：本地登录态已失效，需要重新登录；
/// - 连接原因：连接中断但用户仍处于登录态，SDK 会自动重连。
///
/// 注意：token 过期不会触发 [ConnectionEventHandler.onDisconnected]，
/// 而是通过 [ConnectionEventHandler.onTokenDidExpire] 通知。
/// ~end
abstract final class ChatDisconnectErrorCode {
  // Logout reasons.

  /// ~english
  /// The daily active users (DAU) or monthly active users (MAU) of the app has reached the upper limit.
  /// ~end
  ///
  /// ~chinese
  /// 应用的日活跃用户数（DAU）或月活跃用户数（MAU）达到上限。
  /// ~end
  static const int APP_ACTIVE_NUMBER_REACH_LIMITATION = 8;

  /// ~english
  /// The token does not match the login information.
  /// ~end
  ///
  /// ~chinese
  /// token 与登录信息不匹配。
  /// ~end
  static const int INVALID_TOKEN = 104;

  /// ~english
  /// The parameters used to set up the connection are invalid.
  /// ~end
  ///
  /// ~chinese
  /// 建立连接所用的参数无效。
  /// ~end
  static const int INVALID_PARAM = 110;

  /// ~english
  /// The user does not exist.
  /// ~end
  ///
  /// ~chinese
  /// 用户不存在。
  /// ~end
  static const int USER_NOT_FOUND = 204;

  /// ~english
  /// The current account is logged in on another device.
  ///
  /// This is the only reason that may carry device information, see the `info`
  /// parameter of [ConnectionEventHandler.onDisconnected].
  /// ~end
  ///
  /// ~chinese
  /// 当前账号在其他设备登录。
  ///
  /// 这是唯一可能携带设备信息的原因，见 [ConnectionEventHandler.onDisconnected] 的 `info` 参数。
  /// ~end
  static const int USER_LOGIN_ANOTHER_DEVICE = 206;

  /// ~english
  /// The current account has been removed from the server.
  /// ~end
  ///
  /// ~chinese
  /// 当前账号已被服务器删除。
  /// ~end
  static const int USER_REMOVED = 207;

  /// ~english
  /// The account is bound to another device and cannot log in on this device.
  /// ~end
  ///
  /// ~chinese
  /// 账号已与其他设备绑定，无法在本设备登录。
  /// ~end
  static const int USER_BIND_ANOTHER_DEVICE = 213;

  /// ~english
  /// The number of devices the account is logged in on exceeds the limit.
  /// ~end
  ///
  /// ~chinese
  /// 账号登录的设备数超过限制。
  /// ~end
  static const int USER_LOGIN_TOO_MANY_DEVICES = 214;

  /// ~english
  /// The password of the current account has been changed.
  /// ~end
  ///
  /// ~chinese
  /// 当前账号的密码已被修改。
  /// ~end
  static const int USER_KICKED_BY_CHANGE_PASSWORD = 216;

  /// ~english
  /// The current account is kicked offline by another device.
  /// ~end
  ///
  /// ~chinese
  /// 当前账号被其他设备踢下线。
  /// ~end
  static const int USER_KICKED_BY_OTHER_DEVICE = 217;

  /// ~english
  /// The login device differs from the previous one, and the user has to log in again.
  ///
  /// This reason takes effect only when the server enables the option that does
  /// not kick the other devices offline.
  /// ~end
  ///
  /// ~chinese
  /// 登录设备与上次不同，需要重新登录。
  ///
  /// 仅在服务端开启「不踢掉其他设备上的登录」开关时生效。
  /// ~end
  static const int USER_DEVICE_CHANGED = 220;

  /// ~english
  /// No available server address can be obtained.
  /// ~end
  ///
  /// ~chinese
  /// 无法获取可用的服务器地址。
  /// ~end
  static const int SERVER_GET_DNSLIST_FAILED = 304;

  /// ~english
  /// The service of the app is restricted by the server.
  /// ~end
  ///
  /// ~chinese
  /// 应用的服务被服务器禁用。
  /// ~end
  static const int SERVER_SERVICE_RESTRICTED = 305;

  // Connection reasons: the user stays logged in and the SDK reconnects automatically.

  /// ~english
  /// The network is unavailable.
  ///
  /// On iOS a network disconnection is reported without a reason code, so the
  /// callback receives `null` instead of this value.
  /// ~end
  ///
  /// ~chinese
  /// 网络不可用。
  ///
  /// iOS 的网络断开不携带原因码，此时回调收到的是 `null` 而不是该值。
  /// ~end
  static const int NETWORK_ERROR = 2;

  /// ~english
  /// The number of users or the service quota of the app exceeds the limit.
  /// ~end
  ///
  /// ~chinese
  /// 应用的用户数或服务额度超限。
  /// ~end
  static const int EXCEED_SERVICE_LIMIT = 4;

  /// ~english
  /// The server is not reachable, for example the connection timed out, the DNS
  /// resolution failed, or the connection was refused.
  ///
  /// This is the most common reason under an unstable network.
  /// ~end
  ///
  /// ~chinese
  /// 无法连接服务器，例如连接超时、DNS 解析失败或连接被拒绝。
  ///
  /// 这是弱网下最常见的原因。
  /// ~end
  static const int SERVER_NOT_REACHABLE = 300;

  /// ~english
  /// An unknown server error occurred, for example an IO error or an unexpected
  /// closing of the connection stream.
  /// ~end
  ///
  /// ~chinese
  /// 发生未知的服务器错误，例如 IO 错误或连接流异常关闭。
  /// ~end
  static const int SERVER_UNKNOWN_ERROR = 303;

  /// ~english
  /// The transfer decryption failed.
  /// ~end
  ///
  /// ~chinese
  /// 传输解密失败。
  /// ~end
  static const int SERVER_DECRYPTION_FAILED = 306;
}
