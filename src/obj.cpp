#include "../include/obj.hpp"

obj::obj(const char * fname, Vec3f *vertices, int *tris)
{
   int vertCount = 0;
   int triCount = 0;

   std::ifstream infile(fname);

   std::string line;
   while (std::getline(infile, line))
   {
      std::istringstream iss(line);
      char lineType;
      if (!(iss >> lineType)){ break; } // error
      else if(lineType == 'v')
      {
         float a, b, c;

         try
         {
            iss >> a >> b >> c;
            vertices[vertCount++] = (Vec3f(a, b, c));
         }
         catch (std::exception& e)
         {
            // Likely vertices weren't allocated
            break;
         }
      }else if(lineType == 'f')
      {
         int a, b, c;

         try
         {
            iss >> a >> b >> c;
            tris[triCount++] = a - 1;
            tris[triCount++] = b - 1;
            tris[triCount++] = c - 1;
         }
         catch (std::exception& e)
         {
            // Likely tris weren't allocated
            break;
         }
      }
   }
}
