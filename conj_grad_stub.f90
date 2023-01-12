!-----------------------------
        subroutine conj_grad (x, b, A)
!-----------------------------

!       THIS IS THE LINEAR SYSTEM SOLVER

        use stream_vel_variables

        real(8), intent(inout), dimension(n) :: x
        real(8), intent(in), dimension(n) :: b
        real(8), intent(in), dimension(n,3) :: A
        
        integer :: i


        do i=1,n
          x(i) = x(i) + A(i,1) * b(i) + A(i,2) * b(i) + A(i,3) * b(i)
        enddo
       
        end subroutine conj_grad
