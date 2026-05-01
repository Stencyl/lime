for filename in ${NATIVE_TOOLKIT_PATH}/sdl/wayland-protocols/*; do
  protocol=$(basename $filename .xml)
  wayland-scanner client-header ${NATIVE_TOOLKIT_PATH}/sdl/wayland-protocols/$protocol.xml ${NATIVE_TOOLKIT_PATH}/custom/sdl/wayland-generated-protocols/$protocol-client-protocol.h
  wayland-scanner private-code ${NATIVE_TOOLKIT_PATH}/sdl/wayland-protocols/$protocol.xml ${NATIVE_TOOLKIT_PATH}/custom/sdl/wayland-generated-protocols/$protocol-protocol.c
done