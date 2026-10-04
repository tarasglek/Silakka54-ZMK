#pragma once

struct k_work;
typedef void (*k_work_handler_t)(struct k_work *work);
struct k_work {
    k_work_handler_t handler;
};
static inline void k_work_init(struct k_work *work, k_work_handler_t handler) {
    work->handler = handler;
}
int k_work_submit(struct k_work *work);
#define ARG_UNUSED(value) (void)(value)
#define SYS_INIT(function, level, priority)
#define APPLICATION 0
#define CONFIG_APPLICATION_INIT_PRIORITY 0
