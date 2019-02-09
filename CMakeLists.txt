# TODO: sensible minimum CMake version
cmake_minimum_required(VERSION 3.3)
project(nextpnr-chipdb)

# List of families to build
set(FAMILIES ice40 ecp5)

set(ARCH "" CACHE STRING "Architecture family for nextpnr-chipdb build")
set_property(CACHE ARCH PROPERTY STRINGS ${FAMILIES})

if (NOT ARCH)
    message(STATUS "Architecture not set, building for all")
    SET(ARCH "all")
endif ()

if (ARCH STREQUAL "all")
    SET(ARCH ${FAMILIES})
endif()

foreach(item ${ARCH})
    if (NOT item IN_LIST FAMILIES)
        message(FATAL_ERROR "Architecture '${item}' not in list of supported architectures")
    endif()
endforeach()

set(CMAKE_CXX_STANDARD 11)
if (MSVC)
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /D_DEBUG /W4 /wd4100 /wd4244 /wd4125 /wd4800 /wd4456 /wd4458 /wd4305 /wd4459 /wd4121 /wd4996")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /W4 /wd4100 /wd4244 /wd4125 /wd4800 /wd4456 /wd4458 /wd4305 /wd4459 /wd4121 /wd4996 /wd4127")
else()
set(CMAKE_CXX_FLAGS_DEBUG "-Wall -fPIC -ggdb -pipe")
set(CMAKE_CXX_FLAGS_RELEASE "-Wall -fPIC -O3 -g -pipe")
endif()
set(CMAKE_DEFIN)


find_package(PythonInterp 3.5 REQUIRED)
# List of Boost libraries to include
find_package(Boost REQUIRED COMPONENTS filesystem thread program_options)

set(CMAKE_BUILD_TYPE Release)

ADD_EXECUTABLE(bbasm external/nextpnr/bba/main.cc)
target_link_libraries(bbasm LINK_PUBLIC ${Boost_PROGRAM_OPTIONS_LIBRARY})

foreach (family ${ARCH})
    message(STATUS "Configuring architecture : ${family}")
    include(${family}/family.cmake)
endforeach (family)