package com.dragonfamilycountercomponent

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

@ReactModule(name = DragonFamilyCounterComponentViewManager.NAME)
class DragonFamilyCounterComponentViewManager : SimpleViewManager<DragonFamilyCounterComponentView>() {
    override fun getName() = NAME

    override fun createViewInstance(reactContext: ThemedReactContext): DragonFamilyCounterComponentView {
        val view = DragonFamilyCounterComponentView(reactContext)

        view.onLimitReached = {
            view.sendOnLimitReachedEvent()
        }
        return view
    }

    @ReactProp(name = "initialAnimationDuration")
    fun setInitialAnimationDuration(view: DragonFamilyCounterComponentView, duration: Int) {
        view.update_initialAnimationDuration(duration.toDouble())
    }

    @ReactProp(name = "timeInterval")
    fun setTimeInterval(view: DragonFamilyCounterComponentView, interval: Int) {
        view.update_timeInterval(interval.toDouble())
    }

    @ReactProp(name = "countOfRubiesInInterval")
    fun setCountOfRubiesInInterval(view: DragonFamilyCounterComponentView, count: Double) {
        view.update_countOfRubiesInInterval(count)
    }

    @ReactProp(name = "initialValue")
    fun setInitialValue(view: DragonFamilyCounterComponentView, initialValue: Double) {
        view.update_initialValue(initialValue)
    }

    @ReactProp(name = "limit")
    fun setLimit(view: DragonFamilyCounterComponentView, limit: Int) {
        view.update_limit(limit)
    }

    @ReactProp(name = "textStyle")
    fun setTextStyle(view: DragonFamilyCounterComponentView, textStyle: ReadableMap) {
        val textStyleMap = mutableMapOf<String, Any>()
        if (textStyle.hasKey("fontFamily")) textStyleMap["fontFamily"] = textStyle.getString("fontFamily") ?: ""
        if (textStyle.hasKey("fontSize")) textStyleMap["fontSize"] = textStyle.getDouble("fontSize").toFloat()
        if (textStyle.hasKey("color")) textStyleMap["color"] = textStyle.getString("color") ?: "#000000"
        view.update_textStyle(textStyleMap)
    }

    @ReactProp(name = "thousandsSeparatorSpacing")
    fun setThousandsSeparatorSpacing(view: DragonFamilyCounterComponentView, spacing: Float) {
        view.update_thousandsSeparatorSpacing(spacing)
    }

    override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any>? {
        val event = mutableMapOf<String, Any>(
            "onLimitReached" to mutableMapOf("registrationName" to "onLimitReached")
        )
        return event
    }

    companion object {
        const val NAME = "DragonFamilyCounterComponentView"
    }
}