#include <jni.h>
#include "../cpp/CounterLogic.h"
#include <memory>
#include <iostream>
#include <android/log.h>

#define LOG_TAG "TUTA"
#define LOGD(...) __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)


JavaVM *gJvm = nullptr;
jobject gCallbackObject = nullptr;

std::unique_ptr<CounterLogic> counterLogic;

extern "C" JNIEXPORT void JNICALL
Java_com_dragonfamilycountercomponent_CounterBridge_nativeInit(JNIEnv *env, jobject instance) {
    LOGD("C++: adapter: 'nativeInit' called");
    env->GetJavaVM(&gJvm);
    gCallbackObject = env->NewGlobalRef(instance);
}

extern "C" JNIEXPORT void JNICALL
Java_com_dragonfamilycountercomponent_CounterBridge_initWithInitialValue(JNIEnv *env, jobject instance,
                                                                       jdouble initialValue, jdouble limit,
                                                                       jdouble loopTimeIntervalSeconds,
                                                                       jdouble loopCountOfRubiesInTimeInterval) {
    LOGD("C++: adapter: 'initWithInitialValue' called with values");

    counterLogic = std::make_unique<CounterLogic>(
            initialValue,
            limit,
            loopTimeIntervalSeconds,
            loopCountOfRubiesInTimeInterval,
            [](double value) {
                LOGD("C++: adapter: Callback onValueUpdate called with value");
                std::cout << "Callback onValueUpdate called with value: " << value << std::endl;
                JNIEnv *env;
                gJvm->AttachCurrentThread(&env, nullptr);
                jclass clazz = env->GetObjectClass(gCallbackObject);
                jmethodID onValueUpdate = env->GetMethodID(clazz, "onValueUpdate", "(D)V");
                env->CallVoidMethod(gCallbackObject, onValueUpdate, value);
                gJvm->DetachCurrentThread();
            },
            [](double value) {
                LOGD("C++: adapter: Callback onLimitReached called with value");
                std::cout << "Callback onLimitReached called with value: " << value << std::endl;
                JNIEnv *env;
                gJvm->AttachCurrentThread(&env, nullptr);
                jclass clazz = env->GetObjectClass(gCallbackObject);
                jmethodID onLimitReached = env->GetMethodID(clazz, "onLimitReached", "(D)V");
                env->CallVoidMethod(gCallbackObject, onLimitReached, value);
                gJvm->DetachCurrentThread();
            });
}

extern "C" JNIEXPORT void JNICALL
Java_com_dragonfamilycountercomponent_CounterBridge_start(JNIEnv *env, jobject instance) {
    LOGD("C++: adapter: 'start' called");
    if (counterLogic) {
        counterLogic->start();
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_dragonfamilycountercomponent_CounterBridge_stop(JNIEnv *env, jobject instance) {
    LOGD("C++: adapter: 'stop' called");
    if (counterLogic) {
        counterLogic->stop();
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_dragonfamilycountercomponent_CounterBridge_updateLimit(JNIEnv *env, jobject instance, jdouble newLimit) {
    LOGD("C++: adapter: 'updateLimit' called with value");
    if (counterLogic) {
        counterLogic->setLimit(newLimit);
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_dragonfamilycountercomponent_CounterBridge_updateValue(JNIEnv *env, jobject instance, jdouble newValue) {
    LOGD("C++: adapter: 'updateValue' called with value");
    if (counterLogic) {
        counterLogic->setValue(newValue);
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_dragonfamilycountercomponent_CounterBridge_updateLoopTimeIntervalSeconds(JNIEnv *env, jobject instance, jdouble newInterval) {
    LOGD("C++: adapter: 'updateLoopTimeIntervalSeconds' called with value");
    if (counterLogic) {
        counterLogic->setLoopTimeIntervalSeconds(newInterval);
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_dragonfamilycountercomponent_CounterBridge_updateCounterCountRubies(JNIEnv *env, jobject instance, jdouble newCount) {
    LOGD("C++: adapter: 'updateCounterCountRubies' called with value");
    if (counterLogic) {
        counterLogic->setLoopCountOfRubiesInTimeIntervalSeconds(newCount);
    }
}
