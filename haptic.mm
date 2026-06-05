#include <napi.h>
#import <AppKit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>
#include <atomic>
#include <mutex>
#include <vector>

typedef const void *MTDeviceRef;

typedef struct {
  float x;
  float y;
} MTPoint;

typedef struct {
  MTPoint position;
  MTPoint velocity;
} MTVector;

typedef int MTTouchState;

typedef struct {
  int frame;
  double timestamp;
  int identifier;
  MTTouchState state;
  int fingerId;
  int handId;
  MTVector normalizedPosition;
  float total;
  float pressure;
  float angle;
  float majorAxis;
  float minorAxis;
  MTVector absolutePosition;
  int field14;
  int field15;
  float density;
} MTTouch;

typedef void (*MTFrameCallback)(MTDeviceRef, MTTouch[], int, double, int);

extern "C" {
CFArrayRef MTDeviceCreateList(void);
Boolean MTDeviceIsBuiltIn(MTDeviceRef device);
Boolean MTDeviceSupportsForce(MTDeviceRef device);
int MTDeviceStart(MTDeviceRef device, int mode);
int MTDeviceStop(MTDeviceRef device);
void MTDeviceRelease(MTDeviceRef device);
void MTRegisterContactFrameCallback(MTDeviceRef device, MTFrameCallback callback);
void MTUnregisterContactFrameCallback(MTDeviceRef device, MTFrameCallback callback);
}

static std::atomic<float> currentPressure(0.0f);
static std::atomic<bool> currentFingerPresent(false);
static std::once_flag sensorInitFlag;
static std::mutex sensorMutex;
static std::vector<MTDeviceRef> sensorDevices;

static void UpdateTouchState(MTTouch touches[], int numTouches) {
  bool hasTouch = touches && numTouches > 0;
  float pressure = hasTouch ? touches[0].pressure : 0.0f;
  currentFingerPresent.store(hasTouch, std::memory_order_relaxed);
  currentPressure.store(hasTouch ? pressure : 0.0f, std::memory_order_relaxed);
}

static void ContactFrameCallback(MTDeviceRef, MTTouch touches[], int numTouches, double, int) {
  UpdateTouchState(touches, numTouches);
}

static void InitializeSensors() {
  std::lock_guard<std::mutex> lock(sensorMutex);
  CFArrayRef devices = MTDeviceCreateList();
  if (!devices) return;
  CFIndex count = CFArrayGetCount(devices);
  for (CFIndex index = 0; index < count; ++index) {
    MTDeviceRef device = reinterpret_cast<MTDeviceRef>(CFArrayGetValueAtIndex(devices, index));
    if (!device || !MTDeviceIsBuiltIn(device) || !MTDeviceSupportsForce(device)) continue;
    CFRetain(device);
    sensorDevices.push_back(device);
    MTRegisterContactFrameCallback(device, ContactFrameCallback);
    MTDeviceStart(device, 0);
  }
  CFRelease(devices);
}

static void EnsureSensorsInitialized() {
  std::call_once(sensorInitFlag, InitializeSensors);
}

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

static Napi::Value GetPressure(const Napi::CallbackInfo& info) {
  EnsureSensorsInitialized();
  return Napi::Number::New(info.Env(), currentPressure.load(std::memory_order_relaxed));
}

static Napi::Value IsFingerPresent(const Napi::CallbackInfo& info) {
  EnsureSensorsInitialized();
  return Napi::Boolean::New(info.Env(), currentFingerPresent.load(std::memory_order_relaxed));
}

static Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports["perform"] = Napi::Function::New(env, Perform);
  exports["getPressure"] = Napi::Function::New(env, GetPressure);
  exports["isFingerPresent"] = Napi::Function::New(env, IsFingerPresent);
  return exports;
}

NODE_API_MODULE(macos_haptic, Init)
