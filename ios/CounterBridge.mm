#import "CounterBridge.h"
#import "../cpp/CounterLogic.h"

@interface CounterBridge()
@property (nonatomic) CounterLogic *counterLogic;
@end

@implementation CounterBridge

- (instancetype)initWithInitialValue:(double)initialValue loop_time_interval_seconds:(double)loop_time_interval_seconds loop_count_of_rubies_in_time_interval:(double)loop_count_of_rubies_in_time_interval limit:(double)limit {
    self = [super init];
    if (self) {
        __weak CounterBridge *weakSelf = self;

        auto onValueUpdateCallback = [weakSelf](double value) {
            CounterBridge *strongSelf = weakSelf;
            if (strongSelf) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (strongSelf.onUpdateBlock) {
                        strongSelf.onUpdateBlock(value); // Вызов блока
                    }
                });
            }
        };
        
        auto onLimitReachedCallback = [weakSelf](double value) {
            CounterBridge *strongSelf = weakSelf;
            if (strongSelf) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (strongSelf.onLimitReachedBlock) {
                        strongSelf.onLimitReachedBlock(value); // Вызов блока
                    }
                });
            }
        };

        _counterLogic = new CounterLogic(initialValue, limit,loop_time_interval_seconds, loop_count_of_rubies_in_time_interval,
                                         onValueUpdateCallback, onLimitReachedCallback);
    }
    return self;
}

- (void)start {
    _counterLogic->start();
}

- (void)stop {
    _counterLogic->stop();
}

- (void)updateLimit:(double)newLimit {
    if (_counterLogic) {
        _counterLogic->setLimit(newLimit); // Устанавливаем новое значение ограничения
    }
}

- (void)updateValue:(double)newValue {
    _counterLogic->setValue(newValue);
}

- (void)updateLoopTimeIntervalSeconds:(double)newValue {
    _counterLogic->setLoopTimeIntervalSeconds(newValue);
}

- (void)updateCounterCountRubies:(double)newValue {
    _counterLogic->setLoopCountOfRubiesInTimeIntervalSeconds(newValue);
}

- (double)getValue {
    return _counterLogic->getValue();
}

@end
