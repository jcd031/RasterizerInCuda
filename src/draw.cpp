#include "../include/draw.hpp"

draw::draw(const uint32_t w, const uint32_t h)
{
   IMAGE_WIDTH = w;
   IMAGE_HEIGHT = h;

   SDL_Init(SDL_INIT_VIDEO);
   window = SDL_CreateWindow("SDL2 Pixel Drawing", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, IMAGE_WIDTH, IMAGE_HEIGHT, 0);
   renderer = SDL_CreateRenderer(window, -1, 0);
   texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STATIC, IMAGE_WIDTH, IMAGE_HEIGHT);
   pitch = IMAGE_WIDTH * sizeof(uint32_t);

   try{ init(IMAGE_WIDTH, IMAGE_HEIGHT, &pixels);}
   catch( std::exception& e) { std::cout << "Couldn't initialize\n";}
}

int draw::onLoop(Matrix44f worldToCamera)
{
   run(worldToCamera);
   SDL_UpdateTexture(texture, NULL, pixels, pitch);

   SDL_RenderClear(renderer);
   SDL_RenderCopy(renderer, texture, NULL, NULL);
   SDL_RenderPresent(renderer);
   clearScreen();

   return 0;
}

int draw::onFinish()
{
   finish();
   SDL_DestroyTexture(texture);
   SDL_DestroyRenderer(renderer);
   SDL_DestroyWindow(window);
   SDL_Quit();

   return 0;
};
