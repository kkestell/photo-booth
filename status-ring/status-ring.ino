#include <Adafruit_NeoPixel.h>

#define PIN_BUTTON_CAPTURE 4

Adafruit_NeoPixel pixels = Adafruit_NeoPixel(60, 3, NEO_GRB + NEO_KHZ800);

void setup() {
  pinMode(PIN_BUTTON_CAPTURE, INPUT);
  digitalWrite(PIN_BUTTON_CAPTURE, HIGH);

  Serial.begin(9600);

  pixels.begin();
  clear();
}

void clear() {
  for(int i = 0; i < 60; i++) {
    pixels.setPixelColor(i, pixels.Color(0, 0, 0));
  }

  pixels.show();
}

void countdown() {
  for(int b = 0; b < 64; b++) {
    for(int i = 0; i < 60; i++) {
      pixels.setPixelColor(i, pixels.Color(b, b, b));
    }
    pixels.show();
    delay(16);
  }

  for(int i = 0; i < 60; i++) {
    if(i - 1 >= 0)
      pixels.setPixelColor(i - 1, pixels.Color(32, 32, 32));

    if(i - 2 >= 0)
      pixels.setPixelColor(i - 2, pixels.Color(16, 16, 16));

    if(i - 3 >= 0)
      pixels.setPixelColor(i - 3, pixels.Color(4, 4, 4));

    if(i - 4 >= 0)
      pixels.setPixelColor(i - 4, pixels.Color(0, 0, 0));

    pixels.show();

    delay(40);
  }

  clear();
}

void red_alert() {
  for(int c = 0; c < 3; c++) {
    for(int b = 0; b < 256; b++) {
      for(int i = 0; i < 60; i++) {
        pixels.setPixelColor(i, pixels.Color(b, 0, 0));
      }
      pixels.show();
    }

    delay(250);

    for(int b = 255; b >= 0; b--) {
      for(int i = 0; i < 60; i++) {
        pixels.setPixelColor(i, pixels.Color(b, 0, 0));
      }
      pixels.show();
    }

    delay(250);
  }

  clear();
}

void sparkle() {
  for(int i = 0; i < 100; i++) {
    clear();
    for(int c = 0; c < 30; c++) {
      pixels.setPixelColor(random(60), pixels.Color(64, 64, 64));
      pixels.show();
    }
  }

  clear();
}

void breathe() {
  for(int c = 0; c < 3; c++) {
    for(int b = 1; b < 41; b++) {
      for(int i = 0; i < 60; i++) {
        pixels.setPixelColor(i, pixels.Color(b, b, b));
      }
      pixels.show();
      delay(50);
    }

    delay(500);

    for(int b = 40; b > 0; b--) {
      for(int i = 0; i < 60; i++) {
        pixels.setPixelColor(i, pixels.Color(b, b, b));
      }
      pixels.show();
      delay(50);
    }

    delay(1000);
  }

  clear();
}

void loop() {
  int buttonState = 0;
  buttonState = digitalRead(PIN_BUTTON_CAPTURE);
  if (digitalRead(PIN_BUTTON_CAPTURE) == LOW) {
    Serial.write("0");
    delay(1000);
  }

  if (Serial.available() > 0) {  
    int command = Serial.read() - 48;
    if(command == 0)
      countdown();
    if(command == 1)
      red_alert();
    if(command == 2)
      sparkle();
    if(command == 3)
      breathe();
  }
}
