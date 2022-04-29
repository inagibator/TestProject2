unit N_CMDebMP1;
// Any debug code (MP means Michail Portnoj)

interface
uses Classes, SysUtils,
  N_Types, K_Types;

function  N_D4WEncript( ASrcStr: AnsiString ): AnsiString;
function  N_D4WDecript( ASrcStr: AnsiString ): AnsiString;

procedure N_CMDebMPProc1 ();
procedure N_CMDebMPProc2 ();

implementation
uses

  K_CLib0,
  N_Lib0;
//  N_PMTDiagr2F;

//************************************************************ N_D4WEncript ***
// Encript given ASrcStr by D4W algorithm
//
function  N_D4WEncript( ASrcStr: AnsiString ): AnsiString;
var
  i: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;

  for i := 1 to Length(ASrcStr) do
  begin
    N_i1 := Integer(ASrcStr[i]);
    N_i2 := N_i1 * 750;
    N_s := Format( '%d', [N_i2] );
    SL.Add( N_s );
  end;

  Result := SL.CommaText;
  SL.Free;
end; // function  N_D4WEncript( ASrcStr: AnsiString ): AnsiString;

//************************************************************ N_D4WDecript ***
// Decript given ASrcStr by D4W algorithm
//
function  N_D4WDecript( ASrcStr: AnsiString ): AnsiString;
begin
{
var
  i, NumChars: Integer;
  SL: TStringList;

  SL := TStringList.Create;
  SL.CommaText := ASrcStr;
  NumChars := SL.Count;
  SetLength( Result, NumChars );

  for i := 1 to NumChars do
  begin
    N_s := SL[i-1];
    N_i1 := StrToInt( N_s );
    N_i2 := N_i1 div 750;
    Result[i] := Char( N_i2 )
  end;

  SL.Free;
}
end; // function  N_D4WDecript( ASrcStr: AnsiString ): AnsiString;

//********************************************************** N_CMDebMPProc1 ***
// Debug MP Proc1
//
procedure N_CMDebMPProc1();
begin
  N_SL.Clear;
  N_SL.Add( '1111' );
  N_SL.Add( '222 222' );
  N_i1 := N_LogChannels[N_Dump1LCInd].LCFlashCounter;
  N_Dump1Strings( N_SL, 5);
  N_i2 := N_LogChannels[N_Dump1LCInd].LCFlashCounter;

//  N_s1 := N_D4WEncript( '1ab' );
//  N_s2 := N_D4WDecript( N_s1 );

//  K_ShowMessage( 'Message text 1', 'Form Caption 1', K_msWarning );
//  N_CreateTstRFrameForm( nil ).Show;
//  N_ShowPMTDiagram2();
end; // procedure N_CMDebMPProc1

//********************************************************** N_CMDebMPProc2 ***
// Debug MP Proc2
//
procedure N_CMDebMPProc2();
begin
  K_ShowMessage( 'Message text 2', 'Form Caption 2', K_msWarning );
end; // procedure N_CMDebMPProc2


end.
