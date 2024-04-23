/**
 *  \~chinese
 *  @header EMLocationMessageBody.h
 *  @abstract 位置消息体
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMLocationMessageBody.h
 *  @abstract Location message body
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMMessageBody.h"

/**
 *  \~chinese
 *  位置消息体。
 *
 *  \~english
 *  The location message body.
 */
@interface EMLocationMessageBody : EMMessageBody

/**
 *  \~chinese
 *  纬度。
 *
 *  \~english
 *  The location latitude.
 */
@property (nonatomic) double latitude;

/**
 *  \~chinese
 *  经度。
 *
 *  \~english
 *  The location longitude.
 */
@property (nonatomic) double longitude;

/**
 *  \~chinese
 *  地址信息。
 *
 *  \~english
 *  The address.
 */
@property (nonatomic, copy) NSString * _Nullable address;

/**
 *  \~chinese
 *  建筑物名称
 *
 *  \~english
 *  buildingName
 */
@property (nonatomic, copy) NSString *_Nullable buildingName;

/**
 *  \~chinese
 *  初始化位置消息体
 *
 *  @param aLatitude   纬度。
 *  @param aLongitude  经度。
 *  @param aAddress    地理位置信息。
 *  
 *  @result 位置消息体实例。
 *
 *  \~english
 *  Initializes a location message body instance.
 *
 *  @param aLatitude   The latitude.
 *  @param aLongitude  The longitude.
 *  @param aAddress    The address.
 *
 *  @result The location message body instance.
 */
- (instancetype _Nonnull)initWithLatitude:(double)aLatitude
                       longitude:(double)aLongitude
                         address:(NSString * _Nullable)aAddress;
/*!
 *  \~chinese
 *  初始化位置消息体
 *
 *  @param aLatitude   纬度
 *  @param aLongitude  经度
 *  @param aAddress    地理位置信息
 *  @param aBuildingName    建筑物名称
 *
 *  @result 位置消息体实例
 *
 *  \~english
 *  Initialize a location message body instance
 *
 *  @param aLatitude   Latitude
 *  @param aLongitude  Longitude
 *  @param aAddress    Address
 *  @param aBuildingName    BuildingName
 *
 *  @result Location message body instance
 */
- (instancetype _Nonnull)initWithLatitude:(double)aLatitude
                       longitude:(double)aLongitude
                         address:(NSString *_Nullable)aAddress
                    buildingName:(NSString *_Nullable)aBuildingName;

@end
