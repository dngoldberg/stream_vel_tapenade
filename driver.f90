program driver_all

use stream_vel_variables
implicit none

real(8), dimension(n) :: bb, g_bb, adbb, bb0
real(8), dimension(n+1) :: u, adu, g_u
real(8) :: fc, fdfc, g_fc, adfc
real(8) :: fc_0, fc_pert1, fc_pert2, accuracy, accuracyAD
real(8), parameter :: ep = 1.d-4
integer :: ii


!  initialize	
        fc    = 0.
        bb    = 1.
        bb0   = 1.
        adbb    = 0.

        adfc  = 1.

        call stream_vel_b( u, bb, adbb, fc, adfc )
!        call stream_vel_nodiff( u, bb, fc )
 write(*,*) "fc", fc

 print *, '    position       rel err'
 print *, '----------------------------------------------------------------'
        do ii=1,n
         bb = bb0
         bb(ii) = bb(ii) + ep
         call stream_vel( u, bb, fc_pert1 )
         bb = bb0
         bb(ii) = bb(ii) - ep
         call stream_vel( u, bb, fc_pert2 )
         fdfc = (fc_pert1-fc_pert2)/(2*ep)
         print *,ii,1-adbb(ii)/fdfc
        enddo

	end program
