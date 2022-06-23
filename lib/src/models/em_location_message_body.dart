import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// 位置消息类。
///
class EMLocationMessageBody extends EMMessageBody {
  ///
  /// 创建一个位置消息体实例。
  ///
  /// Param [latitude] 纬度。
  ///
  /// Param [longitude] 经度。
  ///
  /// Param [address] 地址。
  ///
  /// Param [buildingName] 建筑物名称。
  ///
  EMLocationMessageBody({
    required this.latitude,
    required this.longitude,
    String? address,
    String? buildingName,
  }) : super(type: MessageType.LOCATION) {
    _address = address;
    _buildingName = buildingName;
  }

  /// @nodoc
  EMLocationMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.LOCATION) {
    this.latitude = map.getDoubleValue("latitude", defaultValue: 0.0)!;
    this.longitude = map.getDoubleValue("longitude", defaultValue: 0.0)!;
    this._address = map.getStringValue("address");
    this._buildingName = map.getStringValue("buildingName");
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data.setValueWithOutNull("address", this._address);
    data.setValueWithOutNull("buildingName", this._buildingName);
    return data;
  }

  String? _address;
  String? _buildingName;

  /// 地址。
  String? get address => _address;

  /// 建筑物名称。
  String? get buildingName => _buildingName;

  /// 纬度。
  late final double latitude;

  /// 经度。
  late final double longitude;
}
