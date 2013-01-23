#include "dmx_server.h"

#define _(drv) extern struct dmx_controler drv;
#include "dmx_drv_list.h"
#undef _

#define _(drv) &drv,
struct dmx_controler *dmx_drv_list[] = {
#include "dmx_drv_list.h"
  0
};
#undef _
