#ifndef DRAW_H
#define DRAW_H

#include <SDL2/SDL.h>
#include "../include/geometry.hpp"

extern "C"
int init(const uint32_t imageWidth, const uint32_t imageHeight, uint32_t ** p);
extern "C"
int run(Matrix44f worldToCamera);
extern "C"
int clearScreen();
extern "C"
int finish();

class draw
{
   public:
      uint32_t IMAGE_WIDTH;
      uint32_t IMAGE_HEIGHT;

      SDL_Window * window;
      SDL_Renderer * renderer;
      SDL_Texture * texture;

      int pitch;
      uint32_t * pixels;

      draw(const uint32_t w, const uint32_t h);

      int onLoop(Matrix44f worldToCamera);

      int onFinish();
};

#endif
