#include <napi.h>
#import <AppKit/AppKit.h>

static NSHapticFeedbackPattern ParsePattern(const std::string& pattern) {
  if (pattern == "generic") return NSHapticFeedbackPatternGeneric;
  if (pattern == "alignment") return NSHapticFeedbackPatternAlignment;
  if (pattern == "levelChange") return NSHapticFeedbackPatternLevelChange;
  return NSHapticFeedbackPatternGeneric;
}

static Napi::Value Perform(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  if (info.Length() < 1 || !info[0].IsString()) {
    Napi::TypeError::New(env, "pattern must be a string").ThrowAsJavaScriptException();
    return env.Undefined();
  }
  [[NSHapticFeedbackManager defaultPerformer]
      performFeedbackPattern:ParsePattern(info[0].As<Napi::String>().Utf8Value())
             performanceTime:NSHapticFeedbackPerformanceTimeNow];
  return env.Undefined();
}

static Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports["perform"] = Napi::Function::New(env, Perform);
  return exports;
}

NODE_API_MODULE(macos_haptic, Init)
