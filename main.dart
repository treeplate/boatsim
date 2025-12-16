/// @dart=2.10
import 'dart:io';
import 'package:dart_console/dart_console.dart';

void game(Console console) {
  /// Intro
  console.clearScreen();
  console.write("This game, ");
  console.setForegroundColor(ConsoleColor.yellow);
  console.write("Boating"); // maybe we should have a better name
  console.resetColorAttributes();
  console.writeLine(", is a scrolling boat navigation game.");
  console.write("You use ");
  console.setForegroundColor(ConsoleColor.yellow);
  console.write("WASD "); //maybe also arrow keys?
  console.resetColorAttributes();
  console.writeLine("to navigate your boat.");
  console.write("Your goal is to get to the ");
  console.setForegroundColor(ConsoleColor.white);
  console.write("_");
  console.resetColorAttributes();
  console.writeLine(", or port.");
  console.write("Avoid ");
  console.setForegroundColor(ConsoleColor.brightYellow);
  console.write("█");
  console.resetColorAttributes();
  console.writeLine(", or shores.");
  console.write("You are a ");
  console.setForegroundColor(ConsoleColor.white);
  console.setBackgroundColor(ConsoleColor.blue);
  console.write("B");
  console.resetColorAttributes();
  console.writeLine(", or boat.");
  console.hideCursor();
  console.readKey();
  // maybe add more text

  /// Setup
  Water water = Water.parse(File('world.txt').readAsStringSync());
  Boat boat = water.boat;
  loop: while (true) {
    /// Rendering
    console.resetColorAttributes();
    console.clearScreen();
    console.setForegroundColor(ConsoleColor.brightGreen);
    console.write("-" * console.windowWidth);
    console.cursorPosition = Coordinate(console.windowHeight-1, 0);
    console.write("-" * console.windowWidth);
    water.render(console, 0, 1, console.windowWidth, console.windowHeight-2, boat.y.round() - 5);

    /// Key detection
    Key key = console.readKey();
    if (key.isControl) {
      switch (key.controlChar) {
        case ControlCharacter.escape:
          break loop;
        case ControlCharacter.ctrlC:
          break loop;
        case ControlCharacter.ctrlD:
          break loop;
        default:
      }
    } else {
      switch (key.char) {
        case 'q':
          break loop;
        case 'w':
          if(!water.isCollision<Shore>(boat.x, boat.y+1)) boat.y += 1.0;
          break;
        case 'a':
          if(!water.isCollision<Shore>(boat.x-1, boat.y)) boat.x -= 1.0;
          break;
        case 's':
          if(!water.isCollision<Shore>(boat.x, boat.y-1)) boat.y -= 1.0;
          break;
        case 'd':
          if(!water.isCollision<Shore>(boat.x+1, boat.y)) boat.x += 1.0;
          break;
        
      }
    }

    /// Win check

    Port port = water.contents.whereType<Port>().single;
    if(port.x == boat.x && port.y == boat.y) {
      console.setBackgroundColor(ConsoleColor.white);
      console.clearScreen();
      console.setForegroundColor(ConsoleColor.brightYellow);
      console.cursorPosition = Coordinate((console.windowHeight/2).round(), (console.windowWidth/2).round());
      console.writeLine("You Win!");
      while(console.readKey().char != "q") {
        console.writeLine("Presss q");
      }
      break loop;
    }
  }
}
final Console console = Console();
void main() {
  /// cleanup
  
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
  
  /// Parsing

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
        case 0x0043: // C
          contents.add(Port(x/1, y/1));
          break;
        case 0x0023: // #
          contents.add(Shore(x.toDouble(), y.toDouble()));
          break;
      }
      contents.add(River(x.toDouble(), y.toDouble()));
      x += 1;
    }
    //console.writeLine(contents.toString());
    //console.readKey();
    return Water(contents, data.indexOf("\n"), boat);
  }

  List<Thing> contents;
  int worldWidth;

  /// Rendering

  void render(Console console, int x, int y, int width, int height, int yScroll) {
    int worldX = (width / 2 - worldWidth / 2).round();
    int screenLeft = -worldX;
    int screenRight = width - worldX;
    for (Thing thing in contents) {
      if (thing.x >= screenLeft && thing.x < screenRight &&
          thing.y > yScroll && thing.y <= yScroll + height) {
        thing.paint(
          console,
          x + worldX + thing.x.round() ,
          y + (height - (thing.y.round() - yScroll)),
          this,
        );
      }
    }
  }

  /// Collision detection

  bool isCollision<T>(double potentialX, double potentialY) {
    for(Thing thing in contents) {
      if(thing.x == potentialX && thing.y == potentialY && (thing is T)) return true;
    }
    return false;
  }
}

/// Things

abstract class Thing {
  Thing(this.x, this.y);
  double x, y = 0.0;
  ConsoleColor get color;
  ConsoleColor get background;
  String get icon;
  void paint(Console console, int x, int y, Water water) {
    console.cursorPosition = Coordinate(y, x);
    console.setForegroundColor(color);
    console.setBackgroundColor(background);
    if((!water.isCollision<Boat>(this.x, this.y) || this is Boat) && (!water.isCollision<Shore>(this.x, this.y) || this is Shore) && (!water.isCollision<Port>(this.x, this.y) || this is Port)) {
      console.write(icon);
    }
  }
  String toString() => "$icon ($x, $y)";
}

class Shore extends Thing {
  Shore(double x, double y) : super(x, y);
  ConsoleColor get color => ConsoleColor.brightYellow;
  ConsoleColor get background => ConsoleColor.blue;
  String get icon => "█";
}

class Boat extends Thing {
  Boat(double x, double y) : super(x, y);
  ConsoleColor get color => ConsoleColor.brightWhite;
  ConsoleColor get background => ConsoleColor.blue;
  String get icon => 'B';
}
class Port extends Thing {
  Port(double x, double y) : super(x, y);
  ConsoleColor get color => ConsoleColor.brightWhite;
  ConsoleColor get background => ConsoleColor.blue;
  String get icon => '_';
}
class River extends Thing {
  River(double x, double y) : super(x, y);
  ConsoleColor get color => ConsoleColor.brightWhite;
  ConsoleColor get background => ConsoleColor.blue;
  String get icon => ' ';
}