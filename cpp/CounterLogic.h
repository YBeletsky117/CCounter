#ifndef COUNTER_LOGIC_H
#define COUNTER_LOGIC_H

#include <functional>

class CounterLogic {
public:
    CounterLogic(
        double initialValue,
        double limit,
        double loop_time_interval_seconds,
        double loop_count_of_rubies_in_time_interval,
        std::function<void(double)> onValueUpdate,
        std::function<void(double)> onLimitReached
    );

    void start();
    void stop();
    void setValue(double newValue);
    double getValue();
    void setLimit(double newLimit);
    void setLoopTimeIntervalSeconds(double value);
    void setLoopCountOfRubiesInTimeIntervalSeconds(double value);

private:
    void updateLoop();

    // Интервал времени счёта
    double loop_time_interval_seconds; // default: 1 second
    // Кол-во инкрементируемых рубинов во временной интервал
    double loop_count_of_rubies_in_time_interval;

    double value;
    double limit;
    bool running;
    std::function<void(double)> onValueUpdate;
    std::function<void(double)> onLimitReached;
};

#endif /* COUNTER_LOGIC_H */
