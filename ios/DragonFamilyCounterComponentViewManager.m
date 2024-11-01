#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(DragonFamilyCounterComponentViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(initialAnimationDuration, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(color, NSString)
RCT_EXPORT_VIEW_PROPERTY(fontSize, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(timeInterval, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(countOfRubiesInInterval, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(initialValue, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(limit, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(textStyle, NSDictionary)

RCT_EXPORT_VIEW_PROPERTY(onLimitReached, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(thousandsSeparatorSpacing, NSNumber)

@end
