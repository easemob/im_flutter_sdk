import '../internal/em_transform_tools.dart';

import 'em_chat_enums.dart';
import '../tools/em_extension.dart';

///
/// 创建群组时的属性配置类。
///
class EMGroupOptions {
  ///
  /// 设置群组属性。
  ///
  /// Param [style] 群组的类型。详见 {EMGroupStyle}。
  ///
  /// Param [count] 群组的最大成员数，默认为 200。
  ///
  /// Param [inviteNeedConfirm] 邀请用户进群是否需要对方同意。收到邀请是否自动入群取决于两个设置：创建群组时设置 inviteNeedConfirm 以及通过 {@link EMOptions#setAutoAcceptGroupInvitation(boolean)} 确定是否自动接受加群邀请。
  /// 具体使用如下：
  ///（1）如果 inviteNeedConfirm 设置为 'false'，在服务端直接加受邀人进群，
  /// 与受邀人对 {@link EMOptions#setAutoAcceptGroupInvitation(boolean)} 的设置无关。
  /// (2) 如果 inviteNeedConfirm 设置为 'true'，是否自动入群取决于被邀请人对 {@link EMOptions#setAutoAcceptGroupInvitation(boolean)} 的设置。
  /// {@link EMOptions#setAutoAcceptGroupInvitation(boolean)} 为 SDK 级别操作，设置为 'true' 时，受邀人收到入群邀请后，SDK 在内部调用同意入群的 API，
  /// 自动接受邀请入群；
  /// 若设置为 'false'，即非自动同意其邀请，用户可以选择接受邀请进群，也可选择拒绝邀请。
  ///
  /// Param [extension] 群组详情扩展，可以采用 JSON 格式，以包含更多群信息。
  ///
  EMGroupOptions({
    this.style = EMGroupStyle.PrivateOnlyOwnerInvite,
    this.maxCount = 200,
    this.inviteNeedConfirm = false,
    this.ext,
  });

  /// 群组类型。
  final EMGroupStyle style;

  /// 群组的最大人数上限。
  final int maxCount;

  ///
  /// 邀请用户进群是否需要对方同意。收到邀请是否自动入群取决于两个设置：创建群组时设置 inviteNeedConfirm 以及通过 {@link EMOptions#setAutoAcceptGroupInvitation(boolean)} 确定是否自动接受加群邀请。
  /// 具体使用如下：
  ///（1）如果 inviteNeedConfirm 设置为 'false'，在服务端直接加受邀人进群，
  /// 与受邀人对 {@link EMOptions#setAutoAcceptGroupInvitation(boolean)} 的设置无关。
  /// (2) 如果 inviteNeedConfirm 设置为 'true'，是否自动入群取决于被邀请人对 {@link EMOptions#setAutoAcceptGroupInvitation(boolean)} 的设置。
  /// {@link EMOptions#setAutoAcceptGroupInvitation(boolean)} 为 SDK 级别操作，设置为 'true' 时，受邀人收到入群邀请后，SDK 在内部调用同意入群的 API，自动接受邀请入群；
  /// 若设置为 'false'，即非自动同意其邀请，用户可以选择接受邀请进群，也可选择拒绝邀请。
  ///
  /// **Return** 邀请用户进群是否需要对方同意。
  ///
  final bool inviteNeedConfirm;

  /// 群 extension
  final String? ext;

  /// @nodoc
  Map toJson() {
    Map data = Map();
    data['style'] = groupStyleTypeToInt(style);
    data['maxCount'] = maxCount;
    data['inviteNeedConfirm'] = inviteNeedConfirm;
    data.setValueWithOutNull("ext", ext);
    return data;
  }

  @override
  String toString() {
    return this.toJson().toString();
  }
}
