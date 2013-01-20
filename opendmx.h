#ifndef _OPEN_DMX_H_
#define _OPEN_DMX_H_

#include <ftdi.h>


int opendmx_open(struct ftdi_context *ftdic);
int opendmx_init(struct ftdi_context *ftdic);
int opendmx_send(struct ftdi_context *ftdic, unsigned char *data);
int opendmx_close(struct ftdi_context *ftdic);

#endif
