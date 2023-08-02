cmake_minimum_required(VERSION 3.16 FATAL_ERROR) # Policies <= CMP0097 default to NEW

project(qBittorrent-custom
    DESCRIPTION "The qBittorrent BitTorrent client (custom build)"
    HOMEPAGE_URL "https://github.com/aralex/qBittorrent-custom"
    LANGUAGES CXX
)


set(LIB_INSTALL_DIR "lib64")

set(CMAKE_BUILD_RPATH_USE_ORIGIN ON)
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)
set(CMAKE_SKIP_BUILD_RPATH OFF)
#set(CMAKE_INSTALL_RPATH "\$ORIGIN/../${LIB_INSTALL_DIR}")
set(CMAKE_INSTALL_RPATH "                                                                                                    ")

add_subdirectory(libtorrent)
add_subdirectory(qBittorrent)

set(CPACK_PROJECT_NAME              ${CMAKE_PROJECT_NAME})
set(CPACK_PROJECT_VERSION           "4.5.4")

set(CPACK_PACKAGE_VERSION           ${CPACK_PROJECT_VERSION})
set(CPACK_PACKAGE_NAME              ${CMAKE_PROJECT_NAME})
set(CPACK_PACKAGE_RELEASE           1)
set(CPACK_PACKAGE_CONTACT           "artem@inze.net")
set(CPACK_PACKAGE_VENDOR            "Artem N. Alexeyev")
set(CPACK_PACKAGING_INSTALL_PREFIX  "/opt/${CMAKE_PROJECT_NAME}")
set(CPACK_PACKAGE_FILE_NAME         "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}")
set(TOP_DIR                         "${CMAKE_BINARY_DIR}/_CPack_Packages/Linux/RPM")

set(CPACK_GENERATOR "RPM")

set(CPACK_SOURCE_RPM  OFF)
set(CPACK_SOURCE_TBZ2 OFF)
set(CPACK_SOURCE_TGZ  OFF)
set(CPACK_SOURCE_TXZ  OFF)
set(CPACK_SOURCE_TZ   OFF)
set(CPACK_SOURCE_ZIP  OFF)

set(CPACK_BINARY_DEB     OFF)
set(CPACK_BINARY_FREEBSD OFF)
set(CPACK_BINARY_IFW     OFF)
set(CPACK_BINARY_NSIS    OFF)
set(CPACK_BINARY_RPM     ON)
set(CPACK_BINARY_STGZ    OFF)
set(CPACK_BINARY_TBZ2    OFF)
set(CPACK_BINARY_TGZ     OFF)
set(CPACK_BINARY_TXZ     OFF)
set(CPACK_BINARY_TZ      OFF)

set(CPACK_RPM_USER_BINARY_SPECFILE "${CMAKE_BINARY_DIR}/qbittorrent-custom.spec")
configure_file("${CMAKE_SOURCE_DIR}/qbittorrent-custom.spec.in" "${CPACK_RPM_USER_BINARY_SPECFILE}" @ONLY IMMEDIATE)

include(CPack)
