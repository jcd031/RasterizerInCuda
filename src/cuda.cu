#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <fstream>
#include <cmath>

#include "../include/obj.hpp"

// Project takes some 3D coordinates and transform them
// in 2D coordinates using the transformation matrix
__host__ __device__
void Project(Vec3f coord, Vec3i &ret, Matrix44f transMat, const uint32_t imageWidth, const uint32_t imageHeight, const uint32_t widthOffset, const uint32_t heightOffset)
{
   ret.z = coord.x * transMat.x[0][2] + coord.y * transMat.x[1][2] + coord.z * transMat.x[2][2] + transMat.x[3][2];
   float pCamerax = coord.x * transMat.x[0][0] + coord.y * transMat.x[1][0] + coord.z * transMat.x[2][0] + transMat.x[3][0];
   float pCameray = coord.x * transMat.x[0][1] + coord.y * transMat.x[1][1] + coord.z * transMat.x[2][1] + transMat.x[3][1];

   ret.x = (int)((pCamerax / -ret.z) * imageHeight + widthOffset); 
   ret.y = (int)((pCameray / ret.z) * imageHeight + heightOffset);
}

__host__ __device__
void setPixel(
      uint32_t * pixels,
      const int x,
      const int y,
      const int color,
      const uint32_t imageWidth,
      const uint32_t imageHeight
      )
{
   if (x >=0 && x < imageWidth && y >=0 && y < imageHeight)
   {
      int index = y * imageWidth + x;
      pixels[index] = color;
   }
}

// Clamping values to keep them between 0 and 1
__host__ __device__
float Clamp(float value, float min = 0, float max = 1)
{
   return (min > ((value < max) ? value:max)) ? min:value;
   //return Math.Max(min, Math.Min(value, max));
}

// Interpolating the value between 2 vertices 
// min is the starting point, max the ending point
// and gradient the % between the 2 points
__host__ __device__
float Interpolate(float min, float max, float gradient)
{
   return min + (max - min) * Clamp(gradient);
}

struct triangleData
{
   int dXa;
   int dYa;
   int dYb;
   int dXb;
   int dXc;
   int dYc;

   int top;
   int left;
   int bottom;
   int right;

   int eA;
   int eB;
   int eC;
   
   int boxHeight;
   int boxWidth;
   int boxSize;
};

__global__
void computeTriangles( 
      uint32_t * pixels,
      triangleData * tD,
      const Vec3f *verts,
      const int * tris,
      const int numTris,
      Vec3i * projected,
      const Matrix44f worldToCamera,
      const uint32_t imageWidth,
      const uint32_t imageHeight
      )
{
   int indexGPU = blockIdx.x * blockDim.x + threadIdx.x;
   int stride = blockDim.x * gridDim.x;
   for (int i = indexGPU; i < numTris; i+=stride)
   {
      // Get triangle data
      Vec3i A = projected[tris[i]], B = projected[tris[i+1]], C = projected[tris[i+2]];

      tD[i].top = max(0, min(A.y, min(B.y, C.y)));
      tD[i].left = max(0, min(A.x, min(B.x, C.x)));
      tD[i].bottom = min(imageHeight, max(A.y, max(B.y, C.y)));
      tD[i].right = min(imageWidth, max(A.x, max(B.x, C.x)));

      tD[i].boxHeight = tD[i].bottom - tD[i].top;
      tD[i].boxWidth = tD[i].right - tD[i].left;
      if(tD[i].boxHeight > 0 && tD[i].boxWidth > 0)
      {
         tD[i].boxSize = tD[i].boxHeight * tD[i].boxWidth;

         tD[i].dXa = B.x - A.x;
         tD[i].dYa = B.y - A.y;
         tD[i].dYb = C.y - B.y;
         tD[i].dXb = C.x - B.x;
         tD[i].dXc = A.x - C.x;
         tD[i].dYc = A.y - C.y;

         tD[i].eA = (tD[i].left - A.x) * tD[i].dYa - (tD[i].top - A.y) * tD[i].dXa;
         tD[i].eB = (tD[i].left - B.x) * tD[i].dYb - (tD[i].top - B.y) * tD[i].dXb;
         tD[i].eC = (tD[i].left - C.x) * tD[i].dYc - (tD[i].top - C.y) * tD[i].dXc;
      }
      else
      {
         tD[i].boxSize = 0;
      }
   }
}

__global__
void rasterTriangles(
      uint32_t * pixels,
      const triangleData * tD,
      const int numTris,
      const uint32_t imageWidth,
      const uint32_t imageHeight
      )
{
   // Temporary debugging color
   //int color = 0x00ffff + 255 * blockIdx.x / blockDim.x;
   int color = 0xffffff;

   for ( int i = 0; i < numTris; i++)
   {
      if ( tD[i].boxSize > 0)
      {
         int indexGPU = blockIdx.x * blockDim.x + threadIdx.x;
         int stride = blockDim.x * gridDim.x;
         for (int j = indexGPU; j < tD[i].boxSize; j+=stride)
         {
            int x = j % tD[i].boxWidth;
            int y = j / tD[i].boxWidth;

            int offsetA = x * tD[i].dYa - y * tD[i].dXa;
            int offsetB = x * tD[i].dYb - y * tD[i].dXb;
            int offsetC = x * tD[i].dYc - y * tD[i].dXc;

            if (tD[i].eA + offsetA >= 0 && tD[i].eB + offsetB >= 0 & tD[i].eC + offsetC >= 0)
            {
               setPixel(pixels, tD[i].left + x, tD[i].top + y, color, imageWidth, imageHeight);
            }
         }
      }
   }
}
// Compute the 2D pixel coordinates of a point defined in world space. This function
// requires the point original world coordinates of course, the world-to-camera
// matrix (which you can get from computing the inverse of the camera-to-world matrix,
// the matrix transforming the camera), the canvas dimension and the image width and
// height in pixels.
__global__
void computePixelCoordinates( 
      uint32_t * pixels,
      const Vec3f *verts,
      const int n,
      Vec3i *pRaster,
      const Matrix44f worldToCamera,
      const uint32_t imageHeight,
      const uint32_t imageWidth,
      const int wXh,
      const uint32_t widthOffset,
      const uint32_t heightOffset
      )
{
   int indexGPU = blockIdx.x * blockDim.x + threadIdx.x;
   int stride = blockDim.x * gridDim.x;
   for (int i = indexGPU; i < n; i+=stride)
   {
      float pCameraz = verts[i].x * worldToCamera.x[0][2] + verts[i].y * worldToCamera.x[1][2] + verts[i].z * worldToCamera.x[2][2] + worldToCamera.x[3][2];
      if(pCameraz < -1)
      {
         float pCamerax = verts[i].x * worldToCamera.x[0][0] + verts[i].y * worldToCamera.x[1][0] + verts[i].z * worldToCamera.x[2][0] + worldToCamera.x[3][0];
         float pCameray = verts[i].x * worldToCamera.x[0][1] + verts[i].y * worldToCamera.x[1][1] + verts[i].z * worldToCamera.x[2][1] + worldToCamera.x[3][1];

         pRaster[i].x = (int)((pCamerax / -pCameraz) * imageHeight + widthOffset); 
         pRaster[i].y = (int)((pCameray / pCameraz) * imageHeight + heightOffset);

         //setPixel(pixels, pRaster[i].x, pRaster[i].y, 0xffffff, imageWidth, imageHeight);
      }
   }
}

Vec3f *verts;
Vec3i *vertArray;
int *tris;
triangleData * tD;

int numTris;
int numVertices;

obj * xtree;

uint32_t imageWidth;
uint32_t imageHeight;
uint32_t * pixels;

   extern "C"
int init(const uint32_t iW, const uint32_t iH, uint32_t ** p)
{
   imageWidth = iW;
   imageHeight = iH;

   // Magically knowing the size of each obj beforehand. Will need to create a table to grab these values from.
   numTris = 384;
   numVertices = 146;

   cudaMallocManaged(&vertArray, numVertices*sizeof(Vec3i));
   cudaMallocManaged(&tD, numTris*sizeof(triangleData));
   cudaMallocManaged(&tris, numTris*sizeof(int));
   cudaMallocManaged(&verts, numVertices*sizeof(Vec3f));
   cudaMallocManaged(p, imageWidth*imageHeight*sizeof(uint32_t));
   pixels = *p;

   // Have to set the data after the malloc because cudaMalloc resets the pointer;
   *xtree = obj("xtree.obj", verts, tris);

   return 0;
}

   extern "C"
int run(Matrix44f worldToCamera)
{
   int wXh = imageWidth*imageHeight;
   int widthHalf = imageWidth/2;
   int heightHalf = imageHeight/2;

   int blockSize = 256;
   int numBlocks = (numTris + blockSize - 1) / blockSize;
   computePixelCoordinates<<<numBlocks, blockSize>>>(pixels, verts, numVertices, vertArray, worldToCamera, imageHeight, imageWidth, wXh, widthHalf, heightHalf);

   computeTriangles<<<numBlocks, blockSize>>>(pixels, tD, verts, tris, numTris, vertArray, worldToCamera, imageWidth, imageHeight);
   
   rasterTriangles<<<numTris, blockSize>>>(pixels, tD, numTris, imageWidth, imageHeight);

   cudaDeviceSynchronize();

   return 0;
}

   extern "C"
int clearScreen()
{
   cudaMemset(pixels, 0, imageWidth*imageHeight*sizeof(uint32_t));
   return 0;
}

   extern "C"
int finish()
{
   cudaFree(pixels);
   cudaFree(vertArray);
   cudaFree(tD);
   cudaFree(tris);
   cudaFree(verts);

   return 0;
}
