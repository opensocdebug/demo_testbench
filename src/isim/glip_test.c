#include <libglip.h>

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

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
    packet[2] = (0x2 << 12) | 0x0;
    packet[3] = 0;

    glip_write_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);

    glip_read_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);
    assert(size_written == 8);
    assert(packet[0] == 3);
    assert(packet[1] == 0);
    assert(packet[2] == 1);

    printf("Found module type 0x%04x\n", packet[3]);

    packet[0] = 3;
    packet[1] = 0x1;
    packet[2] = (0x2 << 12) | 0x0;
    packet[3] = 1;

    glip_write_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);

    glip_read_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);
    assert(size_written == 8);
    assert(packet[0] == 3);
    assert(packet[1] == 0);
    assert(packet[2] == 1);

    printf("  module version 0x%04x\n", packet[3]);

    sleep(1);

    /* close the connection to the target */
    glip_close(gctx);
    /* free all resources */
    glip_free(gctx);

    return 0;
}
