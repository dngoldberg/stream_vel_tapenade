!        Generated by TAPENADE     (INRIA, Ecuador team)
!  Tapenade 3.16 (master) -  9 Oct 2020 17:47
!
!  Differentiation of conj_grad in reverse (adjoint) mode:
!   gradient     of useful results: ax x a
!   with respect to varying inputs: ax a
!-----------------------------
SUBROUTINE CONJ_GRAD_B(x, xb, b, a, ab)
!-----------------------------
!       THIS IS THE LINEAR SYSTEM SOLVER
  USE STREAM_VEL_VARIABLES
  IMPLICIT NONE
  REAL*8, DIMENSION(n), INTENT(INOUT) :: x
  REAL*8, DIMENSION(n), INTENT(INOUT) :: xb
  REAL*8, DIMENSION(n), INTENT(IN) :: b
  REAL*8, DIMENSION(n, 3), INTENT(IN) :: a
  REAL*8, DIMENSION(n, 3) :: ab
  INTEGER :: i
  REAL*8, DIMENSION(n) :: tau

  call CONJ_GRAD(x, b, a)
  call CONJ_GRAD(tau, xb, a)

  do i = 1,n
   ab(i,2) = ab(i,2) - tau(i) * x(i)
   if (i.gt.1) then
           ab(i,1) = ab(i,1) - tau(i) * x(i-1)
   endif
   if (i.lt.n) then
           ab(i,3) = ab(i,3) - tau(i) * x(i+1)
   endif
  enddo
  xb(:) = 0.
END SUBROUTINE CONJ_GRAD_B



