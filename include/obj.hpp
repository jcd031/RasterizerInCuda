#ifndef OBJ_H
#define OBJ_H

#include <fstream>
#include <sstream>
#include <string>

#include "../include/geometry.hpp"

class obj
{
   private:

   public:
   //obj();
   obj(const char * fname, Vec3f *vertices, int *tris);
};

#endif
