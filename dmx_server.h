#ifndef _DMX_SERVER_H_
#define _DMX_SERVER_H_

typedef void* dmx_handler;

typedef int (*dmx_function)(dmx_handler);
typedef int (*dmx_send_function)(dmx_handler, unsigned char*);


struct dmx_controler
{
    char *name;
    dmx_function dmx_open;
    dmx_send_function dmx_send;
    dmx_function dmx_close;

    dmx_handler dh;
};

extern const struct dmx_controler *dmx_drv[];

#ifdef DMX_DRV_DEF
#define DMX_DRV_REGISTER(drv) int main() {\
  puts("_(dmx_drv_" #drv ")"); return 0;\
}
#else
#define DMX_DRV_REGISTER(drv) const struct dmx_controler dmx_drv_ ## drv = {\
  #drv,\
  (dmx_function) drv ## _open,\
  (dmx_send_function) drv ## _send,\
  (dmx_function) drv ## _close\
};
#endif

#endif
