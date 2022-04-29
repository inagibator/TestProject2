unit K_FCMECacheProc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList, ComCtrls, ExtCtrls,
  N_BaseF, N_CM1, N_CM2, N_DGrid, N_Rast1Fr, N_Types,
  K_CM0;

function K_CMECacheFilesProcessDlg( APSlide : TN_PUDCMSlide = nil;
                                    ASlidesCount : Integer = 0;
                                    ANewSlidesInd : Integer = 0 ) : Boolean;

type TK_FormCMECacheProc = class( TN_BaseForm )

    ActionList1: TActionList;
      CloseCancel: TAction;
      SaveSelectedAs: TAction;
      DeleteSelected: TAction;
      SaveSelected: TAction;

    Button1: TButton;
    Button2: TButton;
    GBThumbnails: TGroupBox;
    LbAvailable: TLabel;
    LbVAvailable: TLabel;
    LbProcessed: TLabel;
    LbVProcessed: TLabel;
    ThumbPanel: TPanel;
    ThumbsRFrame: TN_Rast1Frame;
    Button5: TButton;
    GBSlideInfo: TGroupBox;
    LbSlideState: TLabel;
    Image: TImage;
    Label1: TLabel;
    BtFullScreen: TButton;
    SaveSelectedFull: TAction;
    FullScreen: TAction;


    procedure FormShow           ( Sender: TObject );
    procedure FormKeyDown ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure CloseCancelExecute ( Sender: TObject );
    procedure SaveSelectedExecute        ( Sender: TObject );
    procedure SaveSelectedAsExecute(Sender: TObject);
    procedure SaveSelectedFullExecute(Sender: TObject);
    procedure DeleteSelectedExecute(Sender: TObject);
    procedure FullScreenExecute(Sender: TObject);
  private
    { Private declarations }
    ECPAvailableCount: Integer;
    ECPProcessedCount: Integer;
    ECPSaveEnabled : Boolean;
    ECPSaveAsNewEnabled : Boolean;

    procedure ECPDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure ECPGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                  AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure ShowAvailableAndProcessed ();
    procedure DeleteSelectedElement();
    procedure LoadCurImg( AUDSlide : TN_UDCMSlide );
    function  LoadSrcImg( AUDSlide : TN_UDCMSlide ) : Boolean;
    procedure TryToLoadSrcImgAndSetFlags( AUDSlide : TN_UDCMSlide );
    function  GetImgFName( const AFName : string; AImgChar : Char ) : string;
  public
    { Public declarations }
    //*** Slide Fieds Vars
    ECPIniMediaType: Integer;
    ECPThumbsDGrid: TN_DGridArbMatr;
    ECPDrawSlideObj: TN_CMDrawSlideObj;
    ECPSaveSlidesFlag : Boolean;
//    procedure CurStateToMemIni (); override;
//    procedure MemIniToCurState (); override;
    procedure ECPChangeThumbState1( ADGObj: TN_DGridBase; AInd: integer);
    procedure ECPChangeThumbState( ADGObj: TN_DGridBase; AInd: integer);
end; // type TK_FormCMECacheProc = class( TN_BaseForm )

procedure K_CMECacheFilesShowDlg();

implementation

{$R *.dfm}

uses Types, Math,
  K_Clib0, K_VFunc, K_SCript1, K_SBuf, K_STBuf, K_UDC,
  {K_FCMSetSlidesAttrs,} K_FCMSetSlidesAttrs2, K_FEText,
  N_Comp1, N_Lib1, K_CML1F;

var
  ECPSlides : TN_UDCMSArray;
  ECPSlidesLockState : TK_CMEDBLockStateArray;

//************************************************** K_CMECacheFilesProcess ***
// Process ECache Files and prepare Needed Slides
//
//   Parameters
// AECSlides  - resulting array of slides created from Emergncy Cache files
// Result - Returns index of first "New" slide in resulting array
//
function K_CMECacheFilesProcess( var AECSlides : TN_UDCMSArray ) : Integer;
var
  ECFPath : string;
  ECFNamePat : string;
  LInd, i1, j, Ind, LCount : Integer;
  DFile: TK_DFile;
  DSize : Integer;
//  WUDSlide : TN_UDCMSlide;
  RSlide : TK_RArray;
  FStream : TFileStream;
  PCMSlide : TN_PCMSlide;
  WCPat : string;
label LExit;

  procedure ProcessFile( const AFName : string );
//  var
//    FHandle : Integer;
  begin
    try
// This code was for debug only
//      FHandle := FileOpen( ECFPath + AFName, fmOpenReadWrite );
//      N_Dump1Str( 'EC>> After FileOpen File=' + AFName );
//      if FHandle < 0 then
//      begin
//        N_Dump1Str( 'EC>> Fail FileOpen File=' + AFName );
//        Exit;
//      end;
//      FStream := TFileStream.Create( FHandle );

      FStream := nil;
      FStream := TFileStream.Create( ECFPath + AFName, fmOpenReadWrite );
      N_Dump1Str( 'EC>> After TFileStream.Create File=' + AFName );
      if FStream.Size = 0 then
      begin
        FreeAndNil( FStream ); // Wrong Stream size - ECache File just before deletion
        N_Dump1Str( 'EC>> Delete Size=0 File=' + AFName );
        K_DeleteFile( ECFPath + AFName ); // Try Delete - may be it wasn't deleted
        Exit;
      end;
      // Load ECFile to Slide
      K_DFStreamOpen( FStream, DFile, [K_dfoProtected] );

      DSize := DFile.DFPlainDataSize;
      if SizeOf(Char) = 2 then
        DSize := DSize shr 1;
      SetLength( K_CMEDAccess.StrTextBuf, DSize );
      K_DFRead( @K_CMEDAccess.StrTextBuf[1], DFile.DFPlainDataSize, DFile );
{//debug
with TK_FormTextEdit.Create(Application) do
  EditText( K_CMEDAccess.StrTextBuf, Caption );
{}//debug

      K_SerialTextBuf.LoadFromText( K_CMEDAccess.StrTextBuf );

      AECSlides[Ind] := TN_UDCMSlide( K_LoadTreeFromText( K_SerialTextBuf ) );
      if AECSlides[Ind] = nil then
      begin
        FreeAndNil( FStream );
        N_Dump1Str( 'EC>> File ' + ECFPath + AFName + ' has not proper format' );
        if mrYes = K_CMShowMessageDlg( format( K_CML1Form.LLLECache1.Caption,
//                                       '    Last session of Media Suite was terminated abnormally.'#13#10 +
//                                       'Files for unsaved object ID=%s have not proper format.'#13#10 +
//                                       '    Press Yes to remove files for this unsaved object?',
                                       [Copy( AFName, 2, 8 )] ), mtConfirmation ) then
        begin
          WCPat := ChangeFileExt( AFName, '' );
          WCPat := Copy( WCPat, 1, Length(WCPat) - 1 ) + '*.*';
          K_DeleteFolderFiles( ECFPath, WCPat, [] ); // Del ECache Main + Image Files
          N_Dump1Str( 'EC>> Files ' + ECFPath + WCPat + ' were deleted' );
        end;
        Exit;
      end;

      with AECSlides[Ind] do
      begin
//          PrepROIView( [K_roiRestoreIfImage] );
        CMSlideECFName := ECFPath + AFName;
        CMSlideECFStream := FStream;
      // Change Slide RArray type from 'TN_CMECSlide' to 'TN_CMSlide'
        RSlide := K_RCreateByTypeName( 'TN_CMSlide', 1, [] );
        PCMSlide := P;
        TN_PCMSlide(RSlide.P)^ := PCMSlide^;
        PCMSlide^.CMSHist := nil; // Clear History Before Destroy
        R.ARelease();
        R := RSlide;
        if (Result < 0) and (cmsfIsNew in P^.CMSRFlags) then
        // First New Slide Index
          Result := Ind;
      end;
      Inc(Ind);
    except
    on E: Exception do
      begin
        N_Dump1Str( 'EC>> Locked File=' + AFName + ' >> ' + E.Message );
        FreeAndNil( FStream );
        K_CMEDAccess.TmpStrings[LInd] := AFName;
        Inc(LInd);
      end;
    end;
  end; // procedure ProcessFile

  procedure CheckFile( const AFileName, AErrStr : string; AMode : word );
  begin
    try
      FStream := nil;
      FStream := TFileStream.Create( ECFPath + AFileName, AMode );
      if FStream.Size = 0 then
      begin
        N_Dump1Str( format( 'EC>> Delete Size=0 OpenMode=%s File=%s', [AErrStr,AFileName] ) );
        FreeAndNil( FStream );
        K_DeleteFile( ECFPath + AFileName ); // Try Delete - may be it wasn't deleted
      end
      else
      begin
        N_Dump1Str( format( 'EC>> Open Size=%d OpenMode=%s File=%s', [FStream.Size,AErrStr,AFileName] ) );
        FreeAndNil( FStream ); // Wrong Stream size - ECache File just before deletion
      end;
    except
    on E: Exception do
      begin
        FreeAndNil( FStream );
        N_Dump1Str( format( 'EC>> Locked OpenMode=%s File=%s (E=%s)', [AErrStr,AFileName,E.Message] ) );
      end;
    end;
  end; // procedure CheckFile

begin
  with TK_CMEDDBAccess(K_CMEDAccess) do begin
//    ECFPath := K_ExpandFileName( '(#CMECacheFiles#)' );
    ECFPath := K_CMGetECacheFilesPath();
    ECFNamePat := format( 'F*_%d_%d_*A.ecd', [CurProvID, CurPatID] );
//    ECFNamePat := format( 'F????????_%d_???????????????.ecd', [CurProvID] );
    TmpStrings.Clear;
    K_ScanFilesTree( ECFPath, EDAScanFilesTreeSelectFile, ECFNamePat );
    N_Dump1Str( format( 'EC>> Check ECache Files Count=%d ActRTID=%d',
                              [TmpStrings.Count, AppRTID] ) );
    Result := -1;
    if TmpStrings.Count = 0 then Exit;
    TmpStrings.Sort();

    SetLength( AECSlides, TmpStrings.Count );
    Ind := 0;
    LInd := 0;
    for i1 := 0 to TmpStrings.Count - 1 do
    begin
      ProcessFile( TmpStrings[i1] );
    end;

    j := 0;
    while (LInd > 0) and (j <= 20) do
    begin
    // Try to Process Files which are used by other process
      Inc(j);
      N_Dump1Str( format( 'EC>> Try %d ECache Locked Files Count=%d ActRTID=%d',
                              [j, LInd, AppRTID] ) );
      sleep(100);
      LCount := LInd - 1;
      LInd := 0;
      for i1 := 0 to LCount do
        ProcessFile( TmpStrings[i1] );
    end;

    if LInd > 0 then
    begin
      N_Dump1Str( format( 'EC>> Resulting Locked ECache Files Count=%d ActRTID=%d',
                                [LInd, AppRTID] ) );
      // Try to Open Files in other modes
      for i1 := 0 to LInd - 1 do
      begin
        CheckFile( TmpStrings[i1], 'OpenRead', fmOpenRead );
        CheckFile( TmpStrings[i1], 'OpenRead + ShareDenyNone', fmOpenRead + fmShareDenyNone );
      end;
    end;

    N_Dump1Str( format( 'EC>> Process ECache Files Count=%d ActRTID=%d',
                              [Ind, AppRTID] ) );
    SetLength( AECSlides, Ind );
  end;
end; // end of K_CMECacheFilesProcess

//************************************************** K_CMECacheFilesShowDlg ***
// ECache Files Show Dialog
//
procedure K_CMECacheFilesShowDlg();
var
  i, j, n, ProvID, PatID, k : Integer;
  WStr, WSID, SProvID, SPatID: string;
  ECFPath : string;
  ECFNamePat : string;
  FL, SL : TStringList;
  yy, mm, dd, hh, nn, ss :Integer;

  function  ParseID( ) : Integer;
  begin
    n := 0;
    SetLength( WSID, 10 );
    while (j <= Length(WStr)) and (WStr[j] <> '_') do begin
      Inc(n);
      WSID[n] := WStr[j];
      Inc(j);
    end;
    SetLength( WSID, n );
    Result := StrToIntDef( WSID, -1 );
  end;

  function  ParseDE( ) : Integer;
  begin
    SetLength( WSID, 2 );
    WSID[1] := WStr[j];
    Inc(j);
    WSID[2] := WStr[j];
    Inc(j);
    Result := StrToIntDef( WSID, -1 );
  end;

begin
  with TK_CMEDDBAccess(K_CMEDAccess) do begin
//    ECFNamePat := format( 'F*_%d_%d*A.ecd', [CurProvID, CurPatID] );
    ECFNamePat := format( 'F*_%d_*A.ecd', [CurProvID] );
//    ECFPath := K_ExpandFileName( '(#CMECacheFiles#)' );
    ECFPath := K_CMGetECacheFilesPath();
    TmpStrings.Clear;
    K_ScanFilesTree( ECFPath, EDAScanFilesTreeSelectFile, ECFNamePat );
    N_Dump1Str( format( 'EC>> Show ECache Files Count=%d ActRTID=%d',
                              [TmpStrings.Count, AppRTID] ) );
    if TmpStrings.Count = 0 then Exit;

    TmpStrings.Sort();
    FL := TStringList.Create;
    FL.Assign(TmpStrings);

    SL := TStringList.Create;
    SL.Add( '            File Name                         Saved at         Provider: Name or ID           Patient: Name or ID' );
    k := 1;
    for i := 0 to FL.Count - 1 do begin
      WStr := FL[i];
      j := 11;
      ProvID := ParseID( );
      if ProvID < 0 then Continue; // wrong file format
      Inc(j);
      PatID := ParseID( );
      if PatID < 0 then Continue; // wrong file format
      Inc(j);
      yy := 2000 + ParseDE( );
      mm := ParseDE( );
      dd := ParseDE( );
      hh := ParseDE( );
      nn := ParseDE( );
      ss := ParseDE( );
      SProvID := format( ' Provider: %-20s', [K_CMGetProviderDetails( ProvID )] );
      SPatID  := format( ' Patient: %-20s', [K_CMGetPatientDetails( PatID )] );
      SL.Add( format( '%2d. %s', [k, WStr] ) +
              K_DateTimeToStr( EncodeDate( yy, mm, dd ) + EncodeTime( hh, nn, ss, 0 ),
                               '  dd.mm.yyyy hh:nn AM/PM ' ) +
                               SProvID + SPatID );
      Inc(k);
    end;
    SL.Add( '' );
    with  K_GetFormTextEdit( nil, 'CMSEFFiles',
          [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] ) do
    begin
      BtCancel.Visible := FALSE;
      EditStrings( SL, 'Emergency folder files list',
                                      TRUE, TRUE );
    end;
    FL.Free;
    SL.Free;
  end;
end; // K_CMECacheFilesShowDlg

//*********************************************** K_CMECacheFilesProcessDlg ***
// ECache Files Process Dialog
//
//   Parameters
// APSlide       - pointer to slides
// ASlidesCount  - number of slides
// ANewSlidesInd - new slides start index
// Result - Returns TRUE if some files were saved, else FALSE if no files were saved to DB
//
// If Slides for ECache porcessing are not specified than they are selected from
// ECache folder for current provider
//
function K_CMECacheFilesProcessDlg( APSlide : TN_PUDCMSlide = nil;
                                    ASlidesCount : Integer = 0;
                                    ANewSlidesInd : Integer = 0 ) : Boolean;
var
  i, SCount, ACount : Integer;
  SInds : TN_IArray;
  UDSlide : TN_UDCMSlide;
  PCMSlide : TN_PCMSlide;
  USFlags : TK_CMEDBUStateFlags;
  CurImgFName : string;

  procedure BuildRFName();
  begin
    CurImgFName := UDSlide.CMSlideECFName;
    CurImgFName[Length(CurImgFName) - 4] := 'R';
  end;

  procedure DelECache( AInd : Integer; AUnlock : Boolean );
  begin
  //  ECache should be clear
    K_CMEDAccess.EDAClearSlideECache( UDSlide );
    if AUnlock then
      K_CMEDAccess.EDAUnlockSlides( @UDSlide, 1, K_cmlrmEditImgLock );
    UDSlide.UDDelete;
    SInds[AInd] := -1;
    Inc(SCount);
  end;

  function IfECacheIsDeleted( AInd : Integer; AUnlock : Boolean; ACheck : Boolean ) : Boolean;
  begin
    Result := ACheck;
    if not Result then
    begin
      with PCMSlide^ do
        Result := not (cmsfIsMediaObj in CMSDB.SFlags) and
                  not FileExists( CurImgFName );
//                  not FileExists( ChangeFileExt( UDSlide.CMSlideECFName, 'R.ecd' ) );
    end;
    if not Result then Exit;
    DelECache( AInd, AUnlock );
  end;

begin
  N_Dump1Str( 'Start ECache Files Processing' );
  Result := False;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
{
    K_CMShowMessageDlg( '*************', mtInformation,[],TRUE );
}

    if APSlide = nil then
    begin
    //!!! this case is really used now
      ANewSlidesInd := K_CMECacheFilesProcess( ECPSlides );
      ASlidesCount := Length(ECPSlides);
      if ASlidesCount = 0 then Exit;
    end   // if APSlide = nil then
    else
    begin // if APSlide <> nil then
      SetLength( ECPSlides, ASlidesCount );
      Move( APSlide^, ECPSlides[0], SizeOf(TN_UDCMSlide) * ASlidesCount );
    end;   // if APSlide <> nil then

    /////////////////////////////////////////////////
    // Prepare Slides State Array and Show Attributes
    //
    SetLength( ECPSlidesLockState, ASlidesCount );

    if ANewSlidesInd >= 0 then
    begin //!!! this code is used if slides are selected from ECache files
      // New Slide Flag to all New (Array Tail)
      USFlags := [K_dbusECacheNew];
//      FillChar( ECPSlidesLockState[ANewSlidesInd], ASlidesCount - ANewSlidesInd, Byte(USFlags) ); // New Slide Flag
      K_MoveVector( ECPSlidesLockState[ANewSlidesInd].LSUpdate, SizeOf(TK_CMEDBLockState),
                    USFlags, 0, 1, ASlidesCount - ANewSlidesInd );
      ASlidesCount := ANewSlidesInd;
    end; // if ANewSlidesInd >= 0 then

    /////////////////////////////////////////////////////////
    // Slides source list preprocessing
    //
    if ASlidesCount > 0 then
    begin
      // Deleted Slide Flag to all
      USFlags := [K_dbusECacheDel];
//      FillChar( ECPSlidesLockState[0], ASlidesCount, Byte(USFlags) ); // Deleted Slide Flag to all
      K_MoveVector( ECPSlidesLockState[0].LSUpdate, SizeOf(TK_CMEDBLockState),
                    USFlags, 0, 1, ASlidesCount );

      /////////////////////////////////
      //    Check Duplicates
      // Now previous Slide State is removed unconditionally
      // but may be original image exists only in previous state
      // so it may be usefull to "move" original image from previous
      // to last
      SetLength( SInds, Length( ECPSlides ) );
      SCount := 0;
      for i := 0 to High(SInds) do
      begin
        SInds[i] := i;
        if (i < ASlidesCount) and
           (i > 0)            and
           (UDSlide.ObjName = ECPSlides[i].ObjName) then
          IfECacheIsDeleted( i-1, FALSE, TRUE );
        UDSlide := ECPSlides[i];
        BuildRFName();
      end; // for i := 0 to High(SInds) do
      //    Check Duplicates
      /////////////////////////////////

      //////////////////////////////////////////////////////////////////////
      // Compress Slides array by Indexes build while duplicates are checked
      //
      if SCount > 0 then
      begin
      // Correct Slides to Lock Count
        ASlidesCount := ASlidesCount - SCount;
        ACount := K_BuildActIndicesAndCompress( nil, nil, @SInds[0], @SInds[0],
                                      Length( ECPSlides ) );
        SCount := K_MoveVectorBySIndex( ECPSlides[0], -1, ECPSlides[0], -1,
                             SizeOf(TN_UDCMSlide), ACount, @SInds[0] );
        SetLength( ECPSlides, SCount );
        K_MoveSPLVectorBySIndex( ECPSlidesLockState[0], -1, ECPSlidesLockState[0], -1,
                                 ACount, K_GetTypeCodeSafe('TK_CMEDBLockState').All,
                                 [K_mdfFreeDest],  @SInds[0] );
        SetLength( ECPSlidesLockState, SCount );
      end; // if SCount > 0 then
      //
      // Compress Slides array by Indexes build while duplicates are checked
      //////////////////////////////////////////////////////////////////////

      EDALockSlides( @ECPSlides[0], ASlidesCount, K_cmlrmEditAllLock );
      // Real Lock State to Locked
      if LockResCount > 0 then
        K_MoveSPLVectorByDIndex( ECPSlidesLockState[0], -1,
                              LockResState[0], -1, LockResCount,
                              K_GetTypeCodeSafe('TK_CMEDBLockState').All,
                              [K_mdfFreeDest], @LockResState[0].LSSrcInd,
                              SizeOf(TK_CMEDBLockState) );
    end; // if ASlidesCount > 0 then
    //
    // Slides source list preprocessing
    /////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////
    // Mark slides which ECache State is not enough to save them to DB
    //
    SetLength( SInds, Length(ECPSlides) );
    SCount := 0;
    for i := 0 to High(ECPSlides) do
    begin
      SInds[i] := i;
      UDSlide := ECPSlides[i];
      BuildRFName();
      PCMSlide := UDSlide.P;
      with UDSlide, PCMSlide^ do
      begin
        if K_dbusECacheDel in ECPSlidesLockState[i].LSUpdate then
        begin
          if IfECacheIsDeleted( i, FALSE, (cmsfIsMediaObj in CMSDB.SFlags) ) then Continue;
        end
        else
        if cmsfIsUsed in CMSRFlags then
        begin
        // Slide is locked by other user
          if not (cmsfIsMediaObj in CMSDB.SFlags) and
             not FileExists( CurImgFName ) then // Source image file doesn't exist
          begin // Mark this index as deleted
            DelECache( i, TRUE );
            Continue;
          end;
// !!! 2015-02-14 is not needed - all is done in above code
//        if IfECacheIsDeleted( i, TRUE, FALSE ) then Continue;
        end   // if cmsfIsUsed in CMSRFlags then
        else
        begin // if not (cmsfIsUsed in CMSRFlags) then
        // Slide is locked - check Slide Cur State updates - if ECache to DB is enabled
          if ECPSlidesLockState[i].LSUpdate *
            [K_dbusOldProps,K_dbusNewProps,
             K_dbusOldMapRoot,K_dbusNewMapRoot,
             K_dbusOldCurImg,K_dbusNewCurImg] <> [] then
          begin
            if not (cmsfIsMediaObj in CMSDB.SFlags)          and
               not FileExists( CurImgFName )                 and // Source image file doesn't exist
              ((ECPSlidesLockState[i].LSUpdate * [K_dbusOldMapRoot,K_dbusNewMapRoot,K_dbusOldCurImg,K_dbusNewCurImg]) <> []) then
            begin
              DelECache( i, TRUE );
              Continue;
            end; // if not (cmsfIsMediaObj in CMSDB.SFlags) ...
          end; // if ECPSlidesLockState[i] ...
        end; // if not (cmsfIsUsed in CMSRFlags) then
      end; // with UDSlide, PCMSlide^ do
    end; // for i := 0 to High(ECPSlides) do
    //
    // Mark slides which ECache State is not enough to save them to DB
    /////////////////////////////////////////////////////////////////////

    ///////////////////////////
    // Remove marked slides
    //
    ACount := Length(ECPSlides);
    if SCount > 0 then
    begin
      ACount := K_BuildActIndicesAndCompress( nil, nil, @SInds[0], @SInds[0],
                                      Length( ECPSlides ) );
      K_MoveVectorBySIndex( ECPSlides[0], -1, ECPSlides[0], -1,
                            SizeOf(TN_UDCMSlide), ACount, @SInds[0] );
      K_MoveSPLVectorBySIndex( ECPSlidesLockState[0], -1, ECPSlidesLockState[0], -1,
                               ACount,  K_GetTypeCodeSafe('TK_CMEDBLockState').All,
                               [K_mdfFreeDest],  @SInds[0] );
      SetLength( ECPSlides, ACount );
      SetLength( ECPSlidesLockState, ACount );
    end; // if SCount > 0 then
    //
    // Remove marked slides
    ///////////////////////////

    with TK_FormCMECacheProc.Create(Application) do
    begin
    /////////////////////////////////////////////////
    // Prepare Form View
    //
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

      Image.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);

      ECPDrawSlideObj := TN_CMDrawSlideObj.Create();
      ECPThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, ECPGetThumbSize );

      with ECPThumbsDGrid do
      begin
        DGEdges := Rect( 3, 3, 3, 12 );
        DGGaps  := Point( 6, 0 );

        DGLFixNumCols   := 0;
        DGLFixNumRows   := 1;
        DGSkipSelecting := True;
        DGChangeRCbyAK  := True;
//        DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
        DGMultiMarking  := False; //
        DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

        DGBackColor := ColorToRGB(clBtnFace);

        DGMarkNormWidth := 3;
        DGMarkNormShift := 2;

        DGMarkBordColor := $800000;
    //      DGNormBordColor := $808080;
        DGNormBordColor := $BBBBBB;
        DGNormBordColor := DGBackColor;

        DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
        DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

        DGDrawItemProcObj := ECPDrawThumb;
        DGChangeItemStateProcObj := ECPChangeThumbState1;
        DGNumItems := Length(ECPSlides);
        ECPThumbsDGrid.DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
        ECPThumbsDGrid.DGMarkSingleItem( 0 );
      end; // with ThumbsDGrid do

      ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events

//      FormStyle := fsStayOnTop;
      Caption := K_CML1Form.LLLECache4.Caption  + ' ' + K_CMGetProviderDetails( CurProvID );
//      Caption := 'Unsaved object(s) recovery ' + K_CMGetProviderDetails( CurProvID );
    //
    // Prepare Form View
    /////////////////////////////////////////////////

      if ACount > 0 then ShowModal;

      Result := ECPSaveSlidesFlag;

    /////////////////////////////////////////////////
    // Clear Remaining Slide Contexts
    //
      SetLength( SInds, Length(ECPSlides) );
      SCount := 0;
      for i := 0 to High(ECPSlides) do
      begin
        if ECPSlidesLockState[i].LSUpdate * [K_dbusECacheNew,K_dbusECacheDel] <> [] then
        begin
        // Free Context for New And Deleted Slides without Unlock
          UDSlide := ECPSlides[i];
//          FreeAndNil(UDSlide.CMSlideECFStream); // is done in the destructor
//          UDSlide.Free;
          UDSlide.UDDelete();
          SInds[i] := -1;
          Inc(SCount);
        end
        else
          SInds[i] := i;
      end; // for i := 0 to High(ECPSlides) do

      if SCount > 0 then
      begin
      // Remove Processed Slides from ECPSlides
        i := Length(ECPSlides);
        K_MoveVectorByDIndex( ECPSlides[0], -1, ECPSlides[0], -1,
                              SizeOf(TN_UDCMSlide), i, @SInds[0] );
        SetLength( ECPSlides, i - SCount );
      end; // if SCount > 0 then

      if Length(ECPSlides) > 0 then
      begin
        // Unlock Locked slides
        EDAUnlockSlides( @ECPSlides[0], Length(ECPSlides),
                                        K_cmlrmEditImgLock );

        // Free Context for Locked slides
        K_CMEDAccess.LockResCount := 0;
        for i := 0 to High( ECPSlides ) do
        begin
//          FreeAndNil(ECPSlides[i].CMSlideECFStream); // is done in the destructor
//          ECPSlides[i].Free;
          ECPSlides[i].UDDelete();
        end;
      end; // if Length(ECPSlides) > 0 then

      ECPSlides := nil;
      ECPSlidesLockState := nil;
      ECPThumbsDGrid.Free;
      ECPDrawSlideObj.Free;
      ThumbsRFrame.RFFreeObjects();
    end; // with TK_FormCMECacheProc.Create(Application) do
    //
    // Clear Remaining Slide Contexts
    /////////////////////////////////////////////////
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do
end; // end of K_CMECacheFilesProcessDlg

//******************************************** TK_FormCMECacheProc.FormShow ***
// Form Show Handler
//
procedure TK_FormCMECacheProc.FormShow(Sender: TObject);
begin
  inherited;

  ECPAvailableCount := Length(ECPSlides);
  ECPProcessedCount := 0;
  ShowAvailableAndProcessed();
end; // end of K_FormCMSetSlidesAttrs.FormShow

//***************************************** TK_FormCMECacheProc.FormKeyDown ***
//  Form Key Down Handler
//
procedure TK_FormCMECacheProc.FormKeyDown( Sender: TObject;
                                       var Key: Word; Shift: TShiftState );
begin
  if not( [ssAlt] = Shift ) then Exit;
end; // end of TK_FormCMECacheProc.FormKeyDown

//********************************** TK_FormCMECacheProc.CloseCancelExecute ***
// Form OK Action Execute
//
procedure TK_FormCMECacheProc.CloseCancelExecute(Sender: TObject);
begin
  if not (fsModal in FormState)	then Close;
  ModalResult := mrCancel;
end; // end of TK_FormCMECacheProc.CloseCancelExecute

//********************************* TK_FormCMECacheProc.SaveSelectedExecute ***
// Form OK Action Execute
//
procedure TK_FormCMECacheProc.SaveSelectedExecute(Sender: TObject);
var
  UDSlide : TN_UDCMSlide;
//  FName : string;
//  DFile: TK_DFile;
  UnlockFlag : Boolean;
  PCMSlide : TN_PCMSlide;

begin
  with ECPThumbsDGrid do begin
  // Delete selected slide ECache Files
    UDSlide := ECPSlides[DGSelectedInd];
    PCMSlide := UDSlide.P;
    with TK_CMEDDBAccess(K_CMEDAccess), UDSlide, PCMSlide^ do begin
      if not (cmsfIsNew in CMSRFlags) and
         (cmsfIsLocked in CMSRFlags)  and
         (ECPSlidesLockState[DGSelectedInd].LSUpdate *
           [K_dbusOldProps,K_dbusNewProps,
            K_dbusOldMapRoot,K_dbusNewMapRoot,
            K_dbusOldCurImg,K_dbusNewCurImg] <> []) then
      begin
      // If changed by other user
        if mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLECache2.Caption,
//           'The selected object have been already changed by other user'#13#10
//           '       Are you sure you want to replace it?',
                                        mtConfirmation ) then Exit;
      end;
    // Prepare Slide Data For Saving
      if (cmsfIsMediaObj in CMSDB.SFlags) or (cmsfIsImg3DObj in CMSDB.SFlags) then
      begin
      // Prepare Video  or Img 3D
        if cmsfIsLocked in CMSRFlags then
          CMSRFlags := CMSRFlags + [cmsfAttribsChanged];
      end
      else
      begin
      // Prepare Image
        // Set Proper Save Flags
        if not (cmsfIsNew in CMSRFlags) then
        begin
        // Get Current Image from ECache File

          TryToLoadSrcImgAndSetFlags( UDSlide );

          if (cmsfIsLocked in CMSRFlags)  and
             (ECPSlidesLockState[DGSelectedInd].LSUpdate *
             [K_dbusOldProps,K_dbusNewProps,
              K_dbusOldMapRoot,K_dbusNewMapRoot,
              K_dbusOldCurImg,K_dbusNewCurImg] <> []) then
          begin
          // DB Slide State is Newer then in ECache - Set All needed Save Flags by DB and ECache real State
            if (ECPSlidesLockState[DGSelectedInd].LSUpdate * [K_dbusOldProps,K_dbusNewProps] <> []) then
              CMSRFlags := CMSRFlags + [cmsfAttribsChanged];
            if (ECPSlidesLockState[DGSelectedInd].LSUpdate * [K_dbusOldMapRoot,K_dbusNewMapRoot] <> []) then
              CMSRFlags := CMSRFlags + [cmsfMapRootChanged,cmsfAttribsChanged];
            if (ECPSlidesLockState[DGSelectedInd].LSUpdate * [K_dbusOldCurImg,K_dbusNewCurImg] <> []) then
              CMSRFlags := CMSRFlags + [cmsfCurImgChanged,cmsfAttribsChanged];
          end;
        end;
        // Get Current Image from ECache File

        if (cmsfIsNew in CMSRFlags) or
           (cmsfCurImgChanged in CMSRFlags) then
        begin
          LoadCurImg( UDSlide );
{
//          FName := ChangeFileExt( CMSlideECFName, 'R.ecd' );
          FName := GetImgFName( CMSlideECFName, 'R' );
          if not K_DFOpen( FName, DFile, [] ) then
            raise Exception.Create( 'Couldn''t open ECache File ' + FName );
          if Length( BlobBuf ) < DFile.DFPlainDataSize then
            SetLength( BlobBuf, DFile.DFPlainDataSize );
          K_DFReadAll( @BlobBuf[0], DFile );
          SetCurrentImageBySData( @BlobBuf[0], DFile.DFPlainDataSize );
}
        end;
      end;
      UnlockFlag := not (cmsfIsNew in CMSRFlags) and
                    not (K_dbusECacheDel in ECPSlidesLockState[DGSelectedInd].LSUpdate);
    end;


    ECPSaveSlidesFlag := TRUE;
    K_CMEDAccess.EDASaveSlidesArray( @UDSlide, 1 );
    if UnlockFlag then
      K_CMEDAccess.EDAUnlockSlides( @UDSlide, 1, K_cmlrmEditImgLock );
    K_CMEDAccess.LockResCount := 0;
    UDSlide.UDDelete;

    DeleteSelectedElement();
  end;
end; // end of TK_FormCMECacheProc.SaveSelectedExecute

//******************************* TK_FormCMECacheProc.SaveSelectedAsExecute ***
//
procedure TK_FormCMECacheProc.SaveSelectedAsExecute(Sender: TObject);
var
  UDSlide : TN_UDCMSlide;
//  FName : string;
//  DFile: TK_DFile;
  SlideDumpInfo : string;
  PCMSlide : TN_PCMSlide;
begin
  with ECPThumbsDGrid do begin
  // Delete selected slide ECache Files
    UDSlide := ECPSlides[DGSelectedInd];

    PCMSlide := UDSlide.P;
    with TK_CMEDDBAccess(K_CMEDAccess), UDSlide, PCMSlide^ do
    begin
    // Prepare Slide Data For Saving
      if not (cmsfIsMediaObj in CMSDB.SFlags) and
         not (cmsfIsImg3DObj in CMSDB.SFlags) then
      begin
        // Get Original Image from ECache File
        TryToLoadSrcImgAndSetFlags( UDSlide );
      end;
    end;

    SlideDumpInfo := '';
    if K_dbusECacheDel in ECPSlidesLockState[DGSelectedInd].LSUpdate then
      SlideDumpInfo := ' Deleted'
    else
    if K_dbusECacheNew in ECPSlidesLockState[DGSelectedInd].LSUpdate then
    begin
      SlideDumpInfo := ' New';
      K_CMSetSlidesAttrs( @UDSlide, 1, nil,
                 K_CML1Form.LLLECache15.Caption,
//               'Object properties / Diagnoses',
               [], UDSlide.P.CMSMediaType, TRUE );
    end
    else
    begin
      K_CMEDAccess.EDAUnlockSlides( @UDSlide, 1, K_cmlrmEditImgLock );
    end;

    N_Dump2Str( 'EC>> Save as new 1 Slide ID=' + UDSlide.ObjName +  SlideDumpInfo );

    Include( UDSlide.P.CMSRFlags, cmsfIsNew );
    SaveSelectedExecute( Sender );
  end;

end; // end of TK_FormCMECacheProc.SaveSelectedAsExecute

//****************************  TK_FormCMECacheProc.SaveSelectedFullExecute ***
//
procedure TK_FormCMECacheProc.SaveSelectedFullExecute(Sender: TObject);
var
  UDSlide : TN_UDCMSlide;
begin
  with ECPThumbsDGrid do
    UDSlide := ECPSlides[DGSelectedInd];

  if 0 <> K_CMEDAccess.EDACheckFilesAccessBySlidesSet( @UDSlide, 1,
//         ' The action couldn''t be done.' ) then
         ' ' ) then
    Exit;

  if ECPSaveEnabled then
  begin
    N_Dump1Str( 'EC>> Save Slide ID=' + ECPSlides[ECPThumbsDGrid.DGSelectedInd].ObjName );
    SaveSelectedExecute( Sender );
  end
  else
  if ECPSaveAsNewEnabled then
  begin
    N_Dump1Str( 'EC>> Save as new 0 Slide ID=' + ECPSlides[ECPThumbsDGrid.DGSelectedInd].ObjName );
    SaveSelectedAsExecute( Sender );
  end;
end; // end of TK_FormCMECacheProc.ECPChangeThumbState

//*************************************** TK_FormCMECacheProc.DeleteExecute ***
//
procedure TK_FormCMECacheProc.DeleteSelectedExecute(Sender: TObject);

var
  UDSlide : TN_UDCMSlide;
begin
//  if mrYes <> K_CMShowMessageDlg( 'Are you sure you want to delete selected object saved state?',
//                                    mtConfirmation ) then Exit;
  with ECPThumbsDGrid do begin
  // Delete selected slide ECache Files
    UDSlide := ECPSlides[DGSelectedInd];
    if not K_CMSlideDelConfirmDlg( UDSlide ) then Exit;
    N_Dump1Str( 'EC>> Delete Slide ID=' + UDSlide.ObjName );
    K_CMEDAccess.EDAClearSlideECache( UDSlide );
    if ECPSlidesLockState[DGSelectedInd].LSUpdate * [K_dbusECacheNew,K_dbusECacheDel] = [] then
      K_CMEDAccess.EDAUnlockSlides( @UDSlide, 1, K_cmlrmEditImgLock );
    K_CMEDAccess.LockResCount := 0;
    UDSlide.UDDelete;
    DeleteSelectedElement();
  end;

end; // end of TK_FormCMECacheProc.DeleteExecute

//*********************************** TK_FormCMECacheProc.FullScreenExecute ***
// Form FullScreen Action Execute
//
procedure TK_FormCMECacheProc.FullScreenExecute(Sender: TObject);
var
  UDSlide : TN_UDCMSlide;

begin
  if not FullScreen.Enabled then Exit; // because Action FullScreen may be called by DblClick handler even if it is diabled
  with ECPThumbsDGrid do begin
    UDSlide := ECPSlides[DGSelectedInd];
    N_Dump2Str( 'EC>> FullScreen0 ID=' + UDSlide.ObjName );
    // Check DIB UDData Format to  skip Full Screen
    LoadCurImg( UDSlide );
    try
      TN_UDDIB(UDSlide.DirChild(K_CMSlideIndCurImg)).LoadDIBObj(); // Load Current Image DIBObj
    except
    on E: Exception do begin
      N_Dump1Str( format( 'EC>> Slide ID=%s Cur LoadDIBObj Error >> %s', [UDSlide.ObjName, E.Message] ) );
      K_CMShowMessageDlg( K_CML1Form.LLLECache16.Caption,
//                        'Image Data has not proper format'
                                                             mtWarning );
      Exit;
    end;
  end;

    N_Dump2Str( 'EC>> FullScreen1 ID=' + UDSlide.ObjName );
    N_ShowCompInFullScreen( UDSlide.GetMapRoot() );
    N_Dump2Str( 'EC>> FullScreen2 ID=' + UDSlide.ObjName );
  end;
end; // procedure TK_FormCMECacheProc.FullScreenExecute

//********************************* TK_FormCMECacheProc.ECPChangeThumbState ***
// Thumbnail Change State processing (used as TN_DGridBase.DGChangeItemStateProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - Index of Thumbnail that is change state
//
procedure TK_FormCMECacheProc.ECPChangeThumbState(
                                   ADGObj: TN_DGridBase; AInd: integer);
var
  DT : TDateTime;
  ChangedDTText : string;
  RFName : string;
begin
  with ECPThumbsDGrid do
  begin

    SaveSelected.Enabled   := (DGSelectedInd >= 0) and
                              ((DGItemsFlags[DGSelectedInd] and N_DGMarkBit) <> 0);
    DeleteSelected.Enabled := SaveSelected.Enabled;
    SaveSelectedAs.Enabled := SaveSelected.Enabled;
    LbSlideState.Caption := '';
    N_Dump2Str( 'EC>> Select0 ID=' + ECPSlides[DGSelectedInd].ObjName );
    if not SaveSelectedAs.Enabled then Exit;
    N_Dump2Str( 'EC>> Select1 ID=' + ECPSlides[DGSelectedInd].ObjName );
    with ECPSlidesLockState[DGSelectedInd],
         ECPSlides[DGSelectedInd], P^ do
    begin
      DT := Max( CMSDTPropMod, Max( CMSDTImgMod, CMSDTMapRootMod ) );
      ChangedDTText := K_DateTimeToStr( DT, 'dd.mm.yyyy hh:nn:ss' );
      RFName := GetImgFName( CMSlideECFName, 'R' );
      if K_dbusECacheDel in LSUpdate then
      begin
        SaveSelected.Enabled := FALSE;            // Deleted
        SaveSelectedAs.Enabled :=
                not (cmsfIsMediaObj in CMSDB.SFlags) and
                FileExists( RFName );
        LbSlideState.Caption := format( K_CML1Form.LLLECache8.Caption + K_CML1Form.LLLECache5.Caption,
//         'Object state was saved at %s.   It was deleted later.',
                                        [ChangedDTText] )
//        'Object state was saved at ' + ChangedDTText + '.   It was deleted later.'
      end
      else
      if K_dbusECacheNew in LSUpdate then
      begin
        SaveSelected.Enabled := FALSE;            // New
        LbSlideState.Caption := format( K_CML1Form.LLLECache6.Caption,
        // 'New Object created at %s.   Source=%s',
                                        [K_DateTimeToStr( CMSDTCreated, 'dd.mm.yyyy hh:nn:ss' ),
                                         CMSSourceDescr] );
//        LbSlideState.Caption := 'New Object created at ' +
//            K_DateTimeToStr( CMSDTCreated, 'dd.mm.yyyy hh:nn:ss' ) +
//            '.   Source=' + CMSSourceDescr;
      end
      else
      if cmsfIsUsed in CMSRFlags then
      begin
      // is locked by some other user
        SaveSelected.Enabled := FALSE;
        SaveSelectedAs.Enabled :=
                not (cmsfIsMediaObj in CMSDB.SFlags) and
                FileExists( RFName );
        LbSlideState.Caption := format( K_CML1Form.LLLECache8.Caption + K_CML1Form.LLLECache7.Caption,
        // 'Object state was saved at %s.   It is now used and cannot be changed.',
                                        [ChangedDTText] );
//        LbSlideState.Caption := 'Object state was saved at ' + ChangedDTText + '.   It is now used and cannot be changed.';
      end
      else
      begin
      // is locked - check slide updates is not needed because ECache State is enough to Replace DB State if needed
        LbSlideState.Caption := format( K_CML1Form.LLLECache8.Caption,
//                       'Object state was saved at %s.'
                                       [ChangedDTText] );
//          'Object state was saved at ' + ChangedDTText + '.';
        SaveSelectedAs.Enabled :=
              not (cmsfIsMediaObj in CMSDB.SFlags) and
              FileExists( RFName );
        if LSUpdate * [K_dbusOldProps,K_dbusNewProps,
                       K_dbusOldMapRoot,K_dbusNewMapRoot,
                       K_dbusOldCurImg,K_dbusNewCurImg] <> [] then
        begin
          LbSlideState.Caption := LbSlideState.Caption + K_CML1Form.LLLECache9.Caption;
          // '   It was ñhanged later.';
//          LbSlideState.Caption := LbSlideState.Caption + '. It was already ñhanged by other user';
          SaveSelected.Enabled := SaveSelectedAs.Enabled           or
                                  (cmsfIsMediaObj in CMSDB.SFlags) or
                                  (LSUpdate = [K_dbusNewProps]);
        end;
      end;
    end;
  end;

end; // end of TK_FormCMECacheProc.ECPChangeThumbState

//*********************************** TK_FormCMECacheProc.ECPChangeThumbState1 ******
// Thumbnail Change State processing (used as TN_DGridBase.DGChangeItemStateProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - Index of Thumbnail that is change state
//
procedure TK_FormCMECacheProc.ECPChangeThumbState1(
                                   ADGObj: TN_DGridBase; AInd: integer);
var
  DT : TDateTime;
  ChangedDTText : string;
  ChangedProvText : string;
begin
  with ECPThumbsDGrid do
  begin

    SaveSelectedFull.Enabled   := (DGSelectedInd >= 0) and
                              ((DGItemsFlags[DGSelectedInd] and N_DGMarkBit) <> 0);
    DeleteSelected.Enabled := SaveSelectedFull.Enabled;

    LbSlideState.Caption := '';
    FullScreen.Enabled := FALSE;
    N_Dump2Str( 'EC>> Select0 ID=' + ECPSlides[DGSelectedInd].ObjName );
    if not SaveSelectedFull.Enabled then Exit;

    N_Dump2Str( 'EC>> Select1 ID=' + ECPSlides[DGSelectedInd].ObjName );
    with ECPSlidesLockState[DGSelectedInd],
         ECPSlides[DGSelectedInd], P^ do
    begin
      ECPSaveAsNewEnabled :=
              not (cmsfIsMediaObj in CMSDB.SFlags) and
              FileExists( GetImgFName( CMSlideECFName, 'R' ) ); // Source file Exists
      FullScreen.Enabled := ECPSaveAsNewEnabled;
      ChangedProvText := K_CMGetProviderDetails( CMSProvIDModified );
      LbSlideState.Caption := format( K_CML1Form.LLLECache10.Caption + #13#10,
//          'Created: %s'#13#10 + 'Source: %s'#13#10,
          [K_DateTimeToStr( CMSDTCreated, 'dd.mm.yyyy "at" hh:nn AM/PM' ),CMSSourceDescr] );
//          'Created: ' +
//          K_DateTimeToStr( CMSDTCreated, 'dd.mm.yyyy "at" hh:nn AM/PM' )+ #13#10 +
//          'Source: ' + CMSSourceDescr + #13#10;

      DT := Max( CMSDTPropMod, Max( CMSDTImgMod, CMSDTMapRootMod ) );
      ChangedDTText := K_DateTimeToStr( DT, 'dd.mm.yyyy "at" hh:nn AM/PM' );
      if K_dbusECacheDel in LSUpdate then
      begin
      // Deleted Slide
        ECPSaveEnabled := FALSE;
        LbSlideState.Caption := LbSlideState.Caption + format(
               K_CML1Form.LLLECache11.Caption + #13#10 + K_CML1Form.LLLECache12.Caption,
//             'Last modification by current user: %s'#13#10'Has already been deleted by now.',
                                [ChangedDTText] );
//             'Last modification by current user: ' +  ChangedDTText + #13#10 +
//             'Was already deleted now.'
      end  // if K_dbusECacheDel in LSUpdate then
      else
      if K_dbusECacheNew in LSUpdate then
      begin
      // New Slide
        ECPSaveEnabled := FALSE;
        ECPSaveAsNewEnabled := TRUE;
      end // if K_dbusECacheNew in LSUpdate then
      else
      if cmsfIsUsed in CMSRFlags then
      begin
      // is locked by some other user
        ECPSaveEnabled := FALSE;
        LbSlideState.Caption := LbSlideState.Caption + format(
               K_CML1Form.LLLECache11.Caption + #13#10 + K_CML1Form.LLLECache13.Caption,
//             'Last modification by current user: %s'#13#10'Is now being modified now by %s.',
                                [ChangedDTText,K_CMGetProviderDetails( LSProvIDLock )] );
//             'Last modification by current user: ' +  ChangedDTText + #13#10 +
//             'Is now being modified now by ' + K_CMGetProviderDetails( LSProvIDLock );
      end   // if cmsfIsUsed in CMSRFlags then
      else
      begin // other
      // is locked - check slide updates is not needed because ECache State is enough to Replace DB State if needed
        ECPSaveEnabled := TRUE;
        LbSlideState.Caption := LbSlideState.Caption + format(
                K_CML1Form.LLLECache11.Caption + #13#10,
//             'Last modification by current user: %s'#13#10,
                                [ChangedDTText] );
//             'Last modification by current user: ' +  ChangedDTText + #13#10;
        if LSUpdate * [K_dbusOldProps,K_dbusNewProps,
                       K_dbusOldMapRoot,K_dbusNewMapRoot,
                       K_dbusOldCurImg,K_dbusNewCurImg] <> [] then
        begin
          LbSlideState.Caption := LbSlideState.Caption + format(
               K_CML1Form.LLLECache14.Caption,
//             'Last modification: %s by %s.',
                                [K_DateTimeToStr( LSDTMod, 'dd.mm.yyyy "at" hh:nn AM/PM' ),
                                 K_CMGetProviderDetails( LSProvIDMod )] );
//             'Last modification: ' + K_DateTimeToStr( LSDTMod, 'dd.mm.yyyy "at" hh:nn AM/PM' ) +
//             ' by ' + K_CMGetProviderDetails( LSProvIDMod );

          ECPSaveEnabled := not ECPSaveAsNewEnabled          and
                            ( (cmsfIsMediaObj in CMSDB.SFlags) or
                              (LSUpdate = [K_dbusNewProps]) );
        end; // if LSUpdate * [K_dbusOldProps,K_dbusNewProps, ...
      end;
    end; // with ECPSlidesLockState[DGSelectedInd] ...
  end; // with ECPThumbsDGrid do
  SaveSelectedFull.Enabled := ECPSaveEnabled or ECPSaveAsNewEnabled;

end; // end of TK_FormCMECacheProc.ECPChangeThumbState1

//************************ TK_FormCMECacheProc.ShowAvailableAndProcessed ***
// Show Available and Processed
//
procedure TK_FormCMECacheProc.ShowAvailableAndProcessed;
begin
  LbVAvailable.Caption := IntToStr( ECPAvailableCount );
  LbVProcessed.Caption := IntToStr( ECPProcessedCount );
end; // end of TK_FormCMECacheProc.ShowAvailableAndProcessed

//*********************************** TK_FormCMECacheProc.DeleteSelectedElement ***
//
procedure TK_FormCMECacheProc.DeleteSelectedElement();

var
  RN, Ind : Integer;
begin
  with ECPThumbsDGrid do begin
  // Delete selected slide ECache Files
    RN := Length(ECPSlides) - 1;
    if RN > DGSelectedInd then begin
      Move( ECPSlides[DGSelectedInd + 1], ECPSlides[DGSelectedInd],
            SizeOf(TN_UDCMSlide) * (RN - DGSelectedInd) );

    // Remove Element from LockState Array
      // Clear string fields before moving
      ECPSlidesLockState[DGSelectedInd].LSCompIDMod := '';
      ECPSlidesLockState[DGSelectedInd].LSCompIDLock := '';

      // Move Array Tail to Removed position
      Move( ECPSlidesLockState[DGSelectedInd + 1], ECPSlidesLockState[DGSelectedInd],
            SizeOf(TK_CMEDBLockState) * (RN - DGSelectedInd) );
      // Fill last Element before Array SetLength - clear references to string elements
      FillChar( ECPSlidesLockState[RN], SizeOf(TK_CMEDBLockState), 0 );
    end;
    SetLength( ECPSlides, RN );
    SetLength( ECPSlidesLockState, RN );
    ECPAvailableCount := RN;
    if RN = 0 then
      CloseCancelExecute(nil)
    else begin
      Inc( ECPProcessedCount );
      ShowAvailableAndProcessed();
      DGNumItems := RN;
      DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
      Ind := DGSelectedInd;
      if Ind >= RN then
        Ind := RN - 1;
      DGMarkSingleItem( Ind );
      ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events
    end;
  end;

end; // end of TK_FormCMECacheProc.DeleteSelectedElement

//***********************************  TK_FormCMECacheProc.LoadCurImg ***
//
procedure TK_FormCMECacheProc.LoadCurImg( AUDSlide : TN_UDCMSlide );
var
  FName : string;
  DFile: TK_DFile;
begin
  with TK_CMEDDBAccess(K_CMEDAccess), AUDSlide do
  begin
    if GetCurrentImage( TRUE ) <> nil then Exit;
    FName := GetImgFName( CMSlideECFName, 'R' );
    if not K_DFOpen( FName, DFile, [] ) then
      raise Exception.Create( 'Couldn''t open ECache File ' + FName );
    if Length( BlobBuf ) < DFile.DFPlainDataSize then
      SetLength( BlobBuf, DFile.DFPlainDataSize );
    K_DFReadAll( @BlobBuf[0], DFile );
    SetCurrentImageBySData( @BlobBuf[0], DFile.DFPlainDataSize );
  end;
end; // end of TK_FormCMECacheProc.LoadCurImg

//***********************************  TK_FormCMECacheProc.LoadSrcImg ***
//
function TK_FormCMECacheProc.LoadSrcImg( AUDSlide : TN_UDCMSlide ) : Boolean;
var
  FName, WMes : string;
  DFile: TK_DFile;
begin
  with TK_CMEDDBAccess(K_CMEDAccess), AUDSlide do begin
    N_Dump2Str( 'EC>> LoadSrcImg ID=' + AUDSlide.ObjName );
    Result := GetSourceImage( TRUE, TRUE ) <> nil;
    if Result then Exit;
    FName := GetImgFName( CMSlideECFName, 'S' );
    Result := K_DFOpen( FName, DFile, [] );
    if Result then Begin
      N_Dump2Str( 'EC>> Get SrcImg from FName=' + FName );
      if Length( BlobBuf ) < DFile.DFPlainDataSize then
        SetLength( BlobBuf, DFile.DFPlainDataSize );
      K_DFReadAll( @BlobBuf[0], DFile );
      SetSourceImageBySData( @BlobBuf[0], DFile.DFPlainDataSize, EDAFreeBuffer );
    end else
    begin
      WMes := 'EC>> Get SrcImg from DB=';
      Result := GetSourceImage(FALSE, TRUE) <> nil;
      if Result then
        WMes := WMes + 'TRUE';
      N_Dump2Str( WMes );
    end;
  end;
end; // end of TK_FormCMECacheProc.LoadSrcImg

//***********************************  TK_FormCMECacheProc.TryToLoadSrcImgAndSetFlags ***
//
procedure TK_FormCMECacheProc.TryToLoadSrcImgAndSetFlags( AUDSlide : TN_UDCMSlide );
var
  PCMSMRImgAttrs : TK_PCMSMRImgAttrs;

begin
  with AUDSlide, P()^ do
  begin

    PCMSMRImgAttrs := GetPMapRootAttrs();
    if (K_smriRestoreSrcImg in PCMSMRImgAttrs.MRImgFlags) and
       LoadSrcImg( AUDSlide ) then
    begin
    // Source  Image Exists
      CMSDB.SFlags := CMSDB.SFlags + [cmsfHasSrcImg,cmsfSaveSrcImg];
      N_Dump2Str( 'EC>> SrcImg is actual and exists >> +cmsfHasSrcImg +cmsfSaveSrcImg' );
    end
    else
    begin
    // Source Image is not actual or is absent - prep Slide corresponding Flags
  //??          CMSDB.SFlags := CMSDB.SFlags - [cmsfHasSrcImg,cmsfSaveSrcImg];
      CMSDB.SFlags := CMSDB.SFlags - [cmsfHasSrcImg]; // may be it is more correct
      CMSDB.SFlags := CMSDB.SFlags + [cmsfSaveSrcImg]; // may be it is more correct
      Exclude( PCMSMRImgAttrs.MRImgFlags, K_smriRestoreSrcImg );
      N_Dump2Str( 'EC>> SrcImg is not actual or absent >> -cmsfHasSrcImg +cmsfSaveSrcImg -K_smriRestoreSrcImg' );
    end;
  end;
end; // end of TK_FormCMECacheProc.TryToLoadSrcImgAndSetFlags

//***********************************  TK_FormCMECacheProc.GetImgFName ***
//
function TK_FormCMECacheProc.GetImgFName( const AFName : string; AImgChar : Char ) : string;
begin
  Result := AFName;
  Result[Length(Result) - 4] := AImgChar;
end; // end of TK_FormCMECacheProc.GetImgFName

{
//***********************************  TK_FormCMECacheProc.CurStateToMemIni  ******
//
procedure TK_FormCMSetSlidesAttrs.CurStateToMemIni();
begin
  inherited;
end; // end of TK_FormCMECacheProc.CurStateToMemIni

//***********************************  TK_FormCMECacheProc.MemIniToCurState  ******
//
procedure TK_FormCMSetSlidesAttrs.MemIniToCurState();
begin
  inherited;
end; // end of TK_FormCMECacheProc.MemIniToCurState
}

//************************************ TK_FormCMECacheProc.ECPDrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel and may be not equal to upper left Grid pixel )
//
// Is used as value of ECPThumbsDGrid.DGDrawItemProcObj field
//
procedure TK_FormCMECacheProc.ECPDrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
begin
  with N_CM_GlobObj do  begin
    CMStringsToDraw[0] := '';

    ECPDrawSlideObj.DrawOneThumb2( ECPSlides[AInd],
                                   CMStringsToDraw, ECPThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TK_FormCMECacheProc.ECPDrawThumb

//********************************* TK_FormCMECacheProc.ECPGetThumbSize ***
// Get Thumbnail Size (used as TN_DGridBase.DGGetItemSizeProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - given Thumbnail Index
// AInpSize  - given Size on input, only one fileld (X or Y) should be <> 0
// AOutSize  - resulting Size on output, if AInpSize.X <> 0 then OutSize.Y <> 0,
//                                       if AInpSize.Y <> 0 then OutSize.X <> 0
// AMinSize  - (on output) Minimal Size
// APrefSize - (on output) Preferable Size
// AMaxSize  - (on output) Maximal Size
//
//  Is used as value of ECPThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TK_FormCMECacheProc.ECPGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide : TN_UDCMSlide;
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin
  with {N_CM_GlobObj,} ADGObj do
  begin
    Slide     := ECPSlides[AInd];
    ThumbDIB  := Slide.GetThumbnail();
    ThumbSize := ThumbDIB.DIBObj.DIBSize;

    AOutSize := Point(0,0);
    if AInpSize.X > 0 then // given is AInpSize.X
      AOutSize.Y := Round( AInpSize.X*ThumbSize.Y/ThumbSize.X ) + DGLAddDySize
    else // AInpSize.X = 0, given is AInpSize.Y
      AOutSize.X := Round( (AInpSize.Y-DGLAddDySize)*ThumbSize.X/ThumbSize.Y );

    AMinSize  := Point(10,10);
    APrefSize := ThumbSize;
    AMaxSize  := Point(1000,1000);
  end; // with N_CM_GlobObj. ADGObj do
end; // procedure TK_FormCMECacheProc.ECPGetThumbSize
{
procedure TK_FormCMECacheProc.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited;

end;
}
end.
