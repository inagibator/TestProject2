unit N_CMTst1;
// high level test procedures for CMS Project

interface

uses Windows, SysUtils, Classes, Graphics,
     K_RImage,
     N_Types, N_Gra0, N_Gra1, N_Lib0, N_Lib2, N_Comp1, N_Rast1Fr;

//****************** Global procedures **********************

  procedure N_CMSDebAction2Proc ();
  procedure N_CMSDebAction3Proc ( const ActionUNDOName : string );
  procedure N_CMSDebOption1Proc ( const ActionUNDOName : string );
  procedure N_CMSDebOption2Proc ( const ActionUNDOName : string );

  procedure N_TestRImage1  ();
  procedure N_TestImageLib ();

  //************* UDActions:
  procedure N_UDACreateMountsPattern1 ( APParams: TN_PCAction; AP1, AP2: Pointer );
  procedure N_UDACreateMountsPattern2 ( APParams: TN_PCAction; AP1, AP2: Pointer );
  procedure N_UDACreateMountsThumb    ( APParams: TN_PCAction; AP1, AP2: Pointer );

implementation
uses math, Forms, Clipbrd, Variants, StrUtils, IniFiles, Controls, imglist, StdCtrls,
  K_CLib0, K_UDT1, K_Script1, K_Parse, K_UDT2, K_CM0,
  N_Lib1, N_Gra2, N_Gra3, N_CompBase, N_CompCL, N_GCont, N_Tst1F, N_Tst2F, N_Tst1,
  N_ImLib, N_CMMain5F, N_CMTest2F;


//***************************************************** N_CMSDebAction2Proc ***
// Debug Action 2 - used in TN_CMResForm.aDebAction2Execute
//
procedure N_CMSDebAction2Proc();
//var
//  SGComp: TN_SGComp;
//  EdObjectsRFA: TK_CMEditObjRFA;
//  RFrame: TN_Rast1Frame;
//  MapRoot: TN_UDCompVis;
begin
  N_TstEnumResources();
  Exit;

  N_CreateCMTest2Form( nil ).ShowModal;
  Exit;

//  N_CreateCMTest1Form( nil ).ShowModal;
//  N_TestRImage1();
//  N_TestImageLib();

  with N_CreateTest2Form() do
  begin
    ShowModal();
  end;

  N_s1 := N_MemIniToString( 'FileGPaths', 'LogFiles', '!!' );
  N_s2 := N_MemIniToString( 'FileGPaths', 'Logfiles', '!!' );

  N_CM_MainForm.ScaleBy( 13, 10 );
  Exit;

  N_i := StrToInt( '$10' );
  N_d := 0;
  N_d := 1 / N_d; //to raise exception
{
  N_RFAClassRefs[N_ActEdCMSObjects] := TK_CMEditObjRFA; // Register Class Type

  RFrame := N_CM_MainForm.CMMFActiveEdFrame.RFrame;
  MapRoot := N_CM_MainForm.CMMFActiveEdFrame.EdSlide.GetMapRoot();

  SGComp := TN_SGComp.Create( RFrame ); // Search Group for searching Object points
  with SGComp do
  begin
    PixSearchSize := 8;
    SGFlags := $02; // search lines even out of UDPolyline and UDArc components

    SetLength( SComps, 3 );
    SComps[0].SComp := TN_UDCompVis(MapRoot.DirChild( 2 ));
    SComps[0].SFlags := 3;  // Search both vertexes and segments
    SComps[1].SComp := TN_UDCompVis(MapRoot.DirChild( 3 ));
    SComps[1].SFlags := 3;
    SComps[2].SComp := TN_UDCompVis(MapRoot.DirChild( 5 ));
    SComps[2].SFlags := 3;
  end;

  // Create RFrame Action and add it to Search Group SGComp
  EdObjectsRFA := TK_CMEditObjRFA( SGComp.SetAction( N_ActEdCMSObjects, 0, -1, 0 ) );

  with EdObjectsRFA do
  begin
    ActEnabled := True;
  end;

  RFrame.RFSGroups.Add( SGComp ); // Add SGComp to RFrame
}

{
// Create New Slide from TWAIN (debug implementation)
var
  BMPFName: string;
  ResBmp: TBitmap;
  NamesList: TStringList;
  Label Fin, Old;

  NamesList := nil; // to avoid warning

  with N_CM_MainForm do
  begin

  //*** TWAIN Initialization
  N_TWGlobObj := TN_TWGlobObj.Create( SaveAcquiredImages ); // SaveAcquiredImages is N_CMResForm method

  with N_TWGlobObj do
  begin
    TWGOpenDSManager();
    N_IAdd( Format( 'TWGOpenDSManager RetCode=%d', [TWGRetCode] ));
    if TWGRetCode <> 0 then goto Fin;

    NamesList := TStringList.Create;
    TWGGetDataSources( NamesList );

//    TWGOpenDataSource( '' );
    TWGOpenDataSource( '' );

    N_IAdd( Format( 'After Select RetCode=%d', [TWGRetCode] ));
    if TWGOpCanceled or (TWGRetCode <> 0) then goto Fin;

    TWGGetDIBs();
    N_IAdd( Format( 'TWGGetDIBs RetCode=%d', [TWGRetCode] ));
    if TWGRetCode <> 0 then goto Fin;
    NamesList.Free;
    Exit;

    Fin: //*** TWAIN Finalization
    N_TWGlobObj.Free;
    NamesList.Free;
    Exit;

  end; // with N_TWGlobObj do


  Old: //********************************************** OLD working version

  N_TWGlobObj := TN_TWGlobObj.Create( SaveAcquiredImages );

  TWOpenDSM( Application.Handle );
  TWSelectDS(); // Select Data Source
//  if N_TWGlobObj.TWGOpCanceled then goto Canceled;

  ResBmp := TBitmap.Create();
  ResBmp.Width := 30;
  ResBmp.Height := 10;
  ResBmp.PixelFormat := pf24bit;

  TWAcquire( Application.Handle, ResBmp, True ); // Start Acquiring

  BMPFName := K_ExpandFileName( '(#TmpFiles#)TWAIN.bmp' );
  ResBmp.SaveToFile( BMPFName );

  if TWIsDSEnabled then
    TWDisableDS;
  if TWIsDSOpen then
    TWCloseDS;
  if TWIsDSMOpen then
    TWCloseDSM;

  end; // with N_CM_MainForm do
}
end; // procedure N_CMSDebAction2Proc

procedure N_CMSDebAction3Proc( const ActionUNDOName : string );
// Debug Action 3
begin
  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin

    // Some Code which change Current Image DIBObj should be placed here
{ !!! Change DIB example
var
  NewDIB: TN_DIBObj;
    NewDIB := nil;
    DIBObj.CalcDeNoise1DIB( NewDIB, 5, 2.0/sqrt(2), 1.1, 1.1 );
    DIBObj.Free;
    DIBObj := NewDIB;
}
    DIBObj.DIBNumBits := 12;
    RebuildMapImageByDIB( DIBObj );
  //  Save UNDO State, Thumbnale and so on ...,
  // Slides Operation History code "Noise Redusction" is used
    CMMFFinishImageEditing( ActionUNDOName, [cmssfCurImgChanged] );

  end; // with N_CM_MainForm do

end; // procedure N_CMSDebAction3Proc

procedure N_CMSDebOption1Proc( const ActionUNDOName : string );
// Debug Option 1
//var
//  NewDIB: TN_DIBObj;
begin
  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin

    // Some Code which change Current Image DIBObj should be placed here
{ !!! Change DIB example
    NewDIB := nil;
    DIBObj.CalcDeNoise1DIB( NewDIB, 5, 2.0/sqrt(2), 1.1, 1.1 );
    DIBObj.Free;
    DIBObj := NewDIB;
}
    RebuildMapImageByDIB( DIBObj );
  //  Save UNDO State, Thumbnale and so on ...,
  // Slides Operation History code "Noise Redusction" is used
    CMMFFinishImageEditing( ActionUNDOName, [cmssfCurImgChanged] );

  end; // with N_CM_MainForm do

end; // procedure N_CMSDebOption1Proc

procedure N_CMSDebOption2Proc( const ActionUNDOName : string );
// Debug Option 2
//var
//  NewDIB: TN_DIBObj;
begin
  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin

    // Some Code which change Current Image DIBObj should be placed here
{ !!! Change DIB example
    NewDIB := nil;
    DIBObj.CalcDeNoise1DIB( NewDIB, 5, 2.0/sqrt(2), 1.1, 1.1 );
    DIBObj.Free;
    DIBObj := NewDIB;
}
    RebuildMapImageByDIB( DIBObj );
  //  Save UNDO State, Thumbnale and so on ...,
  // Slides Operation History code "Noise Redusction" is used
    CMMFFinishImageEditing( ActionUNDOName, [cmssfCurImgChanged] );

  end; // with N_CM_MainForm do

end; // procedure N_CMSDebOption2Proc

//*********************************************************** N_TestRImage1 ***
// TK_RasterImage class Tests #1
//
procedure N_TestRImage1();
var
  iInpName, iMode, iLib: integer;
  DIB1: TN_DIBObj;
  InpFName, OutExt: String;
  LogFName: AnsiString;
  FNames1, FNames2, FNames3: TStringList;
  Label FullTest;

  procedure TestOneOutExt( AInpFName, AOutFExt: String; AMode, ALib: integer ); // local
  // Test one AInpFName file with need Output Extension AOutFExt and AMode, ALib
  var
    OutFName: String;
  begin
    OutFName := ExtractFilePath( AInpFName ) + '!!!' +
                ExtractFileName( AInpFName ) +
                IntToStr(ALib) + IntToStr(AMode) +
                AOutFExt;

    N_Show1Str( 'Testing ' + InpFName );
    N_TestLoadDIB( DIB1, InpFName, AMode, ALib );
//    if DIB1 <> nil then DIB1.SaveToBMPFormat( OutFName + '.bmp' ); // for testing N_TestLoadDIB

    N_TestSaveDIB( DIB1, OutFName, AMode, ALib );
  end; // procedure TestOneOutExt - local

begin
  N_Show1Str( 'N_TestRImage1 Start' );
  DIB1 := nil;
  LogFName := AnsiString( K_ExpandFileName( '(#OutFiles#)' + 'ImLibLog.txt' ) );
  N_ImageLib.ILSetLogFileName( @LogFName[1] );

  goto FullTest;

  //***** Here: temporary one file test
  InpFName := K_ExpandFileName( '(#OutFiles#)' + 'ROSE_Color24.jpg' );
  TestOneOutExt( InpFName, '.jpg', 2, 1 );
  DIB1.Free;
  N_Show1Str( 'N_TestRImage1 Finished1' );
  Exit;

  FullTest: //**************************************
  FNames1 := TStringList.Create;
  FNames1.Add( K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_' ) );
  FNames1.Add( K_ExpandFileName( '(#OutFiles#)' + 'ROSE_' ) );

  FNames2 := TStringList.Create;
  for iInpName := 0 to FNames1.Count-1 do // along all Color Formats
  begin
    FNames2.Add( FNames1[iInpName] + 'Gray8' );
    FNames2.Add( FNames1[iInpName] + 'Gray16' );
    FNames2.Add( FNames1[iInpName] + 'Color8' );
    FNames2.Add( FNames1[iInpName] + 'Color24' );
  end; // for iInpName := 0 to FNames1.Count-1 do // along all Color Formats

  FNames3 := TStringList.Create;
  for iInpName := 0 to FNames2.Count-1 do // along all File Extentions
  begin
    FNames3.Add( FNames2[iInpName] + '.bmp' );
    FNames3.Add( FNames2[iInpName] + '.png' );
    FNames3.Add( FNames2[iInpName] + '.jpg' );
    FNames3.Add( FNames2[iInpName] + '.tif' );
  end; // for iInpName := 0 to FNames2.Count-1 do // along all File Extentions

  for iInpName := 0 to FNames3.Count-1 do // along all input Files
  begin
    InpFName := FNames3[iInpName];
    if not FileExists( InpFName ) then Continue;

    for iLib := 1 to 1 do // iLib: =0 - GDI+, =1 - ImageLibrary
    begin

      for iMode := 0 to 2 do // iMode: =0 - from File, =1 - from Stream, =2 - from Memory
      begin
        if (iMode = 2) and (iLib = 0) then Continue; // GDI+ does not support Memory Mode

//        OutExt := '.bmp';
        OutExt := ExtractFileExt( InpFName );
        TestOneOutExt( InpFName, OutExt, iMode, iLib );
      end; // for iMode = 0 to 2 do

    end; // for iLib := 1 to 1 do // iLib: =0 - GDI+, =1 - ImageLibrary

  end; // for iInpName := 0 to FNames3.Count-1 do // along all input Files

  N_Show1Str( 'N_TestRImage1 Finished2' );
end; // procedure N_TestRImage1

//********************************************************** N_TestImageLib ***
// Test N_ImageLib (ImageLibrary.dll functions)
//
procedure N_TestImageLib();
var
  FH1, FH2,RasterSize, FileSize, ResCode: Integer;
  FName1, FName2, FNPrefix, Suffix: String;
  LogFName: AnsiString;
  PBuf: Pointer;
  BArray: TN_BArray;
  DIBInfo1, DIBInfo2: TN_DIBInfo;
  DIBObj1, DIBObj2: TN_DIBObj;
  Label Fin;

  procedure CheckResCode( AErrName: String; AErrCode: Integer = -1234 );
  // Check AErrCode or ResCode variable and dump error if needed
  begin
    if AErrCode = -1234 then AErrCode := ResCode;

    if AErrCode < 0 then // Error occured
    begin
      N_Dump1Str( Format( 'ImLib Error %s,  %s%s ErrCode=%d',
                            [AErrName, FNPrefix, Suffix, AErrCode] ));
    end; // if ResCode < 0 then // Error occured
  end; // procedure CheckResCode - local

  procedure TestOneFile();
// Test FName1 file and create !xxN.bmp resulting files (xx is FNPrefix):
//   !xx1 - create DIB by old TN_DIBObj code (only for bmp, gif, jpg files)
//   !xx2 - create DIB by ILOpenFile
//   !xx3 - create DIB by ILOpenMemory
//   !xx4 - create File by ILCreateFile in BMP format
//   !xx5 - create File by ILCreateImageBuffer in BMP format
//   !xx6 - create File by ILCreateFile in PNG format
//   !xx7 - create File by ILCreateImageBuffer in PNG format
//   !xx8 - create File by ILCreateFile in JPG format
//   !xx9 - create File by ILCreateImageBuffer in JPG format
//
  var
    FileExt: String;
  begin

  with N_ImageLib do
  begin
    N_Dump1Str( '' );
    N_Dump1Str( '     Start testing ' +  FName1 );

    //***** !xx01 - create DIB by old TN_DIBObj code (for supported formats)
    Suffix := '01.bmp';
    FileExt := UpperCase( ExtractFileExt( FName1 ) );
    if (FileExt = '.BMP') or (FileExt = '.GIF') then // or (FileExt = '.JPG') then
    begin
     DIBObj2 := TN_DIBObj.Create( FName1 );

     with DIBObj2 do
     begin
       move( DIBInfo, DIBInfo2, SizeOf(DIBInfo2) );
       N_i2 := PByte(PRasterBytes)^;
       FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
       SaveToBMPFormat( FName2 );
     end;
     DIBObj2.Free;
     N_Dump1Str( 'File created ' + FName2 );
    end; // if (FileExt = '.BMP') or (FileExt = '.GIF') or (FileExt = '.JPG') then

    //***** !xx02 - create DIB by ILOpenFile
    Suffix := '02.bmp';
    FH1 := ILOpenFile( FName1 ); // Read from File
    CheckResCode( 'ILOpenFile', FH1 );
    ResCode := ILGetImagesCount( FH1 );
    CheckResCode( 'ILGetImagesCount' );
    ZeroMemory( @DIBInfo1, SizeOf(DIBInfo1) );
    DIBInfo1.bmi.biSize := SizeOf(DIBInfo1);
    ResCode := ILReadDIBInfo( FH1, 0, @DIBInfo1 );
    CheckResCode( 'ILReadDIBInfo' );

    DIBObj1 := TN_DIBObj.Create();
    with DIBObj1 do
    begin
      PrepEmptyDIBObj( @DIBInfo1, -1, epfAutoAny );

      if (DIBObj1.DIBExPixFmt = epfGray16) or (DIBObj1.DIBExPixFmt = epfColor48) then
        DIBObj1.DIBNumBits := 16;

      RasterSize := DIBSize.Y * RRLineSize;
      ResCode := ILReadPixels( FH1, 0, PRasterBytes, @RasterSize );
      CheckResCode( 'ILReadPixels' );
      N_i1 := PByte(PRasterBytes)^;
      FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
      SaveToBMPFormat( FName2 );
    end;
    ResCode := ILClose( FH1 );
    CheckResCode( 'ILClose' );
    DIBObj1.Free; //it will be created below again
    N_Dump1Str( 'File created ' + FName2 );

    //***** !xx03 - create DIB by ILOpenMemory
    Suffix := '03.bmp';
    FileSize := N_ReadBinFile( FName1, BArray ); // Read from Mem
    FH1 := ILOpenMemory( @BArray[0], FileSize );
    CheckResCode( 'ILOpenMemory', FH1 );
    ResCode := ILGetImagesCount( FH1 );
    CheckResCode( 'ILGetImagesCount' );
    ZeroMemory( @DIBInfo1, SizeOf(DIBInfo1) );
    DIBInfo1.bmi.biSize := SizeOf(DIBInfo1);
    ResCode := ILReadDIBInfo( FH1, 0, @DIBInfo1 );
    CheckResCode( 'ILReadDIBInfo' );

    DIBObj1 := TN_DIBObj.Create();
    with DIBObj1 do
    begin
      PrepEmptyDIBObj( @DIBInfo1, -1, epfAutoAny );

      if (DIBObj1.DIBExPixFmt = epfGray16) or (DIBObj1.DIBExPixFmt = epfColor48) then
        DIBObj1.DIBNumBits := 16;

      RasterSize := DIBSize.Y * RRLineSize;
      ResCode := ILReadPixels( FH1, 0, PRasterBytes, @RasterSize );
      CheckResCode( 'ILReadPixels' );
      FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
      SaveToBMPFormat( FName2 );
    end;
    ResCode := ILClose( FH1 );
    CheckResCode( 'ILClose' );
    N_Dump1Str( 'File created ' + FName2 );

    //***** !xx04 - create File by ILCreateFile in BMP format (for supported formats)
    if (DIBObj1.DIBExPixFmt <> epfGray16) and (DIBObj1.DIBExPixFmt <> epfColor48) then
    begin
      Suffix := '04.bmp';
      FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
      FH2 := ILCreateFile( FName2, N_ILFmtBMP ); // Write to File
      CheckResCode( 'ILCreateFile', FH2 );
      ResCode := ILWriteImage( FH2, @DIBInfo1, DIBObj1.PRasterBytes );
      CheckResCode( 'ILWriteImage' );
      ResCode := ILClose( FH2 );
      CheckResCode( 'ILClose' );
      N_Dump1Str( 'File created ' + FName2 );
    end; // if (DIBObj1.DIBExPixFmt <> epfGray16) and (DIBObj1.DIBExPixFmt <> epfColor48) then


    //***** !xx05 - created by ILCreateImageBuffer in BMP format (for supported formats)
    if (DIBObj1.DIBExPixFmt <> epfGray16) and (DIBObj1.DIBExPixFmt <> epfColor48) then
    begin
      Suffix := '05.bmp';
      FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
      FH2 := ILCreateImageBuffer( N_ILFmtBMP ); // Write to Mem
      CheckResCode( 'ILCreateImageBuffer', FH2 );
      ResCode := ILWriteImage( FH2, @DIBInfo1, DIBObj1.PRasterBytes );
      CheckResCode( 'ILWriteImage' );
      FileSize := ILGetImageBufferPtr( FH2, @PBuf ); // Write to Mem
      CheckResCode( 'ILGetImageBufferPtr', FileSize );
      N_WriteBinFile( FName2, PBuf, FileSize );      // Write to Mem
      ResCode := ILClose( FH2 );
      CheckResCode( 'ILClose' );
//      DIBObj2 := TN_DIBObj.Create( FName2 );
      N_Dump1Str( 'File created ' + FName2 );
    end; // if (DIBObj1.DIBExPixFmt <> epfGray16) and (DIBObj1.DIBExPixFmt <> epfColor48) then

    //***** !xx06 - created by ILCreateFile in PNG format
    Suffix := '06.png';
    FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
    FH2 := ILCreateFile( FName2, N_ILFmtPNG ); // Write to File
    CheckResCode( 'ILCreateFile', FH2 );
    ResCode := ILWriteImage( FH2, @DIBInfo1, DIBObj1.PRasterBytes );
    CheckResCode( 'ILWriteImage' );
    ResCode := ILClose( FH2 );
    CheckResCode( 'ILClose' );
    N_Dump1Str( 'File created ' + FName2 );

    //***** !xx07 - created by ILCreateImageBuffer in PNG format
    Suffix := '07.png';
    FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
    FH2 := ILCreateImageBuffer( N_ILFmtPNG ); // Write to Mem
    CheckResCode( 'ILCreateImageBuffer', FH2 );
    ResCode := ILWriteImage( FH2, @DIBInfo1, DIBObj1.PRasterBytes );
    FileSize := ILGetImageBufferPtr( FH2, @PBuf ); // Write to Mem
    CheckResCode( 'ILGetImageBufferPtr', FileSize );
    N_WriteBinFile( FName2, PBuf, FileSize );      // Write to Mem
    ResCode := ILClose( FH2 );
    CheckResCode( 'ILClose' );
    N_Dump1Str( 'File created ' + FName2 );

    //***** !xx08 - created by ILCreateFile in JPG format (for supported formats)
    if (DIBObj1.DIBExPixFmt <> epfGray16) and (DIBObj1.DIBExPixFmt <> epfColor48) then
    begin
      Suffix := '08.jpg';
      FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
      FH2 := ILCreateFile( FName2, N_ILFmtJPG ); // Write to File
      CheckResCode( 'ILCreateFile', FH2 );
      ResCode := ILWriteImage( FH2, @DIBInfo1, DIBObj1.PRasterBytes );
      CheckResCode( 'ILWriteImage' );
      ResCode := ILClose( FH2 );
      CheckResCode( 'ILClose' );
      N_Dump1Str( 'File created ' + FName2 );
    end; // if (DIBObj1.DIBExPixFmt <> epfGray16) and (DIBObj1.DIBExPixFmt <> epfColor48) then

    //***** !xx09 - created by ILCreateImageBuffer in PNG format
    if (DIBObj1.DIBExPixFmt <> epfGray16) and (DIBObj1.DIBExPixFmt <> epfColor48) then
    begin
      Suffix := '09.jpg';
      FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
      FH2 := ILCreateImageBuffer( N_ILFmtJPG ); // Write to Mem
      CheckResCode( 'ILCreateImageBuffer', FH2 );
      ResCode := ILWriteImage( FH2, @DIBInfo1, DIBObj1.PRasterBytes );
      FileSize := ILGetImageBufferPtr( FH2, @PBuf ); // Write to Mem
      CheckResCode( 'ILGetImageBufferPtr', FileSize );
      N_WriteBinFile( FName2, PBuf, FileSize );      // Write to Mem
      ResCode := ILClose( FH2 );
      CheckResCode( 'ILClose' );
      N_Dump1Str( 'File created ' + FName2 );
    end; // if (DIBObj1.DIBExPixFmt <> epfGray16) and (DIBObj1.DIBExPixFmt <> epfColor48) then

    //***** !xx10 - created by ILCreateFile in Tiff format (for supported formats)
    if (DIBObj1.DIBExPixFmt <> epfColor48) then
    begin
      Suffix := '10.tif';
      FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
      FH2 := ILCreateFile( FName2, N_ILFmtTIF ); // Write to File
      CheckResCode( 'ILCreateFile', FH2 );
      ResCode := ILWriteImage( FH2, @DIBInfo1, DIBObj1.PRasterBytes );
      CheckResCode( 'ILWriteImage' );
      ResCode := ILClose( FH2 );
      CheckResCode( 'ILClose' );
      N_Dump1Str( 'File created ' + FName2 );
    end; // if (DIBObj1.DIBExPixFmt <> epfColor48) then

    //***** !xx11 - created by ILCreateImageBuffer in Tiff format (for supported formats)
    if (DIBObj1.DIBExPixFmt <> epfColor48) then
    begin
      Suffix := '11.tif';
      FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + Suffix );
      FH2 := ILCreateImageBuffer( N_ILFmtTIF ); // Write to Mem
      CheckResCode( 'ILCreateImageBuffer', FH2 );
      ResCode := ILWriteImage( FH2, @DIBInfo1, DIBObj1.PRasterBytes );
      FileSize := ILGetImageBufferPtr( FH2, @PBuf ); // Write to Mem
      CheckResCode( 'ILGetImageBufferPtr', FileSize );
      N_WriteBinFile( FName2, PBuf, FileSize );      // Write to Mem
      ResCode := ILClose( FH2 );
      CheckResCode( 'ILClose' );
      N_Dump1Str( 'File created ' + FName2 );
    end; // if (DIBObj1.DIBExPixFmt <> epfColor48) then

  end; // with N_ImageLib do
  end; //  procedure TestOneFile - local

  procedure TestOneFile2();
// Create DIB by ILOpenFile and save  by ILCreateFile in BMP format
  begin

  with N_ImageLib do
  begin
    FH1 := ILOpenFile( FName1 ); // Read from File
    ZeroMemory( @DIBInfo1, SizeOf(DIBInfo1) );
    DIBInfo1.bmi.biSize := SizeOf(DIBInfo1);
    ResCode := ILReadDIBInfo( FH1, 0, @DIBInfo1 );

    DIBObj1 := TN_DIBObj.Create();
    with DIBObj1 do
    begin
      PrepEmptyDIBObj( @DIBInfo1, -1, epfAutoAny );
      RasterSize := DIBSize.Y * RRLineSize;
      ResCode := ILReadPixels( FH1, 0, PRasterBytes, @RasterSize );
    end;

    FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + 'File2a.bmp' );
    FH2 := ILCreateFile( FName2, N_ILFmtBMP ); // Write to File
    ResCode := ILWriteImage( FH2, @DIBInfo1, DIBObj1.PRasterBytes );
    ResCode := ILClose( FH2 );
    ResCode := ILClose( FH1 );
    DIBObj1.Free;
  end; // with N_ImageLib do
  end; //  procedure TestOneFile2 - local

  procedure TestTiff();
// Create Tiff with several images and read it
  begin

  with N_ImageLib do
  begin
    FNPrefix := 'multi.tif';
    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Gray8.tif' );

    FH1 := ILOpenFile( FName1 ); // Read from File
    ZeroMemory( @DIBInfo1, SizeOf(DIBInfo1) );
    DIBInfo1.bmi.biSize := SizeOf(DIBInfo1);
    ResCode := ILReadDIBInfo( FH1, 0, @DIBInfo1 );

    DIBObj1 := TN_DIBObj.Create();
    with DIBObj1 do
    begin
      PrepEmptyDIBObj( @DIBInfo1, -1, epfAutoAny );
      RasterSize := DIBSize.Y * RRLineSize;
      ResCode := ILReadPixels( FH1, 0, PRasterBytes, @RasterSize );
    end;

    FName2 := K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + 'File2a.bmp' );
    FH2 := ILCreateFile( FName2, N_ILFmtTIF ); // Write to File
    ResCode := ILWriteImage( FH2, @DIBInfo1, DIBObj1.PRasterBytes );
    ResCode := ILClose( FH2 );
    ResCode := ILClose( FH1 );
    DIBObj1.Free;
  end; // with N_ImageLib do
  end; //  procedure TestTiff - local

  procedure TestTmp1();
  // TN_DIBObj LoadFromFileByImLib and SaveToFileByImLib test
  begin
    DIBObj1 := nil;

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Gray8.tif' );
    N_LoadDIBFromFileByImLib( DIBObj1, FName1 );

    FName2 := K_ExpandFileName( '(#OutFiles#)' + '!!!DIBObj' + 'File1.tif' );
    DIBObj1.SaveToBMPFormat( FName2 + '.bmp' );
    N_SaveDIBToFileByImLib( DIBObj1, FName2 );
    FName2 := K_ExpandFileName( '(#OutFiles#)' + '!!!DIBObj' + 'File2.png' );
    N_SaveDIBToFileByImLib( DIBObj1, FName2 );

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Gray16.tif' );
    N_LoadDIBFromFileByImLib( DIBObj1, FName1 );

    FName2 := K_ExpandFileName( '(#OutFiles#)' + '!!!DIBObj' + 'File3.tif' );
    DIBObj1.SaveToBMPFormat( FName2 + '.bmp' );
    N_SaveDIBToFileByImLib( DIBObj1, FName2 );
    FName2 := K_ExpandFileName( '(#OutFiles#)' + '!!!DIBObj' + 'File4.png' );
    N_SaveDIBToFileByImLib( DIBObj1, FName2 );

    DIBObj1.Free;
  end; //  procedure TestTmp1 - local

begin //*************************************** main body of N_TestImageLib
  N_Dump1Str( '' );
  N_Dump1Str( '***** Start N_TestImageLib' );

  with N_ImageLib do
  begin
    ResCode := ILInitAll();
    if ResCode <> 0 then Exit;
    Screen.Cursor := crHourglass;
    LogFName := AnsiString( K_ExpandFileName( '(#OutFiles#)' + 'ImLibLog.txt' ) );
    ILSetLogFileName( @LogFName[1] );

//    TestTiff();
    TestTmp1();
    goto Fin;

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Gray16.tif' );
    FNPrefix := 'ANIMAL_Gray16.tif';
    TestOneFile();

    goto Fin;


    //***** NOT Passed tests:

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ROSE_Color24.tif' );
    FNPrefix := 'ROSE_Color24.tif';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Color8.tif' );
    FNPrefix := 'ANIMAL_Color8.tif';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Gray16.tif' );
    FNPrefix := 'ANIMAL_Gray16.tif';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Gray8.tif' );
    FNPrefix := 'ANIMAL_Gray8.tif'; // error while saving as png or jpg
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Color48.png' );
    FNPrefix := 'ANIMAL_Color48.png'; // неправильные сдвиги
    TestOneFile();

    //***** Passed tests:

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Gray8.bmp' );
    FNPrefix := 'ANIMAL_Gray8.bmp';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Gray8.png' );
    FNPrefix := 'ANIMAL_Gray8.png'; // error while saving as png or jpg
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Color8.bmp' );
    FNPrefix := 'ANIMAL_Color8.bmp';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Color8.png' );
    FNPrefix := 'ANIMAL_Color8.png';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL_Gray16.png' );
    FNPrefix := 'ANIMAL_Gray16.png';
    TestOneFile();


    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ROSE_Gray8.bmp' );
    FNPrefix := 'ROSE_Gray8.bmp';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ROSE_Gray8.png' );
    FNPrefix := 'ROSE_Gray8.png';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ROSE_Gray16.png' );
    FNPrefix := 'ROSE_Gray16.png';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ROSE_Color24.bmp' );
    FNPrefix := 'ROSE_Color24.bmp';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ROSE_Color24.png' );
    FNPrefix := 'ROSE_Color24.png';
    TestOneFile();

    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ROSE_Color24.jpg' );
    FNPrefix := 'ROSE_Color24.jpg';
    TestOneFile();

    //***** End of Passed tests

//    FName1 := K_ExpandFileName( '(#OutFiles#)' + '!aa1.BMP' );
//    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ANIMAL.BMP' );
//    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'AnimalRev.bmp' );
//    FName1 := K_ExpandFileName( '(#OutFiles#)' + 'ROSE.bmp' );
//    DIBObj2 := TN_DIBObj.Create( FName1 );
//    DIBObj2.DIBInfo.bmi.biHeight := -DIBObj2.DIBInfo.bmi.biHeight; // for creating bmp with negative biHeight)
//    DIBObj2.SaveToBMPFormat( K_ExpandFileName( '(#OutFiles#)' + '!aaNegbiHeight.bmp' ) );
//    DIBObj2.DIBInfo.bmi.biHeight := -DIBObj2.DIBInfo.bmi.biHeight;
//    DIBObj2.CopyRectBy2SM( Point(330,10), DIBObj2, Rect(200,100,300,200) ); // CopyRectBy2SM test
//    DIBObj2.SaveToBMPFormat( K_ExpandFileName( '(#OutFiles#)' + '!' + FNPrefix + '7.bmp' ) );
//    Exit;


    Fin: //***********
    ILFreeAll();
//    N_CM_MainForm.CMMFShowStringByTimer( 'N_TestImageLib Finished' );

  Screen.Cursor := crDefault;
  N_Dump1Str( '***** Finish N_TestImageLib' );
  N_Dump1Str( '' );

  end; // with N_ImageLib do

end; // procedure N_TestImageLib();


  //************* UDActions:

procedure N_UDACreateMountsPattern1( APParams: TN_PCAction; AP1, AP2: Pointer );
// Create Mounts Pattern by given Pattern with one Item (Variant #1):
// CAUDBase1  - Source Mounts Pattern Root with one Child - Mounts Item Root
// CAParStr1  - NX NY (Number of Mounts Items along X Y)
// CAIRect    - dxOut(Left) dyOut(Top) dxIn(Right) dyIn(Bottom) - Gaps between Mounts Items
//              ( OuterGapsWidth, OuterGapsHeight, InnerGapsWidth, InnerGapsHeight )
//
// (for using in TN_UDAction under Action Name CreateMountsPattern )
var
  ix, iy, ind, NMPRInd: integer;
  NX, NY: integer;
  ITemWidth, ItemHeight: Float;
  Str1: String;
  MainParent, NMPR, SMPIR, NMPIR: TN_UDBase;
begin
  with APParams^ do
  begin
    Str1 := CAParStr1;
    NX   := N_ScanInteger( Str1 ); // Number of Mounts Items along X
    NY   := N_ScanInteger( Str1 ); // Number of Mounts Items along Y

    //***** CAUDBase1 - Source Mounts Pattern Root
    NMPR  := CAUDBase1.Clone( True ); // New Mounts Pattern Root
    SMPIR := CAUDBase1.DirChild( 0 ); // Source Mounts Pattern Item Root

    with TN_UDCompVis(SMPIR).PCCS()^ do // Get Mounts Pattern Items Size in Pixels
    begin
      ITemWidth  := SRSize.X;
      ITemHeight := SRSize.Y;
    end; // with TN_UDCompVis(NPR).PCCS()^ do // Set New Pattern Root Size in Pixels

    MainParent := CAUDBase1.Owner; // Source and New Mounts Pattern Roots Parent
    NMPR.ObjName := N_CreateUniqueUObjName( MainParent, CAUDBase1.ObjName );
    NMPRInd := MainParent.InsertOneChildAfter( CAUDBase1, NMPR ); // insert NPR just after CAUDBase1

    with TN_UDCompVis(NMPR).PCCS()^ do // Set New Mounts Pattern Root Size in Pixels
    begin
      SRSize.X := NX*ITemWidth  + (NX-1)*CAIRect.Right  + 2*CAIRect.Left;
      SRSize.Y := NY*ItemHeight + (NY-1)*CAIRect.Bottom + 2*CAIRect.Top;
    end; // with TN_UDCompVis(NMPR).PCCS()^ do // Set New Mounts Pattern Root Size in Pixels

    for iy := 0 to NY-1 do // along all Slides Rows
    for ix := 0 to NX-1 do // along all Slides in Row
    begin
      NMPIR := N_CreateSubTreeClone( SMPIR ); // New Mounts Pattern Item Root
      ind := iy*NX + ix;
      NMPIR.ObjName := SMPIR.ObjName + IntToStr( ind );
      NMPR.AddOneChildV( NMPIR );

      with TN_UDCompVis(NMPIR).PCCS()^ do // Set New Item TopLeft in Pixels
      begin
        BPCoords.X := CAIRect.Left + ix*( ITemWidth  + CAIRect.Right  );
        BPCoords.Y := CAIRect.Top  + iy*( ItemHeight + CAIRect.Bottom );
      end; // with TN_UDCompVis(NMPIR).PCCS()^ do // Set New Item TopLeft in Pixels

    end; // for ix ... ; for iy ...

    MainParent.AddChildVNodes( NMPRInd );
    K_SetChangeSubTreeFlags( MainParent );

  end; // with APParams^ do
end; // procedure N_UDACreateMountsPattern1

procedure N_UDACreateMountsPattern2( APParams: TN_PCAction; AP1, AP2: Pointer );
// Create Mounts Pattern by given Pattern with one Item (Variant #2, using N_LayoutIRects1):
//
// CAUDBase1  - Source Study Sample with one Child - Mounts Item Root
// CAUDBase2  - Root for Resulting Study Sample
// CAUDBase3  - Root for UDDIBs ased as Items Images
// CAParStr1  - NX NY (Number of Mounts Items along X Y)
// CAParStr2  - ItemName
// CAIRect    - dxOut(Left) dyOut(Top) dxIn(Right) dyIn(Bottom) - Gaps between Mounts Items
//              ( OuterGapsWidth, OuterGapsHeight, InnerGapsWidth, InnerGapsHeight )
//
// (for using in TN_UDAction under Action Name CreateMountsPattern2 )
//
var
  ind, ir: integer;
  ItemName: String;
  MainParent, NMPR, SMPIR, NMPIR, Thumbnail, WrkUDBase, UDDIB: TN_UDBase;
  UDParaBox : TN_UDParaBox;
  ItemsRects: TN_SIRSArray;
begin
  with APParams^ do
  begin
    N_LayoutIRects1( CAStrArray, ItemsRects );

    //***** CAUDBase1 - Source Study Sample Root
//    NMPR  := CAUDBase1.Clone( True ); // New Study Sample Root

    NMPR := N_CreateSubTreeClone( CAUDBase1 );
    SMPIR := NMPR.DirChild( 0 ); // Source Study Item Sample Root

    with TN_UDCompVis(NMPR).PCCS()^ do // Set New Mounts Pattern Root Size in Pixels
      SRSize := FPoint( ItemsRects[0].IRS.Size );

    ind := 0;
    ItemName := CAParStr2;
    if ItemName = '' then
      ItemName := SMPIR.ObjName;
    K_UDCursorGet('@Tmp:').SetRoot( NMPR ); // Needed to Correct References from Item to MapRoot

    for ir := 1 to High(ItemsRects) do // along all Items Rects
    begin
      NMPR.RefPath := '@Tmp:';
      NMPIR := N_CreateSubTreeClone( SMPIR ); // New Mounts Pattern Item Root
      NMPIR.ObjALiase := ItemName + IntToStr( ind );
      NMPIR.ObjName := IntToStr( ind );

      // Set Item Index text
      UDParaBox := TN_UDParaBox( NMPIR.DirChild(0).DirChild(2) );
      with UDParaBox.PISP()^ do
        TN_POneTextBlock(CPBTextBlocks.P).OTBMText := IntToStr( ind + 1 );

      NMPR.AddOneChildV( NMPIR );

      with TN_UDCompVis(NMPIR).PCCS()^ do // Set New Item TopLeft in Pixels
      begin
        BPCoords := FPoint( ItemsRects[ir].IRS.TopLeft );
        SRSize   := FPoint( ItemsRects[ir].IRS.Size );
      end; // with TN_UDCompVis(NMPIR).PCCS()^ do // Set New Item TopLeft in Pixels

      if ItemsRects[ir].Str <> '' then // Set Item Image
      begin
        WrkUDBase := NMPIR.DirChild(0).DirChild(0);
        UDDIB := N_GetUObjByPath( CAUDBase3, ItemsRects[ir].Str );
        WrkUDBase.PutDirChildSafe( 0, UDDIB );
      end; // if ItemsRects[ir].Str <> '' then // Set Item Image

      Inc( ind );
    end; // for ir := 1 to High(ItemsRects) do // along all Items Rects

    MainParent := CAUDBase2; // Source and New Mounts Pattern Roots Parent
    MainParent.ClearChilds();
   // Add New Sample MapRoot
//    NMPR.ObjName := N_CreateUniqueUObjName( MainParent, CAUDBase1.ObjName );
    MainParent.AddOneChildV( NMPR ); // NPR

    // Remove Source Study Item Sample Root
    NMPR.RemoveDirEntry(0);
   // Add New Sample Thumbnail
    Thumbnail := K_CMBSlideCreateThumbnailUDDIB( K_CMBStudyCreateThumbnailDIBByMapRoot( TN_UDCompVis(NMPR) ) );
    MainParent.InsOneChild( 0, Thumbnail);
    MainParent.AddChildVNodes( 0 );

    K_SetChangeSubTreeFlags( MainParent );

  end; // with APParams^ do
end; // procedure N_UDACreateMountsPattern2

procedure N_UDACreateMountsThumb( APParams: TN_PCAction; AP1, AP2: Pointer );
// Create UDDIB Thumbnail for using in Mounts Pattern by given UDDIB Thumbnail:
// CAUDBase1  - given UDDIB Thumbnail (only CAUDBase1.DIBObj field is used)
//
// (for using in TN_UDAction under Action Name CreateMountsThumb )
var
  Ind: integer;
  NewThumb: TN_UDDIB;
  NewThumbParent: TN_UDBase;
begin
  with APParams^ do
  begin
    NewThumb := N_CreateUDDIB( FRect(0,0,100,100), [], '', 'MountsThumb' );
    NewThumb.DIBObj := TN_DIBObj.Create( TN_UDDIB(CAUDBase1).DIBObj ); // just copy DIBObj

    with NewThumb.PCCS()^ do // set coords related fields needed for showing Thumb in Mounts Item
    begin
      SRSizeAspect  := -3; // means using self DIBObj Aspect
      SRSizeAspType := catGiven; // Aspect is given in SRSizeAspect field
      CurFreeFlags  := [cffFullAspSize]; // use CurFreeRect and preserve given Aspect
    end;

    NewThumbParent := CAUDBase1.Owner;
    Ind := NewThumbParent.InsertOneChildAfter( CAUDBase1, NewThumb ); // insert NewThumb just after CAUDBase1
    NewThumbParent.AddChildVNodes( Ind );
    K_SetChangeSubTreeFlags( NewThumb );
  end; // with APParams^ do
end; // procedure N_UDACreateMountsThumb

Initialization

  N_RegActionProc( 'CreateMountsPattern1', N_UDACreateMountsPattern1 ); // Create Mounts Pattern #1
  N_RegActionProc( 'CreateMountsPattern2', N_UDACreateMountsPattern2 ); // Create Mounts Pattern #2
  N_RegActionProc( 'CreateMountsThumb',    N_UDACreateMountsThumb );    // Create Mounts UDDIB Thumbnail

end.
