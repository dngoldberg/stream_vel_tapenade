EXEC := adjoint
SRC  := $(wildcard *.f90)
OBJ  := $(patsubst %.f90, %.o, $(SRC))
# NOTE - OBJ will not have the object files of c codes in it, this needs to be improved upon.
# Options
F90  := gfortran
CC   := gcc
POP_PUSH:= ./pop_push

# Rules

$(EXEC):  adStack.o stream_vel_dan_b.o conj_grad_adj.o conj_grad.o stream_vel_dan.o
	$(F90) -o $(EXEC) driver.f90 conj_grad_adj.o adStack.o stream_vel_dan_b.o conj_grad.o stream_vel_dan.o

stream_vel_dan.o: stream_vel_dan.f90
	$(F90) -c stream_vel_dan.f90
driver.o: driver.f90 stream_vel_variables.mod 
	$(F90) -c driver.f90

stream_vel_dan_b.o: stream_vel_dan_b.f90 stream_vel_variables.mod
	$(F90) -c stream_vel_dan_b.f90

stream_vel_variables.mod: stream_vel_dan.o

conj_grad_adj.o: conj_grad_adj.f90 stream_vel_variables.mod
	$(F90) -c conj_grad_adj.f90
conj_grad.o: conj_grad.f90 stream_vel_variables.mod
	$(F90) -c conj_grad.f90

driver.o: stream_vel_dan_b.f90 stream_vel_variables.mod 

adStack.o :
	$(CC) -c adStack.c

stream_vel_dan_b.f90: stream_vel_dan.f90
	tapenade -reverse -head "stream_vel(fc)/(bb)" stream_vel_dan.f90 conj_grad_stub.f90
# Useful phony targets

.PHONY: clean

clean:
	$(RM) $(EXEC) *.o $(MOD) $(MSG) *.msg *.mod *_db.f90 *_b.f90 *_d.f90 *~
