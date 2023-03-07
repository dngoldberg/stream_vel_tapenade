
!-----------------------------
        logical function toolarge (cumul)
!-----------------------------
        real, intent(in) :: cumul
        real, STATIC     :: cumul0
        real(8) :: tol

        toolarge = .true.
        tol = 1.e-6

        if (cumul0.eq.0.0) then
         cumul0=cumul
        endif

        if (cumul.lt.tol*cumul0) then
         toolarge = .false.
        endif


        end function toolarge
