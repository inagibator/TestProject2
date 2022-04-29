unit K_BArrays;

interface

uses
  SysUtils, Windows, Classes;

type
  { Exceptions }

  TK_CompareProc = function(const item1, item2 : Pointer): Integer;

  TK_SortOrder = (tsNone, tsAscending, tsDescending);

  { These flags govern some of the behaviour of array methods }
  TK_ArrayFlags = (afOwnsData, afAutoSize, afCanCompare, afSortUnique);
  TK_ArrayFlagSet = Set of TK_ArrayFlags;

  TK_Duplicates = (dupIgnore, dupAccept, dupError);

  TK_BaseArray = class(TPersistent)
  private
    FMemory: Pointer;           { Pointer to item buffer }
    FCapacity: Integer;         { The allocated size of the array }
    FItemSize: Integer;         { Size of individual item in bytes }
    FCount: Integer;            { Count of items in use }
    FSortOrder: TK_SortOrder;     { True if array is considered sorted }
    FFlags: TK_ArrayFlagSet;      { Ability flags }
    FDuplicates: TK_Duplicates;   { Signifies if duplicates are stored or not }
    FCompProc: TK_CompareProc;
    function GetItemPtr(index: Integer): Pointer;
    procedure CopyFrom(toIndex, numItems: Integer; const Source);
    procedure SetCount(NewCount: Integer);
    function GetLimit: Integer;
  protected
    function ValidIndex(Index: Integer): Boolean;
    function HasFlag(aFlag: TK_ArrayFlags): Boolean;
    procedure SetFlag(aFlag: TK_ArrayFlags);
    procedure ClearFlag(aFlag: TK_ArrayFlags);
    procedure SetAutoSize(aSize: Boolean);
    procedure BlockCopy(Source: TK_BaseArray; fromIndex, toIndex, numitems: Integer);
    function GetAutoSize: Boolean;
    function ValidateBounds(atIndex: Integer; var numItems: Integer): Boolean;
    procedure RemoveRange(atIndex, numItems: Integer);
    procedure InternalHandleException;
    procedure InvalidateItems(atIndex, numItems: Integer); virtual;
    procedure SetCapacity(NewCapacity: Integer); virtual;
    procedure Grow; virtual;
  public
    constructor Create(itemcount, iSize: Integer); virtual;
    destructor Destroy; override;
    procedure Clear;
    procedure InsertAt(Index: Integer; const Value);
    procedure Insert(const Value); virtual;
    procedure PutItem(index: Integer; const Value);
    procedure GetItem(index: Integer; var Value);
    procedure RemoveItem(Index: Integer);
    procedure Delete(Index: Integer); virtual;
    procedure Exchange(Index1, Index2: Integer); virtual;
    function IndexOf(Item:Pointer): Integer; virtual;
    function FindItem(var Index: Integer; Value:Pointer): Boolean;
    procedure Sort(Compare: TK_CompareProc); virtual;
    property CompareProc: TK_CompareProc read FCompProc write FCompProc;
    property Duplicates: TK_Duplicates read FDuplicates write FDuplicates;
    property SortOrder: TK_SortOrder read FSortOrder write FSortOrder;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Limit: Integer read GetLimit write SetCapacity;
    property ItemSize: Integer read FItemSize;
    property AutoSize: Boolean read GetAutoSize write SetAutoSize;
    property Count: Integer read FCount write SetCount;
    property List: Pointer read FMemory;
  end;

implementation

  { Helper functions }

function CmpInteger(var item1, item2): Integer;
var
  i1: Integer absolute item1;
  i2: Integer absolute item2;
begin
  if (i1 < i2) then
    Result := -1
  else if (i1 > i2) then
    Result := 1
  else
    Result := 0;
end;

  { TK_BaseArray class }

constructor TK_BaseArray.Create(itemcount, iSize: Integer);
begin
  inherited Create;
  FMemory := nil;
  FCapacity := 0;
  FCount := 0;
  FItemSize := iSize;
  FFlags := [afOwnsData, afAutoSize];

  SetCapacity(itemcount);
end;

destructor TK_BaseArray.Destroy;
begin
  if (FMemory <> nil) then
  begin
    Clear;
    FItemSize := 0;
  end;
  inherited Destroy;
end;

procedure TK_BaseArray.SetCount(NewCount: Integer);
begin
  if (NewCount > FCapacity) then
    SetCapacity(NewCount);
  if (NewCount > FCount) then
    FillMemory(GetItemPtr(FCount), (NewCount - FCount) * FItemSize, 0);
  FCount := NewCount;
end;

procedure TK_BaseArray.Clear;
begin
  if (FCount <> 0) then
  begin
    InvalidateItems(0, FCount);
    FCount := 0;
    SetCapacity(0);  { Has same affect as freeing memory }
  end;
end;

procedure TK_BaseArray.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity <> FCapacity) then
  begin
    ReallocMem(FMemory, NewCapacity * FItemSize);
    FillChar(Pointer(Integer(FMemory) + FCapacity * FItemSize)^, (NewCapacity - FCapacity) * FItemSize, 0);
    FCapacity := NewCapacity;
  end;
end;

procedure TK_BaseArray.Grow;
var
  Delta: Integer;
begin
  if (FCapacity > 64) then
    Delta := FCapacity div 4
  else if (FCapacity > 8) then
    Delta := 16
  else
    Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TK_BaseArray.GetLimit: Integer;
begin
  if (FCount = 0) then
    Result := FCapacity
  else
    Result := FCount;
end;

procedure TK_BaseArray.Insert(const Value);
var Index : Integer;
begin
  if FindItem( Index, @Value ) then
    case Duplicates of
      dupIgnore : Exit;
    end;
  InsertAt( Index, Value );
end;

procedure TK_BaseArray.InsertAt(Index: Integer; const Value);
var pcount : Integer;
begin
  if (Index < 0) or (Index > FCount) then
    Exit;
  if AutoSize then
  begin
    pcount := FCount;
    SetCount(FCount+1);
  end
  else
    Exit;

  if (Index < pcount) then
  begin
    try
      MoveMemory(GetItemPtr(Index+1), GetItemPtr(Index), (pcount - Index) * FItemSize);
    except
      InternalHandleException;
    end;
  end;
  CopyFrom(Index, 1, Value);
end;

function TK_BaseArray.ValidIndex(Index: Integer): Boolean;
begin
  Result := True;
  if (Index < 0) or (Index > FCount) then
  begin
    Result := False;
  end
end;

procedure TK_BaseArray.RemoveItem(Index: Integer);
begin
  Delete(Index);
end;

procedure TK_BaseArray.Delete(Index: Integer);
begin
  { We are removing only one item. }
  if ValidIndex(index) then
  begin
    InvalidateItems(Index, 1);
    Dec(FCount);
    if (Index < FCount) then
    begin
      try
        MoveMemory(GetItemPtr(Index), GetItemPtr(Index + 1), (FCount - Index) * FItemSize);
      except
      end;
    end;
  end;
end;

procedure TK_BaseArray.RemoveRange(atIndex, numItems: Integer);
begin
  if (numItems = 0) then
    Exit;
  if ValidateBounds(atIndex, numItems) then
  begin
    { Invalidate the items about to be deleted so a derived class can do cleanup on them. }
    InvalidateItems(atIndex, numItems);
    { Move the items above those we delete down, if there are any }
    if ((atIndex+numItems) <= FCount) then
    begin
      MoveMemory(GetItemPtr(atIndex), GetItemPtr(atIndex+numItems),
                (FCount-atIndex-numItems+1)* FItemSize);
    end;
    if AutoSize then
      SetCapacity(FCount - numItems);
  end;
end;

procedure TK_BaseArray.Exchange(Index1, Index2: Integer);
begin
end;

procedure TK_BaseArray.Sort(Compare: TK_CompareProc);
begin
end;

procedure TK_BaseArray.CopyFrom(toIndex, numItems: Integer; const Source);
begin
  if (numItems = 0) then Exit;
  if ValidateBounds(toIndex, numItems) then
  begin
    try
      InvalidateItems(toIndex, numItems);
      MoveMemory(GetItemPtr(toIndex), @Source, numItems*FItemSize);
    except
      InternalHandleException;
    end;
  end;
end;

procedure TK_BaseArray.PutItem(index: Integer; const Value);
begin
  if AutoSize and (FCount = FCapacity) then
    Grow;
  if ValidIndex(index) then
  begin
    try
      CopyMemory(GetItemPtr(index), @Value, FItemSize);
    except
      InternalHandleException;
    end;
    if index > FCount-1 then
      Inc(FCount);
  end;
end;

procedure TK_BaseArray.GetItem(index: Integer; var Value);
begin
  if ValidIndex(index) then
  begin
    try
      CopyMemory(@Value, GetItemPtr(index), FItemSize);
    except
      InternalHandleException;
    end;
  end;
end;

function TK_BaseArray.GetItemPtr(index: Integer): Pointer;
begin
  Result := nil;
  if ValidIndex(index) then
    Result := Ptr(LongInt(FMemory) + (index*FItemSize));
end;

function TK_BaseArray.ValidateBounds(atIndex: Integer; var numItems: Integer): Boolean;
begin
  Result := True;
  if (atIndex < 0) or (atIndex > FCount) then
    Result := False;
  if Result then
    if (numItems > Succ(FCount)) or ((FCount-numItems+1) < atIndex) then
      numItems := FCount - atIndex + 1;
end;

procedure TK_BaseArray.InvalidateItems(atIndex, numItems: Integer);
begin
end;

function TK_BaseArray.HasFlag(aFlag: TK_ArrayFlags): Boolean;
begin
   Result := aFlag in FFlags;
end;

procedure TK_BaseArray.SetFlag(aFlag: TK_ArrayFlags);
begin
   Include(FFLags, aFlag);
end;

procedure TK_BaseArray.ClearFlag(aFlag: TK_ArrayFlags);
begin
   Exclude(FFLags, aFlag);
end;

procedure TK_BaseArray.SetAutoSize(aSize: Boolean);
begin
  if (aSize = True) then
    SetFlag(afAutoSize)
  else
    ClearFlag(afAutoSize);
end;

function TK_BaseArray.GetAutoSize : Boolean;
begin
  Result := HasFlag(afAutoSize);
end;

function TK_BaseArray.IndexOf( Item : Pointer): Integer;
var
  item2: Pointer;
begin
  if (SortOrder = tsNone) then
  begin
    for Result := 0 to Count - 1 do
    begin
//      GetItem(Result, item2);

      item2 := GetItemPtr(Result);
      if (FCompProc(item2, Item) = 0) then
        Exit;
    end;
    Result := -1;
  end
  else
    if not FindItem(Result, Item) then
      Result := -1;
end;

function TK_BaseArray.FindItem(var Index: Integer; Value : Pointer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while (L <= H) do
  begin
    I := (L + H) shr 1;
    C := FCompProc(GetItemPtr(I), Value);
    if (C < 0) then
      L := I + 1
    else
    begin
      H := I - 1;
      if (C = 0) then
      begin
        Result := True;
        if (Duplicates <> dupAccept) then L := I;
      end;
    end;
  end;
  Index := L;
end;

procedure TK_BaseArray.BlockCopy(Source: TK_BaseArray; fromIndex, toIndex, numitems: Integer);
begin
  if (numitems = 0) then Exit;
  if (Source is ClassType) and (ItemSize = Source.ItemSize) then
  begin
    if Source.ValidateBounds(fromIndex, numItems) then
    begin
      try
        CopyFrom(toIndex, numItems, Source.GetItemPtr(fromIndex)^);
      except
        InternalHandleException;
      end;
    end;
  end;
end;

procedure TK_BaseArray.InternalHandleException;
begin
  Clear;
//  raise EArrayError.CreateRes(@sGeneralArrayError);
end;

end.
