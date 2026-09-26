# 🕷️ Spider-Man Gesture Web Shooter

    A gesture-controlled virtual web-shooter project built using an **ESP8266**, **MPU6050**, and **Processing**.
    
    The project detects a hand/wrist gesture using the MPU6050. The ESP8266 processes the motion and sends a `SHOOT` command over a local Wi-Fi network to a computer running Processing. Processing then triggers a real-time web-shooting animation.

> **Note:** This project is a visual/software simulation and does not launch physical projectiles.

---

## 🚀 Features

    - Gesture detection using MPU6050
    - ESP8266-based wireless communication
    - ESP8266 creates its own Wi-Fi hotspot
    - No external Wi-Fi router required
    - Real-time Processing animation
    - TCP communication between ESP8266 and Processing
    - Adjustable gesture sensitivity
    - Manual SPACEBAR trigger for testing

---

## 🧠 How It Works  

    Hand/Wrist Gesture
            ↓
         MPU6050
            ↓
         ESP8266
            ↓
       Wi-Fi Hotspot
            ↓
      TCP Connection
            ↓
        Processing
            ↓
     Web Animation

 ## Hardware Used

    | Component         |          Purpose                                   |
    |-------------------|----------------------------------------------------|
    | ESP8266 Node MCU  |          Main controller and Wi-Fi communication   |
    | MPU6050           |          Motion/gesture detection                  |
    | Breadboard        |          Circuit prototyping                       |
    | Jumper Wires      |          Connections                               |
    | USB Cable /       |          Power                                     |
      Power Bank 

##🔌 Circuit Connections
      MPU6050 → ESP8266
      The MPU6050 communicates with the ESP8266 using the I²C protocol.

    | MPU6050 | ESP8266 |
    |---------|---------|
    | VCC     |    3.3V |
    | GND     |     GND |
    | SDA     | D2      |
    | SCL     | D1      |
    
##📡 Wi-Fi Communication
      The ESP8266 creates its own Wi-Fi hotspot.
      The computer connects directly to the ESP8266, so an external Wi-Fi router or internet connection is not required.

      Wi-Fi SSID: SPIDER_WEB_GLOVE
      ESP8266 IP: 192.168.4.1
      TCP Port: 3333

##💻 Software Used

    - Arduino IDE
    - ESP8266 Arduino Core
    - Processing
    - Git
    - GitHub

    
##📁 Project Structure

      Spider-Man-Gesture-Web-Shooter/
      │
      ├── ESP8266/
      │   └── Spider_Web_Glove.ino
      │
      ├── Processing/
      │   └── Spider_Web_Glove.pde
      │
      └── README.md

      
##👨‍💻 Author

    Mohammed Ayaan Ali , Asad Hussain , Mohd Hannan
    Engineering student interested in embedded systems, robotics, and electronics.

## ⭐ Project
If you find this project interesting, consider giving the repository a ⭐ on GitHub!
