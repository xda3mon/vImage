
#include <iostream>
#include <sstream>
#include <algorithm>
#include <cmath>
#include <limits>
#include "detect/face_detection.h"
#include "detect/detect_resource.h"
#include "detect/face_detection_seeta.h"

using namespace std;
using namespace seeta;

int DetectFace(FaceDetectInput *fdi, FaceDetectOutput *fdo) {
  if(fdi == NULL)
    return false;
  FaceDetectInput& face_detect = *fdi;
  FaceDetectOutput& face_output = *fdo;
  BoundingBox& desired_bbox = face_detect.desired_bbox;
  float min_coselection_rate = face_detect.min_coselection_rate;
  int image_width = face_detect.width;
  int image_height = face_detect.height;
  ImageData img_data(image_width, image_height);
  img_data.data = face_detect.image_buffer;
  img_data.num_channels = 1;
  FaceDetection detector = DetectResource::GetInstance().GetDetector();
  detector.SetMinFaceSize(40);
  detector.SetScoreThresh(2.f);
  detector.SetImagePyramidScaleFactor(0.8f);
  detector.SetWindowStep(4, 4);
  std::vector<FaceInfo> faces = detector.Detect(img_data); 
  // Compute coselection rate of two rects
  int max_inter_area = 0;
  float proportion_area = 0.0;
  int select_index = ChooseMiddleFace(faces, image_width, image_height);
  if(select_index == -1)
    return false;
  FaceInfo select_face = faces[select_index];
  BoundingBox& real_bbox = face_output.real_bbox;
  real_bbox.x = select_face.bbox.x;
  real_bbox.y = select_face.bbox.y;
  real_bbox.width = select_face.bbox.width;
  real_bbox.height = select_face.bbox.height;
  float ratio = ComputeCoselectionRate(real_bbox, desired_bbox);
  if(ratio > min_coselection_rate) {
    face_output.in_bbox = true;
  } else {
    face_output.in_bbox = false;
  }
  face_output.has_face = true;
  return true;
}

int ChooseMiddleFace(vector<FaceInfo> faces, int image_width, int image_height) {
  int num_face = static_cast<int>(faces.size());
  if(num_face <= 1)  return num_face - 1;
  int select_index = -1;
  float min_dis_to_center = numeric_limits<float>::max();
  for(int i = 0; i < num_face; i++) {
    Rect cur_bbox = faces[i].bbox;
    float cenetr_point_x = cur_bbox.x + cur_bbox.width / 2.0 - image_width / 2.0;
    float center_point_y = cur_bbox.y + cur_bbox.height / 2.0 - image_height / 2.0;
    float cur_dis = pow(cenetr_point_x, 2) + pow(center_point_y, 2);
    if(cur_dis < min_dis_to_center) {
      select_index = i;
      min_dis_to_center = cur_dis;
    }
  }
  return select_index;
}

float ComputeCoselectionRate(BoundingBox& real_bbox, BoundingBox& desired_bbox) {
  int x1 = real_bbox.x;
  int y1 = real_bbox.y;
  int width1 = real_bbox.width;
  int height1 = real_bbox.height;
  
  int x2 = desired_bbox.x;
  int y2 = desired_bbox.y;
  int width2 = desired_bbox.width;
  int height2 = desired_bbox.height;
  
  int endx = std::max(x1 + width1, x2 + width2);
  int startx = std::min(x1, x2);
  int width = width1 + width2 - (endx - startx);
  
  int endy = std::max(y1 + height1,y2 + height2);
  int starty = std::min(y1, y2);
  int height = height1 + height2 - (endy - starty);
  
  if(width <= 0 || height <= 0)  return 0;
  int coselection_area = width * height;
  int real_area = width1 * height1;
  return (float)coselection_area / (float)real_area;
}
