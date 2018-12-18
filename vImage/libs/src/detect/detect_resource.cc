#include "detect/face_detection_seeta.h"
#include "detect/detect_resource.h"

using namespace seeta;

DetectResource& DetectResource::GetInstance() {
  static DetectResource instance;
  return instance;
}

FaceDetection DetectResource::GetDetector() {
  return FaceDetection();
}
