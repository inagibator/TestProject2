unit N_MSExcel;
// MS Excel related code

interface
uses Windows, Classes, Graphics, Controls, ExtCtrls,
  K_Types, K_UDT1, K_Script1, K_SBuf, K_STBuf, //
  N_Types, N_Lib0, N_Lib2, N_Gra2, //
  N_CompCL, N_CompBase, N_Comp1, N_Comp2, N_DGrid, N_Rast1Fr, N_MSWord;


type TN_MSExcelObj = class( TObject ) // Object for working with MS Excel documents
  MSEServer:        Variant;     // Excel Server (OLE Server)
  MSEServerName:     string;     // Required Server Name ('Excel.Application', 'Excel.Application.10', ...)
  MSEMinMajorVersion: integer;   // Required Server Minimal Major Version (8-97, 9-2000, 10-2002(XP), 11-2003)
  MSEGenFlags:   TN_MSGenFlags; // Excel Server General Flags
  MSEResDocFlags: TN_MSResDocFlags; // Resulting Document Flags
  MSEPPMode:  TN_MSPasParMode;  // Passing Params between VBA and Delphi mode
  MSEMajorVersion:  integer;     // Excel Server Major version (8-97, 9-2000, 10-2002(XP), 11-2003)
  MSEWasCreated:    boolean;     // Excel Server was created in MSEStartWorking (did not exists before)
  MSEWasVisible:    boolean;     // Excel Server existed before call to MSEStartWorking and was visible
  MSEExcelMacros: TStringList;    // Excel Macros Names (DelhiName=ExcelName)
  MSEPDCounter:     integer;     // Processed Documents Counter (needed for creating hundreds of documents)
  MSEDCounterDelta: integer;     // MSEPDCounter Delta (used for calling intermediate Save)
  MSEMainWBook:     Variant;     // Excel Main Workbook (document beeing created)
  MSEStrVars:    TStringList;    // Named string variables for communicating between documents (?)
  MSEDocNames:   TStringList;    // Currently opened Documents Full Names (with Flag in Object field:
                                 // =0 - own file (opened by TN_MSExcelObj), =1 - was opened before call to MSEStartWorking
  MSECurWBook:      Variant;     // Current Excel Workbook
  MSECurWSheet:     Variant;     // Current Excel Worksheet for using in SPL functions
  MSEOutDir:         string;     // Out Files Directory
  MSETmpDir:         string;     // Tmp Files Directory
  MSEMainDocFName:   string;     // Excel Main Document Full File Name
  MSEPPDoc:         Variant;     // Excel special Document used for Passing Params

  constructor Create();
  destructor  Destroy; override;
  function  MSECreateServer  (): boolean;
  function  MSEStartWorking  (): boolean;
  function  MSEGetServerInfo ( AMode: integer; AHeader: string = '' ): TStringList;
  function  MSEDocIsOpened   ( AFullFileName: string ): boolean;
  function  MSEOpenDoc       ( AFullFileName: string; AOpenDocFlags: TN_MSOpenDocFlags = [] ): Variant;
  function  MSECloseDoc      ( AFullFileName: string ): boolean;
  function  MSESaveDocAs     ( ADoc: Variant; AFullFileName: string ): boolean;
  function  MSEAddTableByStrMatr ( ADocument: Variant; AStrMatr: TN_ASArray; AShowProgress: TN_OneStrProcObj = nil ): boolean;
  function  MSEFinishWorking (): boolean;
end; // type TN_MSExcelObj = class( TObject )

var
  N_MSEDelphiMem: TN_BArray;

  N_MSEPPModeNames: array [0..6] of string = ( 'Not Given', 'File',
                                 'Clipboard by API', 'Delphi Mem', 'PSDoc Var',
                                 'PSDoc Text', 'PSDoc Clb' );

  N_MSECloseServerStrings: array [0..3] of string = ( ' Save all Documents ',
         ' Cancel all Documents ', 'Close Excel manually', 'Abort Using Excel' );



implementation
uses math, Forms, SysUtils, Dialogs, Variants, ComObj,
  K_UDConst, K_CLib0, K_Arch, K_Parse,
  N_ClassRef, N_Lib1, N_Gra0, N_Gra1, N_EdRecF,
  N_EdParF;

//********** TN_MSExcelObj class methods  **************

//***************************************************** TN_MSExcelObj.Create ***
//
constructor TN_MSExcelObj.Create();
begin
  MSEServerName  := 'Excel.Application';
//  MSEServerName  := 'Excel.Application.10';
  MSEMinMajorVersion := 8; // Excel 97

  MSEGenFlags := [];
//  MSEGenFlags := [mewfUseVBA,mewfUseWin32API];

  MSEPPMode := ppmNotGiven;
//  MSEPPMode := ppmDelphiMem;

  MSETmpDir := K_ExpandFIleName( '(#TmpFiles#)' );
  if not DirectoryExists( MSETmpDir ) then
    raise Exception.Create( 'TmpFiles Directory is absent!');

  MSEExcelMacros := TStringList.Create;
  MSEStrVars     := TStringList.Create;
  MSEDocNames    := TStringList.Create;
end; // constructor TN_MSExcelObj.Create

//**************************************************** TN_MSExcelObj.Destroy ***
//
destructor TN_MSExcelObj.Destroy();
begin
  MSEExcelMacros.Free;
  MSEStrVars.Free;
  MSEDocNames.Free;

  MSECurWSheet := Unassigned();
  MSECurWBook  := Unassigned();
  MSEPPDoc     := Unassigned();
  MSEServer    := Unassigned();

  inherited;
end; // destructor TN_MSExcelObj.Destroy

//******************************************* TN_MSExcelObj.MSEStartWorking ***
// Start Working with Excel Server
//
//     Parameters
// Result  - Return True if OK
//
// Init Excel Server (if not yet), add Excel Templates and load Excel Macro Names
//
function TN_MSExcelObj.MSEStartWorking(): boolean;
var
  i, NumDocs: integer;
  Str, DocName: string;
  ParamsForm: TN_EditParamsForm;
begin
  Result := True;
  if not VarIsEmpty( MSEServer ) then Exit; // MSEServer is already OK

  MSEServer := N_GetOLEServer( MSEServerName, @MSEWasCreated );
  MSEWasVisible := MSEServer.Visible; // save initial state of Visible property

  //***** Get Excel Server Version

  Str := MSEServer.Version;
  Str := Copy( Str, 1, Pos( '.', Str )-1 );
  MSEMajorVersion := StrToInt( Str );

  //***** Check if MSEServer is invisible (this may occure after previous errors)

  if (not MSEWasCreated) and (not MSEWasVisible) then // Quit MSEServer and create again
  begin
    MSEServer.Visible := True; // to enable view Excel warnings and close all Docs manually

    ParamsForm := N_CreateEditParamsForm( 300 );
    with ParamsForm do
    begin
      Caption := 'Closing current copy of Excel';
      AddFixComboBox( 'Close Mode:', N_MSECloseServerStrings, 0 );

      ShowSelfModal();

      if (ModalResult <> mrOK) or       // Closing Mode was not choosen or
         (EPControls[0].CRInt = 3) then // Abort Mode was choosen
      begin
        MSEServer := Unassigned();
        Application.ProcessMessages(); // a precaution
        Result := False;
        Exit;
      end; // Abort Using Excel (Abort current session of creating new document)

      if EPControls[0].CRInt <= 1 then // Close all Docs programmatically without saving
      begin
        NumDocs := MSEServer.Documents.Count;

        for i := NumDocs downto 1 do
        begin
          if EPControls[0].CRInt = 1 then // Cancel all Docs
            MSEServer.Documents.Item(i).Saved := True;

          MSEServer.Documents.Item(i).Close;
        end; // for i := NumDocs downto 1 do
      end; // if EPControls[0].CRInt <= 1 then // Close all Docs programmatically

    end; // with ParamsForm do

    MSEServer.Quit;
    MSEServer := Unassigned();
    Application.ProcessMessages(); // a precaution

    //*** Some dialog is needed, because closing Excel may took several seconds
    N_WarnByMessage( 'New copy of Excel would be created' );

    MSEServer := N_GetOLEServer( MSEServerName, @MSEWasCreated ); // Create again
  end; // if ... then // Quit MSEServer and create again


  //***** Check if current Excel Version is suitable

  if MSEMajorVersion < MSEMinMajorVersion then
  begin
    if MSEWasCreated then // MSEServer was just created, Quit it
    begin
      MSEServer.Quit;
      MSEServer := Unassigned();
    end; // if MSEWasCreated then // MSEServer was just created, Quit it

    Result := False;
    Exit;
  end; // Check if current Excel Version is suitable

  MSEServer.Visible := mswfAlwaysVisible in MSEGenFlags; // Set Visible mode if needed (for debug)

  //***** Fill MSEDocNames by Documents full file Names
  //      (by Documents, that were opened before MSEServer was created)

  NumDocs := MSEServer.Documents.Count;
  MSEDocNames.Clear;

  for i := 1 to NumDocs do // along all opened Documents
  begin
    DocName := MSEServer.Documents.Item(i).FullName;

    with MSEDocNames do
      Objects[ Add( DocName ) ] := TObject(1); // Add Name and set "was opened before" flag
  end; // for i := 1 to NumDocs do // along all opened Documents

  if not (mswfUseVBA in MSEGenFlags) then // "No VBA" mode
  begin
    //***** in "No VBA" mode - all is done
    Exit;
  end;

end; // procedure TN_MSExcelObj.MSEStartWorking

//******************************************* TN_MSExcelObj.MSECreateServer ***
// Create Excel Server
//
//     Parameters
// Result  - Return True if OK
//
function TN_MSExcelObj.MSECreateServer(): boolean;
var
  Str: string;
begin
  Result := True;
  if not VarIsEmpty( MSEServer ) then Exit; // MSEServer is already OK

  MSEServer := CreateOLEObject( MSEServerName );
  MSEWasCreated := True;
  MSEWasVisible := False;

  //***** Get Excel Server Version

  Str := MSEServer.Version;
  Str := Copy( Str, 1, Pos( '.', Str )-1 );
  MSEMajorVersion := StrToInt( Str );

  //***** Check if current Excel Version is suitable

  if MSEMajorVersion < MSEMinMajorVersion then
  begin
    if MSEWasCreated then // MSEServer was just created, Quit it
    begin
      MSEServer.Quit;
      MSEServer := Unassigned();
    end; // if MSEWasCreated then // MSEServer was just created, Quit it

    Result := False;
    Exit;
  end; // Check if current Excel Version is suitable

  MSEServer.Visible := mswfAlwaysVisible in MSEGenFlags; // Set Visible mode if needed (for debug)

end; // procedure TN_MSExcelObj.MSECreateServer

//******************************************* TN_MSExcelObj.MSEGetServerInfo ***
// Get Info about current Excel Server (for debug).
//
//     Parameters
// AMode   - what Info to collect:
//#F
//   =0 - only one short string with Version and flags
//   =1 - all variables and modes
//   =2 - same as =1 + all Doc and AddIn Names
//#/F
// AHeader - if not empty it was added as first string
// Result  - Return N_InfoSL (global object) with Info strings
//
// N_InfoSL is used as global working variable.
//
function TN_MSExcelObj.MSEGetServerInfo( AMode: integer; AHeader: string ): TStringList;
var
  i, NumDocs, NumAddins, NumWindows: integer;
  Str: string;
  WW: Variant;
begin
  N_InfoSL.Clear;
  Result := N_InfoSL;

  if AHeader <> '' then
  begin
    N_InfoSL.Add( '' );
    N_InfoSL.Add( AHeader );
  end;

  if VarIsEmpty( MSEServer ) then
  begin
    N_InfoSL.Add( 'MSEServer is not defined!' );
    Exit; // all done
  end;

  if AMode = 0 then // one short string with Version and flags
  begin
    Str := Format( 'Ver:%s, Fl:%d%d', [MSEServer.Application.Build,
                              integer(MSEPPMode), TN_PByte(@MSEGenFlags)^ ] );
    N_InfoSL.Add( Str );
    Exit; // all done
  end; // if AMode = 0 then // one short string with Version and flags


  //***** here: Amode >= 1 get Info about all variables and modes

  NumDocs    := MSEServer.Documents.Count;
  NumAddins  := MSEServer.AddIns.Count;
  NumWindows := MSEServer.Windows.Count;

  with N_InfoSL do
  begin
    Str := 'Excel Build ' + MSEServer.Application.Build;
    Str := Format( '%s, NumDocs=%d, NumAddIns=%d, NumWindows=%d', [Str,NumDocs,NumAddins,NumWindows] );
    Add( Str );

    if mswfUseVBA in MSEGenFlags then
    begin
      if mswfUseWin32API in MSEGenFlags then
        Str := 'VBA and Win32API Used'
      else
        Str := 'VBA is Used, Win32API NOT';
    end else
      Str := 'VBA NOT Used';

    if integer(MSEPPMode) >= 7 then // Debug
      N_i := 1;

    Str := Str + ', PPMode:' + N_MSEPPModeNames[integer(MSEPPMode)];
    Str := Str + Format( ', WasVisible:%d, WasCreated:%d',
                           [integer(MSEWasVisible),integer(MSEWasCreated)] );
    Add( Str );

    if AMode >= 2 then // add all Doc and AddIn Names
    begin
      Str := 'Documents: ';
      for i := 1 to NumDocs do
      begin
        Str := Str + MSEServer.Documents.Item(i).Name;
        if i < NumDocs then Str := Str + ', ';
      end;
      Add( Str );

      Str := 'AddIns: ';
      for i := 1 to NumAddins do
      begin
        Str := Str + MSEServer.AddIns.Item(i).Name;
        if i < NumAddins then Str := Str + ', ';
      end;
      Add( Str );

      Add( 'Windows:' );
      for i := 1 to NumWindows do
      begin
        WW := MSEServer.Windows.Item(i);
        Str := Format( '  i=%d, IsActive=%d, Caption:%s, DocName:%s, IsVisible=%d',
                       [i,integer(WW.Active),WW.Caption,WW.Document.Name,integer(WW.Visible)] );
//        Str := Str + .Name;
        Add( Str );
      end;
      Add( '' );
    end; // if AMode >= 2 then // add all Doc and AddIn Names

    if AHeader <> '' then
    begin
      N_InfoSL.Add( '***** End of ' + AHeader );
      N_InfoSL.Add( '' );
    end;
  end; // with N_InfoSL do
end; // function TN_MSExcelObj.MSEGetServerInfo

//********************************************* TN_MSExcelObj.MSEDocIsOpened ***
// Return True if Document with given AFullFileName is already Opened.
//
//     Parameters
// AFullFileName - Full File Name of Document to check
// Result        - True if Document with given AFullFileName is already Opened
//
function TN_MSExcelObj.MSEDocIsOpened( AFullFileName: string ): boolean;
begin
  Result := (0 <= MSEDocNames.IndexOf( AFullFileName ));
end; // procedure TN_MSExcelObj.MSEDocIsOpened

//************************************************* TN_MSExcelObj.MSEOpenDoc ***
// Open given file as Excel Document and return Opened Document
//
//     Parameters
// AFullFileName - Full File Name of Document to open
// AOpenDocFlags - Openening Documents mode Flags
// Result        - Opened Document
//
// If this file was already opened, then it will be closed without saving
// changes and reopened.
//
function TN_MSExcelObj.MSEOpenDoc( AFullFileName: string; AOpenDocFlags: TN_MSOpenDocFlags = [] ): Variant;
begin
  with MSEDocNames do
  begin
    if MSEDocIsOpened( AFullFileName ) then // already opened, close it
      MSECloseDoc( AFullFileName );

//    N_i1 := MSEServer.Documents.Count;

    if MSEMajorVersion >= 10 then // Documents.Open method has "Visible" parametr
    begin
      Result := MSEServer.Documents.Open( FileName:=AFullFileName, Visible:=(odfVisible in AOpenDocFlags) );
//      Result := MSEServer.Documents.Open( FileName:=AFullFileName, Visible:=True );
    end else
      Result := MSEServer.Documents.Open( FileName:=AFullFileName );

    Objects[ Add( AFullFileName ) ] := TObject(0); // Add and set "was NOT initially opened" flag
//    N_i2 := IndexOf( AFullFileName );
  end; // with MSEDocNames do
end; // procedure TN_MSExcelObj.MSEOpenDoc

//************************************************ TN_MSExcelObj.MSECloseDoc ***
// If Excel Document with given AFullFileName exists, Close it without saving
//
//     Parameters
// AFullFileName - Full File Name of Document to check
// Result        - Return False if Document was already closed (before this call)
//
function TN_MSExcelObj.MSECloseDoc( AFullFileName: string ): boolean;
var
  Ind: integer;
begin
  Result := False;
  Ind := MSEDocNames.IndexOf( AFullFileName );
  if Ind = -1 then Exit;  // no such a Document
  Result := True;

  MSEDocNames.Delete( Ind ); // Remove form MSEDocNames
  MSEServer.Documents.Item( AFullFileName ).Close( SaveChanges:=wdDoNotSaveChanges );
  Application.ProcessMessages();
end; // procedure TN_MSExcelObj.MSECloseDoc

//*********************************************** TN_MSExcelObj.MSESaveDocAs ***
// Save given ADoc under given AFullFileName
//
//     Parameters
// ADoc          - Document to Save
// AFullFileName - Full File Name under which ADoc should be saved
// Result        - Return True if OK
//
function TN_MSExcelObj.MSESaveDocAs( ADoc: Variant; AFullFileName: string ): boolean;
begin
  Result := True;

  if ADoc.FullName = AFullFileName then // save Adoc under self name
  begin
    ADoc.Save;
    Exit;
  end; // if ADoc.FullName = AFullFileName then // save Adoc under self name

  if MSEDocIsOpened( AFullFileName ) then // another Document has needed Name
    MSECloseDoc( AFullFileName );

  if FileExists( AFullFileName ) then // delete file to avoid warning while SaveAs
    DeleteFile( AFullFileName );

  ADoc.SaveAs( Filename := AFullFileName );
  Application.ProcessMessages();
end; // procedure TN_MSExcelObj.MSESaveDocAs

//*************************************** TN_MSExcelObj.MSEAddTableByStrMatr ***
// Add New Table to given ADocument
//
//     Parameters
// ADocument     - given ADocument
// AStrMatr      - given String Matr with needed Table content
// AShowProgress - given Procedure of Object for showing Progeress string
// Result        - Return True if OK
//
//
function TN_MSExcelObj.MSEAddTableByStrMatr( ADocument: Variant; AStrMatr: TN_ASArray;
                                            AShowProgress: TN_OneStrProcObj ): boolean;
begin
  Result := True;
end; // procedure TN_MSExcelObj.MSEAddTableByStrMatr


//******************************************* TN_MSExcelObj.MSEFinishWorking ***
// Finish Working with Excel Server
//
// Close all documents, created after call to MSEStartWorking,
// free Variant variables and Quit Excel Server or make it Visible
// Return True if OK
//
function TN_MSExcelObj.MSEFinishWorking(): boolean;
begin
  Result := True;
end; // function TN_MSExcelObj.MSEFinishWorking


end.
