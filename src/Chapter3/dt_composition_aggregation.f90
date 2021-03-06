! File: dt_composition_aggregation.f90
! Purpose: Demonstrate how more complex types can be constructed using
!          aggregation; specifically, we look at how a 'Vec3d'-type may be
!          constructed from a 'Vec2d'-type.

module Vec2d_class
  implicit none
  private

  type, public :: Vec2d ! DT explicitly declared "public"
     private  ! Make internal data "private" by default.
     real :: mU = 0., mV = 0.
   contains
     private  ! Make methods "private" by default.
     procedure, public :: getMagnitude => getMagnitudeVec2d
     procedure, public :: getU => getUVec2d
     procedure, public :: getV => getVVec2d
  end type Vec2d

  ! Generic IFACE, for type-overloading
  ! (to implement user-defined CTOR)
  interface Vec2d
     module procedure createVec2d
  end interface Vec2d

contains
  type(Vec2d) function createVec2d( u, v ) ! CTOR
    real, intent(in) :: u, v
    createVec2d%mU = u
    createVec2d%mV = v
  end function createVec2d

  real function getMagnitudeVec2d( this ) ! Method to compute magnitude.
    class(Vec2d), intent(in) :: this
    getMagnitudeVec2d = sqrt( this%mU**2 + this%mV**2 )
  end function getMagnitudeVec2d

  real function getUVec2d( this ) ! Accessor-method (GETter).
    class(Vec2d), intent(in) :: this
    getUVec2d = this%mU ! Direct-access IS allowed here.
  end function getUVec2d

  real function getVVec2d( this ) ! Accessor-method (GETter).
    class(Vec2d), intent(in) :: this
    getVVec2d = this%mV ! Direct-access IS allowed here.
  end function getVVec2d
end module Vec2d_class

module Vec3d_class
  use Vec2d_class
  implicit none
  private

  type, public :: Vec3d
     private
     type(Vec2d) :: mVec2d ! DT-aggregation
     real :: mW = 0.
   contains
     private
     procedure, public :: getU => getUVec3d
     procedure, public :: getV => getVVec3d
     procedure, public :: getW => getWVec3d
     procedure, public :: getMagnitude => getMagnitudeVec3d
  end type Vec3d

  interface Vec3d
     module procedure createVec3d
  end interface Vec3d

contains
  ! Custom CTOR for the aggregate-type.
  type(Vec3d) function createVec3d( u, v, w )
    real, intent(in) :: u, v, w
    createVec3d%mVec2d = Vec2d( u, v ) ! Call CTOR of component.
    createVec3d%mW = w
  end function createVec3d

  real function getMagnitudeVec3d( this )
    class(Vec3d), intent(in) :: this
    getMagnitudeVec3d = sqrt( this%getU()**2 + this%getV()**2 + this%mW**2 )
  end function getMagnitudeVec3d

  real function getUVec3d( this )
    class(Vec3d), intent(in) :: this
    getUVec3d = this%mVec2d%getU() ! forward work to component
  end function getUVec3d

  real function getVVec3d( this )
    class(Vec3d), intent(in) :: this
    getVVec3d = this%mVec2d%getV() ! forward work to component
  end function getVVec3d

  real function getWVec3d( this )
    class(Vec3d), intent(in) :: this
    getWVec3d = this%mW
  end function getWVec3d
end module Vec3d_class

program test_driver_aggregation
  use Vec3d_class
  implicit none
  type(Vec3d) :: X

  X = Vec3d( 1.0, 2.0, 3.0 )
  write(*, '(4(a,f6.3))') "X%U = ", X%getU(), ", X%V = ", X%getV(), &
       ", X%W = ", X%getW(), ", X%magnitude = ", X%getMagnitude()
end program test_driver_aggregation
