/* gcc -ansi -o cuecable cuecable.c -lusb-1.0 */
 
#include <stdio.h>
#include <string.h> 

#include <libusb-1.0/libusb.h>

int test_vip_pid(libusb_device_handle *h, uint16_t vendor_id, uint16_t product_id)
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

void clear_features(libusb_device_handle *h)
{
    //unsigned char data[sizeof(desc)] = {0};

    libusb_control_transfer(h, LIBUSB_ENDPOINT_OUT | LIBUSB_RECIPIENT_ENDPOINT
                             , LIBUSB_REQUEST_CLEAR_FEATURE
                             , 0x0000, 0x001
                             , 0, 0
                             , 200);
    
    libusb_control_transfer(h, LIBUSB_ENDPOINT_OUT | LIBUSB_RECIPIENT_ENDPOINT
                             , LIBUSB_REQUEST_CLEAR_FEATURE
                             , 0x0000, 0x0081
                             , 0, 0
                             , 200);

}

int main(int argc, char *argv[])
{    
    libusb_device **all_usb;
    libusb_device_handle *cue;
    int device_count, device_index;
    
    unsigned char data[64] = {0x67, 0x45, 0};
    int err = 0;
    int count_out;

    /* if any errors occurs) */
    if( libusb_init(0) ){
        printf("error occurs when initialized usb\n");
        return -1;
    }

    device_count = libusb_get_device_list(0, &all_usb);

    for(device_index = 0; device_index < device_count; device_index++){
        libusb_device_handle *h;
        int err;
        int bus_number = libusb_get_bus_number(all_usb[device_index]);
        int device_addr= libusb_get_device_address(all_usb[device_index]);


        err = libusb_open(all_usb[device_index], &h);
        if( err ){
            printf("error occurs when attempting to open usb device %i,%i\n",
                   bus_number, device_addr);
            continue;
        }
        if( test_vip_pid(h, 0x0547, 0x1026) ){
            cue = h;
            printf("device found %i,%i\n", bus_number, device_addr);
            break;
        }

        libusb_close(h);

    }
    libusb_free_device_list(all_usb, 0);

    clear_features(cue);

    err = libusb_bulk_transfer(cue,
                               LIBUSB_ENDPOINT_OUT, data, 2, &count_out, 200);
    if( err || count_out != 2 )
        goto errors;

    err = libusb_bulk_transfer(cue,
                               LIBUSB_ENDPOINT_IN, data, 3, &count_out, 200);
    if( err || count_out != 3 ){
        goto errors;
    }

    printf("1 -- %hhx%hhx%hhx\n", data[0], data[1], data[2]);

    libusb_close(cue);
    libusb_exit(0);
    return 0;

errors:

    printf("couldn't send request. data(%i), err(%i)\n", count_out, err);
    printf("error occurs during transfere\n");
    return -1;
}
