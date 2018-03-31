#ifndef EVENTS_H
#define EVENTS_H

#include <SDL2/SDL.h>

class events
{
   private:
      SDL_Event event;
   public:
      void (*onQuit)();

      void (*onKeyDownA)();
      void (*onKeyDownD)();
      void (*onKeyDownS)();
      void (*onKeyDownW)();

      void (*onKeyUpA)();
      void (*onKeyUpD)();
      void (*onKeyUpS)();
      void (*onKeyUpW)();

      int onLoop();
};

#endif
