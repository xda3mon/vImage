#ifndef BELL_DETECTION_H
#define BELL_DETECTION_H

#include "bell_mouth.h"
#include "detect/face_detection_seeta.h"

using namespace std;
using namespace seeta;

/// input and output structure type
//enum ColorType {BGRA = 0, RGBA};
//
//struct BoundingBox {
//    int x;
//    int y;
//    int width;
//    int height;
//};
//
//struct FaceDetectInput {
//    unsigned char *image_buffer;
//    int width;
//    int height;
//    ColorType color_type;
//    BoundingBox desired_bbox;
//    float min_coselection_rate = 0.7;
//};
//
//struct FaceDetectOutput {
//    bool has_face;
//    bool in_bbox;
//    BoundingBox real_bbox;
//};

/** @brief Detect the user's face by real time
 *  @param 
 *  @return bool
 */
int DetectFace(FaceDetectInput *fdi, FaceDetectOutput *fdo);

/** @brief Calculate the coincidence rate of the desired bounding box and the real bounding box
 *  @param 
 *  @return bool
 */
float ComputeCoselectionRate(BoundingBox& real_bbox, BoundingBox& desired_bbox);

/** @brief If it exists multiple faces, choose the middle one
 *  @param 
 *  @return FaceInfo
 */
int ChooseMiddleFace(vector<FaceInfo> faces, int image_width, int image_height);

#endif  // BELL_DETECTION_H
