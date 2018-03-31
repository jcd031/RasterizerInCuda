#include <iostream>

#include "../include/draw.hpp"
#include "../include/camera.hpp"
#include "../include/events.hpp"

// User defined code
bool quit = false;
void quit_func(){ quit = true; }

bool keyW, keyA, keyS, keyD;
void onKeyDownW(){ keyW = true;}
void onKeyDownA(){ keyA = true;}
void onKeyDownS(){ keyS = true;}
void onKeyDownD(){ keyD = true;}
void onKeyUpW(){ keyW = false;}
void onKeyUpA(){ keyA = false;}
void onKeyUpS(){ keyS = false;}
void onKeyUpD(){ keyD = false;}

int func()
{
   events Event_Handler;
   // Setting user code to run on specified events
   Event_Handler.onQuit = quit_func;
   Event_Handler.onKeyDownW = onKeyDownW;
   Event_Handler.onKeyDownA = onKeyDownA;
   Event_Handler.onKeyDownS = onKeyDownS;
   Event_Handler.onKeyDownD = onKeyDownD;
   Event_Handler.onKeyUpW = onKeyUpW;
   Event_Handler.onKeyUpA = onKeyUpA;
   Event_Handler.onKeyUpS = onKeyUpS;
   Event_Handler.onKeyUpD = onKeyUpD;

   draw SDL_Window(1280,720);

   camera Camera(0.871214, 0, -0.490904, 0, -0.192902, 0.919559, -0.342346, 0, 0.451415, 0.392953, 0.801132, 0, 14.77467, 29.361945, 27.993464, 1);

   while (!quit)
   {
      // Main: User defined functions will run here if the event triggers
      Event_Handler.onLoop();

      // User code: Move the camera based on player input
      //    Currently not normalizing diagonals
      Camera.translateR(0.1f*(keyA-keyD), 0, 0.1f*(keyW-keyS));
      //Camera.rotateR(0, 0.001f, 0.001f);

      // Main: Draw the world from the given camera
      SDL_Window.onLoop(Camera.matrix); 
   }

   SDL_Window.onFinish();
    
   return 0;
}

int main()
{
  func();
  std::cout << "Ran from driver\n";

  return 0;
}
