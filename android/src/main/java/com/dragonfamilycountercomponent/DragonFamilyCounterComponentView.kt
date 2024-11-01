package com.dragonfamilycountercomponent

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ScaleXSpan
import android.util.AttributeSet
import android.util.Log
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale
import java.util.Timer
import kotlin.concurrent.schedule
import kotlin.math.log

class DragonFamilyCounterComponentView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyle: Int = 0
) : FrameLayout(context, attrs, defStyle) {

    private val textView: TextView

    var onLimitReached: ((Int) -> Unit)? = null

    private var initialAnimationTimer: Timer? = null
    private var targetValue: Double = 0.0
    private var counterBridge: CounterBridge? = null
    private var displayLinkTimer: Timer? = null
    private var startTime: Long = 0L

    // Outside parameters
    private var thousandsSeparatorSpacing: Float = 0f
    private var initialValue: Double = 0.0
    private var limit: Int = 1000
    private var timeInterval: Double = 1.0
    private var initialAnimationDuration: Double = 1000.0
    private var textStyle: Map<String, Any> = emptyMap()

    fun update_thousandsSeparatorSpacing(value: Float) {
        thousandsSeparatorSpacing = value
        updateTextViewWithFormattedValue(targetValue)
        requestLayout()
    }

    fun update_initialValue(value: Double) {
        initialValue = value
        restart()
    }

    fun sendOnLimitReachedEvent() {
        val reactContext = context as ReactContext
        reactContext.getJSModule(RCTEventEmitter::class.java)
            .receiveEvent(id, "onLimitReached", null)
    }

    fun update_limit(value: Int) {
        limit = value
        counterBridge?.updateLimit(value.toDouble())
        restart()
        requestLayout()
    }

    fun update_timeInterval(value: Double) {
        timeInterval = value
        counterBridge?.updateLoopTimeIntervalSeconds(value)
        requestLayout()
    }

    fun update_countOfRubiesInInterval(value: Double) {
        counterBridge?.updateCounterCountRubies(value)
        requestLayout()
    }

    fun update_initialAnimationDuration(value: Double) {
        initialAnimationDuration = value
        initialAnimationTimer?.cancel()
        requestLayout()
    }

    fun update_textStyle(value: Map<String, Any>) {
        textStyle = value
        applyTextStyle(textView)
        requestLayout()
    }

    init {
        textView = TextView(context).apply {
            text = ""
            textSize = 18f
            setSingleLine(true)
            maxLines = 1
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT
            )
            gravity = Gravity.CENTER
        }
        applyTextStyle(textView)
        addView(textView)
        setupCounterBridge()
    }

    private fun restart() {
        counterBridge?.stop()
        if (initialValue >= 1) {
            animateToInitialValue()
        } else {
            counterBridge?.updateValue(initialValue.toDouble())
        }
    }

    private fun setupCounterBridge() {
        counterBridge = CounterBridge(
            context,
            onLimitReached = {
                onLimitReached?.invoke(it.toInt())
            },
            onValueUpdate = { newValue -> post {
                textView.text = formatNumberWithThousandsSeparator(newValue)
            } }
        )
    }

    private fun updateTextViewWithFormattedValue(value: Double) {
        targetValue = value
        textView.text = formatNumberWithThousandsSeparator(value)
    }

    private fun formatNumberWithThousandsSeparator(value: Double): SpannableStringBuilder {
        val formatter = DecimalFormat("#,###", DecimalFormatSymbols(Locale.US))
        val formatted = formatter.format(value).replace(",", " ")

        val spannableString = SpannableStringBuilder(formatted)

        for (i in formatted.indices) {
            if (formatted[i] == ' ') {
                spannableString.setSpan(
                    ScaleXSpan(thousandsSeparatorSpacing * 0.08f), // Устанавливаем расстояние
                    i,
                    i + 1,
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                )
            }
        }

        return spannableString
    }


    private fun animateToInitialValue() {
        targetValue = initialValue
        startTime = System.currentTimeMillis()
        displayLinkTimer = Timer()
        displayLinkTimer?.schedule(0, 16) {
            post {
                updateAnimation()
            }
        }
    }

    private fun updateAnimation() {
        val animationDuration = initialAnimationDuration
        val elapsedTime = (System.currentTimeMillis() - startTime) / 1000.0
        val progress = (elapsedTime / animationDuration).coerceAtMost(1.0)
        val tempValue = (targetValue * progress)

        textView.text = formatNumberWithThousandsSeparator(tempValue)

        if (progress == 1.0) {
            displayLinkTimer?.cancel()
            displayLinkTimer = null
            startRegularAnimation()
        }
    }

    private fun startRegularAnimation() {
        if (initialValue >= 1) {
            setupCounterLogic()
            counterBridge?.start()
        }
    }

    private fun setupCounterLogic() {
        counterBridge?.initWithInitialValue(initialValue.toDouble(), limit.toDouble(), timeInterval, 0.0)
    }

    private fun applyTextStyle(label: TextView) {
        val fontFamily = textStyle["fontFamily"] as? String
        val fontSize = textStyle["fontSize"] as? Float ?: 16f
        val fontWeight = textStyle["fontWeight"] as? String
        val colorHex = textStyle["color"] as? String
        val letterSpacing = textStyle["letterSpacing"] as? Float

        if (fontFamily != null) {
            val typeface = if (fontWeight != null) {
                Typeface.create(fontFamily, fontWeightFromString(fontWeight))
            } else {
                Typeface.create(fontFamily, Typeface.NORMAL)
            }
            label.typeface = typeface
        }

        label.textSize = fontSize

        colorHex?.let {
            label.setTextColor(Color.parseColor(it))
        }

        letterSpacing?.let {
            label.letterSpacing = it
        }
    }

    private fun fontWeightFromString(weight: String): Int {
        return when (weight.toLowerCase()) {
            "regular" -> Typeface.NORMAL
            "medium" -> Typeface.BOLD
            "semibold" -> Typeface.BOLD
            "bold" -> Typeface.BOLD
            "heavy" -> Typeface.BOLD
            "black" -> Typeface.BOLD
            else -> Typeface.NORMAL
        }
    }
}
