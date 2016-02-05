#include <glip/libglip.h>

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int main() {
    int rv;
    struct glip_ctx *gctx;

    /*    struct glip_option backend_options[] = {
      { .name = "device", .value = "/dev/ttyUSB1" },
      { .name = "speed", .value = "1000000" },
    };
    
    rv = glip_new(&gctx, "uart", backend_options, 2);*/
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

    glip_read_b(gctx, 0, 12, (uint8_t*) packet, &size_written, 1*1000);

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

    uint16_t uart_id = 0;
    
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
	uart_id = i;
      } else {
	printf("unknown\n");
      }
    }

    if (uart_id == 0) {
	printf("No UART found.\n");
	exit (-1);
    }
      
    printf("Ready. Enable UART\n");

    packet[0] = 4;
    packet[1] = uart_id;    
    packet[2] = (0x4) << 10 | 0x0;
    packet[3] = 0x3;
    packet[4] = 0x1 << 11 | 0x0;

    glip_write_b(gctx, 0, 10, (uint8_t*) packet, &size_written, 1*1000);

    glip_read_b(gctx, 0, 6, (uint8_t*) packet, &size_written, 1*1000);
    assert(size_written == 6);
    assert(packet[0] == 2);
    assert(packet[1] == 0);
    assert(packet[2] == (1 << 11) | uart_id);
    
    while (1) {
      glip_read_b(gctx, 0, 8, (uint8_t*) packet, &size_written, 0);
      assert(size_written == 8);
      assert(packet[0] == 3);
      assert(packet[1] == 0);
      assert(packet[2] == 0x4402);

      printf("%c", (packet[3] & 0xff)); 
    }
    
    /* close the connection to the target */
    glip_close(gctx);
    /* free all resources */
    glip_free(gctx);

    return 0;
}
