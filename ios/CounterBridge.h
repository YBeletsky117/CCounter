#import <Foundation/Foundation.h>

@interface CounterBridge : NSObject

@property (nonatomic, copy) void (^onUpdateBlock)(double); // Блок для обновления в Swift
@property (nonatomic, copy) void (^onLimitReachedBlock)(double);

- (instancetype)initWithInitialValue:(double)initialValue loop_time_interval_seconds:(double)loop_time_interval_seconds loop_count_of_rubies_in_time_interval:(double)loop_count_of_rubies_in_time_interval limit:(double)limit;
- (void)start;
- (void)stop;
- (void)updateValue:(double)newValue;
- (double)getValue;
- (void)updateLimit:(double)newLimit;
- (void)updateLoopTimeIntervalSeconds:(double)newValue;
- (void)updateCounterCountRubies:(double)newValue;

@end
