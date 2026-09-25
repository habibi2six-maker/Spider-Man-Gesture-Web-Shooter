#include <ESP8266WiFi.h>
#include <Wire.h>

// =====================================================
// WIFI HOTSPOT
// =====================================================

const char* AP_SSID = "SPIDER_WEB_GLOVE";
const char* AP_PASSWORD = "YOUR_WIFI_PASS";

WiFiServer server(3333);
WiFiClient client;


// =====================================================
// MPU6050
// =====================================================

#define MPU_ADDR 0x68

int16_t ax, ay, az;

long baseX = 0;
long baseY = 0;
long baseZ = 0;

const long GESTURE_THRESHOLD = 14000;
const unsigned long COOLDOWN = 1000;

unsigned long lastShoot = 0;


// =====================================================
// READ MPU6050
// =====================================================

bool readMPU() {

  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B);

  if (Wire.endTransmission(false) != 0) {
    return false;
  }

  int bytesReceived = Wire.requestFrom(MPU_ADDR, 6, true);

  if (bytesReceived != 6) {
    return false;
  }

  ax = (Wire.read() << 8) | Wire.read();
  ay = (Wire.read() << 8) | Wire.read();
  az = (Wire.read() << 8) | Wire.read();

  return true;
}


// =====================================================
// CALIBRATION
// =====================================================

void calibrateSensor() {

  Serial.println();
  Serial.println("CALIBRATING...");
  Serial.println("KEEP MPU6050 STILL!");

  long sumX = 0;
  long sumY = 0;
  long sumZ = 0;

  int validReadings = 0;

  for (int i = 0; i < 30; i++) {

    if (readMPU()) {

      sumX += ax;
      sumY += ay;
      sumZ += az;

      validReadings++;
    }

    delay(50);
  }

  if (validReadings > 0) {

    baseX = sumX / validReadings;
    baseY = sumY / validReadings;
    baseZ = sumZ / validReadings;
  }

  Serial.println("CALIBRATION COMPLETE");

  Serial.print("Base X: ");
  Serial.println(baseX);

  Serial.print("Base Y: ");
  Serial.println(baseY);

  Serial.print("Base Z: ");
  Serial.println(baseZ);

  Serial.println("SYSTEM READY");
}


// =====================================================
// SETUP
// =====================================================

void setup() {

  Serial.begin(115200);

  delay(1000);

  // MPU6050
  // NodeMCU:
  // D2 = SDA
  // D1 = SCL

  Wire.begin(D2, D1);

  // Wake MPU6050
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B);
  Wire.write(0x00);
  Wire.endTransmission();

  delay(100);


  // ---------------------------------------------------
  // WIFI HOTSPOT
  // ---------------------------------------------------

  Serial.println();
  Serial.println("==============================");
  Serial.println(" SPIDER-MAN WEB GLOVE");
  Serial.println("==============================");

  Serial.println("Starting Wi-Fi hotspot...");

  WiFi.mode(WIFI_AP);

  WiFi.softAP(AP_SSID, AP_PASSWORD);

  delay(500);

  Serial.println("HOTSPOT READY");

  Serial.print("Wi-Fi name: ");
  Serial.println(AP_SSID);

  Serial.print("Wi-Fi password: ");
  Serial.println(AP_PASSWORD);

  Serial.print("ESP8266 IP: ");
  Serial.println(WiFi.softAPIP());


  // ---------------------------------------------------
  // TCP SERVER
  // ---------------------------------------------------

  server.begin();

  server.setNoDelay(true);

  Serial.println("TCP SERVER STARTED");
  Serial.println("Port: 3333");


  // ---------------------------------------------------
  // CALIBRATE
  // ---------------------------------------------------

  calibrateSensor();
}


// =====================================================
// LOOP
// =====================================================

void loop() {

  // ---------------------------------------------------
  // CHECK FOR PROCESSING CONNECTION
  // ---------------------------------------------------

  if (!client || !client.connected()) {

    if (client) {
      client.stop();
    }

    WiFiClient newClient = server.available();

    if (newClient) {

      client = newClient;

      client.setNoDelay(true);

      Serial.println();
      Serial.println("================================");
      Serial.println("PROCESSING CONNECTED");
      Serial.println("================================");
    }
  }


  // ---------------------------------------------------
  // READ MPU6050
  // ---------------------------------------------------

  if (!readMPU()) {

    delay(20);

    return;
  }


  // ---------------------------------------------------
  // CALCULATE MOVEMENT
  // ---------------------------------------------------

  long deltaX = abs((long)ax - baseX);
  long deltaY = abs((long)ay - baseY);
  long deltaZ = abs((long)az - baseZ);


  bool gestureDetected =
    deltaX > GESTURE_THRESHOLD ||
    deltaY > GESTURE_THRESHOLD ||
    deltaZ > GESTURE_THRESHOLD;


  // ---------------------------------------------------
  // GESTURE
  // ---------------------------------------------------

  if (gestureDetected) {

    unsigned long now = millis();

    if (now - lastShoot > COOLDOWN) {

      Serial.println("SHOOT");

      // Send to Processing
      if (client && client.connected()) {

        client.print("SHOOT\n");

        Serial.println("SHOOT SENT TO PROCESSING");
      }

      else {

        Serial.println("PROCESSING NOT CONNECTED");
      }

      lastShoot = now;
    }
  }


  delay(20);
}