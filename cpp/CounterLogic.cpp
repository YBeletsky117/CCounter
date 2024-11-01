#include "CounterLogic.h"
#include <thread>
#include <chrono>
#include <iostream>

// PUBLIC
CounterLogic::CounterLogic(
    double initialValue,
    double limit,
    double loop_time_interval_seconds,
    double loop_count_of_rubies_in_time_interval,
    std::function<void(double)> onValueUpdate,
    std::function<void(double)> onLimitReached
):
    value(initialValue),
    limit(limit),
    running(false),
    loop_time_interval_seconds(loop_time_interval_seconds),
    loop_count_of_rubies_in_time_interval(loop_count_of_rubies_in_time_interval),
    onLimitReached(onLimitReached),
    onValueUpdate(onValueUpdate) {
        std::cout << "TUTA: C++: CounterLogic init" << std::endl;
}

void CounterLogic::start() {
    running = true;
    std::cout << "TUTA: C++: start" << std::endl;
    std::thread([this]() { this->updateLoop(); }).detach();
}

void CounterLogic::stop() {
    std::cout << "TUTA: C++: stop" << std::endl;
    running = false;
}

void CounterLogic::setValue(double newValue) {
    std::cout << "TUTA: C++: setValue - new: " << newValue << ", old: " << value << std::endl;
    value = newValue;
}

double CounterLogic::getValue() {
    return value;
}

void CounterLogic::setLimit(double newLimit) {
    std::cout << "TUTA: C++: setLimit - new: " << newLimit << ", old: " << limit << std::endl;
    limit = newLimit;
}

void CounterLogic::setLoopTimeIntervalSeconds(double newValue) {
    std::cout << "TUTA: C++: setLoopTimeIntervalSeconds - new: " << newValue << ", old: " << limit << std::endl;
    loop_time_interval_seconds = newValue;
}

void CounterLogic::setLoopCountOfRubiesInTimeIntervalSeconds(double newValue) {
    std::cout << "TUTA: C++: setLoopCountOfRubiesInTimeIntervalSeconds - new: " << newValue << ", old: " << limit << std::endl;
    loop_count_of_rubies_in_time_interval = newValue;
}

// PRIVATE
void CounterLogic::updateLoop() {
    while (running) {
        if (loop_count_of_rubies_in_time_interval > 0) {
            std::this_thread::sleep_for(std::chrono::duration<double>(loop_time_interval_seconds));

            value += loop_count_of_rubies_in_time_interval;

            if (value >= limit) {
                value = limit;
                onLimitReached(value);
                stop();
            }

            if (onValueUpdate) {
                onValueUpdate(value);
            }
        } else {
            std::this_thread::sleep_for(std::chrono::duration<double>(loop_time_interval_seconds));
        }
    }

    if (!running) {
        value = 0;
    }
}

