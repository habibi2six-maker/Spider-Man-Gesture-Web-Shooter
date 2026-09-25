import processing.net.*;

// ============================================================
// SPIDER-MAN GESTURE WEB SHOOTER
// PROJECTILE + REFERENCE-STYLE WEB
// ESP8266 WI-FI VERSION
// ============================================================

// ============================================================
// ESP8266 WIFI
// ============================================================

Client esp;

String ESP_IP = "192.168.4.1";
int ESP_PORT = 3333;


// ============================================================
// ANIMATION
// ============================================================

int MAX_WEBS = 30;
int MAX_PROJECTILES = 10;

PGraphics wall;

float[] webX = new float[MAX_WEBS];
float[] webY = new float[MAX_WEBS];
float[] webSize = new float[MAX_WEBS];
float[] webGrowth = new float[MAX_WEBS];

boolean[] webActive = new boolean[MAX_WEBS];

int[] webCreatedTime = new int[MAX_WEBS];
int[] webSeed = new int[MAX_WEBS];
int[] webRays = new int[MAX_WEBS];

float[] projectileX = new float[MAX_PROJECTILES];
float[] projectileY = new float[MAX_PROJECTILES];

float[] projectileTargetX = new float[MAX_PROJECTILES];
float[] projectileTargetY = new float[MAX_PROJECTILES];

float[] projectileVX = new float[MAX_PROJECTILES];
float[] projectileVY = new float[MAX_PROJECTILES];

boolean[] projectileActive = new boolean[MAX_PROJECTILES];


// ============================================================
// SETUP
// ============================================================

void setup() {

  size(1200, 700);

  createBrickWall();

  for (int i = 0; i < MAX_WEBS; i++) {
    webActive[i] = false;
  }

  for (int i = 0; i < MAX_PROJECTILES; i++) {
    projectileActive[i] = false;
  }

  // ----------------------------------------------------------
  // CONNECT TO ESP8266
  // ----------------------------------------------------------

  println("======================================");
  println("SPIDER-MAN GESTURE WEB SHOOTER");
  println("======================================");

  println("Connecting to ESP8266...");
  println("IP: " + ESP_IP);
  println("Port: " + ESP_PORT);

  try {

    esp = new Client(this, ESP_IP, ESP_PORT);

    println("Connection attempt started.");

  } catch (Exception e) {

    println("ESP8266 connection error:");
    println(e);
  }
}


// ============================================================
// DRAW
// ============================================================

void draw() {

  image(wall, 0, 0);


  // ==========================================================
  // RECEIVE ESP8266 MESSAGE
  // ==========================================================

  if (esp != null && esp.active()) {

    while (esp.available() > 0) {

      String msg = esp.readStringUntil('\n');

      if (msg != null) {

        msg = trim(msg);

        println("ESP8266: " + msg);


        // ----------------------------------------------------
        // GESTURE DETECTED
        // ----------------------------------------------------

        if (msg.equals("SHOOT")) {

          println("GESTURE DETECTED!");
          println("WEB SHOOT!");

          shootProjectile();
        }
      }
    }
  }


  // ==========================================================
  // ANIMATION
  // ==========================================================

  updateProjectiles();

  drawAllWebs();
}


// ============================================================
// BRICK WALL
// ============================================================

void createBrickWall() {

  wall = createGraphics(width, height);

  wall.beginDraw();

  wall.background(118, 42, 38);

  int brickWidth = 80;
  int brickHeight = 35;

  wall.noStroke();

  randomSeed(4567);


  for (int y = 0; y < height; y += brickHeight) {

    int row = y / brickHeight;

    int offset = 0;

    if (row % 2 == 1) {
      offset = brickWidth / 2;
    }


    for (
      int x = -brickWidth;
      x < width + brickWidth;
      x += brickWidth
    ) {

      float shade = random(-10, 10);

      wall.fill(
        118 + shade,
        42 + shade * 0.4,
        38 + shade * 0.3
      );

      wall.rect(
        x + offset + 1,
        y + 1,
        brickWidth - 2,
        brickHeight - 2
      );
    }
  }


  wall.stroke(48, 32, 30);
  wall.strokeWeight(2);


  for (int y = 0; y < height; y += brickHeight) {

    wall.line(
      0,
      y,
      width,
      y
    );
  }


  for (int y = 0; y < height; y += brickHeight) {

    int row = y / brickHeight;

    int offset = 0;

    if (row % 2 == 1) {
      offset = brickWidth / 2;
    }


    for (
      int x = -brickWidth;
      x < width + brickWidth;
      x += brickWidth
    ) {

      wall.line(
        x + offset,
        y,
        x + offset,
        y + brickHeight
      );
    }
  }


  randomSeed(9876);

  wall.strokeWeight(1);


  for (int i = 0; i < 220; i++) {

    float x = random(width);
    float y = random(height);

    float length = random(3, 12);

    wall.stroke(65, 30, 28, 100);

    wall.line(
      x,
      y,
      x + random(-length, length),
      y + random(-2, 2)
    );
  }


  randomSeed(2468);

  wall.noStroke();


  for (int i = 0; i < 20; i++) {

    float x = random(width);
    float y = random(height);

    wall.fill(255, 120, 100, 8);

    wall.ellipse(
      x,
      y,
      random(40, 100),
      random(40, 100)
    );
  }


  wall.endDraw();
}


// ============================================================
// SHOOT PROJECTILE
// ============================================================

void shootProjectile() {

  for (int i = 0; i < MAX_PROJECTILES; i++) {

    if (!projectileActive[i]) {

      projectileActive[i] = true;

      projectileX[i] = width / 2.0;
      projectileY[i] = height - 15;

      projectileTargetX[i] = mouseX;
      projectileTargetY[i] = mouseY;


      float dx =
        projectileTargetX[i] - projectileX[i];

      float dy =
        projectileTargetY[i] - projectileY[i];


      float distance =
        sqrt(dx * dx + dy * dy);


      if (distance < 1) {
        distance = 1;
      }


      float speed = 28;


      projectileVX[i] =
        dx / distance * speed;

      projectileVY[i] =
        dy / distance * speed;


      return;
    }
  }
}


// ============================================================
// UPDATE PROJECTILES
// ============================================================

void updateProjectiles() {

  for (int i = 0; i < MAX_PROJECTILES; i++) {

    if (!projectileActive[i]) {
      continue;
    }


    projectileX[i] += projectileVX[i];
    projectileY[i] += projectileVY[i];


    float dx =
      projectileTargetX[i] - projectileX[i];

    float dy =
      projectileTargetY[i] - projectileY[i];


    float distance =
      sqrt(dx * dx + dy * dy);


    if (distance < 30) {

      createWeb(
        projectileTargetX[i],
        projectileTargetY[i]
      );

      projectileActive[i] = false;

      continue;
    }


    drawProjectile(
      projectileX[i],
      projectileY[i],
      projectileVX[i],
      projectileVY[i]
    );
  }
}


// ============================================================
// DRAW PROJECTILE
// ============================================================

void drawProjectile(
  float x,
  float y,
  float vx,
  float vy
) {

  float angle = atan2(vy, vx);


  pushMatrix();

  translate(x, y);

  rotate(angle);


  noStroke();

  fill(255, 255, 255, 35);

  ellipse(
    -10,
    0,
    22,
    10
  );


  fill(255, 255, 255, 80);

  ellipse(
    -6,
    0,
    14,
    7
  );


  fill(255);

  ellipse(
    0,
    0,
    8,
    8
  );


  stroke(255, 180);

  strokeWeight(1.2);

  line(
    -5,
    0,
    -18,
    0
  );


  popMatrix();
}


// ============================================================
// CREATE WEB
// ============================================================

void createWeb(float x, float y) {

  for (int i = 0; i < MAX_WEBS; i++) {

    if (!webActive[i]) {

      webActive[i] = true;

      webX[i] = x;
      webY[i] = y;

      webSize[i] = random(100, 160);

      webRays[i] = int(random(6, 8));

      webSeed[i] = int(random(1000000));

      webGrowth[i] = 0;

      webCreatedTime[i] = millis();

      return;
    }
  }
}


// ============================================================
// DRAW ALL WEBS
// ============================================================

void drawAllWebs() {

  for (int i = 0; i < MAX_WEBS; i++) {

    if (!webActive[i]) {
      continue;
    }


    int age =
      millis() - webCreatedTime[i];


    if (age >= 10000) {

      webActive[i] = false;

      continue;
    }


    float alpha = 255;


    if (age > 9000) {

      alpha =
        map(
          age,
          9000,
          10000,
          255,
          0
        );
    }


    drawSpiderWeb(
      webX[i],
      webY[i],
      webSize[i],
      webGrowth[i],
      webSeed[i],
      webRays[i],
      alpha
    );


    if (webGrowth[i] < 1.0) {

      webGrowth[i] +=
        0.12 * (1.0 - webGrowth[i])
        + 0.025;


      if (webGrowth[i] > 1.0) {
        webGrowth[i] = 1.0;
      }
    }
  }
}


// ============================================================
// DRAW SPIDER WEB
// ============================================================

void drawSpiderWeb(
  float x,
  float y,
  float size,
  float growth,
  int seed,
  int rays,
  float alpha
) {

  if (growth <= 0) {
    return;
  }


  randomSeed(seed);


  float s =
    size * growth;


  float[] rayLength =
    new float[rays];


  for (int i = 0; i < rays; i++) {

    if (random(1) < 0.78) {

      rayLength[i] =
        random(
          s * 0.75,
          s * 1.05
        );

    } else {

      rayLength[i] =
        random(
          s * 0.55,
          s * 0.78
        );
    }
  }


  float rotation =
    random(TWO_PI);


  // ==========================================================
  // RADIAL STRANDS
  // ==========================================================

  for (int i = 0; i < rays; i++) {

    float angle =
      rotation +
      TWO_PI / rays * i;


    float length =
      rayLength[i];


    float curveAmount =
      random(-12, 12);


    float startX = x;
    float startY = y;


    float midX =
      x +
      cos(angle) * length * 0.48 -
      sin(angle) * curveAmount;


    float midY =
      y +
      sin(angle) * length * 0.48 +
      cos(angle) * curveAmount;


    float endX =
      x +
      cos(angle) * length;


    float endY =
      y +
      sin(angle) * length;


    stroke(255, alpha);

    strokeWeight(
      random(1.7, 2.5)
    );

    noFill();


    beginShape();

    curveVertex(
      startX,
      startY
    );

    curveVertex(
      startX,
      startY
    );

    curveVertex(
      midX,
      midY
    );

    curveVertex(
      endX,
      endY
    );

    curveVertex(
      endX,
      endY
    );

    endShape();
  }


  // ==========================================================
  // CURVED WEB CONNECTIONS
  // ==========================================================

  int rings = 5;


  for (int r = 1; r <= rings; r++) {

    float ringProgress =
      (float) r / rings;


    float baseRadius =
      s * 0.16 +
      s * 0.84 *
      ringProgress;


    float sag =
      random(0.08, 0.18);


    stroke(255, alpha);


    if (r <= 2) {

      strokeWeight(
        random(1.0, 1.4)
      );

    } else {

      strokeWeight(
        random(1.3, 1.8)
      );
    }


    noFill();


    for (int i = 0; i < rays; i++) {

      int next =
        (i + 1) % rays;


      float angleA =
        rotation +
        TWO_PI / rays * i;


      float angleB =
        rotation +
        TWO_PI / rays * next;


      // ======================================================
      // FIX FOR CLOSING SEGMENT
      // ======================================================

      if (next == 0) {
        angleB += TWO_PI;
      }


      float radiusA =
        baseRadius *
        (rayLength[i] / s);


      float radiusB =
        baseRadius *
        (rayLength[next] / s);


      int points = 12;


      float[] px =
        new float[points + 1];


      float[] py =
        new float[points + 1];


      for (int p = 0; p <= points; p++) {

        float t =
          (float) p / points;


        float radius =
          lerp(
            radiusA,
            radiusB,
            t
          );


        float inward =
          sin(PI * t) *
          sag *
          baseRadius;


        radius -= inward;


        float angle =
          lerp(
            angleA,
            angleB,
            t
          );


        float angleWobble =
          sin(
            t * PI +
            seed * 0.001 +
            r
          ) * 0.012;


        angle += angleWobble;


        px[p] =
          x +
          cos(angle) *
          radius;


        py[p] =
          y +
          sin(angle) *
          radius;
      }


      // ======================================================
      // CATMULL-ROM CURVE
      // ======================================================

      beginShape();

      curveVertex(
        px[0],
        py[0]
      );


      for (int p = 0; p <= points; p++) {

        curveVertex(
          px[p],
          py[p]
        );
      }


      curveVertex(
        px[points],
        py[points]
      );

      endShape();
    }
  }


  // ==========================================================
  // CENTER
  // ==========================================================

  noStroke();

  fill(255, alpha);

  ellipse(
    x,
    y,
    6,
    6
  );


  randomSeed(millis());
}


// ============================================================
// KEYBOARD TEST
// ============================================================

void keyPressed() {

  if (key == ' ') {

    println("MANUAL SHOOT");

    shootProjectile();
  }
}