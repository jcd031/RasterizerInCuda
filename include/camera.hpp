#ifndef CAMERA_H
#define CAMERA_H
#include <math.h>

#include "../include/geometry.hpp"

class camera
{
   public:
      Matrix44f matrix;

      camera(
         float a,
         float b,
         float c,
         float d,
         float e,
         float f,
         float g,
         float h,
         float i,
         float j,
         float k,
         float l,
         float m,
         float n,
         float o,
         float p
      );

      // Relative Transform
      void translateR(float x, float y, float z);

      // Relative Transform, radians
      void rotateR(float x, float y, float z);
};

#endif
