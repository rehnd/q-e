!
! Copyright (C) 2001 PWSCF group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!

subroutine poolrecover (vec, length, nkstot, nks)
  !
  ! recovers on the first processor of the first pool a distributed vector
  !
#ifdef __PARA
#include "machine.h"
  use para
  USE kinds, only : DP
  implicit none

  include 'mpif.h'

  integer :: status (MPI_STATUS_SIZE)
  integer :: length, i, nks1, rest, fine, nbase, info, nks, nkstot

  real (kind=DP) :: vec (length, nkstot)

  if (npool <= 1) return

  if (mod (nkstot, kunit) /= 0) call errore ('poolrecover', &
       'nkstot/kunit is not an integer', nkstot)
  nks1 = kunit * (nkstot / kunit / npool)

  rest = (nkstot - nks1 * npool) / kunit

  call mpi_barrier (MPI_COMM_WORLD, info)
  if (me == 1 .and. mypool /= 1) then
     call mpi_send (vec, length * nks, MPI_REAL8, 0, 17, &
          MPI_COMM_ROW, info)
     call errore ('poolrecover', 'info<>0 in send', info)
  endif

  do i = 2, npool
     if (i <= rest) then
        fine = nks1 + kunit
        nbase = (nks1 + kunit) * (i - 1)
     else
        fine = nks1
        nbase = rest * (nks1 + kunit) + (i - 1 - rest) * nks1
     endif
     if (me == 1 .and. mypool == 1) then
        call mpi_recv (vec (1, nbase+1), length * fine, MPI_REAL8, i - &
             1, 17, MPI_COMM_ROW, status, info)
        call errore ('poolrecover', 'info<>0 in recv', info)
     endif
  enddo
#endif
  return
end subroutine poolrecover

subroutine ipoolrecover (ivec, length, nkstot, nks)
  !
  ! as abov, for an integer vector
  !
#ifdef __PARA
  use para
  implicit none

  include 'mpif.h'

  integer :: status (MPI_STATUS_SIZE)
  integer :: length, i, nks1, rest, fine, nbase, info, nks, nkstot

  integer :: ivec (length, nkstot)

  if (npool <= 1) return

  if (mod (nkstot, kunit) /= 0) call errore ('poolrecover', &
       'nkstot/kunit is not an integer', nkstot)
  nks1 = kunit * (nkstot / kunit / npool)

  rest = (nkstot - nks1 * npool) / kunit

  call mpi_barrier (MPI_COMM_WORLD, info)
  if (me == 1 .and. mypool /= 1) then
     call mpi_send (ivec, length * nks, MPI_INTEGER, 0, 17, &
          MPI_COMM_ROW, info)
     call errore ('ipoolrecover', 'info<>0 in send', info)

  endif
  do i = 2, npool
     if (i <= rest) then
        fine = nks1 + kunit
        nbase = (nks1 + kunit) * (i - 1)
     else
        fine = nks1
        nbase = rest * (nks1 + kunit) + (i - 1 - rest) * nks1
     endif
     if (me == 1 .and. mypool == 1) then
        call mpi_recv (ivec (1, nbase+1), length * fine, MPI_INTEGER, &
             i - 1, 17, MPI_COMM_ROW, status, info)
        call errore ('ipoolrecover', 'info<>0 in recv', info)
     endif
  enddo
#endif
  return

end subroutine ipoolrecover

