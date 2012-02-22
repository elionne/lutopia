cmake_minimum_required(VERSION 2.8)
project(lutopia)

set(src vt_lua.c cuecable.c)

add_executable(lutopia ${src} )
target_link_libraries(lutopia lua usb-1.0)
install(TARGETS lutopia DESTINATION ../)
