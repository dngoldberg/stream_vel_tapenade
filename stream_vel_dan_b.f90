!        Generated by TAPENADE     (INRIA, Ecuador team)
!  Tapenade 3.16 (master) -  9 Oct 2020 17:47
!
!  Differentiation of stream_vel in reverse (adjoint) mode:
!   gradient     of useful results: fc
!   with respect to varying inputs: bb fc
!   RW status of diff variables: bb:out fc:in-zero
!-----------------------------
!subroutine stream_vel (u, targetu, bb, fc)
SUBROUTINE STREAM_VEL_B(u, bb, bbb, fc, fcb)
!-----------------------------
  USE STREAM_VEL_VARIABLES
  IMPLICIT NONE
  REAL*8, DIMENSION(n+1), INTENT(INOUT) :: u
  REAL*8, DIMENSION(n+1) :: ub
!real(8), intent(inout), dimension(n+1) :: targetu
  REAL*8, DIMENSION(n), INTENT(INOUT) :: bb
  REAL*8, DIMENSION(n), INTENT(INOUT) :: bbb
  REAL*8, INTENT(INOUT) :: fc
  REAL*8, INTENT(INOUT) :: fcb
  REAL*8, DIMENSION(n, 3) :: a
  REAL*8, DIMENSION(n, 3) :: ab
  REAL*8, DIMENSION(n) :: f, beta_fric, h, beta_0, h0, utmp, b, nu
  REAL*8, DIMENSION(n) :: beta_fricb, utmpb, nub
  REAL*8, DIMENSION(n+1) :: uold
  REAL*8 :: fend, maxdiff
  INTEGER :: i, j
  REAL :: sumdiff
  INTEGER :: branch
  REAL :: cumul
  REAL*8, DIMENSION(n) :: hb
  REAL*8, DIMENSION(n) :: bb0
  REAL*8, DIMENSION(n) :: hb0
  REAL*8, DIMENSION(n) :: beta_fricb0
  REAL*8, DIMENSION(n) :: bb1
  REAL*8 :: ub1(n+1)
  REAL*8 :: ub0(n+1)
  CALL STREAM_VEL_INIT(h0, beta_0)
  beta_fric = beta_0 + bb
  h = h0
  CALL STREAM_VEL_TAUD(h, f, fend)
  u = 0.
!------ driving stress -------------
  DO i=1,n
    b(i) = -(dx*f(i))
    IF (i .LT. n) THEN
      CALL PUSHCONTROL1B(1)
      b(i) = b(i) - f(i+1)*dx
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
  END DO
  b(n) = b(n) + fend
  sumdiff = 1e10
!-----------------------------------
!        do i=1, n_nl
  DO WHILE (sumdiff .GT. 1.e-14)
    uold = u
    CALL STREAM_VEL_VISC(h, u, nu)
! update viscosities
    CALL STREAM_ASSEMBLE(nu, beta_fric, a)
! assemble tridiag matrix
! this represents discretization of
!  (nu^(i-1) u^(i)_x)_x - \beta^2 u^(i) = f
    utmp = 0
    CALL CONJ_GRAD(utmp, b, a)
! solve linear system for new u
    DO j=1,n
! effectively apply boundary condition u(1)==0
      u(j+1) = utmp(j)
    END DO
    sumdiff = 0.
    DO j=1,n
!          u(j+1) = utmp(j)                ! effectively apply boundary condition u(1)==0
      sumdiff = sumdiff + (u(j+1)-uold(j+1))**2
    END DO
  END DO
  uold = u
  CALL STREAM_VEL_VISC(h, u, nu)
! update viscosities
  CALL PUSHREAL8ARRAY(a, 79*3)
  CALL STREAM_ASSEMBLE(nu, beta_fric, a)
! assemble tridiag matrix
! this represents discretization of
!  (nu^(i-1) u^(i)_x)_x - \beta^2 u^(i) = f
  utmp = 0
  CALL CONJ_GRAD(utmp, b, a)
! solve linear system for new u
  DO j=1,n
! effectively apply boundary condition u(1)==0
    CALL PUSHREAL8(u(j+1))
    u(j+1) = utmp(j)
  END DO
  sumdiff = 0.
  DO j=1,n
!          u(j+1) = utmp(j)                ! effectively apply boundary condition u(1)==0
    sumdiff = sumdiff + (u(j+1)-uold(j+1))**2
  END DO
  ub = 0.0_8
  DO i=n+1,2,-1
    ub(i) = ub(i) + 2*u(i)*fcb
  END DO
  nub = 0.0_8
  beta_fricb = 0.0_8
  ab = 0.0_8
  cumul = 1.6E7
  ub0 = ub
  bb1(1:n) = bb0(1:n)
  beta_fricb0(1:n) = beta_fricb(1:n)
  hb0(1:n) = hb(1:n)
  dxb0 = dxb
  CALL ADSTACK_STARTREPEAT()
  DO WHILE (cumul .GT. 8000000.0)
    ub1 = ub
    utmpb = 0.0_8
    DO j=n,1,-1
      CALL POPREAL8(u(j+1))
      utmpb(j) = utmpb(j) + ub(j+1)
      ub(j+1) = 0.0_8
    END DO
    CALL CONJ_GRAD_B(utmp, utmpb, b, a, ab)
    CALL POPREAL8ARRAY(a, 79*3)
    beta_fricb = 0.0_8
    CALL STREAM_ASSEMBLE_B(nu, nub, beta_fric, beta_fricb, a, ab)
    CALL STREAM_VEL_VISC_B(h, u, ub, nu, nub)
    cumul = 0.0
    ub = ub + ub0
    cumul = cumul + SUM((ub-ub1)**2)
    CALL ADSTACK_RESETREPEAT()
  END DO
  bb0(1:n) = bb1(1:n)
  beta_fricb(1:n) = beta_fricb0(1:n)
  hb(1:n) = hb0(1:n)
  dxb = dxb0
  CALL ADSTACK_ENDREPEAT()
  utmpb = 0.0_8
  DO j=n,1,-1
    CALL POPREAL8(u(j+1))
    utmpb(j) = utmpb(j) + ub(j+1)
    ub(j+1) = 0.0_8
  END DO
  CALL CONJ_GRAD_B(utmp, utmpb, b, a, ab)
  CALL POPREAL8ARRAY(a, 79*3)
  CALL STREAM_ASSEMBLE_B(nu, nub, beta_fric, beta_fricb, a, ab)
  ub = 0.0_8
  CALL STREAM_VEL_VISC_B(h, u, ub, nu, nub)
  ub = 0.0_8
  DO i=n,1,-1
    CALL POPCONTROL1B(branch)
  END DO
  bbb = 0.0_8
  bbb = beta_fricb
  fcb = 0.0_8
END SUBROUTINE STREAM_VEL_B

!  Differentiation of stream_vel_visc in reverse (adjoint) mode:
!   gradient     of useful results: u nu
!   with respect to varying inputs: u nu
!-----------------------------
SUBROUTINE STREAM_VEL_VISC_B(h, u, ub, nu, nub)
!-----------------------------
  USE STREAM_VEL_VARIABLES
  IMPLICIT NONE
  REAL*8, DIMENSION(n), INTENT(IN) :: h
  REAL*8, DIMENSION(n+1), INTENT(IN) :: u
  REAL*8, DIMENSION(n+1) :: ub
  REAL*8, DIMENSION(n), INTENT(INOUT) :: nu
  REAL*8, DIMENSION(n), INTENT(INOUT) :: nub
  REAL*8 :: ux, tmp
  REAL*8 :: uxb, tmpb
  INTEGER :: i
  REAL*8 :: temp
  DO i=n,1,-1
    ux = (u(i+1)-u(i))/dx
    tmp = ux**2 + ep_glen**2
    temp = (-nglen+1)/(2.*nglen)
    IF (tmp .LE. 0.0 .AND. (temp .EQ. 0.0 .OR. temp .NE. INT(temp))) &
&   THEN
      tmpb = 0.0_8
    ELSE
      tmpb = temp*tmp**(temp-1)*h(i)*.5*aglen**(-(1.0/nglen))*nub(i)
    END IF
    nub(i) = 0.0_8
    uxb = 2*ux*tmpb
    ub(i+1) = ub(i+1) + uxb/dx
    ub(i) = ub(i) - uxb/dx
  END DO
END SUBROUTINE STREAM_VEL_VISC_B

!  Differentiation of stream_assemble in reverse (adjoint) mode:
!   gradient     of useful results: nu beta_fric a
!   with respect to varying inputs: nu beta_fric a
!-----------------------------
SUBROUTINE STREAM_ASSEMBLE_B(nu, nub, beta_fric, beta_fricb, a, ab)
!-----------------------------
  USE STREAM_VEL_VARIABLES
  IMPLICIT NONE
  REAL*8, DIMENSION(n), INTENT(IN) :: nu, beta_fric
  REAL*8, DIMENSION(n) :: nub, beta_fricb
  REAL*8, DIMENSION(n, 3), INTENT(INOUT) :: a
  REAL*8, DIMENSION(n, 3), INTENT(INOUT) :: ab
  INTEGER :: i
  INTEGER :: branch
  DO i=1,n
    IF (i .GT. 1) THEN
      CALL PUSHCONTROL1B(0)
    ELSE
      CALL PUSHCONTROL1B(1)
    END IF
    IF (i .LT. n) THEN
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
  END DO
  DO i=n,1,-1
    CALL POPCONTROL1B(branch)
    IF (branch .NE. 0) THEN
      beta_fricb(i+1) = beta_fricb(i+1) + 2*beta_fric(i+1)*dx*ab(i, 3)/&
&       6. + 2*beta_fric(i+1)*dx*ab(i, 2)/3.
      nub(i+1) = nub(i+1) + 4*ab(i, 2)/dx - 4*ab(i, 3)/dx
      ab(i, 3) = 0.0_8
    END IF
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 0) THEN
      beta_fricb(i) = beta_fricb(i) + 2*beta_fric(i)*dx*ab(i, 1)/6.
      nub(i) = nub(i) - 4*ab(i, 1)/dx
      ab(i, 1) = 0.0_8
    END IF
    nub(i) = nub(i) + 4*ab(i, 2)/dx
    beta_fricb(i) = beta_fricb(i) + 2*beta_fric(i)*dx*ab(i, 2)/3.
    ab(i, 2) = 0.0_8
  END DO
END SUBROUTINE STREAM_ASSEMBLE_B

