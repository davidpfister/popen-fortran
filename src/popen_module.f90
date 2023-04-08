!*******************************************************************************
!>
! A simple module for `popen`.

    module popen_module

    use,intrinsic :: iso_c_binding

    implicit none

    private

    interface

        function popen(command, mode) bind(C,name='popen')
        import :: c_char, c_ptr
        character(kind=c_char),dimension(*) :: command
        character(kind=c_char),dimension(*) :: mode
        type(c_ptr) :: popen
        end function popen

        function fgets(s, siz, stream) bind(C,name='fgets')
        import :: c_char, c_ptr, c_int
        type (c_ptr) :: fgets
        character(kind=c_char),dimension(*) :: s
        integer(kind=c_int),value :: siz
        type(c_ptr),value :: stream
        end function fgets

        function pclose(stream) bind(C,name='pclose')
        import :: c_ptr, c_int
        integer(c_int) :: pclose
        type(c_ptr),value :: stream
        end function pclose

    end interface

    public :: c2f_string, get_command_as_string

contains

    !*******************************************************************************
    !>
    !  Convert a C string to a Fortran string

    function c2f_string(c) result(f)

        implicit none

        character(len=*),intent(in) :: c
        character(len=:),allocatable :: f

        integer :: i

        i = index(c,c_null_char)

        if (i<=0) then
            f = c
        else if (i==1) then
            f = ''
        else if (i>1) then
            f = c(1:i-1)
        end if

    end function c2f_string

    !*******************************************************************************
    !>
    !  Return the result of the command as a string

    function get_command_as_string(command) result(str)

        implicit none

        character(len=*),intent(in) :: command
        character(len=:),allocatable :: str

        integer,parameter :: buffer_length = 1000

        type(c_ptr) :: h
        integer(c_int) :: istat
        character(kind=c_char,len=buffer_length) :: line

        str = ''
        h = c_null_ptr
        h = popen(command//c_null_char,'r'//c_null_char)

        if (c_associated(h)) then
            do while (c_associated(fgets(line,buffer_length,h)))
                str = str//c2f_string(line)
            end do
            istat = pclose(h)
        end if

    end function get_command_as_string

!*******************************************************************************
    end module popen_module
!*******************************************************************************