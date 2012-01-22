#ifndef CUECABLE_H
#define CUECABLE_H

#include <libusb-1.0/libusb.h>

int cue_sync(libusb_device_handle *h);
int cue_dmx(libusb_device_handle *h, uint16_t addr, unsigned char value);
libusb_device_handle* cue_open();
void cue_close(libusb_device_handle *cue);

#endif
