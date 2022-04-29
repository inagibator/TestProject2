unit K_FCMECacheRecoverMedia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ActnList, Menus, StdCtrls,
  N_BaseF, N_Rast1Fr, N_Gra2,
  K_UDT1, K_CM0;

type
  TK_FormCMCacheRecoverMedia = class(TN_BaseForm)
    VTreeFrame: TN_VTreeFrame;
    PopupMenu: TPopupMenu;
    ActionList: TActionList;
    aCheckAllMarkedObjs: TAction;
    aUncheckAllMarkedObjs: TAction;
    aRecoverSelected: TAction;
    Checkallmarkedobjectsforimport1: TMenuItem;
    Uncheckallmarkedobjects1: TMenuItem;
    Importcheckedobjects1: TMenuItem;
    BtRecover: TButton;
    GBCurPatInfo: TGroupBox;
    LbCurPatName: TLabel;
    GBCurMediaInfo: TGroupBox;
    RFrame: TN_Rast1Frame;
    LbMediaPatName: TLabel;
    LbMediaPat: TLabel;
    LbMediaClient: TLabel;
    LbMediaClientName: TLabel;
    BtCancel: TButton;
    RGSortOrder: TRadioGroup;
    procedure aCheckAllMarkedObjsExecute(Sender: TObject);
    procedure aUncheckAllMarkedObjsExecute(Sender: TObject);
    procedure aRecoverSelectedExecute(Sender: TObject);
    procedure RGSortOrderClick(Sender: TObject);
  private
    { Private declarations }
    UDRoot : TN_UDBase;      // UDRoot for Patient UDNodes
    FFNames : TStrings;
    ECCurSortOrder : Integer;
    ECFPath : string;
    YYYY, MM, DD  : string;
    HH, NN, SS : string;
    CurMediaPat : Integer;
    CurMediaPatName : string;
    EmCachePathLength : Integer;
  public
    { Public declarations }
    function  ECProcessFile( const AFName : string;
                             var APCMSlide : TN_PCMSlide ) : TN_UDBase;
    procedure ECRebuildView1( ASkipRebuild : Boolean = FALSE );
    procedure ECRebuildView2( ASkipRebuild : Boolean = FALSE );

    procedure ECSDisableActions( );
    procedure ECSVTFOnSelect( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
    procedure ECSVTFOnMouseDown( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
    procedure ECSOnDoubleClickProcObj( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState );
  end;

var
  K_FormCMCacheRecoverMedia: TK_FormCMCacheRecoverMedia;

function K_CMCacheMediaRecoveryDlg( AFNames : TStrings = nil ) : Boolean;

implementation

uses K_CLib0, K_UDC, K_UDConst, K_UDT2, K_Script1, K_CML1F,
     K_CM1, K_STBuf, K_FCMECacheProc,
     N_Types, N_Gra0, N_CompCL, N_CompBase, N_Comp1, N_CM1, N_Lib0, N_CMMain5F;

{$R *.dfm}

function K_CMCacheMediaRecoveryDlg( AFNames : TStrings = nil ) : Boolean;
var
  ML : TStrings;
  UDNode : TN_UDCMSlide;
  PCMSlide : TN_PCMSlide;
  i : Integer;
  EmCachePath : string;
begin
  K_FormCMCacheRecoverMedia := TK_FormCMCacheRecoverMedia.Create(Application);
  with K_FormCMCacheRecoverMedia, TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    ECFPath := K_CMGetECacheFilesPath();
    FFNames := AFNames;
//    Result := FALSE;
    EmCachePath := K_ExpandFileName('(#CMECacheFilesRoot#)');
    EmCachePathLength := Length(EmCachePath);
    if FFNames = nil then
    begin
      TmpStrings.Clear;
      if K_CMGAModeFlag then
        K_ScanFilesTree( EmCachePath, EDASelectDataFiles, 'F*_A.ecd' )
      else
        K_ScanFilesTree( ECFPath, EDAScanFilesTreeSelectFile, 'F*_A.ecd' );
      N_Dump1Str( format( 'ECS>> Select ECache Files Count=%d ActRTID=%d',
                                [TmpStrings.Count, AppRTID] ) );
//      if TmpStrings.Count = 0 then Exit;
      FFNames := TStringList.Create();
      FFNames.Assign( TmpStrings );
    end;

    UDRoot := TN_UDBase.Create;

    ECRebuildView1( TRUE );
    ECCurSortOrder := 0;

    VtreeFrame.CreateVTree( UDRoot, K_fvSkipCurrent + K_fvDirSortedByObjName, 3 );
    VTreeFrame.MultiMark := true;
    VTreeFrame.VTree.TreeView.ShowHint := FALSE;
    VTreeFrame.VTree.TreeView.FullExpand;
    VTreeFrame.OnMouseDownProcObj := ECSVTFOnMouseDown;
    VTreeFrame.OnSelectProcObj := ECSVTFOnSelect;
    VTreeFrame.OnDoubleClickProcObj := ECSOnDoubleClickProcObj;

    K_VTreeFrameShowFlags := K_VTreeFrameShowFlags + [K_vtfsSkipInlineEdit];

    RFrame.RFCenterInDst := True;
    RFrame.DstBackColor   := ColorToRGB( Color );
    RFrame.OCanvBackColor := ColorToRGB( Color );
    RFrame.RedrawAllAndShow();

    with K_CMEDAccess do
    begin
      ML := EDAGetPatientMacroInfo( CurPatID );
      LbCurPatName.Caption := format( '%s %s',
        [ML.Values['PatientSurname'],ML.Values['PatientFirstName']] );
      if Trim(LbCurPatName.Caption) = '' then
        LbCurPatName.Caption := format( 'Px. CN = %s',[ML.Values['PatientCardNumber']] );
    end;

    ECSDisableActions();

    Result := ShowModal() = mrOK;

    if Result then
    begin
    // Check all selected objects state - in order to check if CurPatient Slides are Recoverd
      Result := FALSE;
      with VTreeFrame.VTree do
      begin
        for i := 0 to CheckedUObjsList.Count - 1 do
        begin
          UDNode := TN_UDCMSlide( CheckedUObjsList[i] );
          PCMSlide := UDNode.P();
          with PCMSlide^ do
          if (CMSRFlags *
             [cmsfIsNew,cmsfCurImgChanged,cmsfMapRootChanged,
              cmsfAttribsChanged,cmsfThumbChanged] = []) and
             (CMSPatID = K_CMEDAccess.CurPatID) then
          begin
            Result := TRUE;
            break;
          end;
        end; // for i := 0 to CheckedUObjsList.Count - 1 do
      end; // with VTreeFrame.VTree do
    end; // if Result then

    UDRoot.UDDelete();
    RFrame.RFFreeObjects();

    if AFNames = nil then FFNames.Free;

    K_FormCMCacheRecoverMedia := nil;

  end; // with TK_FormCMScanSelectMedia.Create(Application) do

  K_VTreeFrameShowFlags := K_VTreeFrameShowFlags - [K_vtfsSkipInlineEdit];


end;

//***************************** TK_FormCMScanSelectMedia.ECSVTFOnMouseDown ***
// implementation of TN_VTreeFrame OnMouseDownProc
//
procedure TK_FormCMCacheRecoverMedia.ECSVTFOnMouseDown( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
begin
  ECSDisableActions();
end; // end of procedure TK_FormCMScanSelectMedia.ECSVTFOnMouseDown


//***************************** TK_FormCMScanSelectMedia.ECSVTFOnMouseDown ***
// implementation of TN_VTreeFrame OnMouseDownProc
//
procedure TK_FormCMCacheRecoverMedia.ECSOnDoubleClickProcObj( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState );
begin
  if (AVNode <> nil) and (Button = mbLeft) then
  begin // Marked Node
    if not (AVNode.VNUDObj is TN_UDCMSlide) then
    begin
      with TK_ScanUDSubTree.Create do
      begin
        ChangeNodesCheckedState( AVNode.VNUDObj, 0 );
        Free();
      end;
    end; // if AVNode.VNUDObj.DirChild(0) is TN_UDCMSlide then
    ECSDisableActions();
  end;

end; // end of procedure TK_FormCMScanSelectMedia.ECSVTFOnMouseDown

//******************************** TK_FormCMScanSelectMedia.ECSVTFOnSelect ***
// implementation of TN_VTreeFrame OnSelectProc
//
procedure TK_FormCMCacheRecoverMedia.ECSVTFOnSelect( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
var
  UDThumb : TN_UDBase;
  SlideECFPath : string;
  PatCardNum : string;
{
  ML : TStrings;
  PatFName : string;
  PatSName : string;
}
begin
  if (AVNode = nil ) or
     ((AVNode.VNUDObj.ObjFlags and K_fpObjTVAutoCheck) = 0) then
  begin
  // Selected Node is not Slide - Clear Slide Preview
    RFrame.RFrInitByComp( nil );
    RFrame.ShowMainBuf();
    LbMediaPat.Visible := FALSE;
    LbMediaPatName.Visible := FALSE;
    LbMediaClient.Visible := FALSE;
    LbMediaClientName.Visible := FALSE;
    Exit;
  end;


  UDThumb := AVNode.VNUDObj.DirChild(K_CMSlideIndThumbnail);

  // Show Thumbnail
  RFrame.RVCTFrInit3( TN_UDDIB(UDThumb) );
  RFrame.aFitInWindowExecute( nil );
  RFrame.RedrawAllAndShow();

  with TN_UDCMSlide(AVNode.VNUDObj), P^ do
  begin
    // Show Patient Info
    LbMediaPat.Visible := TRUE;
    LbMediaPatName.Visible := TRUE;
    if CurMediaPat <> CMSPatID then
    begin // Change Patient Info
      CurMediaPat := CMSPatID;
      PatCardNum := format( 'ID %d', [CurMediaPat] );
      CurMediaPatName := K_CMGetPatientName1( CurMediaPat, @PatCardNum );
      CurMediaPatName := format( '[%s] %s', [PatCardNum, CurMediaPatName]  );
  {
      CurMediaPatSID := IntToSTr(CMSPatID);
      ML := K_CMEDAccess.EDAGetPatientMacroInfo( CurMediaPat );

      PatFName := ML.Values['PatientFirstName'];
      PatSName := ML.Values['PatientSurname'];
      if (PatFName = '') and (PatSName = '') then
        CurMediaPatName := format( 'CN = %s',[ML.Values['PatientCardNumber']] )
      else
        CurMediaPatName := format( '%s %s', [PatFName,PatSName] );
  }
      LbMediaPatName.Caption := CurMediaPatName;
    end;

  // Show Client Info
    SlideECFPath := ExtractFilePath(CMSlideECFName);
    LbMediaClient.Visible := TRUE;
    LbMediaClientName.Visible := TRUE;
    if EmCachePathLength < Length(SlideECFPath) then
      LbMediaClientName.Caption := ExtractFileName(ExcludeTrailingPathDelimiter( SlideECFPath ))
    else
      LbMediaClientName.Caption := '(' + CMSCompIDModified + ')';
{ 1
    LbMediaClient.Visible := EmCachePathLength < Length(SlideECFPath);
    LbMediaClientName.Visible := LbMediaClient.Visible;
    if LbMediaClient.Visible then
      LbMediaClientName.Caption := ExtractFileName(ExcludeTrailingPathDelimiter( SlideECFPath ));
}
{ 0
    LbMediaClient.Visible := K_CMGAModeFlag and (EmCachePathLength < Length(SlideECFPath));
    LbMediaClientName.Visible := LbMediaClient.Visible;
    if LbMediaClient.Visible then
      LbMediaClientName.Caption := ExtractFileName(ExcludeTrailingPathDelimiter( SlideECFPath ));
}
  end; // with TN_UDCMSlide(AVNode.VNUDObj), P^ do

end; // end of procedure TK_FormCMScanSelectMedia.ECSVTFOnSelect

//************************ TK_FormCMScanSelectMedia.aCheckAllMarkedImagesExecute ***
// Set all marked images checked state for future import event handler
//
procedure TK_FormCMCacheRecoverMedia.aCheckAllMarkedObjsExecute(Sender: TObject);
var
  i : Integer;
begin
  with VTreeFrame.VTree do
  begin
    for i := MarkedVNodesList.Count - 1 downto 0 do
      with TN_VNode(MarkedVNodesList[i]) do
      begin
//        if (VNUDObj.ObjFlags and K_fpObjTVSpecMark1) <> 0 then Continue;
        with TK_ScanUDSubTree.Create do
        begin
          ChangeNodesCheckedState( VNUDObj, 1 );
          Free();
        end;
      end;
  end;
  VTreeFrame.TreeView.Repaint;
  ECSDisableActions();
end; // procedure TK_FormCMScanSelectMedia.aCheckAllMarkedImagesExecute

//***************** TK_FormCMScanSelectMedia.aUncheckAllMarkedImagesExecute ***
// Clear all marked images checked state to prevent future import event handler
//
procedure TK_FormCMCacheRecoverMedia.aUncheckAllMarkedObjsExecute(Sender: TObject);
var
  i : Integer;
begin
  with VTreeFrame.VTree do
  begin
    for i := MarkedVNodesList.Count - 1 downto 0 do
      with TN_VNode(MarkedVNodesList[i]) do
      begin
//        if (VNUDObj.ObjFlags and K_fpObjTVSpecMark1) <> 0 then Continue;
        with TK_ScanUDSubTree.Create do
        begin
          ChangeNodesCheckedState( VNUDObj, -1 );
          Free();
        end;
      end;
  end;
  VTreeFrame.TreeView.Repaint;
  ECSDisableActions();
end; // procedure TK_FormCMScanSelectMedia.aUncheckAllMarkedImagesExecute

//************************ TK_FormCMScanSelectMedia.aRecoverSelectedExecute ***
// Import all checked images event handler
//
procedure TK_FormCMCacheRecoverMedia.aRecoverSelectedExecute(Sender: TObject);
var
  i, NewInd : Integer;
  FL : TStringList;
  UDNode : TN_UDCMSlide;
  SelectedSlides : TN_UDCMSArray;
begin

  N_Dump2Str( 'SCS> RecoverSelected Start' );
  FL := TStringList.Create;

  with VTreeFrame.VTree do
  begin
    for i := 0 to CheckedUObjsList.Count - 1 do
    begin
      UDNode := TN_UDCMSlide( CheckedUObjsList[i] );
      FL.AddObject( UDNode.CMSlideECFName, UDNode );
    end; // for i := 0 to CheckedUObjsList.Count - 1 do
  end; // with VTreeFrame.VTree do

  FL.Sort();
  NewInd := -1;
  SetLength( SelectedSlides, FL.Count );
  for i := 0 to FL.Count - 1 do
  begin
    SelectedSlides[i] := TN_UDCMSlide( FL.Objects[i] );
    Inc( SelectedSlides[i].RefCounter ); // To Prevent real Slides destroy inside K_CMECacheFilesProcessDlg
    if (NewInd = -1) and (cmsfIsNew in SelectedSlides[i].P.CMSRFlags) then
      NewInd := i;
  end;
  FL.Free;
  K_CMECacheFilesProcessDlg( @SelectedSlides[0], Length(SelectedSlides), NewInd );

  ModalResult := mrOK;

end; // procedure TK_FormCMScanSelectMedia.aRecoverSelectedExecute

//****************************** TK_FormCMScanSelectMedia.ECSDisableActions ***
// Check all actions enabled disabled state
//
procedure TK_FormCMCacheRecoverMedia.ECSDisableActions;
begin

  with VTreeFrame.VTree do
  begin
    aRecoverSelected.Enabled := CheckedUObjsList.Count <> 0;
  end;
end; // procedure TK_FormCMScanSelectMedia.ECSDisableActions;

//********************************** TK_FormCMScanSelectMedia.ECProcessFile ***
// Check all actions enabled disabled state
//
function TK_FormCMCacheRecoverMedia.ECProcessFile( const AFName : string;
                                                   var APCMSlide : TN_PCMSlide ) : TN_UDBase;
var
  DFile: TK_DFile;
  DSize : Integer;
  WCPat : string;
  WCPath : string;
  ECFName : string;
  UDSlide : TN_UDCMSlide;
  UDName1, UDName2 : string;
begin
  Result := nil;

  if K_CMGAModeFlag then
    ECFName := AFName
  else
    ECFName := ECFPath + AFName;

  if not K_DFOpen( ECFName, DFile, [K_dfoProtected] ) then
  begin
    N_Dump1Str( format( 'ECS> SLide A-file Open error="%s" File=%s',
                [K_DFGetErrorString(DFile.DFErrorCode), ECFName] ) );
    Exit;
  end;

  DSize := DFile.DFPlainDataSize;

  if DSize = 0 then
  begin
    N_Dump1Str( format( 'ECS> SLide A-file is empty File=%s', [ECFName] ) );
    Exit;
  end;

  if SizeOf(Char) = 2 then
    DSize := DSize shr 1;
  SetLength( K_CMEDAccess.StrTextBuf, DSize );
  if not K_DFReadAll( @K_CMEDAccess.StrTextBuf[1], DFile ) then
  begin
    N_Dump1Str( format( 'ECS> SLide A-file Read error="%s" File=%s',
                [K_DFGetErrorString(DFile.DFErrorCode),ECFName] ) );
    Exit;
  end;

  K_SerialTextBuf.LoadFromText( K_CMEDAccess.StrTextBuf );

  UDSlide := TN_UDCMSlide( K_LoadTreeFromText( K_SerialTextBuf ) );
  if UDSlide = nil then
  begin
    N_Dump1Str( format( 'ECS> Wrong File Format File=%s', [ECFName] ) );
    WCPat := ChangeFileExt( ExtractFileName(AFName), '' );
    WCPat := Copy( WCPat, 1, Length(WCPat) - 1 ) + '*.*';
    WCPath := ExtractFilePath(ECFName);
    K_DeleteFolderFiles( WCPath, WCPat, [] ); // Del ECache Main + Image or Video Files
    N_Dump1Str( 'ECS> Files ' + WCPath + WCPat + ' were deleted' );
    Exit;
  end;

  with UDSlide do
  begin
    UDSlide.ObjFlags := UDSlide.ObjFlags or K_fpObjTVAutoCheck;
    CMSlideECFName := ECFName;
    APCMSlide := P();
    with APCMSlide^ do
    begin
      if cmsfIsMediaObj in APCMSlide^.CMSDB.SFlags then
        UDName1 := 'Video'
      else
        UDName1 := 'Image';

      if cmsfIsNew in APCMSlide^.CMSRFlags then
        UDName2 := 'New'
      else
        UDName2 := 'Edited';
    end; // with APCMSlide^ do

    ObjAliase := format( '%s:%s:%s, %s, %s', [HH,NN,SS,UDName1,UDName2] );
  end; // with UDSlide do
  Result := UDSlide;
end; // procedure TK_FormCMScanSelectMedia.ECProcessFile

//********************************* TK_FormCMScanSelectMedia.ECRebuildView1 ***
// Rebuild View1
//
procedure TK_FormCMCacheRecoverMedia.ECRebuildView1( ASkipRebuild : Boolean = FALSE );
var
  i, FNameLength : Integer;
  UDSlide : TN_UDBase;
  UDPat : TN_UDBase;
  UDDate : TN_UDBase;
  PrevSDate, SDate : string;
  PCMSlide : TN_PCMSlide;
  PatUDName, PatName, PatFName, PatSName : string;

  FName : string;
  ML : TStrings;
begin

  PrevSDate := '';
  UDDate := nil;
  UDPat := nil;
  PCMSlide := nil;
  for i := 0 to FFNames.Count - 1 do
  begin
    FName := FFNames[i];

    // Get Timestamp info
    FNameLength := Length( FName ) - 20;
    YYYY := '20' + Copy( FName, FNameLength, 2 );
    MM := Copy( FName, FNameLength + 2, 2 );
    DD := Copy( FName, FNameLength + 4, 2 );
    HH := Copy( FName, FNameLength + 6, 2 );
    NN := Copy( FName, FNameLength + 8, 2 );
    SS := Copy( FName, FNameLength + 10, 2 );

    UDSlide := ECProcessFile( FName, PCMSlide );

    // Prepare Date Node
    SDate := YYYY + '/' + MM  + '/' + DD;
    if (UDDate = nil) or (UDDate.ObjAliase <> SDate) then
    begin // Add New Date Node

      if UDDate <> nil then
        UDDate := UDRoot.DirChildByObjName( SDate, K_ontObjAliase );

      if UDDate = nil then
      begin
        UDDate := TN_UDBase.Create;
        UDDate.ObjName := YYYY + MM  + DD;
        UDDate.ObjAliase := SDate;
        UDRoot.AddOneChild( UDDate );
      end;

      UDPat := nil; // Clear previos Patient Node
    end; // if (UDDate = nil) or (UDDate.ObjAliase <> SDate) then

    // Prepare Patient Node
    ML := K_CMEDAccess.EDAGetPatientMacroInfo( PCMSlide.CMSPatID );

    PatFName := ML.Values['PatientFirstName'];
    PatSName := ML.Values['PatientSurname'];
    if (PatFName = '') and (PatSName = '') then
    begin
//      PatUDName := 'CN=' + ML.Values['PatientCardNumber'];
//      PatName := format( 'Px. CN = %s',[ML.Values['PatientCardNumber']] );
        PatUDName := K_CMGetPatientName1( PCMSlide.CMSPatID );
        PatName := PatUDName;
    end
    else
    begin
      PatUDName := PatSName + PatFName;
      PatName := PatSName + ' ' + PatFName;
    end;

    if (UDPat = nil) or (UDPat.ObjName <> PatUDName) then
    begin
      if UDPat <> nil then
        UDPat := UDDate.DirChildByObjName( PatUDName );

      if UDPat = nil then
      begin
        UDPat := TN_UDBase.Create;
        UDPat.ObjName := PatUDName;
        UDPat.PrepareObjName( 0, ' ' );
        UDPat.ObjAliase := PatName;
        UDDate.AddOneChild( UDPat );
      end;
    end;

    UDPat.AddOneChild( UDSlide );

  end; // for i := 0 to AFNames.Count - 1do

  if ASkipRebuild then Exit;
  VtreeFrame.RebuildVTree( UDRoot );
  VTreeFrame.VTree.TreeView.FullExpand;

end; // procedure TK_FormCMScanSelectMedia.ECRebuildView1

//********************************* TK_FormCMScanSelectMedia.ECRebuildView2 ***
// Rebuild View2
//
procedure TK_FormCMCacheRecoverMedia.ECRebuildView2( ASkipRebuild : Boolean = FALSE);
var
  i, FNameLength : Integer;
  UDSlide : TN_UDBase;
  UDPat : TN_UDBase;
  UDDate : TN_UDBase;
  SDate : string;
  PCMSlide : TN_PCMSlide;
  PatUDName, PatName, PatFName, PatSName : string;

  FName : string;
  ML : TStrings;
begin

  UDDate := nil;
  UDPat := nil;
  PCMSlide := nil;
  for i := 0 to FFNames.Count - 1 do
  begin
    FName := FFNames[i];

    // Get Timestamp info
    FNameLength := Length( FName ) - 20;
    YYYY := '20' + Copy( FName, FNameLength, 2 );
    MM := Copy( FName, FNameLength + 2, 2 );
    DD := Copy( FName, FNameLength + 4, 2 );
    HH := Copy( FName, FNameLength + 6, 2 );
    NN := Copy( FName, FNameLength + 8, 2 );
    SS := Copy( FName, FNameLength + 10, 2 );

    UDSlide := ECProcessFile( FName, PCMSlide );

    // Prepare Patient Node
    ML := K_CMEDAccess.EDAGetPatientMacroInfo( PCMSlide.CMSPatID );

    PatFName := ML.Values['PatientFirstName'];
    PatSName := ML.Values['PatientSurname'];
    if (PatFName = '') and (PatSName = '') then
    begin
      PatUDName := 'CN=' + ML.Values['PatientCardNumber'];
      PatName := format( 'Px. CN = %s',[ML.Values['PatientCardNumber']] );
    end
    else
    begin
      PatUDName := PatSName + PatFName;
      PatName := PatSName + ' ' + PatFName;
    end;

    if (UDPat = nil) or (UDPat.ObjName <> PatUDName) then
    begin
      if UDPat <> nil then
        UDPat := UDDate.DirChildByObjName( PatUDName );

      if UDPat = nil then
      begin
        UDPat := TN_UDBase.Create;
        UDPat.ObjName := PatUDName;
        UDPat.ObjAliase := PatName;
        UDRoot.AddOneChild( UDPat );
      end;
      UDDate := nil; // Clear previos Patient Node
    end;

    // Prepare Date Node
    SDate := YYYY + '/' + MM  + '/' + DD;
    if (UDDate = nil) or (UDDate.ObjAliase <> SDate) then
    begin // Add New Date Node

      if UDDate <> nil then
        UDDate := UDPat.DirChildByObjName( SDate, K_ontObjAliase );

      if UDDate = nil then
      begin
        UDDate := TN_UDBase.Create;
        UDDate.ObjName := YYYY + MM  + DD;
        UDDate.ObjAliase := SDate;
        UDPat.AddOneChild( UDDate );
      end;
    end;

    UDDate.AddOneChild( UDSlide );

  end; // for i := 0 to AFNames.Count - 1do

  if ASkipRebuild then Exit;
  VtreeFrame.RebuildVTree( UDRoot );
  VTreeFrame.VTree.TreeView.FullExpand;

end; // procedure TK_FormCMScanSelectMedia.ECRebuildView2

procedure TK_FormCMCacheRecoverMedia.RGSortOrderClick(Sender: TObject);
begin
  if RGSortOrder.ItemIndex = ECCurSortOrder then Exit;
  UDRoot.ClearChilds();
  // Clear Selected state
  ECSVTFOnSelect( VTreeFrame, nil, mbLeft, [] );
  ECCurSortOrder := RGSortOrder.ItemIndex;
  case ECCurSortOrder of
    0 : ECRebuildView1();
    1 : ECRebuildView2();
  end;
end; // procedure TK_FormCMScanSelectMedia.RGSortOrderClick

end.


