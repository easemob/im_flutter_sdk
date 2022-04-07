import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// The location message body.
///
class EMLocationMessageBody extends EMMessageBody {
  ///
  /// Creates a location message body.
  ///
  /// Param [latitude] The latitude.
  ///
  /// Param [longitude] The longitude.
  ///
  /// Param [address] The address.
  ///
  /// Param [buildingName] The building name.
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

  EMLocationMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.LOCATION) {
    this.latitude = map.getDoubleValue("latitude", defaultValue: 0.0)!;
    this.longitude = map.getDoubleValue("longitude", defaultValue: 0.0)!;
    this._address = map.getStringValue("address");
    this._buildingName = map.getStringValue("buildingName");
  }

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

  /// The address.
  String? get address => _address;

  /// The building name.
  String? get buildingName => _buildingName;

  /// The latitude.
  late final double latitude;

  /// The longitude.
  late final double longitude;
}
