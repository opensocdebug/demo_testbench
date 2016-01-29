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

    if (packet[3] != 1) {
      printf("Expected SCM at index 1, but not found\n");
      exit(-1);
    } else {
      printf("Found SCM\n");
    }
    
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

    printf("  SCM version 0x%04x\n", packet[3]);
    
    packet[0] = 3;
    packet[1] = 0x1;    
    packet[2] = (0x2 << 12) | 0x0;
    packet[3] = 0x200;

    glip_write_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);

    glip_read_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);
    assert(size_written == 8);
    assert(packet[0] == 3);
    assert(packet[1] == 0);
    assert(packet[2] == 1);

    if (packet[3] != 0xdead) {
      printf("Expected system ID 0xdead, found %04x\n", packet[3]);
      exit(-1);
    } else {
      printf("Found system ID 0xdead\n");
    }

    packet[0] = 3;
    packet[1] = 0x1;    
    packet[2] = (0x2 << 12) | 0x0;
    packet[3] = 0x201;

    glip_write_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);

    glip_read_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);
    assert(size_written == 8);
    assert(packet[0] == 3);
    assert(packet[1] == 0);
    assert(packet[2] == 1);

    printf("SCM says there are %d modules, enumerate:\n", packet[3]);

    printf(" [1] SCM\n");

    for (int i = 2; i <= packet[3]; i++) {
      packet[0] = 3;
      packet[1] = i;
      packet[2] = (0x2 << 12) | 0x0;
      packet[3] = 0;
      
      glip_write_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);
      
      glip_read_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 1*1000);
      assert(size_written == 8);
      assert(packet[0] == 3);
      assert(packet[1] == 0);
      assert(packet[2] == i);
      
      printf(" [%d] ", i);
      if (packet[3] == 0x2) {
	printf("DEM_UART\n");
      } else {
	printf("unknown\n");
      }
    }
    
    /* close the connection to the target */
    glip_close(gctx);
    /* free all resources */
    glip_free(gctx);

    return 0;
}
