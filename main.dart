// @dart=2.10
import 'dart:io';
import 'package:dart_console/dart_console.dart';

void game(Console console) {
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
  Water water = Water.parse(File('world.txt').readAsStringSync());
  Boat boat = water.boat;
  loop: while (true) {
    console.setBackgroundColor(ConsoleColor.blue);
    console.clearScreen();
    console.setForegroundColor(ConsoleColor.brightGreen);
    console.write("-" * console.windowWidth);
    console.cursorPosition = Coordinate(console.windowHeight-1, 0);
    console.write("-" * console.windowWidth);
    water.render(console, 0, 0, console.windowWidth, console.windowHeight, boat.y.round() - 2);
    Key key = console.readKey();
    if (key.isControl) {
      switch (key.controlChar) {
        case ControlCharacter.escape:
          break loop;
        default:
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
}
final Console console = Console();
void main() {
  
  try {
    game(console);
  } finally {
    console.resetColorAttributes();
    console.resetCursorPosition();
    console.clearScreen();
    console.showCursor();
  }
}

// console.readLine(); to read a line
// console.write/writeLine(); to write
// window size is console.windowWidth by console.windowHeight

class Water {
  Water(this.contents, this.worldWidth, this.boat);
  final Boat boat;
  
  factory Water.parse(String data) {
    int x = 0;
    int y = 0;
    Boat boat;
    List<Thing> contents = <Thing>[];
    for (int char in data.runes) {
      switch (char) {
        case 0x000A: 
          x = -1;
          y += 1;
          break;
        case 0x0042: // B
          boat = Boat(x.toDouble(), y.toDouble());
          contents.add(boat);
          break;
        case 0x0023: // #
          contents.add(TestThing(x.toDouble(), y.toDouble()));
          break;
      }
      x += 1;
    }
    //console.writeLine(contents.toString());
    //console.readKey();
    return Water(contents, data.indexOf("\n"), boat);
  }

  List<Thing> contents;
  int worldWidth;

  void render(Console console, int x, int y, int width, int height, int yScroll) {
    int worldX = x + (width / 2 - worldWidth / 2).round();
    int screenLeft = -worldX;
    int screenRight = worldWidth - worldX;
    for (Thing thing in contents) {
      if (thing.x >= screenLeft && thing.x < screenRight &&
          thing.y > yScroll && thing.y <= yScroll + height) {
        thing.paint(
          console,
          worldX + thing.x.round() ,
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
  String toString() => "$icon ($x, $y)";
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
