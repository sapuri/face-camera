import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;
PImage img;

/* Parameters */
final int WINDOW_WIDTH = 640;
final int WINDOW_HEIGHT = 480;
final int MOSAIC_WIDTH = 5;
final int MOSAIC_HEIGHT = 5;
boolean is_active = true;
boolean is_filter_active = true;
String filter_type = "stamp";

void setup() {
  size(640, 480);
  video = new Capture(this, WINDOW_WIDTH/2, WINDOW_HEIGHT/2);
  opencv = new OpenCV(this, WINDOW_WIDTH/2, WINDOW_HEIGHT/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  img = loadImage("images/r18.png");
  video.start();
}

void draw() {
  scale(2);
  opencv.loadImage(video);
  image(video, 0, 0);
  loadPixels();
  noFill();
  stroke(0, 0, 0);
  strokeWeight(0);
  Rectangle[] faces = opencv.detect();
  faceFilter(faces, filter_type);
}

void captureEvent(Capture c) {
  c.read();
}

void faceFilter(Rectangle[] faces, String filter_type) {
  if (is_filter_active == false) return;
  switch (filter_type) {
    case "mosaic":
      for (int k = 0; k < faces.length; k++){
        for(int j = 0; j < faces[k].height; j+=MOSAIC_HEIGHT) {
          for(int i = 0; i < faces[k].width; i+=MOSAIC_WIDTH) {
            color c = pixels[j * faces[k].width + i];
            fill(c);
            rect(faces[k].x+i, faces[k].y+j, MOSAIC_WIDTH, MOSAIC_HEIGHT);
          }
        }
      }
      break;
    case "stamp":
      final int padding = 20; // Adjustment
      for (int i = 0; i < faces.length; i++) {
        image(img, faces[i].x - padding, faces[i].y - padding, faces[i].width + padding*2, faces[i].height + padding*2);
      }
      break;
    default:
      println("Undefined filter_type:", filter_type);
      exit();
  }
}

void keyPressed() {
  /* Pause with Space key */
  if (key == ' ') {
    if (is_active) noLoop();
    else loop();
    is_active = !is_active;
  }

  /* Toggle filter on/off */
  if (key == 's' || key == 'S') is_filter_active = !is_filter_active;

  /* Switch filter type */
  if (key == 'm' || key == 'M') {
    if (filter_type == "mosaic") filter_type = "stamp";
    else if (filter_type == "stamp") filter_type = "mosaic";
    else {
      println("Undefined filter_type:", filter_type);
      exit();
    }
  }

  /* Screenshot */
  if (key == 'p' || key == 'P') {
    String datetimestr = nf(year(),2) + "-" + nf(month(),2) + "-" + nf(day(),2) + " " + nf(hour(),2) + "." + nf(minute(),2) + "." + nf(second(),2);
    String file_path = "screenshots/" + datetimestr + ".png";
    save(file_path);
    println("Screenshot saved >", file_path);
  }
}
