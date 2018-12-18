#ifndef BELL_MOUTH_H
#define BELL_MOUTH_H

#ifdef __cplusplus
extern "C" {
#endif

#define BELL_VERSION 0.01
#define BELL_VERSION_STRING "0.01"
#ifndef BELL_EXPORT
# if defined(WIN32)
#  if defined(BELL_BUILD) && defined(DLL_EXPORT)
#   define BELL_EXPORT __declspec(dllexport)
#  else
#   define BELL_EXPORT
#  endif
# else
#  define BELL_EXPORT __attribute__ ((visibility ("default")))
# endif
#endif

// The structure of input and output
    typedef enum ColorType {BGRA = 0, RGBA} ColorType;
    
    typedef struct BoundingBox {
        int x;
        int y;
        int width;
        int height;
    } BoundingBox;
    
    typedef struct FaceDetectInput {
        unsigned char *image_buffer;
        int width;
        int height;
        ColorType color_type;
        BoundingBox desired_bbox;
        float min_coselection_rate;
    } FaceDetectInput;
    
    typedef struct FaceDetectOutput {
        int has_face;
        int in_bbox;
        BoundingBox real_bbox;
    } FaceDetectOutput;

/** @brief Detect the user's face by real time
 *  @param 
 *  @return bool
 */
BELL_EXPORT int DetectFace(FaceDetectInput *fdi, FaceDetectOutput *fdo);

#ifdef __cplusplus
}  // extern "C"
#endif

#endif  // BELL_MOUTH_H
