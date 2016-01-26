#include <libglip.h>

#include <stdio.h>
#include <stdlib.h>

int main() {
    int rv;
    struct glip_ctx *gctx;

    rv = glip_new(&gctx, "tcp", 0, 0);
    if (rv != 0) {
        printf("An error happened when creating the GLIP context.\n");
        exit(1);
    }

    glip_open(gctx, 1);

    uint16_t packet[16];
    size_t size_written;

    packet[0] = 3;
    packet[1] = 0x1;
    packet[2] = 0x0;
    packet[3] = 0xabcd;

    glip_write_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);
    glip_write_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);

    sleep(1);

    /* close the connection to the target */
    glip_close(gctx);
    /* free all resources */
    glip_free(gctx);

    return 0;
}
