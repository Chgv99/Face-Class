<p align="center">
  <a href="https://github.com/Chgv99/Face-Class/blob/main/README.md">English</a> • <a href="https://github.com/Chgv99/Face-Class/blob/main/README(es).md">Español</a>
</p>

<h1 align="center">
 Face Class
</h1>
<!--<h1 style="display: none">
  EY
</h1>-->
<p align="center">
 <b>A simple class for webcam face-detection implementation in your projects using <a href="https://processing.org/">Processing</a>.</b>
</p>
<p align="center">
 <img src="https://img.shields.io/badge/Project-WIP-orange"> <img src="https://img.shields.io/badge/Documentation-WIP-orange">
</p>
<p align="center">
 <a href="">Features</a> • <a href="">Usage</a>
</p>

<!--<p align="center">
 This is a project 
</p>-->

<!--<h1>Index</h1>
<details>
 <summary>Expand</summary>
 
 1. Description
 2. Usage
    * With some
    * Sub bullets
</details>-->

<!--<p align="center">
  <img width="460" height="300" src="https://github.com/Chgv99/Pong/blob/main/preview.gif">
</p>-->

# Features

You'll be able to receive useful data from your webcam for your project.

<!--The current version contains the following features:
1. Hey
2.
3.-->

# Usage

First of all you'll need to import the class into your project.

1. [Download](https://github.com/Chgv99/Face-Class/archive/refs/heads/main.zip) the *.zip*.
2. Extract
3. Copy Face-Class-main/face_controller/face.pde next to the main file of your Processing project.
4. Now you can call the Face class inside your project!

To make use of the Face class you just need to create an object of the Face class and call *Process()* every frame. See [methods]() for more info.

##
```processing
Face player_face;

void setup() {
  size(640, 480);
  player_face = new Face(this, "DroidCam Source 3", 0.5f, 0.2f, 0.1f, 0.1f);
}

void draw() {  
  player_face.Process(false);
  player_face.GetCrop(width/2,height/2);
}
```


# Methods

| Method | Type        | Description                                              | Parameters           |
| ------ | ----------- | -------------------------------------------------------- | -------------------- |
| Face   | Constructor | Defines the face object                                  | **PApplet parent** (normally *this*), **String camera_name**, **float offset** (x4) (upper, lower, left and right *offsets* of the face (optional)) |
| Process | Void | Updates face variables using camera's output | **boolean display** (shows the whole camera output) |
| GetDistance | float | Returns the distance between the leftmost vertex of both eyes (used as reference) |
| GetDistanceInCm | float | Returns an approximate distance between the camera and the face of the user |
| GetCenter | Point | Returns a point object with the *x* and *y* coordinates of the center of the face |
| GetMouthAmplitude | float (0-1) | Returns mouth's amplitude relative to the size of the face |
| MouthIsOpen | boolean | Returns true if mouth's amplitude is greater than a certain threshold |
| GetCrop | void | Crops the face detected in the camera output and pastes it in the desired position | **int x**, **int y** |

<p align="center">
 GitHub <a href="https://github.com/Chgv99">@Chgv99</a> · Twitter <a href="https://twitter.com/ChgvCode">@ChgvCode</a>
</p>
