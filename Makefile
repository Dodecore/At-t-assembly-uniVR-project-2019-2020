GCC = gcc
FLAGS = -gstabs -m32

all:
	$(GCC) $(FLAGS) -c -o parking.o parking.c
	$(GCC) $(FLAGS) -c -o parking-funz.o parking-funz.s
	$(GCC) $(FLAGS) -o parking parking.o parking-funz.o
clean:
	rm -f *.o  core
