
set(devices 25k 45k 85k)

add_subdirectory(external/prjtrellis/libtrellis ${CMAKE_CURRENT_BINARY_DIR}/generated/libtrellis)

set(TRELLIS_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/external/prjtrellis)

set(DB_PY ${CMAKE_CURRENT_SOURCE_DIR}/external/nextpnr/ecp5/trellis_import.py)

file(MAKE_DIRECTORY ecp5/chipdbs/)
add_library(ecp5_chipdb OBJECT ecp5/chipdbs/)

if (CMAKE_HOST_WIN32)
set(ENV_CMD ${CMAKE_COMMAND} -E env "PYTHONPATH=\"${CMAKE_CURRENT_BINARY_DIR}/generated/libtrellis\;${TRELLIS_ROOT}/util/common\;${TRELLIS_ROOT}/timing/util\"")
else()
set(ENV_CMD ${CMAKE_COMMAND} -E env "PYTHONPATH=${CMAKE_CURRENT_BINARY_DIR}/generated/libtrellis:${TRELLIS_ROOT}/util/common:${TRELLIS_ROOT}/timing/util")
endif()

foreach (dev ${devices})
    set(DEV_CC_DB ${CMAKE_CURRENT_SOURCE_DIR}/ecp5/chipdbs/chipdb-${dev}.bin)
    set(DEV_CC_BBA_DB ${CMAKE_CURRENT_SOURCE_DIR}/ecp5/chipdbs/chipdb-${dev}.bba)
    set(DEV_CONSTIDS_INC ${CMAKE_CURRENT_SOURCE_DIR}/external/nextpnr/ecp5/constids.inc)
    add_custom_command(OUTPUT ${DEV_CC_BBA_DB}
    COMMAND ${ENV_CMD} python3 ${DB_PY} -p ${DEV_CONSTIDS_INC} ${dev} > ${DEV_CC_BBA_DB}
            DEPENDS ${DB_PY} pytrellis
            )
    add_custom_command(OUTPUT ${DEV_CC_DB}
            COMMAND bbasm ${DEV_CC_BBA_DB} ${DEV_CC_DB}
            DEPENDS bbasm ${DEV_CC_BBA_DB}
            )
    target_sources(ecp5_chipdb PRIVATE ${DEV_CC_DB})
    set_source_files_properties(${DEV_CC_DB} PROPERTIES HEADER_FILE_ONLY TRUE)
endforeach (dev)
