#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/sys/printk.h>
#include <zephyr/logging/log.h>

// Initialize the logger for this module
LOG_MODULE_REGISTER(main_app, LOG_LEVEL_DBG);

// The time to sleep between toggles, in milliseconds
constexpr int sleepTimeMs = 1000;

// Get the node identifier for the alias 'led0' from the device tree.
#define LED0_NODE DT_ALIAS(led0)

/**
 * @class Blinker
 * @brief Manages the configuration and blinking of an LED.
 */
class Blinker {
public:
  /**
   * @brief Constructs a Blinker object.
   *
   * Initializes the GPIO for the LED and configures it as an output.
   * It checks if the device is ready and handles configuration errors.
   */
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
    LOG_INF("Blinker initialized successfully for %s pin %d", led.port->name, led.pin);
    isReady = true;
  }

  /**
   * @brief Runs the main blinking loop.
   *
   * This method will loop indefinitely, toggling the LED state and sleeping.
   * It will not execute if the initial setup failed.
   */
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
  // Add a delay to allow hardware and the serial terminal to stabilize
  k_msleep(2000);
  LOG_INF("Application main started");
  
  LOG_INF("Logging subsystem test started.");
  LOG_DBG("This is a debug message.");
  LOG_WRN("This is a warning message.");
  LOG_ERR("This is an error message.");

  Blinker blinker;
  blinker.run();
  return 0; // Should not be reached.
}
