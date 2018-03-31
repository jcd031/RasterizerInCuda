IDIR =include
CC=g++
NVCC=nvcc
CFLAGS=-I$(IDIR)

ODIR=build
OUT=bin/driver
LDIR =lib
LIBNAME=name

LIBS=-lSDL2 -L$(LDIR) -l$(LIBNAME)

_OBJD = driver.o 
OBJD = $(patsubst %,$(ODIR)/%,$(_OBJD))

_OBJ = draw.o cuda.o camera.o obj.o events.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

$(ODIR)/%.o: src/%.cpp 
	$(CC) -c -o $@ $< $(CFLAGS)

$(ODIR)/%.o: src/%.cu 
	$(NVCC) -c -o $@ $< $(CFLAGS)

all: lib driver

lib: $(OBJ)
	ar rcs $(LDIR)/lib$(LIBNAME).a $^

driver: $(OBJD)
	$(NVCC) -o $(OUT) $^ $(CFLAGS) $(LIBS)

.PHONY: clean

clean:
	rm -f $(ODIR)/*.o *~ core $(INCDIR)/*~ 
