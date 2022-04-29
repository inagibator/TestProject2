unit N_MSWord;
// MS Word related code

interface
uses Windows, Classes, Graphics, Controls, ExtCtrls,
  K_Types, K_UDT1, K_Script1, K_SBuf, K_STBuf, //
  N_Types, N_Lib0, N_Lib2, N_Gra2, //
  N_CompCL, N_CompBase, N_Comp1, N_Comp2, N_DGrid, N_Rast1Fr;

type TN_MSOpenDocFlags = Set Of ( // Open Document Flags
                              odfVisible );
// odfVisible - Opened Document should be visible (now implemented only for MSWMajorVersion >= 10)

type TN_MSResDocFlags = Set Of ( // Resulting Document Flags
                              rdfSaveResDoc, rdfShowResDoc, rdfCopyToClip );
// rdfSaveResDoc - Save Resulting Document to File,
// rdfShowResDoc - Show Resulting Document in Word
// rdfCopyToClip - Copy Resulting Document content to Windows Clipboard

type TN_MSGenFlags = Set Of ( // some general MS Word mode flags
                               mswfUseVBA, mswfUseWin32API,
                               mswfAlwaysVisible );
// mswfUseVBA        - VBA macros would be used, otherwise only Pascal would be used
// mswfUseWin32API   - In VBA macros Win32API would be used
// mswfAlwaysVisible - Word should be Always Visible, even while working (mainly for debug)

type TN_MSPasParMode = ( // mode of Passing Params between VBA and Delphi
                      ppmNotGiven,  ppmFile,     ppmWinAPIClb,
                      ppmDelphiMem, ppmPSDocVar, ppmPSDocText, ppmPSDocClb );
// ppmNotGiven
// ppmFile
// ppmWinAPIClb -
// ppmDelphiMem -
// ppmPSDocVar
// ppmPSDocText
// ppmPSDocClb


type TN_MSWordObj = class( TObject ) // Object for working with MS Word documents
  MSWServer:        Variant;     // Word Server (OLE Server)
  MSWServerName:     string;     // Required Server Name ('Word.Application', 'Word.Application.10', ...)
  MSWMinMajorVersion: integer;   // Required Server Minimal Major Version (8-97, 9-2000, 10-2002(XP), 11-2003)
  MSWGenFlags:   TN_MSGenFlags; // Word Server General Flags
  MSWResDocFlags: TN_MSResDocFlags; // Resulting Document Flags
  MSWPPMode:  TN_MSPasParMode;  // Passing Params between VBA and Delphi mode
  MSWMajorVersion:  integer;     // Word Server Major version (8-97, 9-2000, 10-2002(XP), 11-2003)
  MSWWasCreated:    boolean;     // Word Server was created in MSWStartWorking (did not exists before)
  MSWWasVisible:    boolean;     // Word Server existed before call to MSWStartWorking and was visible
  MSWWordMacros: TStringList;    // Word Macros Names (DelhiName=WordName)
  MSWPDCounter:     integer;     // Processed Documents Counter (needed for creating hundreds of documents)
  MSWDCounterDelta: integer;     // MSWPDCounter Delta (used for calling intermediate Save)
  MSWMainDoc:       Variant;     // Word Main Document (document beeing created)
  MSWMainDocIP:     Variant;     // MSWMainDoc current Insertion Point (empty Range)
  MSWStrVars:    TStringList;    // Named string variables for communicating between documents (?)
  MSWDocNames:   TStringList;    // Currently opened Documents Full Names (with Flag in Object field:
                                 // =0 - own file (opened by TN_MSWordObj), =1 - was opened before call to MSWStartWorking
  MSWCurTable:      Variant;     // Current Word Table for using in SPL functions
  MSWCurDoc:        Variant;     // Current Word Document for using in SPL functions
  MSWOutDir:         string;     // Out Files Directory
  MSWTmpDir:         string;     // Tmp Files Directory
  MSWMainDocFName:   string;     // Word Main Document Full File Name
  MSWPPDoc:         Variant;     // Word special Document used for Passing Params

  constructor Create();
  destructor  Destroy; override;
  function  MSWStartWorking  (): boolean;
  function  MSWGetServerInfo ( AMode: integer; AHeader: string = '' ): TStringList;
  function  MSWDocIsOpened   ( AFullFileName: string ): boolean;
  function  MSWOpenDoc       ( AFullFileName: string; AOpenDocFlags: TN_MSOpenDocFlags = [] ): Variant;
  function  MSWCloseDoc      ( AFullFileName: string ): boolean;
  function  MSWSaveDocAs     ( ADoc: Variant; AFullFileName: string ): boolean;
  function  MSWAddTableByStrMatr ( ADocument: Variant; AStrMatr: TN_ASArray; AShowProgress: TN_OneStrProcObj = nil ): boolean;
  function  MSWFinishWorking (): boolean;
end; // type TN_MSWordObj = class( TObject )

var
  N_MSWDelphiMem: TN_BArray;

  N_MSWPPModeNames: array [0..6] of string = ( 'Not Given', 'File',
                                 'Clipboard by API', 'Delphi Mem', 'PSDoc Var',
                                 'PSDoc Text', 'PSDoc Clb' );

  N_MSWCloseServerStrings: array [0..3] of string = ( ' Save all Documents ',
         ' Cancel all Documents ', 'Close Word manually', 'Abort Using Word' );



implementation
uses math, Forms, SysUtils, Dialogs, Variants,
  K_UDConst, K_CLib0, K_Arch, K_Parse,
  N_ClassRef, N_Lib1, N_Gra0, N_Gra1, N_EdRecF,
  N_EdParF;

//********** TN_MSWordObj class methods  **************

//***************************************************** TN_MSWordObj.Create ***
//
constructor TN_MSWordObj.Create();
begin
  MSWServerName  := 'Word.Application';
//  MSWServerName  := 'Word.Application.10';
  MSWMinMajorVersion := 8; // Word 97

  MSWGenFlags := [];
//  MSWGenFlags := [mewfUseVBA,mewfUseWin32API];

  MSWPPMode := ppmNotGiven;
//  MSWPPMode := ppmDelphiMem;

  MSWTmpDir := K_ExpandFIleName( '(#TmpFiles#)' );
  if not DirectoryExists( MSWTmpDir ) then
    raise Exception.Create( 'TmpFiles Directory is absent!');

  MSWWordMacros := TStringList.Create;
  MSWStrVars    := TStringList.Create;
  MSWDocNames   := TStringList.Create;
end; // constructor TN_MSWordObj.Create

//**************************************************** TN_MSWordObj.Destroy ***
//
destructor TN_MSWordObj.Destroy();
begin
  MSWWordMacros.Free;
  MSWStrVars.Free;
  MSWDocNames.Free;

  MSWCurTable  := Unassigned();
  MSWCurDoc    := Unassigned();
  MSWMainDocIP := Unassigned();
  MSWMainDoc   := Unassigned();
  MSWPPDoc     := Unassigned();
  MSWServer    := Unassigned();

  inherited;
end; // destructor TN_MSWordObj.Destroy

//******************************************** TN_MSWordObj.MSWStartWorking ***
// Start Working with Word Server
//
//     Parameters
// Result  - Return True if OK
//
// Init Word Server (if not yet), add Word Templates and load Word Macro Names
//
function TN_MSWordObj.MSWStartWorking(): boolean;
var
  i, NumDocs: integer;
  Str, DocName: string;
  ParamsForm: TN_EditParamsForm;
begin
  Result := True;
  if not VarIsEmpty( MSWServer ) then Exit; // MSWServer is already OK

  MSWServer := N_GetOLEServer( MSWServerName, @MSWWasCreated );
  MSWWasVisible := MSWServer.Visible; // save initial state of Visible property

  //***** Get Word Server Version

  Str := MSWServer.Build;
  Str := Copy( Str, 1, Pos( '.', Str )-1 );
  MSWMajorVersion := StrToInt( Str );

  //***** Check if MSWServer is invisible (this may occure after previous errors)

  if (not MSWWasCreated) and (not MSWWasVisible) then // Quit MSWServer and create again
  begin
    MSWServer.Visible := True; // to enable view Word warnings and close all Docs manually

    ParamsForm := N_CreateEditParamsForm( 300 );
    with ParamsForm do
    begin
      Caption := 'Closing current copy of Word';
      AddFixComboBox( 'Close Mode:', N_MSWCloseServerStrings, 0 );

      ShowSelfModal();

      if (ModalResult <> mrOK) or       // Closing Mode was not choosen or
         (EPControls[0].CRInt = 3) then // Abort Mode was choosen
      begin
        MSWServer := Unassigned();
        Application.ProcessMessages(); // a precaution
        Result := False;
        Exit;
      end; // Abort Using Word (Abort current session of creating new document)

      if EPControls[0].CRInt <= 1 then // Close all Docs programmatically without saving
      begin
        NumDocs := MSWServer.Documents.Count;

        for i := NumDocs downto 1 do
        begin
          if EPControls[0].CRInt = 1 then // Cancel all Docs
            MSWServer.Documents.Item(i).Saved := True;

          MSWServer.Documents.Item(i).Close;
        end; // for i := NumDocs downto 1 do
      end; // if EPControls[0].CRInt <= 1 then // Close all Docs programmatically

    end; // with ParamsForm do

    MSWServer.Quit;
    MSWServer := Unassigned();
    Application.ProcessMessages(); // a precaution

    //*** Some dialog is needed, because closing Word may took several seconds
    N_WarnByMessage( 'New copy of Word would be created' );

    MSWServer := N_GetOLEServer( MSWServerName, @MSWWasCreated ); // Create again
  end; // if ... then // Quit MSWServer and create again


  //***** Check if current Word Version is suitable

  if MSWMajorVersion < MSWMinMajorVersion then
  begin
    if MSWWasCreated then // MSWServer was just created, Quit it
    begin
      MSWServer.Quit;
      MSWServer := Unassigned();
    end; // if MSWWasCreated then // MSWServer was just created, Quit it

    Result := False;
    Exit;
  end; // Check if current Word Version is suitable

  MSWServer.Visible := mswfAlwaysVisible in MSWGenFlags; // Set Visible mode if needed (for debug)

  //***** Fill MSWDocNames by Documents full file Names
  //      (by Documents, that were opened before MSWServer was created)

  NumDocs := MSWServer.Documents.Count;
  MSWDocNames.Clear;

  for i := 1 to NumDocs do // along all opened Documents
  begin
    DocName := MSWServer.Documents.Item(i).FullName;

    with MSWDocNames do
      Objects[ Add( DocName ) ] := TObject(1); // Add Name and set "was opened before" flag
  end; // for i := 1 to NumDocs do // along all opened Documents

  if not (mswfUseVBA in MSWGenFlags) then // "No VBA" mode
  begin
    //***** in "No VBA" mode - all is done
    Exit;
  end;

// VBA related code temporary commented
{
  //***** Here: VBA should be used
  //
  //      Add Global Templates - Macros Libraries in *.dot files,
  //      listed in [WordTemplates] Section in Ini file

  SL := TStringList.Create();
  N_ReadMemIniSection( 'WordTemplates', SL );
//  N_IAdd( GetWSInfo( 2, 'DefWordServer 1' ) ); // debug

  for i := 0 to SL.Count-1 do // along all strings in [WordTemplates] section
  begin
    FName := K_ExpandFileName( SL.ValueFromIndex[i] );

    //***** Check if FName is Virtual file and real file should be created in (#TmpFiles#) Dir
    K_VFAssignByPath( WFVFile, FName );
    if WFVFile.VFType <> K_vftDFile then // FName is Virtual file
    begin
      TmpFName := K_ExpandFIleName( '(#TmpFiles#)' + ExtractFileName(FName) );
      K_VFCopyFile( FName, TmpFName, K_DFCreatePlain ); // copy FName -> TmpFName
      FName := TmpFName;
    end;

    GCWordServer.AddIns.Add( FName );
  end; // for i := 0 to SL.Count-1 do // along all strings in [WordTemplates] section

  GCMSWordMacros := TStringList.Create; // MS Word  Macros Names (DelphiName=WordName)
  N_ReadMemIniSection( 'WordMacros', GCMSWordMacros );
  GCMSWordMacros.Sort;


  //***** GCMSWordMacros are OK, Initialize VBA and check if Win32 API works in VBA

  //***** Initialize VBA

  RunWordMacro( 'N_InitVBA1' ); // first macro, it can be aborted in some Word versions because of using WinAPI
  GCWSPSDoc := GCWordServer.ActiveDocument; // was set in InitVBA1 macro

  Str := GCWSPSDoc.Content.Text;
  if Pos( 'APIOK', Str ) <> 1 then // Win32 API in VBA Failed ( InitVBA1 macro was aborted)
    GCWSVBAFlags := GCWSVBAFlags - [mewfUseWin32API];

  RunWordMacro( 'N_InitVBA2' ); // second macro, it should finish initialization

//  Str := GCWSPSDoc.Content.Text; // Opened full file names, delimeted by %%

//  GCWSDocNames.Clear;
//  N_SplitSubStrings( Str, '%%', GCWSDocNames );

//  for i := 0 to GCWSDocNames.Count-1 do // along all opened Documents
//    GCWSDocNames.Objects[i] := TObject(1); // set "was opened before" flag


//  Str := GetWordParamsStr();  // 'APIOK' or 'APIFailed' was set in 'InitVBA1' and 'InitVBA2' Macros
//  if Str <> 'APIOK' then // Win32 API in VBA Failed
//    GCWSVBAFlags := GCWSVBAFlags - [mewfUseWin32API];

  //***** Set N_Win32APIOK, N_ParamsStrFName and N_ProtocolFName VBA Glob Vars

//  if mewfUseWin32API in GCWSVBAFlags then Str := '1'
//                                     else Str := '0';
// 'N_Win32APIOK%%' + Str +

  Str :=   'N_ParamsStrFName%%' + GCWSTmpDir + N_GCWSParamsStrFName +
         '%%N_ProtocolFName%%'  + GCWSOutDir + 'Protocol.txt' +
         '%%N_DelphiProcId%%'   + IntToStr(GetCurrentProcessId()) +
         '%%N_DelphiMemAdr%%'   + IntToStr(Integer(@N_DelphiMem[0]));

  GCWSPSMode := psmPSDocText; // this Mode is set temporary only for one next call to SetWordParamsStr
  SetWordParamsStr( Str );
  RunWordMacro( 'N_SetGlobVars' );

  SetWordPSMode( N_MEGlobObj.MEWordPSMode ); // set any new PSMode, given by User
//  N_IAdd( GetWSInfo( 2, 'DefWordServer 3' ) ); // debug
}
end; // procedure TN_MSWordObj.MSWStartWorking

//******************************************* TN_MSWordObj.MSWGetServerInfo ***
// Get Info about current Word Server (for debug).
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
function TN_MSWordObj.MSWGetServerInfo( AMode: integer; AHeader: string ): TStringList;
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

  if VarIsEmpty( MSWServer ) then
  begin
    N_InfoSL.Add( 'MSWServer is not defined!' );
    Exit; // all done
  end;

  if AMode = 0 then // one short string with Version and flags
  begin
    Str := Format( 'Ver:%s, Fl:%d%d', [MSWServer.Application.Build,
                              integer(MSWPPMode), TN_PByte(@MSWGenFlags)^ ] );
    N_InfoSL.Add( Str );
    Exit; // all done
  end; // if AMode = 0 then // one short string with Version and flags


  //***** here: Amode >= 1 get Info about all variables and modes

  NumDocs    := MSWServer.Documents.Count;
  NumAddins  := MSWServer.AddIns.Count;
  NumWindows := MSWServer.Windows.Count;

  with N_InfoSL do
  begin
    Str := 'Word Build ' + MSWServer.Application.Build;
    Str := Format( '%s, NumDocs=%d, NumAddIns=%d, NumWindows=%d', [Str,NumDocs,NumAddins,NumWindows] );
    Add( Str );

    if mswfUseVBA in MSWGenFlags then
    begin
      if mswfUseWin32API in MSWGenFlags then
        Str := 'VBA and Win32API Used'
      else
        Str := 'VBA is Used, Win32API NOT';
    end else
      Str := 'VBA NOT Used';

    if integer(MSWPPMode) >= 7 then // Debug
      N_i := 1;

    Str := Str + ', PPMode:' + N_MSWPPModeNames[integer(MSWPPMode)];
    Str := Str + Format( ', WasVisible:%d, WasCreated:%d',
                           [integer(MSWWasVisible),integer(MSWWasCreated)] );
    Add( Str );

    if AMode >= 2 then // add all Doc and AddIn Names
    begin
      Str := 'Documents: ';
      for i := 1 to NumDocs do
      begin
        Str := Str + MSWServer.Documents.Item(i).Name;
        if i < NumDocs then Str := Str + ', ';
      end;
      Add( Str );

      Str := 'AddIns: ';
      for i := 1 to NumAddins do
      begin
        Str := Str + MSWServer.AddIns.Item(i).Name;
        if i < NumAddins then Str := Str + ', ';
      end;
      Add( Str );

      Add( 'Windows:' );
      for i := 1 to NumWindows do
      begin
        WW := MSWServer.Windows.Item(i);
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
end; // function TN_MSWordObj.MSWGetServerInfo

//********************************************* TN_MSWordObj.MSWDocIsOpened ***
// Return True if Document with given AFullFileName is already Opened.
//
//     Parameters
// AFullFileName - Full File Name of Document to check
// Result        - True if Document with given AFullFileName is already Opened
//
function TN_MSWordObj.MSWDocIsOpened( AFullFileName: string ): boolean;
begin
  Result := (0 <= MSWDocNames.IndexOf( AFullFileName ));
end; // procedure TN_MSWordObj.MSWDocIsOpened

//************************************************* TN_MSWordObj.MSWOpenDoc ***
// Open given file as Word Document and return Opened Document
//
//     Parameters
// AFullFileName - Full File Name of Document to open
// AOpenDocFlags - Openening Documents mode Flags
// Result        - Opened Document
//
// If this file was already opened, then it will be closed without saving
// changes and reopened.
//
function TN_MSWordObj.MSWOpenDoc( AFullFileName: string; AOpenDocFlags: TN_MSOpenDocFlags = [] ): Variant;
begin
  with MSWDocNames do
  begin
    if MSWDocIsOpened( AFullFileName ) then // already opened, close it
      MSWCloseDoc( AFullFileName );

//    N_i1 := MSWServer.Documents.Count;

    if MSWMajorVersion >= 10 then // Documents.Open method has "Visible" parametr
    begin
      Result := MSWServer.Documents.Open( FileName:=AFullFileName, Visible:=(odfVisible in AOpenDocFlags) );
//      Result := MSWServer.Documents.Open( FileName:=AFullFileName, Visible:=True );
    end else
      Result := MSWServer.Documents.Open( FileName:=AFullFileName );

    Objects[ Add( AFullFileName ) ] := TObject(0); // Add and set "was NOT initially opened" flag
//    N_i2 := IndexOf( AFullFileName );
  end; // with MSWDocNames do
end; // procedure TN_MSWordObj.MSWOpenDoc

//************************************************ TN_MSWordObj.MSWCloseDoc ***
// If Word Document with given AFullFileName exists, Close it without saving
//
//     Parameters
// AFullFileName - Full File Name of Document to check
// Result        - Return False if Document was already closed (before this call)
//
function TN_MSWordObj.MSWCloseDoc( AFullFileName: string ): boolean;
var
  Ind: integer;
begin
  Result := False;
  Ind := MSWDocNames.IndexOf( AFullFileName );
  if Ind = -1 then Exit;  // no such a Document
  Result := True;

  MSWDocNames.Delete( Ind ); // Remove form MSWDocNames
  MSWServer.Documents.Item( AFullFileName ).Close( SaveChanges:=wdDoNotSaveChanges );
  Application.ProcessMessages();
end; // procedure TN_MSWordObj.MSWCloseDoc

//*********************************************** TN_MSWordObj.MSWSaveDocAs ***
// Save given ADoc under given AFullFileName
//
//     Parameters
// ADoc          - Document to Save
// AFullFileName - Full File Name under which ADoc should be saved
// Result        - Return True if OK
//
function TN_MSWordObj.MSWSaveDocAs( ADoc: Variant; AFullFileName: string ): boolean;
begin
  Result := True;

  if ADoc.FullName = AFullFileName then // save Adoc under self name
  begin
    ADoc.Save;
    Exit;
  end; // if ADoc.FullName = AFullFileName then // save Adoc under self name

  if MSWDocIsOpened( AFullFileName ) then // another Document has needed Name
    MSWCloseDoc( AFullFileName );

  if FileExists( AFullFileName ) then // delete file to avoid warning while SaveAs
    DeleteFile( AFullFileName );

  ADoc.SaveAs( Filename := AFullFileName );
  Application.ProcessMessages();
end; // procedure TN_MSWordObj.MSWSaveDocAs

//*************************************** TN_MSWordObj.MSWAddTableByStrMatr ***
// Add New Table to given ADocument
//
//     Parameters
// ADocument     - given ADocument
// AStrMatr      - given String Matr with needed Table content
// AShowProgress - given Procedure of Object for showing Progeress string
// Result        - Return True if OK
//
//
function TN_MSWordObj.MSWAddTableByStrMatr( ADocument: Variant; AStrMatr: TN_ASArray;
                                            AShowProgress: TN_OneStrProcObj ): boolean;
var
  ix, iy, NumRows, NumCols: integer;
  SavedVisible: boolean;
  FirstRow: Variant;
begin
  Result := True;
  NumRows := Length( AStrMatr );
  NumCols := Length( AStrMatr[0] );

  SavedVisible := MSWServer.Visible;
  MSWServer.Visible := False;

  MSWCurTable := ADocument.Tables.Add( MSWCurDoc.Range, NumRows, NumCols,
                                       wdWord9TableBehavior, wdAutoFitContent );
  FirstRow := MSWCurTable.Rows.Item( 1 );
  FirstRow.Range.Font.Bold := True;
  FirstRow.Range.ParagraphFormat.Alignment := wdAlignParagraphCenter;
  FirstRow.HeadingFormat   := True;

  if Assigned(AShowProgress) then
    AShowProgress( 'Creating Table, please wait ...' );

  MSWServer.Visible := SavedVisible;
  Exit;

  for iy := 0 to NumRows-1 do // along all Table Rows
  begin
    for ix := 0 to NumCols-1 do // along all Columns in iy-th Table Row
    begin
      MSWCurTable.Cell( iy+1, ix+1 ).Range.Text := AStrMatr[iy][ix];
    end; // for ix := 0 to NumCols-1 do // along all Columns in iy-th Table Row


    if (iy+1) mod 10 = 0 then // for each tenth Rows
    begin
      if Assigned(AShowProgress) then
        AShowProgress( Format( 'Creating Table, %d Rows of %d', [iy+1,NumRows] ));

      Application.ProcessMessages();
    end; // if iy mod 10 = 0 then

  end; // for iy := 0 to NumRows-1 do // along all Table Rows

  MSWServer.Visible := SavedVisible;
end; // procedure TN_MSWordObj.MSWAddTableByStrMatr


//******************************************* TN_MSWordObj.MSWFinishWorking ***
// Finish Working with Word Server
//
// Close all documents, created after call to MSWStartWorking,
// free Variant variables and Quit Word Server or make it Visible
// Return True if OK
//
function TN_MSWordObj.MSWFinishWorking(): boolean;
var
  i: integer;
begin
  Result := True;
  if VarIsEmpty( MSWServer ) then Exit; // nothing to do

  MSWCurTable  := Unassigned();
  MSWCurDoc    := Unassigned();
  MSWMainDocIP := Unassigned();

  // Update TOCs (Tables Of Contents) is not temporary implemented
  // Remove Bookmarks is not temporary implemented

  if rdfCopyToClip in MSWResDocFlags then // Copy MSWMainDoc to Clipboard
    MSWMainDoc.Range.Copy;

  if rdfSaveResDoc in MSWResDocFlags then // Save MSWMainDoc to file
    MSWSaveDocAs( MSWMainDoc, MSWMainDocFName );

  if rdfShowResDoc in MSWResDocFlags then // Show MSWMainDoc
    MSWMainDoc.Activate // a precaution
  else // Close MSWMainDoc
    MSWCloseDoc( MSWMainDoc.FullName );

  MSWMainDoc := Unassigned(); // Free reference to Created Document (closed or not)


  //***** Close all temporary opened documents (mainly Templates)

  with MSWDocNames do
  begin
//      N_IAdd( GetWSInfo( 2, 'Deb before delete:' ) ); // debug

    for i := 0 to Count-1 do // along all opened documents
    begin
      if Objects[i] = TObject(0) then // was not opened before cal to MSWStartWorking, close it
      begin
        MSWServer.Documents.Item( Strings[i] ).Close;
//          ShortFName := ExtractFileName( Strings[i] );
//          MSWServer.Documents.Item( ShortFName ).Close;
      end;
    end; // for i := 1 to Count do // along all opened documents

//      N_IAdd( GetWSInfo( 2, 'Deb after delete:' ) ); // debug
  end; // with MSWDocNames do

  if mswfUseVBA in MSWGenFlags then // MSWPPDoc is used only in 'Use VBA' mode
    MSWPPDoc.Close( SaveChanges:=wdDoNotSaveChanges );

  MSWPPDoc := Unassigned();

  if (mswfAlwaysVisible in MSWGenFlags) or // AlwaysVisible debug Mode OR
     (rdfShowResDoc in MSWResDocFlags) then // Resulting document should remains opened
    MSWServer.Visible := True
  else if not MSWWasCreated then // IF MSWServer existed before call to MSWStartWorking
    MSWServer.Visible := MSWWasVisible
  else // MSWServer should be Closed
    MSWServer.Quit;

  MSWServer := Unassigned();
end; // function TN_MSWordObj.MSWFinishWorking


end.
