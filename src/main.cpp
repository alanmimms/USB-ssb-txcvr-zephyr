#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/logging/log.h>

// Initialize the logger for this module
LOG_MODULE_REGISTER(main_app, LOG_LEVEL_INF);

// The time to sleep between toggles, in milliseconds
constexpr int sleepTimeMs = 1000;

// Get the node identifier for the alias 'led0' from the device tree.
#define LED0_NODE DT_ALIAS(led0)

/**
 * @brief Manages the configuration and blinking of an LED to show activity.
 */
class Blinker {
public:
  Blinker() : led(GPIO_DT_SPEC_GET(LED0_NODE, gpios)) {
    if (!device_is_ready(led.port)) {
      LOG_ERR("Error: GPIO device %s is not ready", led.port->name);
      isReady = false;
      return;
    }

    int ret = gpio_pin_configure_dt(&led, GPIO_OUTPUT_ACTIVE);
    if (ret < 0) {
      LOG_ERR("Error %d: failed to configure %s pin %d", ret, led.port->name, led.pin);
      isReady = false;
      return;
    }
    LOG_INF("Blinker initialized successfully");
    isReady = true;
  }

  void run() {
    if (!isReady) {
      return;
    }
    while (1) {
      gpio_pin_toggle_dt(&led);
      k_msleep(sleepTimeMs);
    }
  }

private:
  const struct gpio_dt_spec led;
  bool isReady = false;
};

/**
 * @brief Main entry point for the application.
 */
int main() {
  LOG_INF("Application started");
  LOG_INF("USB stack will be initialized automatically by the system.");
  LOG_INF("Waiting for host connection on USB_OTG_FS port...");

  Blinker blinker;
  blinker.run();

  return 0; // Should not be reached.
}
