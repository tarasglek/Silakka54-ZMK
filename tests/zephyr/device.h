#pragma once

#include <stdbool.h>

struct device {
    bool ready;
};

extern struct device dongle_touch_device;
#define DT_NODELABEL(label) label
#define DEVICE_DT_GET(node) (&dongle_touch_device)
#define device_is_ready(dev) ((dev)->ready)
