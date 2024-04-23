/**
 *  \~chinese 
 *  @header     EMCursorResult.h
 *  @abstract   分段结果对象
 *  @author     Hyphenate
 *  @version    3.00
 *
 *  \~english
 *  @header     EMCursorResult.h
 *  @abstract   Subsection result
 *  @author     Hyphenate
 *  @version    3.00
 */

#import <Foundation/Foundation.h>

/**
 *  \~chinese 
 *  分段显示结果对象。
 * 
 *  用于显示对话，群聊等查询结果。
 *
 *  \~english
 * 
 *  The EmCursorResult interface, which displays query results such as conversations and group chats.
 */
@interface EMCursorResult<__covariant ObjectType> : NSObject

/**
 *  \~chinese
 *  结果列表。
 *
 *  \~english
 *  The result list.
 */
@property (nonatomic, strong) NSArray<ObjectType> * _Nullable list;

/**
 *  \~chinese
 *  获取下一段结果的游标。
 *
 *  \~english
 *  The cursor for retrieving the result of the next section.
 */
@property (nonatomic, copy) NSString * _Nullable cursor;

/**
 *  \~chinese
 *  创建实例。
 *
 *  @param aList    结果列表。
 *  @param aCursor  获取下一段结果的游标。
 *
 *  @result 分段结果的实例。
 *
 *  \~english
 *  Gets the result instance.
 *
 *  @param aList    The result list.
 *  @param aCusror  The cursor for retrieving the result of the next section.
 *
 *  @result An instance of the cursor result.
 */
+ (instancetype _Nonnull)cursorResultWithList:(NSArray<ObjectType> * _Nullable)aList
                           andCursor:(NSString * _Nullable)aCusror;

@end
