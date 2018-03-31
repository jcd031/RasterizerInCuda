#include "../include/events.hpp"

int events::onLoop()
{
   while(SDL_PollEvent(&event))
   {
      switch (event.type)
      {
         case SDL_QUIT:
            onQuit();
            break;
         case SDL_KEYDOWN:
            switch (event.key.keysym.sym)
            {
               case SDLK_a: onKeyDownA(); break;
               case SDLK_d: onKeyDownD(); break;
               case SDLK_s: onKeyDownS(); break;
               case SDLK_w: onKeyDownW(); break;
            }
            break;
         case SDL_KEYUP:
            switch (event.key.keysym.sym)
            {
               case SDLK_a: onKeyUpA(); break;
               case SDLK_d: onKeyUpD(); break;
               case SDLK_s: onKeyUpS(); break;
               case SDLK_w: onKeyUpW(); break;
            }
            break;
      }
   }

   return 0;
}
