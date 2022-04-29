unit N_CMTest2F;
// CMS Testing Form #2

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, OleServer, ToolWin, ImgList, ExtCtrls, Menus,
  GDIPAPI, GDIPOBJ,
  K_CM0,
  N_Types, N_Lib1, N_BaseF, N_Gra0, N_Gra1, N_Gra2, N_FNameFr;

type TN_CMTest2Form = class( TN_BaseForm )
    StatusBar: TStatusBar;
    bnCreateNewSlide: TButton;
    bnChangeAndShow: TButton;
    bnSaveImage: TButton;
    bnStartChanging: TButton;
    bnTest1: TButton;
    bnSetShortCut: TButton;
    edShortCut: TEdit;
    frFName: TN_FileNameFrame;
    bnConvertFiles: TButton;
    Button1: TButton;
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
    procedure bnCreateNewSlideClick ( Sender: TObject );
    procedure bnStartChangingClick  ( Sender: TObject );
    procedure bnChangeAndShowClick  ( Sender: TObject );
    procedure bnSaveImageClick      ( Sender: TObject );
    procedure bnTest1Click          ( Sender: TObject );
    procedure bnConvertFiles1Click   ( Sender: TObject );
    procedure bnConvertFiles2Click   ( Sender: TObject );
    procedure FormActivate          ( Sender: TObject ); override;
    procedure FormHide              ( Sender: TObject );
    procedure MyKeyDown ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure bnSetShortCutClick(Sender: TObject);
  public
    CMT2EditingImage: TN_DIBObj;
    CMT2EditingSlide: TN_UDCMSlide;

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMTest2Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

function  N_CreateCMTest2Form ( AOwner: TN_BaseForm ): TN_CMTest2Form;


implementation
uses
  Contnrs,
  N_Lib0, N_CMMain5F, N_EdParF;

{$R *.dfm}

//****************  TN_CMTest2Form class handlers  ******************

//************************************************ TN_CMTest2Form.FormClose ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TN_CMTest2Form.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
  CMT2EditingImage.Free;
end; // procedure TN_CMTest2Form.FormClose

//************************************ TN_CMTest2Form.bnCreateNewSlideClick ***
// Create new Slide and show it in Actvie Ed3Frame
//
procedure TN_CMTest2Form.bnCreateNewSlideClick( Sender: TObject );
var
  FileName: string;
  LoadedImage : TN_DIBObj;
  FSlide: TN_UDCMSlide;
  FDT: TDateTime;
begin
  FileName := N_GetFNameFromHist( 'Choose File Name', '*.*', 'CMTest2Form', 500 );

  LoadedImage := TN_DIBObj.Create( FileName );

  // Create Slide from DIBObj
  FSlide := K_CMSlideCreateFromDIBObj( LoadedImage, nil );

  // Init Some Slide Fields
  with FSlide.P()^ do
  begin
    CMSSourceDescr := ExtractFileName(FileName);
{$IF SizeOf(Char) = 2} // Wide Chars (Delphi 2010) Types and constants
    FileAge(FileName, FDT);
{$ELSE} // *************** Ansi Chars (Delphi 7) Types and constants
    FDT := FileDateToDateTime(FileAge(FileName));
{$IFEND}
    CMSDTTaken := FDT;
  end; // with FSlide.P()^ do

  // Finish Slide Creation
  K_CMEDAccess.EDAAddSlide(FSlide);
  K_CMEDAccess.EDASaveSlidesArray( @FSlide, 1 );

  // Rebuild Slides Thumbnales View
  N_CM_MainForm.CMMFRebuildVisSlides();

  // Open Loaded Image
  K_CMSMediaOpen( @FSlide, 1 );

  // Refresh CMS GUI Actions context
  N_CM_MainForm.CMMFDisableActions( nil );

  // Clear Form Editing Context
  FreeAndNil(CMT2EditingImage);
  CMT2EditingSlide := nil;

end; // procedure TN_CMTest2Form.bnCreateNewSlideClick

//************************************* TN_CMTest2Form.bnStartChangingClick ***
// Start Changing Image in Active Ed3Frame
//
procedure TN_CMTest2Form.bnStartChangingClick( Sender: TObject );
begin
  if not N_CM_MainForm.CMMFCheckBSlideExisting() then
  begin
    K_CMShowMessageDlg( 'Slide is not selected!', mtWarning );
    Exit;
  end;

// Create Current Image DIBObj Copy for Future changing
  CMT2EditingSlide := N_CM_MainForm.CMMFActiveEdFrame.EdSlide;

  CMT2EditingImage.Free;
  CMT2EditingImage := TN_DIBObj.Create( CMT2EditingSlide.GetCurrentImage().DIBObj );
end; // procedure TN_CMTest2Form.bnStartChangingClick

//************************************* TN_CMTest2Form.bnChangeAndShowClick ***
// Change Image (CMT2EditingImage) and show it in Active Ed3Frame
//
procedure TN_CMTest2Form.bnChangeAndShowClick( Sender: TObject );
begin

  if not N_CM_MainForm.CMMFCheckBSlideExisting() or (CMT2EditingImage = nil) then
  begin
    K_CMShowMessageDlg( 'Nothing to change!', mtWarning );
    Exit;
  end;

  if CMT2EditingSlide <> N_CM_MainForm.CMMFActiveEdFrame.EdSlide then
    bnStartChangingClick( Sender ); // Slide was changed - start new

 // Change CMT2EditingImage Object
 // ...
 // ...
 // ...
 // For example:
    CMT2EditingImage.XORPixels( $00333333 );

  with N_CM_MainForm.CMMFActiveEdFrame do // Show changed CMT2EditingImage Object
  begin
    EdSlide.RebuildMapImageByDIB( CMT2EditingImage );
    RFrame.RedrawAllAndShow();
  end;
end; // procedure TN_CMTest2Form.bnChangeAndShowClick

//***************************************** TN_CMTest2Form.bnSaveImageClick ***
// Change Image (CMT2EditingImage) in Active Ed3Frame
//
procedure TN_CMTest2Form.bnSaveImageClick( Sender: TObject );
begin
  if CMT2EditingImage = nil then
  begin
    K_CMShowMessageDlg( 'Nothing to save!', mtWarning );
    Exit;
  end;

  if not N_CM_MainForm.CMMFCheckBSlideExisting() or
     (CMT2EditingSlide <> N_CM_MainForm.CMMFActiveEdFrame.EdSlide) then
  begin
    K_CMShowMessageDlg( 'Current state is not actual! Nothing to save!', mtWarning );
    // Clear Form Editing Context
    FreeAndNil(CMT2EditingImage);
    CMT2EditingSlide := nil;
    Exit;
  end;

  // Store Changed Image to Slide
  with N_CM_MainForm.CMMFActiveEdFrame.EdSlide.GetCurrentImage() do begin
    DIBObj.Free;                // Free Slide Image
    DIBObj := CMT2EditingImage; // Put Editing Image to Slide
  end;

  // Save Slide and create undo state
  N_CM_MainForm.CMMFFinishImageEditing( 'Test Image Change', [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActUFilter) ) );

  // Clear Form Editing Context
  CMT2EditingImage := nil;
  CMT2EditingSlide := nil;
end; // procedure TN_CMTest2Form.bnSaveImageClick

procedure TN_CMTest2Form.bnTest1Click( Sender: TObject );
var
  i1, i2, i3: Integer;
  b1, b2: Byte;
  NE1, NE2: TNotifyEvent;
  d1, d2: double;
  p1, p2: Pointer;
  i64, ia64, ib64: Int64;

  procedure Dump8Bytes( APrefix: String; APtr: Pointer; APostfix: String = '' ); // local
  var
    i1, i2: Integer;
  begin
    Move( APtr^, i1, 4 );
    Move( (TN_BytesPtr(APtr)+4)^, i2, 4 );
    N_Dump1Str( Format( '%s %8X %8X %s', [APrefix, i1, i2, APostfix] ) );
  end; // procedure Dump8Bytes - local

  procedure PasPar ( ANE: TNotifyEvent ); // - local
  var
    i1: Integer;
    net1: TNotifyEvent;
  begin
    net1 := Self.FormActivate;

    i1 := Integer(CompareMem( @@net1, @@ANE, SizeOf(TNotifyEvent) ));
    N_Dump1Str( Format( '  CompareMem( @@net1, @@ANE, SizeOf(TNotifyEvent) ) = %d', [i1] ) );

{$IF CompilerVersion < 26.0} // Delphi < XE5
  // In Delphi XE5, XE6 ( @NE1 = @NE2 ) causes Syntax error: Incompatible types
    i1 := Integer( @net1 = @ANE );
    N_Dump1Str( Format( '  ( @net1 = @ANE )                                  = %d', [i1] ) );

    i1 := Integer( @net1 = @ANE );
    N_Dump1Str( Format( '  ( @Self.FormActivate = @ANE )                     = %d', [i1] ) );
{$IFEND CompilerVersion < 26.0}

    //***** CompareMem( @net1, @ANE, SizeOf(TNotifyEvent) ) is an error:
    //      in Delphi XE5 Delphi XE5
    //      in Delphi 7 and 2010 - returns True even for different net1 and ANE

{$IF CompilerVersion >= 26.0} // Delphi >= XE5
    i1 := 2;
{$ELSE}
    i1 := Integer(CompareMem( @net1, @ANE, SizeOf(TNotifyEvent) )); // Syntax error in Delphi XE5
{$IFEND CompilerVersion >= 26.0}
    N_Dump1Str( Format( '  CompareMem(  @net1,  @ANE, SizeOf(TNotifyEvent) ) = %d - (not correct in some cases!!!)', [i1] ) );

  end; // procedure PasPar - local

begin
  //*********** Test Method ob Object Comparing code
  N_Dump1Str( '' );
  N_Dump1Str( '********** Compiled by ' + N_DelphiVersion() );

  @NE1 := nil;
  Dump8Bytes( 'after @NE1 := nil               - ', @@NE1 );
  NE1 := Self.FormActivate;
  Dump8Bytes( 'NE1 := Self.FormActivate @@NE1  - ', @@NE1, '(@method, @Self)' );
  NE1( nil );

  NE2 := Self.FormHide;
  Dump8Bytes( 'NE2 := Self.FormHide @@NE2      - ', @@NE2, '(@method, @Self)' );
  NE2( nil );
  N_Dump1Str( '' );

  // i1 := SizeOf(Self.FormActivate);   - not allowed, not enough actual parameters
  // i1 := SizeOf(@Self.FormActivate);  - not allowed, variable required
  // i1 := SizeOf(@@Self.FormActivate); - not allowed, variable required
  // i1 := SizeOf(NE2);                 - not allowed, not enough actual parameters
  // i1 := integer( NE1 = NE2 );        - not allowed, not enough actual parameters

  //***** Error in Delphi 7 and 2010 - SizeOf(@NE2)=4 !
  i1 := SizeOf(@NE2);
  i2 := SizeOf(@@NE2);
  i3 := SizeOf(TNotifyEvent);
  N_Dump1Str( Format( 'SizeOf(@NE2)=%d (should be 8!!!), SizeOf(@@NE2)=%d, SizeOf(TNotifyEvent)=%d', [i1, i2, i3] ) );

  //  i1 := integer( @NE1 = @Self.FormHide );  - not allowed, variable required
{$IF CompilerVersion < 26.0} // Delphi < XE5
  // In Delphi XE5,XE6 ( @NE1 = @NE2 ) causes Syntax error: Incompatible types
  i1 := integer( @NE1 = @NE2 );
  NE2 := Self.FormActivate;
  i2 := integer( @NE1 = @NE2 );
  N_Dump1Str( Format( '@NE1 = @NE2, Should be 0,1: %d,%d', [i1, i2] ) );
  NE2 := Self.FormHide; // restore
{$IFEND CompilerVersion < 26.0}
  N_Dump1Str( '' );

  p1 := TMethod(NE1).Code;
  p2 := TMethod(NE1).Data;
  N_Dump1Str( Format( 'TMethod(NE1).Code = %8X, TMethod(NE1).Data = %8X', [DWORD(p1), DWORD(p2)] ) );
  p1 := TMethod(NE2).Code;
  p2 := TMethod(NE2).Data;
  N_Dump1Str( Format( 'TMethod(NE2).Code = %8X, TMethod(NE2).Data = %8X', [DWORD(p1), DWORD(p2)] ) );
  N_Dump1Str( '' );

  i64 := -2;
  Dump8Bytes( 'i64 := -2                       - ', @i64, '(low high)' );
  ia64 := int64(@NE1);
  Dump8Bytes( 'ia64 := int64(@NE1)             - ', @ia64, '(only first DWORD is OK!!!)' );
  ib64 := int64(@@NE1);
  Dump8Bytes( 'ib64 := int64(@@NE1)            - ', @ib64, '(only first DWORD is OK!!!)' );
  N_Dump1Str( '' );

{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  p1 := nil;
{$ELSE}
  p1 := Pointer( @NE1 ); // Internal Compiler error in Delphi XE5
{$IFEND CompilerVersion >= 26.0}

  Dump8Bytes( 'p1 := Pointer( @NE1 )           - ', @p1, '(@method, DWORD after p1)' );
  p2 := Pointer( @@NE1 );
  Dump8Bytes( 'p2 := Pointer( @@NE1 )          - ', @p2, '(adr of NE1 var, after p2 is p1 content )' );
  p1 := TN_BytesPtr(p2) + 4;
  Dump8Bytes( 'p1 := TN_BytesPtr(p2) + 4       - ', p1,  '(@Self, DWORD after NE1)' );
  N_Dump1Str( '' );

{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  p1 := nil;
{$ELSE}
  p1 := Pointer( @NE2 ); // Internal Compiler error in Delphi XE5
{$IFEND CompilerVersion >= 26.0}

  Dump8Bytes( 'p1 := Pointer( @NE2 )           - ', @p1, '(@method, DWORD after p1)' );
  p2 := Pointer( @@NE2 );
  Dump8Bytes( 'p2 := Pointer( @@NE2 )          - ', @p2, '(adr of NE2 var, after p2 is p1 content )' );
  p1 := TN_BytesPtr(p2) + 4;
  Dump8Bytes( 'p1 := TN_BytesPtr(p2) + 4       - ', p1,  '(@Self, DWORD after NE2)' );
  N_Dump1Str( '' );

  p1 := Pointer( Self );
  Dump8Bytes( 'p1 := Pointer( Self )           - ', @p1, '(@Self, DWORD after p1)' );
  p2 := Pointer( @Self );
  Dump8Bytes( 'p2 := Pointer( @Self )          - ', @p2, '(adr of Self var, after p2 is p1 content )' );
  N_Dump1Str( '' );

  p1 := Pointer( @b1 );
  Dump8Bytes( 'p1 := Pointer( @b1 )            - ', @p1, '(adr of b1 var, DWORD after p1 )' );
  p2:= Pointer( @b2);
  Dump8Bytes( 'p2 := Pointer( @b2 )            - ', @p2, '(adr of b2 var, DWORD after p2 is p1 content )' );

  p1 := Pointer( @d1 );
  Dump8Bytes( 'p1 := Pointer( @d1 )            - ', @p1, '(adr of d1 var, DWORD after p1 )' );
  p2:= Pointer( @d2);
  Dump8Bytes( 'p2 := Pointer( @d2 )            - ', @p2, '(adr of d2 var, DWORD after p2 is p1 content )' );

  i1 := Integer(CompareMem( @@NE1, @@NE2, SizeOf(TNotifyEvent) ));
  NE2 := Self.FormActivate;
  i2 := Integer(CompareMem( @@NE1, @@NE2, SizeOf(TNotifyEvent) ));
  N_Dump1Str( Format( 'i1=%d, i2=%d', [i1, i2] ) );
  N_Dump1Str( '' );

  N_Dump1Str( 'Should be 1:' );
  PasPar( Self.FormActivate );
  N_Dump1Str( 'Should be 1:' );
  PasPar( NE1 );
  N_Dump1Str( '' );
  N_Dump1Str( 'Should be 0:' );
  PasPar( Self.FormHide );
  N_Dump1Str( '' );

  Statusbar.SimpleText := 'bnTest1Click Finished';
end; // procedure TN_CMTest2Form.bnTest1Click

procedure TN_CMTest2Form.bnConvertFiles1Click( Sender: TObject );
var
  i, NumBytes: Integer;
  Pattern, UnicodeDir, DOSContent, NewName: string;
  PData: Pointer;
  ResBytes: TN_BArray;
  FAObjList: TObjectList;
begin
  Pattern := frFName.mbFileName.Text;
  UnicodeDir := ExtractFilePath( Pattern ) + 'UnicodeFiles';

  if DirectoryExists( UnicodeDir ) then
    N_DeleteFiles( UnicodeDir + '\*.*', 1 )
  else
    ForceDirectories( UnicodeDir );

  Pattern := ExtractFilePath(Pattern) + '*' + ExtractFileExt(Pattern);
  FAObjList := N_CreateFilesList( Pattern );

  N_NeededCodePage := 866;
  N_NeededTextEncoding := N_UseBOMFlag + integer(teUTF16LE);

  for i := 0 to FAObjList.Count-1 do
  with TN_FileAttribs( FAObjList[i] ) do
  begin
    DOSContent := N_ReadANSITextFile( FullName );

    // N_NeededCodePage and N_NeededTextEncoding are used in N_EncodeAnsiStringToBytes
    NumBytes := N_EncodeStringToBytes( DOSContent, ResBytes );

    NewName := ExtractFilePath( FullName ) + 'UnicodeFiles\' +
               ExtractFileName( FullName );
    PData := @ResBytes[0];

    N_WriteBinFile( NewName, PData, NumBytes );

  end; // for, with

  StatusBar.SimpleText := Format( '%d files converted', [FAObjList.Count] );
end; // procedure TN_CMTest2Form.bnConvertFiles1Click

procedure TN_CMTest2Form.bnConvertFiles2Click( Sender: TObject );
var
  i, NumBytes: Integer;
  Pattern, Utf8Dir, DOSContent, NewName: string;
  PData: Pointer;
  ResBytes: TN_BArray;
  FAObjList: TObjectList;
begin
  Pattern := frFName.mbFileName.Text;
  Utf8Dir := ExtractFilePath( Pattern ) + 'Utf8Files';

  if DirectoryExists( Utf8Dir ) then
    N_DeleteFiles( Utf8Dir + '\*.*', 1 )
  else
    ForceDirectories( Utf8Dir );

  Pattern := ExtractFilePath(Pattern) + '*' + ExtractFileExt(Pattern);
  FAObjList := N_CreateFilesList( Pattern );

  N_NeededCodePage := 866;
  N_NeededTextEncoding := N_UseBOMFlag + integer(teUTF8);

  for i := 0 to FAObjList.Count-1 do
  with TN_FileAttribs( FAObjList[i] ) do
  begin
    DOSContent := N_ReadANSITextFile( FullName );

    // N_NeededCodePage and N_NeededTextEncoding are used in N_EncodeAnsiStringToBytes
    NumBytes := N_EncodeStringToBytes( DOSContent, ResBytes );

    NewName := ExtractFilePath( FullName ) + 'Utf8Files\' +
               ExtractFileName( FullName );
    PData := @ResBytes[0];

    N_WriteBinFile( NewName, PData, NumBytes );

  end; // for, with

  StatusBar.SimpleText := Format( '%d files converted', [FAObjList.Count] );
end; // procedure TN_CMTest2Form.bnConvertFiles2Click

procedure TN_CMTest2Form.FormActivate( Sender: TObject );
// just for testing in bnTest1Click
begin
  inherited;
  N_Dump1Str( 'From TN_CMTest2Form.FormActivate' );
end; // procedure TN_CMTest2Form.FormActivate

procedure TN_CMTest2Form.FormHide( Sender: TObject );
// just for testing in bnTest1Click
begin
  N_Dump1Str( 'From TN_CMTest2Form.FormHide' );
end; // procedure TN_CMTest2Form.FormHide

procedure TN_CMTest2Form.MyKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState);
// set Text representation to edShortCut.Text
var
  IntShortCut: TShortCut;
  MyKey: Word;
  MyShift: TShiftState;
begin
//  inherited;

  IntShortCut := ShortCut( Key, Shift );        // Convert to ShortCut
  ShortCutToKey( IntShortCut, MyKey, MyShift ); // Convert Back

  edShortCut.Text := ShortCutToText( IntShortCut );
  N_i := TextToShortCut( edShortCut.Text );

  N_Dump1Str( Format ( 'ShortCut Entered: %s, Key=%d, Flags:=%d', [edShortCut.Text, Key, PByte(@Shift)^] ) );

end; // procedure TN_CMTest2Form.MyKeyDown



//****************  TN_CMTest2Form class public methods  ************

//***************************************** TN_CMTest2Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMTest2Form.CurStateToMemIni();
begin
  Inherited;
  N_ComboBoxToMemIni( 'N_CMTest2F_frFName',  frFName.mbFileName );
end; // end of procedure TN_CMTest2Form.CurStateToMemIni

//***************************************** TN_CMTest2Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMTest2Form.MemIniToCurState();
begin
  Inherited;
  N_MemIniToComboBox( 'N_CMTest2F_frFName', frFName.mbFileName );
end; // end of procedure TN_CMTest2Form.MemIniToCurState


    //*********** Global Procedures  *****************************

//***************************************************** N_CreateCMTest2Form ***
// Create and return new instance of TN_CMTest2Form
//
//     Parameters
// AOwner - Owner of created Form
// Result - Return created Form
//
function N_CreateCMTest2Form( AOwner: TN_BaseForm ): TN_CMTest2Form;
begin
  Result := TN_CMTest2Form.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
  end;
end; // function N_CreateCMTest2Form

procedure TN_CMTest2Form.bnSetShortCutClick( Sender: TObject );
begin
  edShortCut.Enabled := True;
end; // procedure TN_CMTest2Form.bnSetShortCutClick

end.
