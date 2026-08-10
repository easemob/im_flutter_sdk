/**
 *  \~chinese
 *  @header EMPageResult.h
 *  @abstract 分段结果类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMPageResult.h
 *  @abstract The subsection result.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

/**
 *  \~chinese
 *  分段结果类，用于封装服务器返回的数据。
 *
 *  \~english
 *  The sub-section result.
 */
@interface EMPageResult<__covariant ObjectType> : NSObject

/**
 *  \~chinese
 *  结果列表。
 *
 *  \~english
 *  The result list.
 */
@property (nonatomic, strong) NSArray<ObjectType> *_Nullable list;

/**
 *  \~chinese
 *  当前列表数目。
 *
 *  \~english
 *  The count of the current list.
 */
@property (nonatomic) NSInteger count;

/**
 *  \~chinese
 *  创建实例。
 *
 *  @param aList    结果列表。
 *  @param aCount   获取当前列表数目。
 *
 *  @result 分段结果的实例。
 *
 *  \~english
 *  Gets the result instance.
 *
 *  @param aList    The result list. 
 *  @param aCount   The count of current list.
 *
 *  @result         The instance of cursor result.
 */
+ (instancetype _Nonnull)pageResultWithList:(NSArray<ObjectType> * _Nullable)aList
                          andCount:(NSInteger)aCount;

@end
