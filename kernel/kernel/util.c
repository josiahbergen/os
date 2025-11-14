#include <kernel/logging.h>
#include <kernel/util.h>

void halt() {
    KERNEL_LOG(INFO, "halt");
    arch_halt();
}
