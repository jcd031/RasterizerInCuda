# RasterizerInCuda

Takes a 3D OBJ file and rasterizes each triangle in parallel. It runs significantly faster than running in sequence on a processor. If I were to continue to work on this, I would add additional optimizations, specifically z-buffering, to approach the performance of a full graphics pipeline.
