unit MagicWand;

{$R-}

interface

uses Windows, SysUtils, Classes, Graphics, Types;

type
  // Прототип функции сравнения цветов
  // Функция должна сравнить цвет исходной точки "a" c цветом проверяемой
  // точки "b" и вернуть true, если цвета достаточно близки.
  TMagicWandCmpFunc = function(a,b: TColor): Boolean;

  // Исключение, возникающее при попытке извлечения значения из пустого стека
  EStackEmpty = class(Exception);

  // Класс-стек
  TPointStack = class
  private
    FList: array of TPoint;
    FSize, FCount: Integer;
  public
    procedure Push(Point: TPoint);
    function Pop: TPoint;
    procedure StackEmpty;
    function Empty: Boolean;
    property Count: Integer read FCount;
  end;

// Функция для выделения части изображения по принципу "волшебной палочки".
// Возвращает регион, содержащий область выделения.
function MagicWandSelect(Graphic: TGraphic; StartPoint: TPoint;
  CmpFunc: TMagicWandCmpFunc): HRGN;

implementation

function MagicWandSelect(Graphic: TGraphic; StartPoint: TPoint;
  CmpFunc: TMagicWandCmpFunc): HRGN;
var
  TempBitmap: TBitmap;           // Временный битмап
  Color: TColor;                 // Цвет стартовой точки
  This,Next: TPointStack;        // Стеки для волнового алгоритма
  Mask: array of array of Byte;  // Маска для волнового алгоритма
  CurPoint: TPoint;              
  Width, Height, i: Integer;

  // Процедура меняет местами стеки Next и This
  procedure XchgStacks;
  var
    Temp: TPointStack;
  begin
    Temp:=Next;
    Next:=This;
    This:=Temp;
  end;

  // Функция распространения волны от точки APoint по 4-м направлениям.
  // Изначально всем элементам маски присваивается значение 0, что означает, что
  // соответствующая точка еще не проверялась на необходимость войти в область
  // выделения.
  // Если точка, соседняя APoint должна войти в выделение, то соответсвующему ей
  // элементу маски присваивается значение 2 и точка заносится в стек следующих
  // источников волны. Если соседняя точка не должна войти в область выделения,
  // то то соответсвующему ей элементу маски присваивается значение 1.
  procedure Wave(APoint: TPoint);
  var
    CurColor: TColor;

    // Возвращает цвет пиксела с координатой (APoint.X+offsx; APoint.Y+offsy)
    function GetPixelColor(offsx,offsy: Integer): TColor;
    var
      R,G,B: Byte;
      Pixel: Longint;
      PPixel: PLongint;
    begin
      PPixel:=PLongint(TempBitmap.ScanLine[APoint.Y + offsy]);
      Inc(PByte(PPixel),3*(APoint.X + offsx));
      Pixel:=PPixel^;
      B:=GetRValue(Pixel);
      G:=GetGValue(Pixel);
      R:=GetBValue(Pixel);
      Result:=RGB(R,G,B);
    end;

  begin
    // Проверяем соседнюю сверху точку
    // Проверяем, не выходит ли точка за область рисунки и не проверялась ли она
    // ранее.
    if (APoint.Y <> 0) and (Mask[APoint.X,APoint.Y - 1] = 0) then
    begin
      CurColor:=GetPixelColor(0,-1);
      // Проверяем, должна ли точка войти в область выделения
      if CmpFunc(Color,CurColor) then begin
        Mask[APoint.X,APoint.Y - 1]:=2;
        Next.Push(Point(APoint.X,APoint.Y - 1));
      end
      else
        Mask[APoint.X,APoint.Y - 1]:=1;
    end;
    // Проверяем соседнюю справа точку
    // Проверяем, не выходит ли точка за область рисунки и не проверялась ли она
    // ранее.
    if (APoint.X <> (Width - 1)) and (Mask[APoint.X + 1,APoint.Y] = 0) then
    begin
      CurColor:=GetPixelColor(1,0);
      // Проверяем, должна ли точка войти в область выделения
      if CmpFunc(Color,CurColor) then begin
        Mask[APoint.X + 1,APoint.Y]:=2;
        Next.Push(Point(APoint.X + 1,APoint.Y));
      end
      else
        Mask[APoint.X + 1,APoint.Y]:=1;
    end;
    // Проверяем соседнюю снизу точку
    // Проверяем, не выходит ли точка за область рисунки и не проверялась ли она
    // ранее.
    if (APoint.Y <> (Height - 1)) and (Mask[APoint.X,APoint.Y + 1] = 0) then
    begin
      CurColor:=GetPixelColor(0,1);
      // Проверяем, должна ли точка войти в область выделения
      if CmpFunc(Color,CurColor) then begin
        Mask[APoint.X,APoint.Y + 1]:=2;
        Next.Push(Point(APoint.X,APoint.Y + 1));
      end
      else
        Mask[APoint.X,APoint.Y + 1]:=1;
    end;
    // Проверяем соседнюю слева точку
    // Проверяем, не выходит ли точка за область рисунки и не проверялась ли она
    // ранее.
    if (APoint.X <> 0) and (Mask[APoint.X - 1,APoint.Y] = 0) then
    begin
      CurColor:=GetPixelColor(-1,0);
      // Проверяем, должна ли точка войти в область выделения
      if CmpFunc(Color,CurColor) then begin
        Mask[APoint.X - 1,APoint.Y]:=2;
        Next.Push(Point(APoint.X - 1,APoint.Y));
      end
      else
        Mask[APoint.X - 1,APoint.Y]:=1;
    end;
  end;

  // Функция строит регион по маске Mask. В регион войдут только те точки,
  // значение в маске которых равно 2.
  function CreateRgnFromMask: HRGN;
  const
    dCount = 1024;
  var
    H: THandle;
    MaxRects: DWORD;
    DataMem: PRgnData;
    X,StartX,FinishX,Y: Integer;

    // Процедура добавляет прямоугольник (StartX, Y, FinishX, Y+1) к региону
    procedure AddRect;
    var
      Rect: PRect;
    begin
      Rect:=PRect(@DataMem^.Buffer[DataMem^.rdh.nCount*SizeOf(TRect)]);
      SetRect(Rect^,StartX,Y,FinishX,Y+1);
      Inc(DataMem^.rdh.nCount);
    end;

  begin
    MaxRects:=dCount;       // Начальное значение MaxRects
    // Выделяем память на данные для региона и получаем указатель на нее
    H:=GlobalAlloc(GMEM_MOVEABLE,SizeOf(TRgnDataHeader)+SizeOf(TRect)*MaxRects);
    DataMem:=GlobalLock(H);
    // Заполняем заголовок
    // Обнуляем все поля в заголовке
    ZeroMemory(@DataMem^.rdh,SizeOf(TRgnDataHeader));
    DataMem^.rdh.dwSize:=SizeOf(TRgnDataHeader);
    DataMem^.rdh.iType:=RDH_RECTANGLES;
    // Начинаем цикл обхода рисунка по точкам. Будем двигаться слева-направо,
    // сверху-вниз. В переменных X и Y будем хранить текущее значение координат.
    // В переменной StartX - начало нового прямоугольника, FinishX -
    // соответственно конец прямоугольника.
    for Y:=0 to Height-1 do begin   // Цикл по строкам
      X:=0; StartX:=0; FinishX:=0;  // Обнуляем X, StartX, FinishX
      while X<Width do begin        // Цикл по столбцам
        // Если Mask[X,Y] = 2,
        // то надо включить ее в новый прямоугольник
        if Mask[X,Y] = 2 then FinishX:=X+1
        else begin
          // Mask[X,Y] <> 2. Значит нужно завершить формирование прямоугольника,
          // если он не пустой, то добавить его к региону и начать формирование
          // нового прямоугольника. Если количество прямоугольников в регионе
          // достигло MaxRects, то увеличиваем MaxRects на dCount, и выделяем 
          // память под данные о регионе заново
          if DataMem^.rdh.nCount>=MaxRects then
          begin
            Inc(MaxRects,dCount);
            GlobalUnlock(H);
            H:=GlobalReAlloc(H,SizeOf(TRgnDataHeader)+SizeOf(TRect)*MaxRects,
                GMEM_MOVEABLE);
            DataMem:=GlobalLock(H);
          end;
          // Если прямоугольник не пустой, добавляем его к региону
          if FinishX>StartX then AddRect;
          // Устанавливаем значения StartX, FinishX для формирования нового
          // прямоугольника
          StartX:=X+1;
          FinishX:=X+1;
        end;
        Inc(X);      // Увеличиваем текущее значение координаты X
      end;
      // Возможен следующий случай: если значение последней точки в строке равно
      // 2, то FinishX будет больше, чем StartX, однако прямоугольник не будет
      // добавлен к региону, так так добавление нового прямоугольника происходит
      // только если встретилось значение, отличное от 2. Это нужно учесть.
      if FinishX>StartX then AddRect;
    end;
    // Формируем регион по данным из DataMem^
    Result:=ExtCreateRegion(nil,SizeOf(TRgnDataHeader)+
      SizeOf(TRect)*DataMem^.rdh.nCount,DataMem^);
    GlobalFree(H); // Освобождаем выделенную память
  end;

begin
  // Создаем в памяти временный битмап, с которым будем работать
  TempBitmap:=TBitmap.Create;
  try
    TempBitmap.Assign(Graphic);
    TempBitmap.PixelFormat:=pf24bit;
    Width:=TempBitmap.Width;
    Height:=TempBitmap.Height;
    // Получаем цвет начальной точки
    Color:=TempBitmap.Canvas.Pixels[StartPoint.X,StartPoint.Y];
    // Создаем маску. Значение 0 соответствует тому, что данная точка не
    // проверялась на необходимость войти в регион. Значение 1 означает, что
    // точка проверялась, но не должна войти в регион. Значение 2 - проверялась
    // и должна войти в регион.
    SetLength(Mask,Width,Height);
    // Создаем стеки для волнового алгоритма
    // This - содержит источники волны текущей итерации
    // Next - содержит источники волны для следующей итерации
    This:=TPointStack.Create;
    Next:=TPointStack.Create;
    // Задаем начальные условия для распространения волны
    Mask[StartPoint.X,StartPoint.Y]:=2;
    Next.Push(StartPoint);
    // Цикл "пока есть источники волны".
    // В цикле извлекаются из стека все точки, которые должны стать новым
    // источником волны и для них вызывается волновая функция.
    while not Next.Empty do begin
      XchgStacks;
      for i:=1 to This.Count do begin
        CurPoint:=This.Pop;
        Wave(CurPoint);
      end;
    end;
    // Строим регион по маске Mask.
    Result:=CreateRgnFromMask;
  finally
    Next.Free;
    This.Free;
    TempBitmap.Free;
  end;
end;

{ TPointStack }

function TPointStack.Empty: Boolean;
begin
  Result:=FCount = 0;
end;

// Извлечь значение из стека
function TPointStack.Pop: TPoint;
begin
  // Проверяем, не пустой ли стек
  if FCount<>0 then begin
    Result:=FList[FCount - 1];
    Dec(FCount);
  end
  else begin
    StackEmpty;
  end;
end;

// Поместить значение в стек
procedure TPointStack.Push(Point: TPoint);
begin
  Inc(FCount);
  // При необходимости, выделяем дополнительную память для стека. Выделяем
  // блоками по 1024 элемента, чтобы исключить частое выделение памяти.
  // Частое обращение к функции SetLength снизит быстродействие.
  if FCount>FSize then begin
    Inc(FSize,1024);
    SetLength(FList,FSize);
  end;
  FList[FCount - 1]:=Point;
end;

procedure TPointStack.StackEmpty;
begin
  raise EStackEmpty.Create('Stack is Empty');
end;

end.
