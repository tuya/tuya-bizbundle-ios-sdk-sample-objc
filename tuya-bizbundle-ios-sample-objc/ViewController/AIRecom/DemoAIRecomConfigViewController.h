#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoAIRecomConfigViewController : UIViewController
/// 应用启动时应用保存的功能配置，必须早于首次使用 AIRecom。
+ (void)applySavedAIRecomConfiguration;
@end

NS_ASSUME_NONNULL_END
