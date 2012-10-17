cmake_minimum_required(VERSION 2.8)
project(lutopia)

set(src vt_lua.c)

add_executable(lutopia ${src} )
target_link_libraries(lutopia lua )
install(TARGETS lutopia DESTINATION ../)

set(dmx_server_src dmx_server.c open_dmx.c)
add_executable(dmx_server ${dmx_server_src} )
target_link_libraries(dmx_server ftdi)
install(TARGETS dmx_server DESTINATION ../)
