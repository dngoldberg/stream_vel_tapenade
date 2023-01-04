EXEC := adjoint
SRC  := $(wildcard *.f90)
OBJ  := $(patsubst %.f90, %.o, $(SRC))
# NOTE - OBJ will not have the object files of c codes in it, this needs to be improved upon.
# Options
F90  := gfortran
CC   := gcc
POP_PUSH:= ./pop_push

# Rules

$(EXEC): $(OBJ) adStack.o stream_vel_dan_b.o
	$(F90) -o $@ $^

%.o: %.f90
	$(F90) -c $<

driver.o: stream_vel_dan_b.f90 stream_vel_dan_diff.mod 
stream_vel_dan_diff.mod: stream_vel_dan_b.o

adStack.o :
	$(CC) -c adStack.c

stream_vel_dan_b.f90: stream_vel_dan.f90
	tapenade -reverse -head "stream_vel(fc)/(bb)" stream_vel_dan.f90
# Useful phony targets

.PHONY: clean

clean:
	$(RM) $(EXEC) *.o $(MOD) $(MSG) *.msg *.mod *_db.f90 *_b.f90 *_d.f90 *~
