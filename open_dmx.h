#ifndef _OPEN_DMX_H_
#define _OPEN_DMX_H_

#include <ftdi.h>


int open_dmx_open(struct ftdi_context *ftdic);
int open_dmx_init(struct ftdi_context *ftdic);
int open_dmx_send(struct ftdi_context *ftdic, unsigned char *data);
int open_dmx_close(struct ftdi_context *ftdic);

#endif
