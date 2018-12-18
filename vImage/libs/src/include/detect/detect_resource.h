#ifndef BELL_DETECT_RESOURCE_H
#define BELL_DETECT_RESOURCE_H

#include "detect/face_detection_seeta.h"

using namespace seeta;

class DetectResource {
public:
  static DetectResource& GetInstance();
  FaceDetection GetDetector();

private:
  DetectResource() {};
  DetectResource(DetectResource const&) = delete;
  void operator=(DetectResource const&) = delete;
};

#endif //  BELL_DETECT_RESOURCE_H