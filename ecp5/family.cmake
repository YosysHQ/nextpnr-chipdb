
set(devices 25k 45k 85k)

if (NOT DEFINED TRELLIS_ROOT)
    message(STATUS "TRELLIS_ROOT not defined using -DTRELLIS_ROOT=/path/to/prjtrellis. Default to /usr/local/share/trellis")
    set(TRELLIS_ROOT "/usr/local/share/trellis")
endif()

file(GLOB found_pytrellis ${TRELLIS_ROOT}/libtrellis/pytrellis.*)

if ("${found_pytrellis}" STREQUAL "")
    message(FATAL_ERROR "failed to find pytrellis library in ${TRELLIS_ROOT}/libtrellis/")
endif()

set(DB_PY ${CMAKE_CURRENT_SOURCE_DIR}/external/nextpnr/ecp5/trellis_import.py)

file(MAKE_DIRECTORY ecp5/chipdbs/)
add_library(ecp5_chipdb OBJECT ecp5/chipdbs/)

if (CMAKE_HOST_WIN32)
set(ENV_CMD ${CMAKE_COMMAND} -E env "PYTHONPATH=\"${TRELLIS_ROOT}/libtrellis\;${TRELLIS_ROOT}/util/common\;${TRELLIS_ROOT}/timing/util\"")
else()
set(ENV_CMD ${CMAKE_COMMAND} -E env "PYTHONPATH=${TRELLIS_ROOT}/libtrellis:${TRELLIS_ROOT}/util/common:${TRELLIS_ROOT}/timing/util")
endif()

foreach (dev ${devices})
    set(DEV_CC_DB ${CMAKE_CURRENT_SOURCE_DIR}/ecp5/chipdbs/chipdb-${dev}.bin)
    set(DEV_CC_BBA_DB ${CMAKE_CURRENT_SOURCE_DIR}/ecp5/chipdbs/chipdb-${dev}.bba)
    set(DEV_CONSTIDS_INC ${CMAKE_CURRENT_SOURCE_DIR}/external/nextpnr/ecp5/constids.inc)
    add_custom_command(OUTPUT ${DEV_CC_BBA_DB}
    COMMAND ${ENV_CMD} python3 ${DB_PY} -p ${DEV_CONSTIDS_INC} ${dev} > ${DEV_CC_BBA_DB}
            DEPENDS ${DB_PY}
            )
    add_custom_command(OUTPUT ${DEV_CC_DB}
            COMMAND bbasm ${DEV_CC_BBA_DB} ${DEV_CC_DB}
            DEPENDS bbasm ${DEV_CC_BBA_DB}
            )
    target_sources(ecp5_chipdb PRIVATE ${DEV_CC_DB})
    set_source_files_properties(${DEV_CC_DB} PROPERTIES HEADER_FILE_ONLY TRUE)
endforeach (dev)
