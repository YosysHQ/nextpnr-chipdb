set(devices 384 1k 5k 8k)
set(DB_PY ${CMAKE_CURRENT_SOURCE_DIR}/external/nextpnr/ice40/chipdb.py)

set(ICEBOX_ROOT "/usr/local/share/icebox" CACHE STRING "icebox location root")
file(MAKE_DIRECTORY ice40/chipdbs/)
add_library(ice40_chipdb OBJECT ice40/chipdbs/)

foreach (dev ${devices})
    if (dev EQUAL "5k")
        set(OPT_FAST "")
        set(OPT_SLOW --slow ${ICEBOX_ROOT}/timings_up5k.txt)
    elseif(dev EQUAL "384")
        set(OPT_FAST "")
        set(OPT_SLOW --slow ${ICEBOX_ROOT}/timings_lp384.txt)
    else()
        set(OPT_FAST --fast ${ICEBOX_ROOT}/timings_hx${dev}.txt)
        set(OPT_SLOW --slow ${ICEBOX_ROOT}/timings_lp${dev}.txt)
    endif()
    set(DEV_TXT_DB ${ICEBOX_ROOT}/chipdb-${dev}.txt)
    set(DEV_CC_BBA_DB ${CMAKE_CURRENT_SOURCE_DIR}/ice40/chipdbs/chipdb-${dev}.bba)
    set(DEV_CC_DB ${CMAKE_CURRENT_SOURCE_DIR}/ice40/chipdbs/chipdb-${dev}.bin)
    set(DEV_CONSTIDS_INC ${CMAKE_CURRENT_SOURCE_DIR}/external/nextpnr/ice40/constids.inc)
    set(DEV_GFXH ${CMAKE_CURRENT_SOURCE_DIR}/external/nextpnr/ice40/gfx.h)
    add_custom_command(OUTPUT ${DEV_CC_BBA_DB}
            COMMAND ${PYTHON_EXECUTABLE} ${DB_PY} -p ${DEV_CONSTIDS_INC} -g ${DEV_GFXH} ${OPT_FAST} ${OPT_SLOW} ${DEV_TXT_DB} > ${DEV_CC_BBA_DB}
            DEPENDS ${DEV_CONSTIDS_INC} ${DEV_GFXH} ${DEV_TXT_DB} ${DB_PY}
            )
    add_custom_command(OUTPUT ${DEV_CC_DB}
            COMMAND bbasm ${DEV_CC_BBA_DB} ${DEV_CC_DB}
            DEPENDS bbasm ${DEV_CC_BBA_DB}
    )
    target_sources(ice40_chipdb PRIVATE ${DEV_CC_DB})
    set_source_files_properties(${DEV_CC_DB} PROPERTIES HEADER_FILE_ONLY TRUE)
endforeach (dev)
