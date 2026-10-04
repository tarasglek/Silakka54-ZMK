#pragma once

#include <stdint.h>

enum boot_mode_type {
    BOOT_MODE_TYPE_BOOTLOADER = 1,
};

int bootmode_set(uint8_t type);
