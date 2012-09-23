/* simple.c

   Simple libftdi usage example

   This program is distributed under the GPL, version 2
*/

#include <stdio.h>
#include <ftdi.h>

int main(void)
{
    unsigned char data[513];

    int i;
    for(i = 0; i < sizeof(data); ++i)
        data[i] = 0x0;

    data[0] = 0;
    data[7] = 0x0;
    data[8] = 0xff;
    data[9] = 0xff;
    
    int ret;
    struct ftdi_context ftdic;
    if (ftdi_init(&ftdic) < 0)
    {
        fprintf(stderr, "ftdi_init failed\n");
        return EXIT_FAILURE;
    }

    if ((ret = ftdi_usb_open(&ftdic, 0x0403, 0x6001)) < 0)
    {
        fprintf(stderr, "unable to open ftdi device: %d (%s)\n", ret, ftdi_get_error_string(&ftdic));
        return EXIT_FAILURE;
    }

    ftdi_set_baudrate(&ftdic, 250000);

    do{
        ftdi_set_line_property2(&ftdic, BITS_8, STOP_BIT_2, NONE, BREAK_ON);
        usleep(200);
        ftdi_set_line_property2(&ftdic, BITS_8, STOP_BIT_2, NONE, BREAK_OFF);
        usleep(12);

        ret = ftdi_write_data(&ftdic, data, sizeof(data));
        usleep(2000);
        data[9]++;

        //printf("bytes written %i\n", ret);
    }while(1);


    if ((ret = ftdi_usb_close(&ftdic)) < 0)
    {
        fprintf(stderr, "unable to close ftdi device: %d (%s)\n", ret, ftdi_get_error_string(&ftdic));
        return EXIT_FAILURE;
    }

    ftdi_deinit(&ftdic);

    return EXIT_SUCCESS;
}