#include <stdio.h>
#include <sys/time.h>

#include "dmx_server.h"
#include "opendmx.h"

int opendmx_open(struct ftdi_context *ftdic)
{
    int ret;
    if (ftdi_init(ftdic) < 0)
    {
        fprintf(stderr, "ftdi_init failed\n");
        return EXIT_FAILURE;
    }

    ret = ftdi_usb_open(ftdic, 0x0403, 0x6001);
    if( ret < 0 )
    {
        fprintf(stderr, "unable to open ftdi device: %d (%s)\n", ret, ftdi_get_error_string(ftdic));
        return EXIT_FAILURE;
    }

    ftdi_set_baudrate(ftdic, 250000);

    return EXIT_SUCCESS;
}

int opendmx_send(struct ftdi_context *ftdic, unsigned char *data)
{
    int ret = 0;
    //struct timeval start, end;

    //gettimeofday(&start, 0);

    ftdi_set_line_property2(ftdic, BITS_8, STOP_BIT_2, NONE, BREAK_ON);
    usleep(92);
    ftdi_set_line_property2(ftdic, BITS_8, STOP_BIT_2, NONE, BREAK_OFF);
    usleep(12);

    ret = ftdi_write_data(ftdic, data, 513);

    //gettimeofday(&end, 0);
    //int diff = 0;

    //if( (end.tv_sec - start.tv_sec) > 0 )
    //    diff = (end.tv_sec - start.tv_sec)*1e6 + (end.tv_usec - start.tv_usec);
    //else
    //    diff = (end.tv_usec - start.tv_usec);
    //if( diff < 0 )
    //    printf("timeval\tstart\tend\n\ttv_sec %i\t%i\n\ttv_usec %i\t%i\n",
    //           start.tv_sec, end.tv_sec, start.tv_usec, end.tv_usec);

    usleep(1204*2);
    //printf("send time %i\n", diff);
    //fflush(stdout);
    return ret;
}

int opendmx_close(struct ftdi_context *ftdic)
{
    int ret = ftdi_usb_close(ftdic);
    if( ret < 0 )
    {
        fprintf(stderr, "unable to close ftdi device: %d (%s)\n", ret, ftdi_get_error_string(ftdic));
        return 1;
    }

    ftdi_deinit(ftdic);
    return 0;
}

DMX_DRV_REGISTER(opendmx)

#ifdef EXEMPLE
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

    struct ftdi_context ftdic;

    open_dmx_init(&ftdic);
    open_dmx_open(&ftdic);
    open_dmx_send(&ftdic, data);


    return EXIT_SUCCESS;
}
#endif
