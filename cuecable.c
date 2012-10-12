/* gcc -o cuecable cuecable.c -lusb-1.0 -DEXEMPLE */

#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <libusb-1.0/libusb.h>

#include "dmx_server.h"

static int cue_init(libusb_device_handle *h);
int cue_sync(libusb_device_handle *h);
int cue_dmx(libusb_device_handle *h, uint16_t addr, unsigned char value);
int cue_send_all(libusb_device_handle *h, unsigned char *data);
int cue_open(libusb_device_handle* h);
int cue_close(libusb_device_handle *cue);

void cue_new(struct dmx_controler *dmx){
    dmx->init      = (dmx_function)cue_open;
    dmx->open_dmx  = (dmx_function)cue_init;
    dmx->send_dmx  = (dmx_send_function)cue_send_all;
    dmx->close_dmx = (dmx_function)cue_close;
}


#if 0
static int test_vip_pid(libusb_device_handle *h, uint16_t vendor_id,
                                                 uint16_t product_id)
{
    struct libusb_device_descriptor desc;
    unsigned char data[sizeof(desc)] = {0};

    libusb_control_transfer(h, LIBUSB_ENDPOINT_IN
                             , LIBUSB_REQUEST_GET_DESCRIPTOR
                             , 0x0100, 0x00
                             , data, 40
                             , 200);

    memcpy(&desc, data, sizeof(desc));
    return desc.idVendor == vendor_id && desc.idProduct == product_id;
}
#endif

static int clear_features(libusb_device_handle *h)
{
    int err;

    err = libusb_control_transfer(h, LIBUSB_ENDPOINT_OUT | LIBUSB_RECIPIENT_ENDPOINT
                                   , LIBUSB_REQUEST_CLEAR_FEATURE
                                   , 0x0000, 0x001
                                   , 0, 0
                                   , 200);
    if( err )
        return err;

    err = libusb_control_transfer(h, LIBUSB_ENDPOINT_OUT | LIBUSB_RECIPIENT_ENDPOINT
                                   , LIBUSB_REQUEST_CLEAR_FEATURE
                                   , 0x0000, 0x0081
                                   , 0, 0
                                   , 200);

    if( err )
        return err;

    return 0;

}

static int cue_init(libusb_device_handle *h)
{
    struct bulk{
        unsigned char data[37];
        size_t len;
    };

    struct bulk bulk_out[] = {
        {{0x67, 0x45}, 2},
        {{0x55, 0x45}, 2},
        {{0x70, 0x45}, 2},
        {{0x41, 0x29, 0x6b, 0xd6, 0xeb, 0x2c, 0xa9, 0x03, 0x21, 0xbb, 0xef, 0x5f, 0x5f, 0x4c, 0xfc, 0x10, 0xec, 0x45}, 18},
        {{0}, 0}
    };

    struct bulk bulk_in[] = {
        {{0}, 3},
        {{0}, 3},
        {{0}, 2},
        {{0}, 17}
    };

    struct bulk *out = bulk_out;
    struct bulk *in  = bulk_in;

    int err;

    while(in->len && out->len ){
        int bytes_transferred = 0;

        err = libusb_bulk_transfer(h, LIBUSB_ENDPOINT_OUT | 0x01
                                    , out->data, out->len
                                    , &bytes_transferred
                                    , 200);
        if( err || bytes_transferred != out->len )
            goto errors;

        usleep(1000);
        err = libusb_bulk_transfer(h, LIBUSB_ENDPOINT_IN | 0x01
                                    , in->data, in->len
                                    , &bytes_transferred
                                    , 200);
        if( err || bytes_transferred != in->len )
            goto errors;

        in++;
        out++;
    }

    return 0;
errors:

    printf("errors occurs during initializing cuecable (%i)\n", err);
    return err;
}

int cue_send_all(libusb_device_handle *h, unsigned char data[512])
{
    int err = 0;

    const unsigned char start_code = 0x59;
    const unsigned char stop_code  = 0x45;
    const unsigned char block_size = 32;

    uint16_t addr = 0x01;
    while( addr <= 512 ){
        int bytes_transferred = 0;

        unsigned char send[37];
        send[0]  = start_code;
        send[1]  = (uint8_t)(addr >> 8) & 0xff;
        send[2]  = (uint8_t)(addr & 0xff);
        send[3]  = 0x20;
        memcpy(&send[4], &data[addr-1], block_size);
        send[36] = stop_code;

        err = libusb_bulk_transfer(h, LIBUSB_ENDPOINT_OUT | 0x01
                                    , send, sizeof(send)
                                    , &bytes_transferred
                                    , 200);

        if( err || bytes_transferred != sizeof(send) )
            break;

        addr += block_size;
    }

    return 0;
}

int cue_sync(libusb_device_handle *h)
{
    unsigned char data[] = {0x48, 0x45};
    int bytes_transferred = 0;

    return libusb_bulk_transfer(h, LIBUSB_ENDPOINT_OUT | 0x01
                                 , data, 2
                                 , &bytes_transferred
                                 , 200);

}

int cue_dmx(libusb_device_handle *h, uint16_t addr, unsigned char value)
{
    unsigned char up[5];
    int bytes_transferred = 0;

    up[0] = 0x57;
    up[1] = (addr>>8) & 0x0f;
    up[2] = addr & 0x0f;
    up[3] = value;
    up[4] = 0x45;

    return libusb_bulk_transfer(h, LIBUSB_ENDPOINT_OUT | 0x01
                                 , up, 5
                                 , &bytes_transferred
                                 , 200);

}

int cue_open(libusb_device_handle *cue)
{
    libusb_device **all_usb;

    int device_count, device_index;

    int err = 0;

    /* if any errors occurs) */
    if( libusb_init(0) ){
        printf("error occurs when initializing usb\n");
        return 0;
    }

    device_count = libusb_get_device_list(0, &all_usb);

    for(device_index = 0; device_index < device_count; device_index++){
        struct libusb_device_descriptor desc;
        int err;
        int bus_number = libusb_get_bus_number(all_usb[device_index]);
        int device_addr= libusb_get_device_address(all_usb[device_index]);

        /* CueCable vendor_id and product_id */
        libusb_get_device_descriptor(all_usb[device_index], &desc);
        if( desc.idVendor == 0x0547 && desc.idProduct == 0x1026 ){
            libusb_device_handle *h;
            err = libusb_open(all_usb[device_index], &h);
            if( err ){
                printf("error occurs when attempting to open usb device %i,%i\n",
                       bus_number, device_addr);
                break;
            }

            cue = h;
            printf("device found %i,%i\n", bus_number, device_addr);
            break;
        }
    }

    libusb_free_device_list(all_usb, 0);
    if( cue == 0 )
        /* device not found */
        return 1;

    err = clear_features(cue);
    if( err ){
        /* error when init cable */
        printf("couldn't clear cuecable (%i)\n", err);
        return 0;
    }

    cue_sync(cue);
    err = cue_init(cue);
    cue_sync(cue);

    return 0;
}

int cue_close(libusb_device_handle *cue)
{
    libusb_close(cue);
    libusb_exit(0);

    return 0;

}

#ifdef EXEMPLE
int main(int argc, char *argv[])
{
    libusb_device_handle *cue = 0;
    unsigned char data[512];

    cue_open(cue);
    if( !cue )
        goto errors;

    data[0] = 0;
    data[1] = 255;
    data[2] = 0;
    data[3] = 0;
    data[4] = 0;

    cue_init(cue);
    cue_send_all(cue, data);

/*
    cue_dmx(cue, 0x02, 00);
    cue_dmx(cue, 0x03, 00);
    cue_dmx(cue, 0x04, 00);
    cue_sync(cue);
*/
    cue_close(cue);
    return 0;

errors:

    printf("error occurs during transfere\n");
    return -1;
}
#endif
