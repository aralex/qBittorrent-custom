cmake_minimum_required(VERSION 3.16 FATAL_ERROR) # Policies <= CMP0097 default to NEW

project(qBittorrent-custom
    DESCRIPTION "The qBittorrent BitTorrent client (custom build)"
    HOMEPAGE_URL "https://github.com/aralex/qBittorrent-custom"
    LANGUAGES CXX
)

add_subdirectory(libtorrent)
add_subdirectory(qBittorrent)
