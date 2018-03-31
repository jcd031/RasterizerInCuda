#include "../include/camera.hpp"

camera::camera(
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
      )
{
   matrix = Matrix44f(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p).inverse();
};

// Relative Transform
void camera::translateR(float x, float y, float z)
{
   matrix[3][0] += x;
   matrix[3][1] += y;
   matrix[3][2] += z;
};

// Relative Transform, radians
void camera::rotateR(float x, float y, float z)
{
   Matrix44f rotation = Matrix44f
      (
       cos(z)*cos(y)+sin(z)*sin(x)*sin(y), -sin(z)*cos(x), sin(z)*sin(x)*cos(y)-cos(z)*sin(y), 0,
       sin(z)*cos(y)-cos(z)*sin(x)*sin(y), cos(z)*cos(x), -cos(z)*sin(x)*cos(y)-sin(z)*sin(y), 0,
       cos(x)*sin(y), sin(x), cos(x)*cos(y), 0,
       0, 0, 0, 1
      );

   Matrix44f::multiply(matrix, rotation, matrix);
};
