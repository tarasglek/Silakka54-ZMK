#pragma once

#include <stdint.h>
#include <zephyr/device.h>

typedef void (*cdc_dte_rate_callback_t)(const struct device *dev, uint32_t rate);
int cdc_acm_dte_rate_callback_set(const struct device *dev,
                                  cdc_dte_rate_callback_t callback);
