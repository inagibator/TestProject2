unit A_DBAnonymizer;

interface

uses
  Classes,
  SysUtils,
  K_CM0,
  ADODB,
  Dialogs;

type
  TDBAnonymizer = class(TObject)
  public
    procedure AnonymizePatients;
    procedure AnonymizeLocations;
    procedure AnonymizeProviders;
  end;



implementation

function RandomString(const ALength: Integer): String;
var
  i: Integer;
  LCharType: Integer;
  x: integer;
begin
  x := 10;
  Result := '';
  for i := 1 to ALength do
  begin
    LCharType := Random(3);
    case LCharType of
      0: Result := Result + Chr(ord('a') + Random(26));
      1: Result := Result + Chr(ord('A') + Random(26));
      2: Result := Result + Chr(ord('0') + Random(10));
    end;
  end;
end;

procedure TDBAnonymizer.AnonymizeLocations;
var
  DS: TADODataSet;
begin
  Randomize;

  DS := TADODataSet.Create(nil);

  try
    DS.Connection := TK_CMEDDBAccess(K_CMEDAccess).LANDBConnection;
    DS.CommandText := 'SELECT * FROM AllLocations';
    DS.Open;

    DS.First;

    while not DS.Eof do
    begin
      DS.Edit;
      DS.FieldByName('ALName').AsString := RandomString(10);
      DS.Post;

      DS.Next;
    end;
  finally
    FreeAndNil(DS);
  end;
end;

procedure TDBAnonymizer.AnonymizePatients;
var
  DS: TADODataSet;
begin
  Randomize;

  DS := TADODataSet.Create(nil);

  try
    DS.Connection := TK_CMEDDBAccess(K_CMEDAccess).LANDBConnection;
    DS.CommandText := 'SELECT * FROM AllPatients';
    DS.Open;

    DS.First;

    while not DS.Eof do
    begin
      DS.Edit;
      DS.FieldByName('APSurname').AsString := RandomString(10);
      DS.FieldByName('APFirstname').AsString := RandomString(10);

      if Length(DS.FieldByName('APMiddle').AsString) > 0 then
        DS.FieldByName('APMiddle').AsString := RandomString(10);

      DS.FieldByName('APDOB').AsDateTime := EncodeDate(2021 - Random(90), Random(12), Random(30));
      DS.Post;

      DS.Next;
    end;
  finally
    FreeAndNil(DS);
  end;
end;

procedure TDBAnonymizer.AnonymizeProviders;
var
  DS: TADODataSet;
begin
  Randomize;

  DS := TADODataSet.Create(nil);

  try
    DS.Connection := TK_CMEDDBAccess(K_CMEDAccess).LANDBConnection;
    DS.CommandText := 'SELECT * FROM AllProviders';
    DS.Open;

    DS.First;

    while not DS.Eof do
    begin
      DS.Edit;
      DS.FieldByName('AUSurname').AsString := RandomString(10);
      DS.FieldByName('AUFirstname').AsString := RandomString(10);

      if Length(DS.FieldByName('AUMiddle').AsString) > 0 then
        DS.FieldByName('AUMiddle').AsString := RandomString(10);

      DS.Post;

      DS.Next;
    end;
  finally
    FreeAndNil(DS);
  end;
end;

end.
