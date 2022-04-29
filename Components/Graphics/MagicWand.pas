unit MagicWand;

{$R-}

interface

uses Windows, SysUtils, Classes, Graphics, Types;

type
  // �������� ������� ��������� ������
  // ������� ������ �������� ���� �������� ����� "a" c ������ �����������
  // ����� "b" � ������� true, ���� ����� ���������� ������.
  TMagicWandCmpFunc = function(a,b: TColor): Boolean;

  // ����������, ����������� ��� ������� ���������� �������� �� ������� �����
  EStackEmpty = class(Exception);

  // �����-����
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

// ������� ��� ��������� ����� ����������� �� �������� "��������� �������".
// ���������� ������, ���������� ������� ���������.
function MagicWandSelect(Graphic: TGraphic; StartPoint: TPoint;
  CmpFunc: TMagicWandCmpFunc): HRGN;

implementation

function MagicWandSelect(Graphic: TGraphic; StartPoint: TPoint;
  CmpFunc: TMagicWandCmpFunc): HRGN;
var
  TempBitmap: TBitmap;           // ��������� ������
  Color: TColor;                 // ���� ��������� �����
  This,Next: TPointStack;        // ����� ��� ��������� ���������
  Mask: array of array of Byte;  // ����� ��� ��������� ���������
  CurPoint: TPoint;              
  Width, Height, i: Integer;

  // ��������� ������ ������� ����� Next � This
  procedure XchgStacks;
  var
    Temp: TPointStack;
  begin
    Temp:=Next;
    Next:=This;
    This:=Temp;
  end;

  // ������� ��������������� ����� �� ����� APoint �� 4-� ������������.
  // ���������� ���� ��������� ����� ������������� �������� 0, ��� ��������, ���
  // ��������������� ����� ��� �� ����������� �� ������������� ����� � �������
  // ���������.
  // ���� �����, �������� APoint ������ ����� � ���������, �� ��������������� ��
  // �������� ����� ������������� �������� 2 � ����� ��������� � ���� ���������
  // ���������� �����. ���� �������� ����� �� ������ ����� � ������� ���������,
  // �� �� ��������������� �� �������� ����� ������������� �������� 1.
  procedure Wave(APoint: TPoint);
  var
    CurColor: TColor;

    // ���������� ���� ������� � ����������� (APoint.X+offsx; APoint.Y+offsy)
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
    // ��������� �������� ������ �����
    // ���������, �� ������� �� ����� �� ������� ������� � �� ����������� �� ���
    // �����.
    if (APoint.Y <> 0) and (Mask[APoint.X,APoint.Y - 1] = 0) then
    begin
      CurColor:=GetPixelColor(0,-1);
      // ���������, ������ �� ����� ����� � ������� ���������
      if CmpFunc(Color,CurColor) then begin
        Mask[APoint.X,APoint.Y - 1]:=2;
        Next.Push(Point(APoint.X,APoint.Y - 1));
      end
      else
        Mask[APoint.X,APoint.Y - 1]:=1;
    end;
    // ��������� �������� ������ �����
    // ���������, �� ������� �� ����� �� ������� ������� � �� ����������� �� ���
    // �����.
    if (APoint.X <> (Width - 1)) and (Mask[APoint.X + 1,APoint.Y] = 0) then
    begin
      CurColor:=GetPixelColor(1,0);
      // ���������, ������ �� ����� ����� � ������� ���������
      if CmpFunc(Color,CurColor) then begin
        Mask[APoint.X + 1,APoint.Y]:=2;
        Next.Push(Point(APoint.X + 1,APoint.Y));
      end
      else
        Mask[APoint.X + 1,APoint.Y]:=1;
    end;
    // ��������� �������� ����� �����
    // ���������, �� ������� �� ����� �� ������� ������� � �� ����������� �� ���
    // �����.
    if (APoint.Y <> (Height - 1)) and (Mask[APoint.X,APoint.Y + 1] = 0) then
    begin
      CurColor:=GetPixelColor(0,1);
      // ���������, ������ �� ����� ����� � ������� ���������
      if CmpFunc(Color,CurColor) then begin
        Mask[APoint.X,APoint.Y + 1]:=2;
        Next.Push(Point(APoint.X,APoint.Y + 1));
      end
      else
        Mask[APoint.X,APoint.Y + 1]:=1;
    end;
    // ��������� �������� ����� �����
    // ���������, �� ������� �� ����� �� ������� ������� � �� ����������� �� ���
    // �����.
    if (APoint.X <> 0) and (Mask[APoint.X - 1,APoint.Y] = 0) then
    begin
      CurColor:=GetPixelColor(-1,0);
      // ���������, ������ �� ����� ����� � ������� ���������
      if CmpFunc(Color,CurColor) then begin
        Mask[APoint.X - 1,APoint.Y]:=2;
        Next.Push(Point(APoint.X - 1,APoint.Y));
      end
      else
        Mask[APoint.X - 1,APoint.Y]:=1;
    end;
  end;

  // ������� ������ ������ �� ����� Mask. � ������ ������ ������ �� �����,
  // �������� � ����� ������� ����� 2.
  function CreateRgnFromMask: HRGN;
  const
    dCount = 1024;
  var
    H: THandle;
    MaxRects: DWORD;
    DataMem: PRgnData;
    X,StartX,FinishX,Y: Integer;

    // ��������� ��������� ������������� (StartX, Y, FinishX, Y+1) � �������
    procedure AddRect;
    var
      Rect: PRect;
    begin
      Rect:=PRect(@DataMem^.Buffer[DataMem^.rdh.nCount*SizeOf(TRect)]);
      SetRect(Rect^,StartX,Y,FinishX,Y+1);
      Inc(DataMem^.rdh.nCount);
    end;

  begin
    MaxRects:=dCount;       // ��������� �������� MaxRects
    // �������� ������ �� ������ ��� ������� � �������� ��������� �� ���
    H:=GlobalAlloc(GMEM_MOVEABLE,SizeOf(TRgnDataHeader)+SizeOf(TRect)*MaxRects);
    DataMem:=GlobalLock(H);
    // ��������� ���������
    // �������� ��� ���� � ���������
    ZeroMemory(@DataMem^.rdh,SizeOf(TRgnDataHeader));
    DataMem^.rdh.dwSize:=SizeOf(TRgnDataHeader);
    DataMem^.rdh.iType:=RDH_RECTANGLES;
    // �������� ���� ������ ������� �� ������. ����� ��������� �����-�������,
    // ������-����. � ���������� X � Y ����� ������� ������� �������� ���������.
    // � ���������� StartX - ������ ������ ��������������, FinishX -
    // �������������� ����� ��������������.
    for Y:=0 to Height-1 do begin   // ���� �� �������
      X:=0; StartX:=0; FinishX:=0;  // �������� X, StartX, FinishX
      while X<Width do begin        // ���� �� ��������
        // ���� Mask[X,Y] = 2,
        // �� ���� �������� �� � ����� �������������
        if Mask[X,Y] = 2 then FinishX:=X+1
        else begin
          // Mask[X,Y] <> 2. ������ ����� ��������� ������������ ��������������,
          // ���� �� �� ������, �� �������� ��� � ������� � ������ ������������
          // ������ ��������������. ���� ���������� ��������������� � �������
          // �������� MaxRects, �� ����������� MaxRects �� dCount, � �������� 
          // ������ ��� ������ � ������� ������
          if DataMem^.rdh.nCount>=MaxRects then
          begin
            Inc(MaxRects,dCount);
            GlobalUnlock(H);
            H:=GlobalReAlloc(H,SizeOf(TRgnDataHeader)+SizeOf(TRect)*MaxRects,
                GMEM_MOVEABLE);
            DataMem:=GlobalLock(H);
          end;
          // ���� ������������� �� ������, ��������� ��� � �������
          if FinishX>StartX then AddRect;
          // ������������� �������� StartX, FinishX ��� ������������ ������
          // ��������������
          StartX:=X+1;
          FinishX:=X+1;
        end;
        Inc(X);      // ����������� ������� �������� ���������� X
      end;
      // �������� ��������� ������: ���� �������� ��������� ����� � ������ �����
      // 2, �� FinishX ����� ������, ��� StartX, ������ ������������� �� �����
      // �������� � �������, ��� ��� ���������� ������ �������������� ����������
      // ������ ���� ����������� ��������, �������� �� 2. ��� ����� ������.
      if FinishX>StartX then AddRect;
    end;
    // ��������� ������ �� ������ �� DataMem^
    Result:=ExtCreateRegion(nil,SizeOf(TRgnDataHeader)+
      SizeOf(TRect)*DataMem^.rdh.nCount,DataMem^);
    GlobalFree(H); // ����������� ���������� ������
  end;

begin
  // ������� � ������ ��������� ������, � ������� ����� ��������
  TempBitmap:=TBitmap.Create;
  try
    TempBitmap.Assign(Graphic);
    TempBitmap.PixelFormat:=pf24bit;
    Width:=TempBitmap.Width;
    Height:=TempBitmap.Height;
    // �������� ���� ��������� �����
    Color:=TempBitmap.Canvas.Pixels[StartPoint.X,StartPoint.Y];
    // ������� �����. �������� 0 ������������� ����, ��� ������ ����� ��
    // ����������� �� ������������� ����� � ������. �������� 1 ��������, ���
    // ����� �����������, �� �� ������ ����� � ������. �������� 2 - �����������
    // � ������ ����� � ������.
    SetLength(Mask,Width,Height);
    // ������� ����� ��� ��������� ���������
    // This - �������� ��������� ����� ������� ��������
    // Next - �������� ��������� ����� ��� ��������� ��������
    This:=TPointStack.Create;
    Next:=TPointStack.Create;
    // ������ ��������� ������� ��� ��������������� �����
    Mask[StartPoint.X,StartPoint.Y]:=2;
    Next.Push(StartPoint);
    // ���� "���� ���� ��������� �����".
    // � ����� ����������� �� ����� ��� �����, ������� ������ ����� �����
    // ���������� ����� � ��� ��� ���������� �������� �������.
    while not Next.Empty do begin
      XchgStacks;
      for i:=1 to This.Count do begin
        CurPoint:=This.Pop;
        Wave(CurPoint);
      end;
    end;
    // ������ ������ �� ����� Mask.
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

// ������� �������� �� �����
function TPointStack.Pop: TPoint;
begin
  // ���������, �� ������ �� ����
  if FCount<>0 then begin
    Result:=FList[FCount - 1];
    Dec(FCount);
  end
  else begin
    StackEmpty;
  end;
end;

// ��������� �������� � ����
procedure TPointStack.Push(Point: TPoint);
begin
  Inc(FCount);
  // ��� �������������, �������� �������������� ������ ��� �����. ��������
  // ������� �� 1024 ��������, ����� ��������� ������ ��������� ������.
  // ������ ��������� � ������� SetLength ������ ��������������.
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
