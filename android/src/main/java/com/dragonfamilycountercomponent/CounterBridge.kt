package com.dragonfamilycountercomponent

import android.content.Context

class CounterBridge(
    context: Context,
    private var lastValue: Double = 0.0,
    private val onValueUpdate: (Double) -> Unit,
    private val onLimitReached: (Double) -> Unit
) {
    init {
        System.loadLibrary("dragon-family-counter-component")
        nativeInit()
    }

    external fun nativeInit()
    external fun initWithInitialValue(initialValue: Double, limit: Double, loopTimeIntervalSeconds: Double, loopCountOfRubiesInTimeInterval: Double)
    external fun start()
    external fun stop()
    external fun updateValue(newValue: Double)
    external fun updateLimit(newLimit: Double)
    external fun updateLoopTimeIntervalSeconds(newInterval: Double)
    external fun updateCounterCountRubies(newCount: Double)

    fun onValueUpdate(newValue: Double) {
        if (newValue != lastValue) {
            lastValue = newValue
            onValueUpdate.invoke(newValue)
        }
    }

    fun onLimitReached(value: Double) {
        onLimitReached.invoke(value)
    }
}
