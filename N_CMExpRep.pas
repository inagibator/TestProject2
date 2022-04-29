unit N_CMExpRep;
// Export CMS Reports to *.tab, *.csv, *.doc and *.xls files

interface
uses Windows, Classes, Graphics, Controls, ExtCtrls,
  K_Types, K_UDT1, K_Script1, K_SBuf, K_STBuf, K_CM0,
  N_Types, N_Lib0, N_Lib2, N_Gra2, N_CM1,
  N_CompCL, N_CompBase, N_Comp1, N_Comp2, N_DGrid, N_Rast1Fr;

type TN_CMExpSMFlags = Set Of ( // Export StrMatr Flags
  esmfLandscape,  // Landscape page orientation (if not set - Portrait)
  esmfShowResFile // Show Resulting file in Word
); // type TN_CMExpSMFlags = Set Of ( // Export StrMatr Flags

procedure N_CMExpStrMatrToWord  ( AStrMatr: TN_ASArray; AResFileName: string;
                                  AExpFlags: TN_CMExpSMFlags; ACFPArray: TN_CFPArray );

procedure N_CMExpStrMatrToExcel ( AStrMatr: TN_ASArray; AResFileName: string;
                                  AExpFlags: TN_CMExpSMFlags; ACFPArray: TN_CFPArray );

procedure N_CMExpRepTest1 ();
procedure N_CMExpRepTest2 ();
procedure N_CMExpRepTest3 ();
procedure N_CMExpRepTest4 ();
procedure N_CMExpRepTest5 ();


implementation
uses math, Forms, SysUtils, Dialogs, Variants,
  K_UDConst, K_CLib0, K_Arch, K_Parse,
  N_ClassRef, N_Lib1, N_Gra0, N_Gra1, N_EdRecF,
  N_MSWord, N_MSExcel, N_CMMain5F;

//**************************************************** N_CMExpStrMatrToWord ***
// Export given AStrMatr to MS Word file
//
//     Parameters
// AStrMatr     - given String Matr with needed Table content
// AResFileName - given Resulting File Name
// AExpFlags    - export Flags
// ACFPArray    - Columns Format Params Array (one elem for each Column)
//
procedure N_CMExpStrMatrToWord( AStrMatr: TN_ASArray; AResFileName: string;
                                AExpFlags: TN_CMExpSMFlags; ACFPArray: TN_CFPArray );
var
  NumRows, NumCols: integer;
  FirstRow: Variant;
  SL: TStringList;
  MSWordObj: TN_MSWordObj;
begin
  //***** Copy to Windows Clipboard AStrMatr content

  SL := TStringList.Create;
  N_SaveSMatrToStrings( AStrMatr, SL, smfTab );
  K_PutTextToClipboard( SL.Text, False ); // False means UNICODE, True means ANSI
  SL.Free;

  MSWordObj := TN_MSWordObj.Create;
  with MSWordObj do
  begin

  //***** Set some general Export Flags

//  MSWGenFlags := [mswfAlwaysVisible]; // debug

  MSWResDocFlags := [rdfSaveResDoc];
  if esmfShowResFile in AExpFlags then
    MSWResDocFlags := MSWResDocFlags + [rdfShowResDoc];

  if not MSWStartWorking() then // Initialize Word Server
    raise Exception.Create( 'MSWStartWorking failed!');

  MSWServer.Visible := False;

  //***** Create new empty document and set some document Flags

  MSWCurDoc := MSWordObj.MSWServer.Documents.Add();
  if esmfLandscape in AExpFlags then
    MSWCurDoc.PageSetup.Orientation := wdOrientLandscape
  else
    MSWCurDoc.PageSetup.Orientation := wdOrientPortrait;

  MSWCurDoc.ShowGrammaticalErrors := False;
  MSWCurDoc.ShowSpellingErrors    := False;

  //***** Create new empty Table and set some Table Flags

  NumRows := Length( AStrMatr );
  NumCols := Length( AStrMatr[0] );
  MSWCurTable := MSWCurDoc.Tables.Add( MSWCurDoc.Range, NumRows, NumCols,
                                       wdWord9TableBehavior, wdAutoFitContent );
  MSWCurTable.Rows.AllowBreakAcrossPages := False;
  MSWCurTable.Range.Paste; // Paste Table Content from Clipboard

  //***** Set some First Table Row properties (should be dome AFTER Paste from Clipboard!)

  FirstRow := MSWCurTable.Rows.Item( 1 );
  FirstRow.Range.Font.Bold := True;
  FirstRow.Range.ParagraphFormat.Alignment := wdAlignParagraphCenter;
  FirstRow.HeadingFormat   := True;

  //***** MSWCurDoc is ready, Save it and Show it if needed

//  N_Dump2Strings( MSWGetServerInfo( 2, 'from N_CMExpStrMatrToWord' ), 4 ); // debug

  MSWCloseDoc( AResFileName ); // could be needed if AResFileName remains opened from previous Word session
  MSWSaveDocAs( MSWCurDoc, AResFileName );

  if (mswfAlwaysVisible in MSWGenFlags) or // AlwaysVisible debug Mode OR
     (rdfShowResDoc in MSWResDocFlags) then // Resulting document should remains opened
    MSWServer.Visible := True
  else if not MSWWasCreated then // IF MSWServer existed before call to MSWStartWorking
    MSWServer.Visible := MSWWasVisible
  else // MSWServer should be Closed
    MSWServer.Quit;

  MSWServer := Unassigned();

  end; // with MSWordObj do

  MSWordObj.Free;
end; // procedure N_CMExpStrMatrToWord

//*************************************************** N_CMExpStrMatrToExcel ***
// Export given AStrMatr to MS Excel file
//
//     Parameters
// AStrMatr     - given String Matr with needed Table content
// AResFileName - given Resulting File Name
// AExpFlags    - export Flags
// ACFPArray    - Columns Format Params Array (one elem for each Column)
//
procedure N_CMExpStrMatrToExcel( AStrMatr: TN_ASArray; AResFileName: string;
                                 AExpFlags: TN_CMExpSMFlags; ACFPArray: TN_CFPArray );
var
//  NumRows, NumCols: integer;
  FirstRow, AllRows, Column: Variant;
  SL: TStringList;
  MSExcelObj: TN_MSExcelObj;
begin
  //***** Copy to Windows Clipboard AStrMatr content

  SL := TStringList.Create;
  N_SaveSMatrToStrings( AStrMatr, SL, smfTab );
  K_PutTextToClipboard( SL.Text, False ); // False means UNICODE, True means ANSI
  SL.Free;

  MSExcelObj := TN_MSExcelObj.Create;
  with MSExcelObj do
  begin

  //***** Set some general Export Flags

//  MSEGenFlags := [mswfAlwaysVisible]; // debug

  MSEResDocFlags := [rdfSaveResDoc];
  if esmfShowResFile in AExpFlags then
    MSEResDocFlags := MSEResDocFlags + [rdfShowResDoc];

  if not MSECreateServer() then // Initialize Excel Server
    raise Exception.Create( 'MSEStartWorking failed!');

//  MSEServer.Visible := False;
//  MSEServer.Visible := True; // debug
  MSECurWBook := MSEServer.Workbooks.Add; // Create new empty Workbook
//  N_i := MSECurWBook.Worksheets.Count;
  MSECurWSheet := MSEServer.ActiveSheet;

  MSECurWSheet.Paste; // Paste AStrMatr content from Windows Clipboard

  Column := MSECurWSheet.Columns.Item[2];
  Column.ColumnWidth := Column.ColumnWidth * 2;
  Column.WrapText := True; // should be set after setting Column Width
  Column.HorizontalAlignment := xlCenter;
  Column.VerticalAlignment := xlTop; // is needed if WrapText is True

  AllRows := MSECurWSheet.Rows;
  FirstRow := AllRows.Item[1]; //Square brackets should be used!!!
//  FirstRow := AllRows[1]; //Square brackets should be used!!!
  FirstRow.Font.Bold := True;

  MSEServer.Visible := True; // debug

{
  //***** Create new empty document and set some document Flags

  MSWCurDoc := MSExcelObj.MSEServer.Documents.Add();
  if esmfLandscape in AFlags then
    MSECurDoc.PageSetup.Orientation := wdOrientLandscape
  else
    MSECurDoc.PageSetup.Orientation := wdOrientPortrait;

  MSECurDoc.ShowGrammaticalErrors := False;
  MSECurDoc.ShowSpellingErrors    := False;

  //***** Create new empty Table and set some Table Flags

  NumRows := Length( AStrMatr );
  NumCols := Length( AStrMatr[0] );
  MSECurTable := MSECurDoc.Tables.Add( MSECurDoc.Range, NumRows, NumCols,
                                       wdExcel9TableBehavior, wdAutoFitContent );
  MSECurTable.Rows.AllowBreakAcrossPages := False;
  MSECurTable.Range.Paste; // Paste Table Content from Clipboard

  //***** Set some First Table Row properties (should be dome AFTER Paste from Clipboard!)

  FirstRow := MSECurTable.Rows.Item( 1 );
  FirstRow.Range.Font.Bold := True;
  FirstRow.Range.ParagraphFormat.Alignment := wdAlignParagraphCenter;
  FirstRow.HeadingFormat   := True;

  //***** MSECurDoc is ready, Save it and Show it if needed

//  N_Dump2Strings( MSEGetServerInfo( 2, 'from N_CMExpStrMatrToExcel' ), 4 ); // debug

  MSECloseDoc( AResFileName ); // could be needed if AResFileName remains opened from previous Excel session
  MSESaveDocAs( MSECurDoc, AResFileName );

  if (MSEfAlwaysVisible in MSEGenFlags) or // AlwaysVisible debug Mode OR
     (rdfShowResDoc in MSEResDocFlags) then // Resulting document should remains opened
    MSEServer.Visible := True
  else if not MSEWasCreated then // IF MSEServer existed before call to MSEStartWorking
    MSEServer.Visible := MSEWasVisible
  else // MSEServer should be Closed
    MSEServer.Quit;

  MSEServer := Unassigned();
}
  end; // with MSExcelObj do

  MSExcelObj.Free;
end; // procedure N_CMExpStrMatrToExcel

//********************************************************* N_CMExpRepTest1 ***
// Export CMS Reports Test #1
//
procedure N_CMExpRepTest1();
var
  FName: string;
  Params: TN_GSSParams;
  StrMatr: TN_ASArray;
begin
  FName := K_ExpandFileName( '(#OutFiles#)' + 'aa1.xls' );
  with Params do
  begin
    GSSPMode     := 1;
    GSSPNumCols  := 3;
    GSSPNumRows  := 10;
    GSSPMinChars := 1;
    GSSPMaxChars := 50;

    N_NeededCodePage := 1251;
    N_NeededTextEncoding := N_UseBOMFlag + integer(teANSI); // teUTF8 teUTF16LE

    N_CreateSampleStrMatr( StrMatr, @Params );
//    N_SaveSMatrToFile2( StrMatr, FName, smfTab );
    N_SaveSMatrToFile2( StrMatr, FName, smfCSV );
  end; // with Params do
//type TN_StrMatrFormat = ( smfCSV, smfTab, smfClip, smfSpace1, smfSpace3 );
end; // procedure N_CMExpRepTest1

//********************************************************* N_CMExpRepTest2 ***
// Export CMS Reports Test #2
//
procedure N_CMExpRepTest2();
var
  FName1, FName2: string;
  SL: TStringList;
  Params: TN_GSSParams;
  StrMatr: TN_ASArray;
  MSWordObj: TN_MSWordObj;
begin
  with Params do
  begin
    GSSPMode     := 1;
    GSSPNumCols  := 8;
    GSSPNumRows  := 200;
    GSSPMinChars := 1;
    GSSPMaxChars := 50;

    N_CreateSampleStrMatr( StrMatr, @Params );
//    N_SaveSMatrToFile( StrMatr, K_ExpandFileName( '(#OutFiles#)' + 'Tab.txt' ), smfTab );

    SL := TStringList.Create;
    N_SaveSMatrToStrings( StrMatr, SL, smfTab );
    K_PutTextToClipboard( SL.Text, False ); // True means ANSI coding
    SL.Free;

//    Exit;
    MSWordObj := TN_MSWordObj.Create;
    MSWordObj.MSWGenFlags := [mswfAlwaysVisible]; // debug

    MSWordObj.MSWResDocFlags := [rdfSaveResDoc,rdfShowResDoc];

    if not MSWordObj.MSWStartWorking() then
      raise Exception.Create( 'MSWStartWorking failed!');

    MSWordObj.MSWCurDoc := MSWordObj.MSWServer.Documents.Add();
    MSWordObj.MSWCurDoc.PageSetup.Orientation := wdOrientLandscape;
    MSWordObj.MSWCurDoc.ShowGrammaticalErrors := True;
    MSWordObj.MSWCurDoc.ShowSpellingErrors := True;
    MSWordObj.MSWAddTableByStrMatr( MSWordObj.MSWCurDoc, StrMatr, N_CM_MainForm.CMMFShowString );
    MSWordObj.MSWCurTable.Range.Paste;

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'TabPat1.doc' );
    FName2 := ChangeFileExt( FName1, '_Res1.doc' );
    N_b := MSWordObj.MSWCloseDoc( FName2 ); // it could remains opened from the previous sesiion
    N_CreateFileCopy( FName1, FName2 );


//    MSWordObj.MSWMainDoc := MSWordObj.MSWOpenDoc( FName2, [odfVisible] );
    MSWordObj.MSWMainDoc := MSWordObj.MSWOpenDoc( FName2, [] );
    N_Dump2Strings( MSWordObj.MSWGetServerInfo( 2, 'Test #2' ), 4 );
//    MSWordObj.MSWMainDocFName := FName2;
    MSWordObj.MSWFinishWorking();
    MSWordObj.Free;
  end; // with Params do
end; // procedure N_CMExpRepTest2

//********************************************************* N_CMExpRepTest3 ***
// Export CMS Reports Test #3 - test N_CMExpStrMatrToWord function
//
procedure N_CMExpRepTest3();
var
  ResFName: string;
  Params: TN_GSSParams;
  StrMatr: TN_ASArray;
begin
  with Params do
  begin
    GSSPMode     := 1;
    GSSPNumCols  := 8;
    GSSPNumRows  := 200;
    GSSPMinChars := 1;
    GSSPMaxChars := 50;

    N_CreateSampleStrMatr( StrMatr, @Params );
//    N_SaveSMatrToFile( StrMatr, K_ExpandFileName( '(#OutFiles#)' + 'Tab.txt' ), smfTab );
  end; // with Params do

  ResFName := K_ExpandFileName( '(#OutFiles#)' + 'ZZRes1.doc' );
//  N_CMExpStrMatrToWord( StrMatr, ResFName, [esmfLandscape,esmfShowResFile] );
//  N_CMExpStrMatrToWord( StrMatr, ResFName, [esmfShowResFile] );
  N_CMExpStrMatrToWord( StrMatr, ResFName, [], nil );

end; // procedure N_CMExpRepTest3

//********************************************************* N_CMExpRepTest4 ***
// Export CMS Reports Test #4 - test N_CMExpStrMatrToExcel function
//
procedure N_CMExpRepTest4();
var
  ResFName: string;
  Params: TN_GSSParams;
  StrMatr: TN_ASArray;
  CFPArray: TN_CFPArray;
begin
  with Params do
  begin
    GSSPMode     := 1;
    GSSPNumCols  := 8;
    GSSPNumRows  := 200;
    GSSPMinChars := 1;
    GSSPMaxChars := 50;

    N_CreateSampleStrMatr( StrMatr, @Params );
//    N_SaveSMatrToFile( StrMatr, K_ExpandFileName( '(#OutFiles#)' + 'Tab.txt' ), smfTab );
  end; // with Params do

  ResFName := K_ExpandFileName( '(#OutFiles#)' + 'ZZRes1.doc' );
//  N_CMExpStrMatrToWord( StrMatr, ResFName, [esmfLandscape,esmfShowResFile] );
//  N_CMExpStrMatrToWord( StrMatr, ResFName, [esmfShowResFile] );

  CFPArray := N_CreateCFPArray( Params.GSSPNumCols, [] );
  N_CMExpStrMatrToExcel( StrMatr, ResFName, [], CFPArray );

end; // procedure N_CMExpRepTest4

//********************************************************* N_CMExpRepTest5 ***
// Export CMS Reports Test #5
//
procedure N_CMExpRepTest5();
var
  FName: string;
  Params: TN_GSSParams;
  StrMatr: TN_ASArray;
  FParams: TN_CFPArray;
  SL: TStringlist;
begin
  N_ws := '1Lÿ';
  N_s := String(UTF8Encode( N_ws ));

  Exit;

  FName := K_ExpandFileName( '(#OutFiles#)' + 'aa1.xls' );
  with Params do
  begin
    GSSPMode     := 1;
    GSSPNumCols  := 4;
    GSSPNumRows  := 7;
    GSSPMinChars := 1;
    GSSPMaxChars := 50;

    N_CreateSampleStrMatr( StrMatr, @Params );
    N_SaveSMatrToFile( StrMatr, FName, smfTab );

    SetLength( FParams, 4 );
    FParams[0].CFPFlags := [];
    FParams[0].CFPWidthCoef := 0;
    FParams[0].CFPMinChars := 0;
    FParams[1].CFPFlags := [cffHorAlignCenter];
    FParams[1].CFPWidthCoef := 0;
    FParams[1].CFPMinChars := 0;
    FParams[2].CFPFlags := [cffHorAlignRight];
    FParams[2].CFPWidthCoef := 0;
    FParams[2].CFPMinChars := 0;
    FParams[3].CFPFlags := [cffHorAlignRight];
    FParams[3].CFPWidthCoef := 0;
    FParams[3].CFPMinChars := 30;

    N_AlignStrMatr( StrMatr, FParams );
    SL := TStringlist.Create;
    N_StrMatrToStrings( StrMatr, SL, ' * ' );

    FName := K_ExpandFileName( '(#OutFiles#)' + 'aa1.txt' );
    SL.SaveToFile( FName );
    SL.Free;
  end; // with Params do
//type TN_StrMatrFormat = ( smfCSV, smfTab, smfClip, smfSpace1, smfSpace3 );
end; // procedure N_CMExpRepTest5

end.
