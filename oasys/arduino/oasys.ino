#include <FastLED.h>

#define trigPin 11
#define echoPin 10
#define LED_PIN     5
#define NUM_LEDS    94
#define BRIGHTNESS  100
#define LED_TYPE    WS2811
#define COLOR_ORDER GRB
#define UPDATES_PER_SECOND 100

int relay = 7;
bool flag = false;
char recieved;

CRGB leds[NUM_LEDS];
CRGBPalette16 currentPalette;
TBlendType    currentBlending;

void setup() {
  Serial.begin (9600);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(relay, OUTPUT);
  delay( 500 ); // delay de seguridad de encendido
  FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.setBrightness(  BRIGHTNESS );
}

void loop() {
  if (flag == false) {
    digitalWrite(relay, HIGH); // apaga
    SetupBlackAndWhiteStripedPalette();
    currentBlending = LINEARBLEND;

    static uint8_t startIndex = 0;
    startIndex = startIndex + 1; /* motion speed */
    FillLEDsFromPaletteColors( startIndex);
    FastLED.show();
    FastLED.delay(1000 / UPDATES_PER_SECOND);
  }
  else{
      long duracion, distancia ;
      digitalWrite(trigPin, LOW);
      delayMicroseconds(2);
      digitalWrite(trigPin, HIGH);
      delayMicroseconds(10);
      digitalWrite(trigPin, LOW);
      duracion = pulseIn(echoPin, HIGH) ;
      distancia = duracion / 2 / 29  ;
      //Serial.println(String(distancia) + " cm.") ;
      if ( distancia >100) {
        digitalWrite ( relay , HIGH); // apaga
      }
      if (distancia < 100 && distancia >20){
        digitalWrite ( relay , LOW); // enciende
        delay(10000);
      }
  }
  while (Serial.available() > 0) {
    recieved = Serial.read();
    Serial.println(String(recieved)) ;
    if (recieved == '1') {
      digitalWrite(relay, LOW); // enciende
      FastLED.clear ();
      FastLED.show();
      delay(10000);
      flag = true;
    }
    if (recieved == '0') {
        flag = false;
    }
  }
}

void FillLEDsFromPaletteColors( uint8_t colorIndex)
{
    uint8_t brightness = 255;

    for( int i = 0; i < NUM_LEDS; i++) {
        leds[i] = ColorFromPalette( currentPalette, colorIndex, brightness, currentBlending);
        colorIndex += 3;
    }
}

void SetupBlackAndWhiteStripedPalette()
{
    // 'black out' all 16 palette entries...
    fill_solid( currentPalette, 16, CRGB::Black);
    // and set every fourth one to white.
    currentPalette[0] = CRGB::White;
    currentPalette[4] = CRGB::White;
    currentPalette[8] = CRGB::White;
    currentPalette[12] = CRGB::White;

}
