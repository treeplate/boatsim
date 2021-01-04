import 'dart:io';
import 'package:dart_console/dart_console.dart';

final console = Console();

void main() {
  console.write("This game, ");
  console.setForegroundColor(ConsoleColor.yellow);
  console.write("Boating"); // maybe we should have a better name
  console.resetColorAttributes();
  console.writeLine(", is a boat navigation game.");
  console.write("You use ");
  console.setForegroundColor(ConsoleColor.yellow);
  console.write("WASD "); //maybe also arrow keys?
  console.resetColorAttributes();
  console.writeLine("to navigate your boat.");
  console.writeLine("Your goal is to get to the other end of the river.");
  console.hideCursor();
  console.readKey();
  // maybe add more text
  Boat boat = Boat(console.windowWidth / 2.0, 2);
  Water water = Water(<Thing>[boat, TestThing(0, 0)]);
  loop: while (true) {
    console.setBackgroundColor(ConsoleColor.blue);
    console.clearScreen();
    console.writeLine("-" * console.windowWidth);
    console.cursorPosition = Coordinate(console.windowHeight, 0);
    console.writeLine("-" * console.windowWidth);
    water.render(console, 0, 0, console.windowWidth, console.windowHeight, boat.y.round() - 2);
    Key key = console.readKey();
    if (key.isControl) {
      switch (key.controlChar) {
        case ControlCharacter.escape:
          break loop;
      }
    } else {
      switch (key.char) {
        case 'q':
          break loop;
        case 'w':
          boat.y += 1.0;
          break;
        case 'a':
          boat.x -= 1.0;
          break;
        case 's':
          boat.y -= 1.0;
          break;
        case 'd':
          boat.x += 1.0;
          break;
      }
    }
    water.checkCollisions();
  }
  console.resetColorAttributes();
  console.resetCursorPosition();
  console.clearScreen();
  console.showCursor();
}

// console.readLine(); to read a line
// console.write/writeLine(); to write
// window size is console.windowWidth by console.windowHeight

class Water {
  Water(this.contents);
  List<Thing> contents;

  void render(Console console, int x, int y, int width, int height, int yScroll) {
    for (Thing thing in contents) {
      if (thing.x >= 0 && thing.x < width &&
          thing.y >= yScroll && thing.y < yScroll + height) {
        thing.paint(
          console,
          x + thing.x.round(),
          y + (height - (thing.y.round() - yScroll)),
        );
      }
    }
  }

  void checkCollisions() {
  }
}

abstract class Thing {
  Thing(this.x, this.y);
  double x, y = 0.0;
  ConsoleColor get color;
  ConsoleColor get background;
  String get icon;
  void paint(Console console, int x, int y) {
    console.cursorPosition = Coordinate(y, x);
    console.setForegroundColor(color);
    console.setBackgroundColor(background);
    console.write(icon);
  }
}

class TestThing extends Thing {
  TestThing(double x, double y) : super(x, y);
  ConsoleColor get color => ConsoleColor.yellow;
  ConsoleColor get background => ConsoleColor.blue;
  String get icon => "#";
}

class Boat extends Thing {
  Boat(double x, double y) : super(x, y);
  ConsoleColor get color => ConsoleColor.brightWhite;
  ConsoleColor get background => ConsoleColor.blue;
  String get icon => 'B';
}