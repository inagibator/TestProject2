unit N_Deb1;
// debug functions, ôêó needed for release versions

interface
uses
  Windows, Classes,
  N_Types;

type TN_DebStream = record  //***** Debug Stream params
    DSName: string;     // Debug Stream Name (file name for DSType=0)
    DSCount: integer;   // Debug Stream Count (file row number for DSType=0)
    DSUsed: boolean;    // Debug Stream was already used by curren application
                        // (current session header was already written)
    DSEnabled: boolean; // writing to Debug Stream is Enabled
end; //*** end of type TN_DebStream = record

//type TN_DebGroup = record  //***** Debug Group params
//    DSInd: integer;    // Debug Stream index (in N_DebStreams array)
//end; //*** end of type TN_DebGroup = record

procedure N_AddDebString ( ADebStreamInd: integer; ADebStr: string );
function  N_DebObjInfo   ( AObject: TObject ): string;
procedure N_ADS ( DebStr: string; i1: integer = -1; i2: integer = -1 );

const N_MaxDebStreamInd = 9;
var
  N_DebStreams: Array [0..N_MaxDebStreamInd] of TN_DebStream;
//   =
//  ( (DSType:-1; DSName:'C:\Delphi_Prj\N_Tree\Deb_0.txt'; DSCount:1), // #0 - stream
//    (DSType:-1; DSName:'C:\DebVBA.txt'; DSCount:1)                   // #1 - stream
//  );

//  N_DebGroups: Array [0..9] of TN_DebGroup =
//      0           1           2           3           4
//  ( (DSInd:0), (DSInd:-1), (DSInd:-1), (DSInd:-1), (DSInd:-1),
//  ( (DSInd:-1), (DSInd:-1), (DSInd:-1), (DSInd:0), (DSInd:-1),

//      5           6           7           8           9
//    (DSInd:-1), (DSInd:-1), (DSInd:-1), (DSInd:-1), (DSInd:-1)
//    (DSInd:-1), (DSInd:-1), (DSInd:-1), (DSInd:-1), (DSInd:-1) // for Cont Debug
//  );

// N_DebGroups index:
//     =0 - creating objects
//     =1 - destroying objects
//     =2 - adding new reference to UData objects
//     =3 - deleting UData objects
//     =4 - loading from SBuf
//     =5 - wrk

implementation
uses Sysutils,
  N_Lib0;

//********************************************************** N_AddDebString ***
// add given ADebStr to Debug Stream with given index ADebStreamInd
//
procedure N_AddDebString( ADebStreamInd: integer; ADebStr: string );
var
  F: TextFile;
begin
  if (ADebStreamInd < 0) or (ADebStreamInd > N_MaxDebStreamInd) then Exit;

  with N_DebStreams[ADebStreamInd] do
  begin
    Assign( F, DSName );
    if FileExists( DSName ) then
      Append( F )
    else
      Rewrite( F );

    if not DSUsed then // first writing, add header string
    begin
      WriteLn( F, '' );
      WriteLn( F, '*** New Dump portion at ' + DateTimeToStr( Now() ) );
      DSUsed := True;
    end;

    WriteLn( F, Format( '%.3d: %s', [DSCount,ADebStr] ));
    Inc( DSCount );

    Flush( F );
    Close( F );
  end; // with N_DebStreams[DSInd] do
end; // end of procedure N_AddDebString

//************************************************ N_DebObjInfo ***
// return string with given AObject Class Name and memory addres
//
function N_DebObjInfo( AObject: TObject ): string;
begin
  if AObject = nil then
    Result := 'NIL'
  else
    Result := Format( ' %s (%.7x) ', [ AObject.ClassName, integer(AObject) ] );
end; // end of function N_DebObjfInfo

//************************************************ N_AddDebString ***
// add given Debug String to ..\data\a1.txt
//
procedure N_ADS( DebStr: string; i1: integer = -1; i2: integer = -1 );
var
  F: TextFile;
  FName: string;
begin
  FName := 'c:\Delphi_Prj\N_Tree\Data\a1.txt';
  Assign( F, FName );

  if FileExists( FName ) then
    Append( F )
  else
    Rewrite( F );  

  WriteLn( F, DebStr, '  ', i1, ' ', i2 );
  Close( F );
end; // end of procedure N_ADS

var
  i: integer;
  F:TextFile;

Initialization
  N_AddStrToFile( 'N_Deb1 Initialization' );

  for i := 0 to N_MaxDebStreamInd do
  begin
    if N_DebStreams[i].DSEnabled then
    begin
      Assign( F, N_DebStreams[i].DSName );
      Rewrite( F );
      WriteLn( F, '0001 Debug Protocol from  ' + DateTimeToStr( Date+Time ) );
      N_DebStreams[i].DSCount := 2;
      Flush( F );
      Close( F );
    end;
  end;

end.

