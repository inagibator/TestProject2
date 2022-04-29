unit N_ME2;
// high level MapEditor objects

interface
uses Windows,
  K_UDT1,
  N_Types;

//****************** Global procedures **********************

function N_CreateTextBoxesByPoints( ARootPanel, ASrcTB, AUDPoints: TN_UDBase ): boolean;

implementation
uses SysUtils,
  N_Lib0, N_Lib1, N_Lib2, N_Gra0, N_Gra1, N_ME1, N_UDat4, N_Comp1;

//****************** Global procedures **********************

//********************************************** N_CreateTextBoxesByPoints ***
// Create UDTextBoxes with UserCoords positions, given by AUDPoints
//
// ARootPanel - TN_UDPanel, where to create new UDTextBoxes
// ASrcTB     - TN_UDTextBox, new UDTextBoxes are clones of given ASrcTB
// AUDPoints  - TN_UDPoints, used as UpperLeft User coords for new UDTextBoxes
//
// Number of created UDTextBoxes is equal to number of Points in AUDPoints,
//   UDTextBoxes are created as ARootPanel children.
//
// If ASrcTB.CSetParams[i].SPSrcPath[1] = '#' then CSCode is added after '#'
//   char (CSCode is taken from UDPoints)
//
// Return True if all UDTextBoxex are created OK
//
function N_CreateTextBoxesByPoints( ARootPanel, ASrcTB, AUDPoints: TN_UDBase ): boolean;
var
  i, Code: integer;
  UObj: TN_UDBase;
  RootPanel: TN_UDPanel;
  UDPoints: TN_UDPoints;
  PatternTB, NewTB: TN_UDTextBox;
begin
  Result := False;

  //***** Check Input Params

  if not (ARootPanel is TN_UDPanel) then
  begin
    N_WarnByMessage( 'Not TN_UDPanel!' );
    Exit;
  end;
  RootPanel := TN_UDPanel(ARootPanel);

  UObj := RootPanel.DirChild(0);
  if not (UObj is TN_UDTextBox) then
  begin
    N_WarnByMessage( 'Not TN_UDTextBox!' );
    Exit;
  end;
  PatternTB := TN_UDTextBox(UObj);

  UObj := AUDPoints;
  if not (UObj is TN_UDPoints) then
  begin
    N_WarnByMessage( 'Not TN_UDPoints!' );
    Exit;
  end;
  UDPoints := TN_UDPoints(UObj);

  Inc( PatternTB.RefCounter ); // to prevent clearing
  RootPanel.ClearChilds;

  for i := 0 to UDPoints.WNumItems-1 do // along all points
  begin
    NewTB := TN_UDTextBox(N_CreateSubTreeClone( PatternTB ));
    RootPanel.AddOneChild( NewTB );
//    Code := UDPoints.Items[i].CCode;
//    UDPoints.GetItemTwoCodes( i, 0, Code, N_i );
    Code := UDPoints.GetItemFirstCode( i, 0 );  // CDinInd temporary = 0!!!

    NewTB.PCCS()^.BPCoords := FPoint(UDPoints.CCoords[UDPoints.Items[i].CFInd]);
    NewTB.ObjName := 'Name_' + IntToStr( Code );

    N_SetCSCodeInUDBase( NewTB, IntToStr( Code ) );
  end; // for i := 0 to UDPoints.WNumItems-1 do // along all points


  PatternTB.UDDelete();
//  N_Show1Str( UDPoints.ObjName + PatternTB.ObjName );

  Result := True;
end; // function N_CreateTextBoxesByPoints



end.
