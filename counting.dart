import 'dart:html';
import 'dart:async';

void main() {
  Main.init();
}

class Main {
  static List<List<int>> field = new List<List<int>>(fieldSize);
  static CanvasElement canvas = document.getElementById("canvas");
  static const int fieldSize = 9;
  static const int cellSize = 40;
  static int currentNum = 2, cursorX = 0, cursorY = 0;
  
  
  static List<List<int>> coordsList = [[0, -1], [-1, 0], [1, 0], [0, 1]];
  
  static void init() {
    for(int n = 0; n < fieldSize; n++) field[n] = new List<int>(9);
    clearField();
    
    canvas.width = cellSize * fieldSize + 1;
    canvas.height = cellSize * fieldSize + 1;
    canvas.context2D
      ..textBaseline = "middle"
      ..textAlign = "center"
      ..setFillColorRgb(0, 0, 0)
      ..setStrokeColorRgb(0, 0, 0);

    
    canvas.onClick.listen((e) {
      int x = e.offset.x ~/ cellSize;
      int y = e.offset.y ~/ cellSize;
      if(moveAllowed(x, y)) {
        field[x][y] = currentNum;
        int x1, y1, num1 = 0;
        for(List<int> coords in coordsList) {
          int xx = x + coords[0];
          int yy = y + coords[1];
          int num = field[xx][yy];
          if(currentNum != num && num > 0) {
            if(num1 == 0) {
              num1 = num;
              x1 = xx;
              y1 = yy;
            } else if (num != num1) {
              field[x][y] = -1;
              field[x1][y1] = -1;
              field[xx][yy] = -1;
            }
          }
        }
        currentNum = currentNum == 3 ? 1 : currentNum + 1;
      }
    });
    
    canvas.onMouseMove.listen((e) {
      cursorX = e.offset.x;
      cursorY = e.offset.y;
    });
    
    document.getElementById("restart").onClick.listen((e) {
      clearField();
    });
    
    new Timer.periodic(new Duration(milliseconds:10), render);
  }
  
  static void clearField() {
    for(int n = 0; n < fieldSize; n++) {
      for(int m = 0; m < fieldSize; m++) field[n][m] = 0;
    }
    field[(fieldSize - 1) ~/ 2][(fieldSize - 1) ~/ 2] = 1;
    currentNum = 2;
  }
  
  static bool moveAllowed(int x, int y) {
    if(field[x][y] != 0) return false;
    bool hasNeighbor = false;
    for(List<int> coords in coordsList) {
      int xx = x + coords[0];
      int yy = y + coords[1];
      if(xx < 0 || xx == fieldSize || yy < 0 || yy == fieldSize) continue;
      int num = field[xx][yy];
      if(num == currentNum) return false; 
      if(num > 0) hasNeighbor = true; 
    }
    return hasNeighbor;
  }
  
  static bool nowRendering = false;
  static void render(Timer timer) {
    if(nowRendering) return;
    CanvasRenderingContext2D context = canvas.context2D;
    context
      ..font = "bold 32px Courier"
      ..clearRect(0, 0, canvas.width, canvas.height)
      ..beginPath();
    
    for(int n = 0; n <= fieldSize; n++) {
      context
        ..moveTo(0, n * cellSize)
        ..lineTo(canvas.width, n * cellSize)
        ..moveTo(n * cellSize, 0)
        ..lineTo(n * cellSize, canvas.height);
    }
    
    for(int n = 0; n < fieldSize; n++) {
      for(int m = 0; m < fieldSize; m++) {
        int num = field[n][m];
        int x = n * cellSize;
        int y = m * cellSize;
        switch(num) {
          case -1:
            context.strokeRect(x + 4, y + 4, cellSize - 8, cellSize - 8);
            break;
          case 0:
            if(moveAllowed(n,m)) context.strokeRect(x + cellSize ~/ 2 - 1
                , y + cellSize ~/ 2 - 1, 3, 3);
            break;
          default:
            context
              ..fillText(num.toString(), x + cellSize ~/ 2
                  , y + cellSize ~/ 2);
            break;
        }
      }
    }
    
    context
      ..clearRect(cursorX, cursorY, cellSize ~/ 2, cellSize ~/ 2)
      ..setFillColorRgb(0, 0, 0)
      ..strokeRect(cursorX, cursorY, cellSize ~/ 2, cellSize ~/ 2)
      ..font = "bold 16px Courier"
      ..fillText(currentNum.toString(), cursorX + cellSize ~/ 4
          , cursorY + cellSize ~/ 4)
      ..closePath()
      ..stroke();
    nowRendering = false;
  } 
}