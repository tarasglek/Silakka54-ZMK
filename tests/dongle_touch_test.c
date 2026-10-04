#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

#include <zephyr/device.h>
#include <zephyr/drivers/uart/cdc_acm.h>
#include <zephyr/kernel.h>
#include <zephyr/retention/bootmode.h>
#include <zephyr/sys/reboot.h>

struct device dongle_touch_device = {.ready = true};
struct device studio_uart_device = {.ready = true};
static struct device *registered_device;
static cdc_dte_rate_callback_t registered_callback;
static int registration_result;
static int queued_work;
static int reboot_count;
static int reboot_type;
static int bootmode_result;
static int bootmode_type;
enum event { BOOTMODE_SET_EVENT, REBOOT_EVENT };
static enum event events[2];
static int event_count;

int bootmode_set(uint8_t type) {
    bootmode_type = (int)type;
    events[event_count++] = BOOTMODE_SET_EVENT;
    return bootmode_result;
}

int cdc_acm_dte_rate_callback_set(const struct device *dev,
                                  cdc_dte_rate_callback_t callback) {
    registered_device = (struct device *)dev;
    registered_callback = callback;
    return registration_result;
}

int k_work_submit(struct k_work *work) {
    queued_work = 1;
    (void)work;
    return 1;
}

void sys_reboot(int type) {
    reboot_count++;
    reboot_type = type;
    events[event_count++] = REBOOT_EVENT;
}

#if __has_include("../module/src/dongle_touch.c")
#include "../module/src/dongle_touch.c"

static void run_queued_work(void) {
    assert(queued_work);
    queued_work = 0;
    reboot_work_handler(&reboot_work);
}

int main(void) {
    assert(dongle_touch_init() == 0);
    assert(registered_device == &dongle_touch_device);
    assert(registered_callback != NULL);

    registered_callback(&studio_uart_device, 1200);
    registered_callback(&dongle_touch_device, 9600);
    assert(!queued_work);
    assert(reboot_count == 0);

    registered_callback(&dongle_touch_device, 1200);
    assert(queued_work);
    assert(reboot_count == 0);
    run_queued_work();
    assert(reboot_count == 1);
    assert(reboot_type == SYS_REBOOT_WARM);
    assert(bootmode_type == BOOT_MODE_TYPE_BOOTLOADER);
    assert(event_count == 2);
    assert(events[0] == BOOTMODE_SET_EVENT);
    assert(events[1] == REBOOT_EVENT);

    event_count = 0;
    bootmode_result = -EIO;
    registered_callback(&dongle_touch_device, 1200);
    run_queued_work();
    assert(reboot_count == 1);
    assert(event_count == 1);
    assert(events[0] == BOOTMODE_SET_EVENT);

    dongle_touch_device.ready = false;
    assert(dongle_touch_init() == -ENODEV);
    dongle_touch_device.ready = true;

    registration_result = -1;
    assert(dongle_touch_init() == -1);

    puts("dongle touch tests passed");
    return 0;
}
#else
int main(void) {
    assert(!"dongle touch module implementation is missing");
    return 1;
}
#endif
