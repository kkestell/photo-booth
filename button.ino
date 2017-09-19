#include <TrinketKeyboard.h>

#define PIN_BUTTON_CAPTURE 0
#define PIN_BUTTON_RESET   2
 
void setup()
{
  pinMode(PIN_BUTTON_CAPTURE, INPUT);
  pinMode(PIN_BUTTON_RESET, INPUT);
 
  digitalWrite(PIN_BUTTON_CAPTURE, LOW);
  digitalWrite(PIN_BUTTON_RESET, LOW);

  TrinketKeyboard.begin();
}

void doze(int ms)
{
  unsigned long start = millis();
  while(millis() < start + ms) {
    TrinketKeyboard.poll();
    delay(8);
  }
}
 
void loop() 
{
  // The poll function must be called at least once every 10 ms
  // or cause a keystroke if it is not, then the computer may
  // think that the device has stopped working, and give errors
  TrinketKeyboard.poll();
 
  if (digitalRead(PIN_BUTTON_CAPTURE) == HIGH) {
    TrinketKeyboard.print("capture\n");
    doze(10000);
  }
 
  if (digitalRead(PIN_BUTTON_RESET) == HIGH) {
    TrinketKeyboard.print("reset\n");
    doze(10000);
  }
}
