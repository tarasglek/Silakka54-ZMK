#include <errno.h>
#include <zephyr/device.h>
#include <zephyr/drivers/uart/cdc_acm.h>
#include <zephyr/kernel.h>
#include <zephyr/retention/bootmode.h>
#include <zephyr/sys/reboot.h>

#define TOUCH_BAUD_RATE 1200

static const struct device *touch_uart;
static struct k_work reboot_work;

static void reboot_work_handler(struct k_work *work) {
    ARG_UNUSED(work);
    if (bootmode_set(BOOT_MODE_TYPE_BOOTLOADER) == 0) {
        sys_reboot(SYS_REBOOT_WARM);
    }
}

static void touch_rate_changed(const struct device *dev, uint32_t rate) {
    if (dev == touch_uart && rate == TOUCH_BAUD_RATE) {
        k_work_submit(&reboot_work);
    }
}

static int dongle_touch_init(void) {
    touch_uart = DEVICE_DT_GET(DT_NODELABEL(dongle_touch_uart));
    if (!device_is_ready(touch_uart)) {
        return -ENODEV;
    }

    k_work_init(&reboot_work, reboot_work_handler);
    return cdc_acm_dte_rate_callback_set(touch_uart, touch_rate_changed);
}

SYS_INIT(dongle_touch_init, APPLICATION, CONFIG_APPLICATION_INIT_PRIORITY);
