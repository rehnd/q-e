!
! Copyright (C) 2001 PWSCF group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!
!-----------------------------------------------------------------------
subroutine poolbcast (ndata, data)
  !-----------------------------------------------------------------------
  !
  ! this routine broadcasts the (distributed) real*8 vector 'data'
  ! from each node of the first pool to each node of all other pools
  !
  USE kinds,  only : DP
#ifdef __PARA
  use para
#endif
  implicit none
  ! on INPUT
  integer :: ndata
  real (kind=DP) :: data (ndata)
#ifdef __PARA
#include "machine.h"
  include 'mpif.h'
  integer :: root, ierr
  !
  if (npool == 1) return
  !
  ! root is the "broadcasting" processor.
  !
  ! rank of the MPI_COMM_ROW
  root = 0
  call mpi_barrier (MPI_COMM_ROW, ierr)
  call mpi_bcast (data, ndata, MPI_REAL8, root, MPI_COMM_ROW, ierr)
  call errore ('poolbcast', 'info<>0', ierr)
#endif
  return
end subroutine poolbcast

