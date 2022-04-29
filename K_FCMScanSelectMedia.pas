unit K_FCMScanSelectMedia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ActnList, Menus, StdCtrls,
  N_BaseF, N_Rast1Fr, N_Gra2,
  K_UDT1, K_CM0, K_Types, System.Actions;

type
  TK_FormCMScanSelectMedia = class(TN_BaseForm)
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
    BtCancel: TButton;
    LbSelectWarning: TLabel;
    RGSortOrder: TRadioGroup;
    GBView: TGroupBox;
    ChBShowRecovered: TCheckBox;
    RBOnline: TRadioButton;
    RBOffline: TRadioButton;

    procedure aCheckAllMarkedObjsExecute(Sender: TObject);
    procedure aUncheckAllMarkedObjsExecute(Sender: TObject);
    procedure aRecoverSelectedExecute(Sender: TObject);
    procedure RGSortOrderClick(Sender: TObject);
    procedure ChBShowRecoveredClick(Sender: TObject);
    procedure RBOfflineClick(Sender: TObject);
  private
    { Private declarations }
    CurCheckSelectState : string;
    UDRoot : TN_UDBase;      // UDRoot for Patient UDNodes
    FFNames : TStrings;
    SCCurSortOrder : Integer;
    SCShowOffline, SCShowOnline, SCShowRecovered : Boolean;
    SCSkipReorder : Boolean;

    SCSTopUDNode : TN_UDBase;
    SCSTopUDNodeName : string;

    function SCSTestUDObjName( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                  ChildInd : Integer; ChildLevel : Integer;
                                  const FieldName : string = '' ) : TK_ScanTreeResult;
  public
    { Public declarations }

    function  SCLoadTextFile( const AFileName : string ) : Boolean;
    procedure SCProcessFile( const AFName, AScanTaskFolder : string;
                             AUDScan : TN_UDBase; ASL : TStrings;
                             var AInd : Integer;
                             var APCMSlide : TN_PCMSlide );
    procedure SCRemoveEmptyTreeNodes( AUDRoot : TN_UDBase );
    procedure SCRebuildView1( ASkipRebuild : Boolean = FALSE );
    procedure SCRebuildView2( ASkipRebuild : Boolean = FALSE );

    procedure SCSDisableActions( );
    procedure SCSVTFOnSelect( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
    procedure SCSVTFOnMouseDown( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
    procedure SCSOnDoubleClickProcObj( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState );
    procedure MemIniToCurState   (); override;
    procedure CurStateToMemIni   (); override;
  end;

var
  K_FormCMScanSelectMedia: TK_FormCMScanSelectMedia;

function K_CMScanSelectMediaDlg( AFNames : TStrings ) : Boolean;

implementation

uses ComCtrls,
     K_CLib0, K_UDC, K_UDConst, K_UDT2, K_Script1, K_CML1F, K_FCMScan,
     K_CM1, K_STBuf,
     N_Types, N_Gra0, N_CompCL, N_CompBase, N_Comp1, N_CM1, N_Lib0, N_CMMain5F,
     N_ClassRef, N_Lib1;

{$R *.dfm}

function K_CMScanSelectMediaDlg( AFNames : TStrings ) : Boolean;
begin

  K_FormCMScanSelectMedia := TK_FormCMScanSelectMedia.Create(Application);
  with K_FormCMScanSelectMedia, K_CMEDAccess do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    UDRoot := TN_UDBase.Create;
    FFNames := AFNames;

//    SCRebuildView1( TRUE );
    SCCurSortOrder := 0;

    VtreeFrame.CreateVTree( UDRoot, K_fvSkipCurrent + K_fvDirSortedByObjName, 4 );
    VTreeFrame.MultiMark := true;
    VTreeFrame.VTree.TreeView.FullExpand;
    VTreeFrame.OnMouseDownProcObj := SCSVTFOnMouseDown;
    VTreeFrame.OnSelectProcObj := SCSVTFOnSelect;
    VTreeFrame.OnDoubleClickProcObj := SCSOnDoubleClickProcObj;

    K_VTreeFrameShowFlags := K_VTreeFrameShowFlags + [K_vtfsSkipInlineEdit];


    LbCurPatName.Caption := K_FormCMScan.SCScanTaskPatName;
{
    with K_FormCMScan.SCSTask do
    begin
      LbCurPatName.Caption := format( '%s %s',
        [Values['PatientSurname'],Values['PatientFirstName']] );
      if Trim(LbCurPatName.Caption) = '' then
        LbCurPatName.Caption := format( 'Px. ID %s',[Values['CurPatID']] );
    end;
}
    RGSortOrderClick(nil);

    RFrame.RFCenterInDst := True;
    RFrame.DstBackColor   := ColorToRGB( Color );
    RFrame.OCanvBackColor := ColorToRGB( Color );
    RFrame.RedrawAllAndShow();


    SCSDisableActions();

    Result := ShowModal() = mrOK;

    UDRoot.UDDelete();
    RFrame.RFFreeObjects();

    K_FormCMScanSelectMedia := nil;

  end; // with TK_FormCMScanSelectMedia.Create(Application) do

  K_VTreeFrameShowFlags := K_VTreeFrameShowFlags - [K_vtfsSkipInlineEdit];


end;

//******************************* TK_FormCMScanSelectMedia.LoadScanTaskFile ***
// Load Text File to K_CMEDAccess.TmpStrings
//
//    Parameters
//  AFileName - file name to load
//  Result - Returns TRUE if success
//
function TK_FormCMScanSelectMedia.SCLoadTextFile( const AFileName : string ) : Boolean;
var
  ErrStr : string;
  ErrCode : Integer;

begin
  N_T1.Start();
  ErrStr := K_VFLoadStrings1( AFileName, K_CMEDAccess.TmpStrings, ErrCode );
  N_T1.Stop();
  Result := ErrStr = '';
  if Result then Exit;
  N_Dump1Str( 'SC> Load Error >> ' + AFileName + #13#10'>>' + ErrStr );
end; // function TK_FormCMScanSelectMedia.SCLoadTextFile

//***************************** TK_FormCMScanSelectMedia.SCSVTFOnMouseDown ***
// implementation of TN_VTreeFrame OnMouseDownProc
//
procedure TK_FormCMScanSelectMedia.SCSVTFOnMouseDown( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
var
  WS : string;
//  i : Integer;
begin
{
  if AVNode <> nil then
  begin
    if VTreeFrame.VTree.MarkedVNodesList.Count = 0 then
    begin
      AVNode.Mark();
      VTreeFrame.TreeView.Repaint;
    end;
  end;
}
{ Skip Popup menu
  if Button = mbRight then
    with Mouse.CursorPos do
      PopupMenu.Popup( X, Y );
}
  if VTreeFrame.VTree.CheckedUObjsList.IndexOf( AVNode.VNUDObj ) <> -1 then
  begin
    with TK_UDStringList(AVNode.VNUDObj.Owner).SL do
      WS := format( '%s,%s,%s,%s,%s,%s',
                    [Values['MTypeID'],Values['DModality'],Values['DKVP'],
                     Values['DExpTime'],Values['DTubeCur'],Values['CurPatID']] );
    if (CurCheckSelectState <> '') and (CurCheckSelectState <> WS) then
    begin
    // Clear All prevouse
      with VTreeFrame.VTree do
        with TK_ScanUDSubTree.Create do
        begin
          ChangeNodesCheckedState( UDRoot, -1 );
{
//          Use this code instead
          for i := CheckedUObjsList.Count - 1 to 0 do
            with TN_UDBase(CheckedUObjsList[i]) do
            begin
              ObjFlags := ObjFlags and not K_fpObjTVChecked;
              CheckedUObjsList.Delete(i);
              RebuildVNodes();
            end;
}
          ChangeNodesCheckedState( AVNode.VNUDObj, 1 );
          Free();
        end;
//      K_CMShowSoftMessageDlg( LbSelectWarning.Caption, mtWarning, 5 );
    end;
    CurCheckSelectState := WS;
  end
  else
  begin
    if VTreeFrame.VTree.CheckedUObjsList.Count = 0 then
      CurCheckSelectState := '';
  end;
  SCSDisableActions();
end; // end of procedure TK_FormCMScanSelectMedia.SCSVTFOnMouseDown


//***************************** TK_FormCMScanSelectMedia.SCSVTFOnMouseDown ***
// implementation of TN_VTreeFrame OnMouseDownProc
//
procedure TK_FormCMScanSelectMedia.SCSOnDoubleClickProcObj( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState );
var
  WS : string;
  ShowWarn : Boolean;
//  i : Integer;
begin
  if (AVNode <> nil) and (Button = mbLeft) then
  begin // Marked Node
    if AVNode.VNUDObj is TK_UDStringList then
    begin
      with TK_UDStringList(AVNode.VNUDObj).SL do
      WS := format( '%s,%s,%s,%s,%s,%s',
                    [Values['MTypeID'],Values['DModality'],Values['DKVP'],
                     Values['DExpTime'],Values['DTubeCur'],Values['CurPatID']] );
      ShowWarn := (CurCheckSelectState <> '') and (CurCheckSelectState <> WS);
      with TK_ScanUDSubTree.Create do
      begin
        if ShowWarn then
         ChangeNodesCheckedState( UDRoot, -1 );
{
//         Use this code instead
          for i := VTreeFrame.VTree.CheckedUObjsList.Count - 1 to 0 do
            with TN_UDBase(VTreeFrame.VTree.CheckedUObjsList[i]) do
            begin
              ObjFlags := ObjFlags and not K_fpObjTVChecked;
              VTreeFrame.VTree.CheckedUObjsList.Delete(i);
              RebuildVNodes();
            end;
}
        ChangeNodesCheckedState( AVNode.VNUDObj, 0 );
        Free();
      end;
//      if ShowWarn then
//        K_CMShowSoftMessageDlg( LbSelectWarning.Caption, mtWarning, 5 );

      CurCheckSelectState := WS;
      if VTreeFrame.VTree.CheckedUObjsList.Count = 0 then
        CurCheckSelectState := '';
    end; // if AVNode.VNUDObj is TK_UDStringList then
    SCSDisableActions();
  end;
end; // end of procedure TK_FormCMScanSelectMedia.SCSVTFOnMouseDown

//******************************** TK_FormCMScanSelectMedia.SCSVTFOnSelect ***
// implementation of TN_VTreeFrame OnSelectProc
//
procedure TK_FormCMScanSelectMedia.SCSVTFOnSelect( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
var
  UDThumb : TN_UDBase;
  UDTaskNode : TN_UDBase;

  procedure ShowPatient(  );
  begin
    LbMediaPat.Visible := (UDTaskNode <> nil) and (UDTaskNode is TK_UDStringList);
    LbMediaPatName.Visible := LbMediaPat.Visible;
    if LbMediaPat.Visible then
    begin
      with TK_UDStringList(UDTaskNode).SL do
        LbMediaPatName.Caption := format( '%s %s',
             [Values['PatientSurname'],Values['PatientFirstName']] );
     if Trim(LbMediaPatName.Caption) = '' then
        LbMediaPatName.Caption := '???';
    end;
  end;

begin
  if (AVNode = nil ) or
//     (AVNode.VNUDObj.ObjName[1] <> 'M') then
     ((AVNode.VNUDObj.ObjFlags and K_fpObjTVAutoCheck) = 0) then
  begin
  // Selected Node is not Slide - Clear Slide Preview
    RFrame.RFrInitByComp( nil );
    RFrame.ShowMainBuf();

    UDTaskNode := nil;
    if (AVNode <> nil) then UDTaskNode := AVNode.VNUDObj;
    ShowPatient( );
{
    LbMediaPat.Visible := (AVNode <> nil) and (AVNode.VNUDObj is TK_UDStringList);
    LbMediaPatName.Visible := LbMediaPat.Visible;
    if LbMediaPat.Visible then
      with TK_UDStringList(AVNode.VNUDObj).SL do
        LbMediaPatName.Caption := format( '%s %s',
             [Values['PatientSurname'],Values['PatientFirstName']] );
}
    Exit;
  end;

  UDTaskNode := AVNode.VNUDObj.Owner;
  ShowPatient( );

  UDThumb := AVNode.VNUDObj.DirChild(K_CMSlideIndThumbnail);

  // Show Thumbnail
  RFrame.RVCTFrInit3( TN_UDDIB(UDThumb) );
  RFrame.aFitInWindowExecute( nil );
  RFrame.RedrawAllAndShow();
{
  LbMediaPat.Visible := TRUE;
  LbMediaPatName.Visible := TRUE;
  with TK_UDStringList(AVNode.VNUDObj.Owner).SL do
    LbMediaPatName.Caption := format( '%s %s',
        [Values['PatientSurname'],Values['PatientFirstName']] );
}
end; // end of procedure TK_FormCMScanSelectMedia.SCSVTFOnSelect

//************************ TK_FormCMScanSelectMedia.aCheckAllMarkedImagesExecute ***
// Set all marked images checked state for future import event handler
//
procedure TK_FormCMScanSelectMedia.aCheckAllMarkedObjsExecute(Sender: TObject);
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
  SCSDisableActions();
end; // procedure TK_FormCMScanSelectMedia.aCheckAllMarkedImagesExecute

//***************** TK_FormCMScanSelectMedia.aUncheckAllMarkedImagesExecute ***
// Clear all marked images checked state to prevent future import event handler
//
procedure TK_FormCMScanSelectMedia.aUncheckAllMarkedObjsExecute(Sender: TObject);
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
  SCSDisableActions();
end; // procedure TK_FormCMScanSelectMedia.aUncheckAllMarkedImagesExecute

//************************ TK_FormCMScanSelectMedia.aRecoverSelectedExecute ***
// Import all checked images event handler
//
procedure TK_FormCMScanSelectMedia.aRecoverSelectedExecute(Sender: TObject);
var
  i : Integer;
  DNum : Integer;
  FL : TStringList;
  UDNode : TN_UDBase;
  CurPatSurname, CurPatFirstname, CurPatID : string;
  WS, NodePatID : string;
  SAFileName, AFileName : string;
  SrcLocFolder : string;
  SrcFileName : string;
  NewFileName : string;
  NewVFileName : string;
  DSize : Integer;
  PData : Pointer;
begin

  N_Dump2Str( 'SCS> RecoverSelected Start' );
  FL := TStringList.Create;

  with K_FormCMScan.SCSTask do
  begin
    CurPatSurname := Values['PatientSurname'];
    CurPatFirstname := Values['PatientFirstName'];
    CurPatID := Values['CurPatID'];
  end;

  DNum := 0;

  with VTreeFrame.VTree do
  begin
    for i := 0 to CheckedUObjsList.Count - 1 do
    begin
      UDNode := TN_UDBase( CheckedUObjsList[i] );
      with TK_UDStringList(UDNode.Owner) do
      begin
        NodePatID := SL.Values['CurPatID'];
        if (NodePatID = '') and
           ( (SL.Values['PatientSurname'] <> CurPatSurname) or
             (SL.Values['PatientFirstName'] <> CurPatFirstname) ) then
        begin
          UDNode.LastVNode.Mark();
          Inc(DNum);
        end;
{ !!! needed only if different patients are selected
        WS := '-';
        if (NodePatID = CurPatID) or (NodePatID = '') then
          WS := '+';
        SL.AddObject( WS + UDNode.ObjName, UDNode );
}
        FL.AddObject( UDNode.ObjName, UDNode );
      end; // with TK_UDStringList(UDNode.Owner) do
    end; // for i := 0 to CheckedUObjsList.Count - 1 do
  end; // with VTreeFrame.VTree do

  if DNum > 0 then
  begin
    VTreeFrame.TreeView.Repaint;
    WS := format('%s %s', [CurPatSurname, CurPatFirstname] );
    if Trim(WS) = '' then
      WS := format('ID %s', [CurPatID] );
    if mrYes <> K_CMShowMessageDlg( format(
                                    'There are objects selected for patient(s) whose details mismatch the current patient %s.'#13#10 +
                                    '       Would you like to save these objects in the patient %s file?'#13#10 +
                                    '                   Press “Yes” to save, “No” to cancel recovery.',
                                    [WS, WS] ),
                              mtConfirmation,  [mbYes, mbNo] ) then Exit;
  end;

  FL.Sort();

  // Prepare Local Task files and folder
  with K_FormCMScan do
  begin
    SCScanTaskLocFolder := SCScanRootLocFolder + Copy( SCScanTaskFolder, Length(SCScanTaskFolder) - 16, 17 );
    SCScanTaskLocRFile  := SCScanRootLocFolder + Copy( SCScanTaskRFile, Length(SCScanTaskRFile) - 19, 20 );
    K_ForceDirPath( SCScanTaskLocFolder );
    SCSTask.Add( 'Remove=TRUE' ); // task should be removed from Local Storage after files transfer

    // Get Current Task R-file content from any of Source Task R-files
    UDNode := TN_UDBase( FL.Objects[0] );
    SrcFileName := UDNode.ObjName;
    SrcFileName := ExtractFilePath( SrcFileName ) + 'txt';
    i := Length(SrcFileName);
    SrcFileName[i-3] := '.';
    SrcFileName[i-19] := 'R';
    SCLoadTextFile( SrcFileName );
    SCRTask.Assign( K_CMEDAccess.TmpStrings );
    SCRTask.Values['IsDone'] := 'TRUE';
    SCRTask.Values['ScanCount'] := IntToStr(FL.Count); // Set Results Count

  // Add DevicePlatesInfo to Upload r-file
    SCDevicePlatesInfoToUpload();

    SCUpdateTaskLocFile( SCScanTaskLocRFile, SCRTask );
    N_Dump2Str( 'SCS> Recover Task Start >> ' + SCScanTaskLocRFile );

    // Copy Files Loop
    for i := 0 to FL.Count - 1 do
    begin
      UDNode := TN_UDBase( FL.Objects[i] );
      SAFileName := UDNode.ObjName;
      AFileName := ExtractFileName( UDNode.ObjName );
      N_Dump2Str( 'SCS> Copy Start Slide >> ' + IntToStr(i) );
      SrcLocFolder := ExtractFilePath( UDNode.ObjName );
      NodePatID := TK_UDStringList(UDNode.Owner).SL.Values['CurPatID'];
      with TN_UDCMSlide(UDNode), P^ do
      begin
        if (NodePatID = '') then
        begin // Slide was scaned in Setup Mode
          // Correct Patient, Provider, Location
          with SCSTask do
          begin
            CMSProvIDCreated := StrToInt(Values['CurProvID']);
            CMSProvIDModified := CMSProvIDCreated;
            CMSLocIDCreated := StrToInt(Values['CurLocID']);
            CMSLocIDModified := CMSLocIDCreated;
          end;
          CMSPatID := StrToInt(CurPatID);

          // Build New File Name
          ObjName := IntToStr(i) + 'new';
          NewFileName := format('%sF%s_%d_%d_%s', [SCScanTaskLocFolder, GetIDForFileName(),
                                     CMSProvIDCreated, CMSPatID,
                                     Copy( AFileName, Length(AFileName) - 20, 21 )]);

          NewVFileName := NewFileName;
          if cmsfIsMediaObj in CMSDB.SFlags then
          begin // Video Slide
            SrcFileName := CMSDB.MediaFExt;
            NewVFileName := copy( NewFileName, 1, Length(NewFileName) - 4 );
            NewVFileName[Length(NewVFileName)] := 'V';
            CMSDB.MediaFExt := NewVFileName + ExtractFileExt(CMSDB.MediaFExt);
            K_CopyFile( SrcFileName, CMSDB.MediaFExt );
            N_Dump2Str( format( 'SCS> Copy  %s >> %s ', [SrcFileName, CMSDB.MediaFExt] ) );
          end   // if cmsfIsMediaObj in CMSDB.SFlags then
          else
          begin // Image Slide
            // Copy Slide CurImage File
            AFileName[Length(AFileName) - 4] := 'R';
            SrcFileName := SrcLocFolder + AFileName;
            NewVFileName[Length(NewVFileName) - 4] := 'R';
            K_CopyFile( SrcFileName, NewVFileName );
            N_Dump2Str( format( 'SCS> Copy  %s >> %s ', [SrcFileName, NewVFileName] ) );

            // Copy Slide SrcImage File
            SrcFileName[Length(SrcFileName) - 4] := 'S';
            if FileExists(SrcFileName) then
            begin
              NewVFileName[Length(NewVFileName) - 4] := 'S';
              K_CopyFile( SrcFileName, NewVFileName );
              N_Dump2Str( format( 'SCS> Copy  %s >> %s ', [SrcFileName, NewVFileName] ) );
            end;
          end; // if not (cmsfIsMediaObj in CMSDB.SFlags) then

          // Save Slide A-file with new attributes
          K_SaveTreeToText( UDNode, K_SerialTextBuf );
          K_CMEDAccess.StrTextBuf := K_SerialTextBuf.TextStrings.Text;
          DSize := Length(K_CMEDAccess.StrTextBuf);
          PData := @K_CMEDAccess.StrTextBuf[1];
          CMSlideECFStream := TFileStream.Create( NewFileName, fmCreate );
          K_DFStreamWriteAll( CMSlideECFStream, K_DFCreateProtected, PData,
                                                            DSize * SizeOf(Char) );

//          FlushFileBuffers( CMSlideECFStream.Handle );
         if not FlushFileBuffers(CMSlideECFStream.Handle) then
           N_Dump1Str( format( '!!! File %s >> FlushFileBuffers Error >> %s', [NewFileName,SysErrorMessage(GetLastError())] ) );
          FreeAndNil( CMSlideECFStream );
          N_Dump2Str( 'SCS> Create  >> ' + NewFileName );

        end   // if (NodePatID = '') then  // Slide was scaned in Setup Mode
        else
        begin // if (NodePatID <> '') then // Slide was scaned in Task Mode
          NewFileName := SCScanTaskLocFolder + AFileName;
          K_CopyFile( ObjName, NewFileName );
          N_Dump2Str( format( 'SCS> Copy  %s >> %s ', [ObjName, NewFileName] ) );
          if cmsfIsMediaObj in CMSDB.SFlags then
          begin // Video Slide
            SrcFileName := ExtractFileName(CMSDB.MediaFExt);
            NewVFileName := SCScanTaskLocFolder + SrcFileName;
            SrcFileName := SrcLocFolder + SrcFileName;
            K_CopyFile( SrcFileName, NewVFileName );
            N_Dump2Str( format( 'SCS> Copy  %s >> %s ', [SrcFileName, NewVFileName] ) );
          end   // if cmsfIsMediaObj in CMSDB.SFlags then
          else
          begin // Image Slide
            // Copy Slide CurImage File
            AFileName[Length(AFileName) - 4] := 'R';
            SrcFileName := SrcLocFolder + AFileName;
            NewVFileName := SCScanTaskLocFolder + AFileName;
            K_CopyFile( SrcFileName, NewVFileName );
            N_Dump2Str( format( 'SCS> Copy  %s >> %s ', [SrcFileName, NewVFileName] ) );

            // Copy Slide SrcImage File
            SrcFileName[Length(SrcFileName) - 4] := 'S';
            if FileExists(SrcFileName) then
            begin
              AFileName[Length(AFileName) - 4] := 'S';
              NewVFileName := SCScanTaskLocFolder + AFileName;
              K_CopyFile( SrcFileName, NewVFileName );
              N_Dump2Str( format( 'SCS> Copy  %s >> %s ', [SrcFileName, NewVFileName] ) );
            end;
          end; // if not (cmsfIsMediaObj in CMSDB.SFlags) then
        end; // if (NodePatID <> '') then // Slide was scanned in Task Mode
      end; // with TN_UDCMSlide(UDNode), P^ do

      // Prepare Reference to Slide Source File for future Upload Info update
      SCSTask.Add( ExtractFileName( Copy( NewFileName, 1, Length(NewFileName) - 6 ) ) +
                   '=' + Copy( SAFileName, 1, Length(SAFileName) - 6 ) );
    end; // for i := 0 to SL.Count - 1 do

    SCUpdateTaskLocFile( K_SCGetTaskRSFileName( SCScanTaskLocRFile, 'S' ), SCSTask ); // 2015-01-29

    N_Dump1Str( 'SCS> Recover Task Prepare Fin >> ' + SCScanTaskLocRFile );
  end; // with K_FormCMScan do

  FL.Free;
  ModalResult := mrOK;

end; // procedure TK_FormCMScanSelectMedia.aRecoverSelectedExecute

//****************************** TK_FormCMScanSelectMedia.SCSDisableActions ***
// Check all actions enabled disabled state
//
procedure TK_FormCMScanSelectMedia.SCSDisableActions;
{
var
  i : Integer;
  UncheckEnable : Boolean;
  CheckEnable : Boolean;
  UDNode : TN_UDBase;
}
begin

  with VTreeFrame.VTree do
  begin
{
    CheckEnable := FALSE;
    UncheckEnable := FALSE;
    for i := 0 to MarkedVNodesList.Count - 1 do
    begin
      UDNode := TN_VNode(MarkedVNodesList[i]).VNUDObj;
      with UDNode do
      begin
        if (ObjFlags and K_fpObjTVSpecMark1) <> 0 then
        begin
          CheckEnable := CheckEnable or
             ( (ObjName[1] <> 'M') or
               (((ObjFlags and K_fpObjTVAutoCheck) <> 0) and ((ObjFlags and K_fpObjTVChecked) = 0)) );
          UncheckEnable := TRUE;
        end;
      end;
    end;
    aCheckAllMarkedObjs.Enabled := CheckEnable;
    aUncheckAllMarkedObjs.Enabled := UncheckEnable and (CheckedUObjsList.Count <> 0);
}
    aRecoverSelected.Enabled := CheckedUObjsList.Count <> 0;
  end;
end; // procedure TK_FormCMScanSelectMedia.SCSDisableActions;

//********************************** TK_FormCMScanSelectMedia.SCProcessFile ***
// Check all actions enabled disabled state
//
procedure TK_FormCMScanSelectMedia.SCProcessFile( const AFName, AScanTaskFolder : string;
                                                  AUDScan : TN_UDBase; ASL : TStrings;
                                                  var AInd : Integer;
                                                  var APCMSlide : TN_PCMSlide );
var
  DFile: TK_DFile;
  DSize : Integer;
  WCPat : string;
  ECFName : string;
  UDSlide : TN_UDCMSlide;
  UDateInfo : string;
  UploadInfo : string;
begin
  UploadInfo := '';
  UDateInfo := ASL.Values[Copy( AFName, 1, Length(AFName) - 6 )];
  if UDateInfo <> '' then
  begin // add Upload Info
    if UDateInfo[Length(UDateInfo)] = '*' then
    begin // Process Recovered
      if not SCShowRecovered then Exit;
      UploadInfo := 'last recovery';
      if UDateInfo[13] = '*' then
        UDateInfo := Copy( UDateInfo, 14, Length(UDateInfo) - 14 ) // last update info
      else
        SetLength( UDateInfo, Length(UDateInfo) - 1 );             // prev update info
    end
    else
      UploadInfo := 'saved';

    UploadInfo := format( '%s %s/%s/%s %s:%s:%s', [UploadInfo,
                            Copy(UDateInfo,5,2), Copy(UDateInfo,3,2),
                            Copy(UDateInfo,1,2), Copy(UDateInfo,7,2),
                            Copy(UDateInfo,9,2), Copy(UDateInfo,11,2)] );
    if Length(UDateInfo) > 12 then
      UploadInfo := format( '%s for %s', [UploadInfo,
                 Copy(UDateInfo,13,Length(UDateInfo))] );
    UploadInfo := '(' + UploadInfo + ')';
  end; // if UDateInfo <> then

  ECFName := AScanTaskFolder + AFName;
  if not K_DFOpen( ECFName, DFile, [K_dfoProtected] ) then
  begin
    N_Dump1Str( format( 'SCS> SLide A-file Open error="%s" File=%s',
                [K_DFGetErrorString(DFile.DFErrorCode),ECFName] ) );
    Exit;
  end;

  DSize := DFile.DFPlainDataSize;
  if SizeOf(Char) = 2 then
    DSize := DSize shr 1;
  SetLength( K_CMEDAccess.StrTextBuf, DSize );
  if not K_DFReadAll( @K_CMEDAccess.StrTextBuf[1], DFile ) then
  begin
    N_Dump1Str( format( 'SCS> SLide A-file Read error="%s" File=%s',
                [K_DFGetErrorString(DFile.DFErrorCode),ECFName] ) );
    Exit;
  end;

  K_SerialTextBuf.LoadFromText( K_CMEDAccess.StrTextBuf );

  UDSlide := TN_UDCMSlide( K_LoadTreeFromText( K_SerialTextBuf ) );
  if UDSlide = nil then
  begin
    N_Dump1Str( format( 'SCS> Wrong File Format File=%s',
                        [ECFName] ) );
    WCPat := ChangeFileExt( AFName, '' );
    WCPat := Copy( WCPat, 1, Length(WCPat) - 1 ) + '*.*';
    K_DeleteFolderFiles( AScanTaskFolder, WCPat, [] ); // Del ECache Main + Image Files
    N_Dump1Str( 'SCS> Files ' + AScanTaskFolder + WCPat + ' were deleted' );
    Exit;
  end;

  with UDSlide do
  begin
    UDSlide.ObjFlags := UDSlide.ObjFlags or K_fpObjTVAutoCheck;
    ObjName := ECFName;
    APCMSlide := P();
    with APCMSlide^ do
    if cmsfIsMediaObj in APCMSlide^.CMSDB.SFlags then
      ObjAliase := 'Video'
    else
      ObjAliase := 'Image';

    ObjAliase := format( '%s %d %s', [ObjAliase, AInd + 1, UploadInfo] );
  end; // with UDSlide do
  AUDScan.AddOneChild( UDSlide );
  Inc(AInd);
end; // procedure TK_FormCMScanSelectMedia.SCProcessFile

//************************* TK_FormCMScanSelectMedia.SCRemoveEmptyTreeNodes ***
// Remove Empty Tree Nodes
//
procedure TK_FormCMScanSelectMedia.SCRemoveEmptyTreeNodes( AUDRoot : TN_UDBase );
var
  i : Integer;
  UDChild : TN_UDBase;
begin
  for i := AUDRoot.DirHigh() downto 0 do
  begin
    UDChild := AUDRoot.DirChild(i);
    if UDChild.ClassFlags <> N_UDBaseCI then Continue;
    if UDChild.DirLength() <> 0 then
      SCRemoveEmptyTreeNodes(UDChild);
    if UDChild.DirLength() = 0 then
      AUDRoot.RemoveDirEntry(i)
  end;
end; // procedure TK_FormCMScanSelectMedia.SCRemoveEmptyTreeNodes

//********************************* TK_FormCMScanSelectMedia.SCRebuildView1 ***
// Rebuild View1 - order by date
//
procedure TK_FormCMScanSelectMedia.SCRebuildView1( ASkipRebuild : Boolean = FALSE );
var
  i, j, FNameLength, SlidesCount : Integer;
  ScanTaskRFile : string;
  ScanTaskSFile : string;
  ScanTaskID : string;
  ScanTaskFolder : string;
  YYYY, MM, DD  : string;
  HH, NN, SS : string;
  SL1, SL2, SL3 : TStringList;
  UDPat : TN_UDBase;
  UDDate : TN_UDBase;
  UDScan : TK_UDStringList;
  PrevSDate, SDate : string;
  RCount, Ind : Integer;
  PCMSlide : TN_PCMSlide;
  PatUDName, PatName, PatFName, PatSName : string;
  ScanType : string;

begin

  N_Dump2Str( 'SC> Order by Date start' );
  SL1 := TStringList.Create;
  SL2 := TStringList.Create;
  SL3 := TStringList.Create;

  PrevSDate := '';
  UDDate := nil;
  UDPat := nil;
  PCMSlide := nil;
  for i := 0 to FFNames.Count - 1 do
  begin
    ScanTaskSFile := FFNames[i];

    FNameLength := Length(ScanTaskSFile);
    ScanTaskID := Copy( ScanTaskSFile, FNameLength - 18, 15 );

    ScanTaskRFile  := ScanTaskSFile;
    ScanTaskRFile[FNameLength-19] := 'R';

    ScanTaskFolder := ScanTaskSFile;
    ScanTaskFolder[FNameLength-19] := 'F';
    ScanTaskFolder := Copy( ScanTaskFolder, 1, FNameLength - 3 );
    ScanTaskFolder[Length(ScanTaskFolder)] := '\';

    if not SCLoadTextFile( ScanTaskSFile ) then Continue;

    if K_CMEDAccess.TmpStrings.Values['CurPatID'] = '' then
    begin
      if not SCShowOffline then Continue;
    end
    else
    begin
      if not SCShowOnline then Continue;
    end;

    SL1.Assign( K_CMEDAccess.TmpStrings );
    if SL1.Values['Remove'] = 'TRUE' then
    begin // Remove Recover Task and Continue
      K_CMScanRemoveTask( 'SCS> Recover Task Local >>', ScanTaskSFile,
                      ScanTaskRFile, ScanTaskFolder, K_CMEDAccess.TmpStrings,
                      N_T1, N_Dump1Str, N_Dump2Str );
      Continue;
    end;

    if not SCLoadTextFile( ScanTaskRFile ) then Continue;
    SL2.Assign( K_CMEDAccess.TmpStrings );

    SlidesCount := StrToIntDef( SL2.Values['ScanCount'], -1 );
    N_Dump2Str( format('SCS> R-File %s ScanCount=%d', [ScanTaskRFile,SlidesCount] ) );

    K_CMEDAccess.TmpStrings.Clear;
    K_ScanFilesTree( ScanTaskFolder, K_CMEDAccess.EDAScanFilesTreeSelectFile, 'F*A.ecd' );

    RCount := K_CMEDAccess.TmpStrings.Count;
    N_Dump2Str( format( 'SCS> Slides in Task Folder %d', [RCount] ) );
    if RCount = 0 then
    begin // Remove Empty Task and Continue
//      N_Dump1Str( format( 'SCS> Task Folder %s is emty', [ScanTaskFolder] ) );
      K_CMScanRemoveTask( 'SCS> Empty Task Local >>', ScanTaskSFile,
                      ScanTaskRFile, ScanTaskFolder, K_CMEDAccess.TmpStrings,
                      N_T1, N_Dump1Str, N_Dump2Str );
      Continue;
    end;
    SL3.Assign( K_CMEDAccess.TmpStrings );

    if RCount > SlidesCount then
      SlidesCount := RCount;
{
    if SlidesCount <= 0 then
    begin // Remove Empty Task and Continue
      K_CMScanRemoveTask( 'SCS> Empty Task Local >>', ScanTaskSFile,
                      ScanTaskRFile, ScanTaskFolder, K_CMEDAccess.TmpStrings,
                      N_T1, N_Dump1Str, N_Dump2Str );
      Continue;
    end;
}
    // Get Timestamp info
    YYYY := '20' + Copy( ScanTaskID, 1, 2 );
    MM := Copy( ScanTaskID, 3, 2 );
    DD := Copy( ScanTaskID, 5, 2 );
    HH := Copy( ScanTaskID, 7, 2 );
    NN := Copy( ScanTaskID, 9, 2 );
    SS := Copy( ScanTaskID, 11, 2 );


    // Prepare Date Node
    SDate := YYYY + '/' + MM  + '/' + DD;
    if PrevSDate <> SDate then
    begin // Add New Date Node
      UDDate := TN_UDBase.Create;
//      UDDate.ObjName := IntToStr(i);
      UDDate.ObjName := format( '%.6d', [FFNames.Count - i] );

      UDDate.ObjAliase := SDate;
      PrevSDate := SDate;
      UDRoot.AddOneChild( UDDate );
      UDPat := nil; // Clear previous Patient Node
    end;

    // Prepare Patient Node
    PatFName   := SL1.Values['PatientFirstName'];
    PatSName   := SL1.Values['PatientSurname'];
    if (PatFName = '') and (PatSName = '') then
    begin
      PatUDName := 'ID' + SL1.Values['CurPatID'];
      PatName := format( 'Px. ID %s',[SL1.Values['CurPatID']] );
    end
    else
    begin
      PatUDName := PatSName + PatFName;
      PatName := PatSName + ' ' + PatFName;
{ !!! new code needed to use PatCardNum
      PatUDName := PatSName + PatFName + SL1.Values['CurPatID'];
      PatName := PatSName + ' ' + PatFName + ' [' + SL1.Values['PatientCardNumber'] + ']';
{}
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
        UDDate.AddOneChild( UDPat );
      end;
    end;

    // Get Task Media Slides Files List
{
    K_CMEDAccess.TmpStrings.Clear();
    K_ScanFilesTree( ScanTaskFolder, K_CMEDAccess.EDAScanFilesTreeSelectFile, 'F*A.ecd' );
    RCount := K_CMEDAccess.TmpStrings.Count;
    if RCount = 0 then
    begin
      N_Dump1Str( format( 'SCS> Task Folder %s is emty', [ScanTaskFolder] ) );
      Continue;
    end;
    if RCount > SlidesCount then
      RCount := SlidesCount;
}
    // Add Media Nodes Loop
    K_CMEDAccess.TmpStrings.Assign( SL3 );
    K_CMEDAccess.TmpStrings.Sort();

    Ind := 0;
    UDScan := TK_UDStringList.Create(); // Add Scan Node
    for j := 0 to RCount - 1 do
      SCProcessFile( K_CMEDAccess.TmpStrings[j], ScanTaskFolder, UDScan, SL1,
                     Ind, PCMSlide );

    N_Dump2Str( format( 'SCS> Task Files Count=%d Scan=%d Result=%d',
                              [K_CMEDAccess.TmpStrings.Count, SlidesCount, Ind] ) );
    if Ind = 0 then
      UDScan.UDDelete()
    else
    begin
      UDScan.ImgInd := 68;
      UDScan.ObjName := format( '%.6d', [i] ); // IntToStr(i);
      UDScan.SL.Assign( SL1 ); // S-file to Node
      UDScan.SL.AddStrings( SL2 ); // R-file to Node

      if SL1.Values['CurPatID'] = '' then
        ScanType := 'Offline'
      else
        ScanType := 'Online';
      UDScan.ObjAliase := format( '%s:%s:%s (%s) %s',
                                  [HH, NN, SS, ScanType, PCMSlide.CMSSourceDescr] );

      // Add Scan Node to Patient Node
      UDPat.AddOneChild( UDScan );
    end;



  end; // for i := 0 to AFNames.Count - 1 do

  SCRemoveEmptyTreeNodes( UDRoot );
  SL1.Free();
  SL2.Free();
  SL3.Free();
  N_Dump2Str( 'SC> Order by Date fin' );
  if ASkipRebuild then Exit;
  VtreeFrame.RebuildVTree( UDRoot );
  VTreeFrame.VTree.TreeView.FullExpand;

end; // procedure TK_FormCMScanSelectMedia.SCRebuildView1

//********************************* TK_FormCMScanSelectMedia.SCRebuildView2 ***
// Rebuild View2 - order by patient
//
procedure TK_FormCMScanSelectMedia.SCRebuildView2( ASkipRebuild : Boolean = FALSE);
var
  i, j, FNameLength, SlidesCount : Integer;
  ScanTaskRFile : string;
  ScanTaskSFile : string;
  ScanTaskID : string;
  ScanTaskFolder : string;
  YYYY, MM, DD  : string;
  HH, NN, SS : string;
  SL1, SL2, SL3 : TStringList;
  UDPat : TN_UDBase;
  UDDate : TN_UDBase;
  UDScan : TK_UDStringList;
  SDate : string;
  RCount, Ind : Integer;
  PCMSlide : TN_PCMSlide;
  PatUDName, PatName, PatFName, PatSName : string;
  ScanType : string;

begin

  N_Dump2Str( 'SC> Order by Patient start' );
  SL1 := TStringList.Create;
  SL2 := TStringList.Create;
  SL3 := TStringList.Create;
  UDDate := nil;
  UDPat := nil;
  PCMSlide := nil;
  for i := 0 to FFNames.Count - 1 do
  begin
    ScanTaskSFile := FFNames[i];

    FNameLength := Length(ScanTaskSFile);
    ScanTaskID := Copy( ScanTaskSFile, FNameLength - 18, 15 );

    ScanTaskRFile  := ScanTaskSFile;
    ScanTaskRFile[FNameLength-19] := 'R';

    ScanTaskFolder := ScanTaskSFile;
    ScanTaskFolder[FNameLength-19] := 'F';
    ScanTaskFolder := Copy( ScanTaskFolder, 1, FNameLength - 3 );
    ScanTaskFolder[Length(ScanTaskFolder)] := '\';

    if not SCLoadTextFile( ScanTaskSFile ) then Continue;

    if K_CMEDAccess.TmpStrings.Values['CurPatID'] = '' then
    begin
      if not SCShowOffline then Continue;
    end
    else
    begin
      if not SCShowOnline then Continue;
    end;

    SL1.Assign( K_CMEDAccess.TmpStrings );
    if SL1.Values['Remove'] = 'TRUE' then
    begin // Remove Recover Task and Continue
      K_CMScanRemoveTask( 'SCS> Recover Task Local >>', ScanTaskSFile,
                      ScanTaskRFile, ScanTaskFolder, K_CMEDAccess.TmpStrings,
                      N_T1, N_Dump1Str, N_Dump2Str );
      Continue;
    end;

    if not SCLoadTextFile( ScanTaskRFile ) then Continue;
    SL2.Assign( K_CMEDAccess.TmpStrings );

    SlidesCount := StrToIntDef( SL2.Values['ScanCount'], -1 );
    N_Dump2Str( format('SCS> R-File %s ScanCount=%d', [ScanTaskRFile,SlidesCount] ) );

    K_CMEDAccess.TmpStrings.Clear;
    K_ScanFilesTree( ScanTaskFolder, K_CMEDAccess.EDAScanFilesTreeSelectFile, 'F*A.ecd' );
    SL3.Assign( K_CMEDAccess.TmpStrings );
    RCount := K_CMEDAccess.TmpStrings.Count;
    N_Dump2Str( format( 'SCS> Slides in Task Folder %d', [RCount] ) );
    if RCount = 0 then
    begin // Remove Empty Task and Continue
//      N_Dump1Str( format( 'SCS> Task Folder %s is emty', [ScanTaskFolder] ) );
      K_CMScanRemoveTask( 'SCS> Empty Task Local >>', ScanTaskSFile,
                      ScanTaskRFile, ScanTaskFolder, K_CMEDAccess.TmpStrings,
                      N_T1, N_Dump1Str, N_Dump2Str );
      Continue;
    end;

    if RCount > SlidesCount then
      SlidesCount := RCount;
{
    if SlidesCount <= 0 then
    begin // Remove Empty Task and Continue
      K_CMScanRemoveTask( 'SCS> Empty Task Local >>', ScanTaskSFile,
                      ScanTaskRFile, ScanTaskFolder, K_CMEDAccess.TmpStrings,
                      N_T1, N_Dump1Str, N_Dump2Str );
      Continue;
    end;
}
    // Prepare Patient Node
    PatFName := SL1.Values['PatientFirstName'];
    PatSName := SL1.Values['PatientSurname'];
    if (PatFName = '') and (PatSName = '') then
    begin
      PatUDName := 'ID' + SL1.Values['CurPatID'];
      PatName := format( 'Px. ID %s',[SL1.Values['CurPatID']] );
    end
    else
    begin
      PatUDName := PatSName + PatFName;
      PatName := PatSName + ' ' + PatFName;
{ !!! new code needed to use PatCardNum
      PatUDName := PatSName + PatFName + SL1.Values['CurPatID'];
      PatName := PatSName + ' ' + PatFName + ' [' + SL1.Values['PatientCardNumber'] + ']';
{}
    end;

    if (UDPat = nil) or (UDPat.ObjName <> PatUDName) then
    begin
      if UDPat <> nil then
        UDPat := UDRoot.DirChildByObjName( PatUDName );

      if UDPat = nil then
      begin
        UDPat := TN_UDBase.Create;
        UDPat.ObjName := PatUDName;
        UDPat.ObjAliase := PatName;
        UDRoot.AddOneChild( UDPat );
      end;
      UDDate := nil; // Clear Prevoiuse Date Node
    end;

    // Get Timestamp info
    YYYY := '20' + Copy( ScanTaskID, 1, 2 );
    MM := Copy( ScanTaskID, 3, 2 );
    DD := Copy( ScanTaskID, 5, 2 );
    HH := Copy( ScanTaskID, 7, 2 );
    NN := Copy( ScanTaskID, 9, 2 );
    SS := Copy( ScanTaskID, 11, 2 );

    // Prepare Date Node
    SDate := YYYY + '/' + MM  + '/' + DD;
    if (UDDate = nil) or (UDDate.ObjAliase <> SDate) then
    begin
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

    // Get Task Media Slides Files List
{
    K_CMEDAccess.TmpStrings.Clear();
    K_ScanFilesTree( ScanTaskFolder, K_CMEDAccess.EDAScanFilesTreeSelectFile, 'F*A.ecd' );
    RCount := K_CMEDAccess.TmpStrings.Count;
    if RCount = 0 then
    begin
      N_Dump1Str( format( 'SCS> Task Folder %s is empty', [ScanTaskFolder] ) );
      Continue;
    end;

    if RCount > SlidesCount then
      RCount := SlidesCount;
}
    // Add Media Nodes Loop
    K_CMEDAccess.TmpStrings.Assign( SL3 );
    K_CMEDAccess.TmpStrings.Sort();

    Ind := 0;
    UDScan := TK_UDStringList.Create(); // Add Scan Node
    for j := 0 to RCount - 1 do
      SCProcessFile( K_CMEDAccess.TmpStrings[j], ScanTaskFolder, UDScan, SL1,
                     Ind, PCMSlide );

    N_Dump2Str( format( 'SCS> Task Files Count=%d Scan=%d Result=%d',
                              [K_CMEDAccess.TmpStrings.Count, SlidesCount, Ind] ) );
    if Ind = 0 then
      UDScan.UDDelete()
    else
    begin
      UDScan.ImgInd := 68;
      UDScan.ObjName := format( '%.6d', [i] ); // IntToStr(i);
      UDScan.SL.Assign( SL1 ); // S-file to Node
      UDScan.SL.AddStrings( SL2 ); // R-file to Node

      if SL1.Values['CurPatID'] = '' then
        ScanType := 'Offline'
      else
        ScanType := 'Online';
      UDScan.ObjAliase := format( '%s:%s:%s (%s) %s',
                                  [HH, NN, SS, ScanType, PCMSlide.CMSSourceDescr] );

      // Add Scan Node to Date Node
      UDDate.AddOneChild( UDScan );
    end;



  end; // for i := 0 to AFNames.Count - 1 do

  SCRemoveEmptyTreeNodes( UDRoot );

  SL1.Free();
  SL2.Free();
  SL3.Free();
  N_Dump2Str( 'SC> Order by Patient fin' );
  if ASkipRebuild then Exit;
  VtreeFrame.RebuildVTree( UDRoot );
  VTreeFrame.VTree.TreeView.FullExpand;

end; // procedure TK_FormCMScanSelectMedia.SCRebuildView2

//******************************* TK_FormCMScanSelectMedia.RGSortOrderClick ***
// RGSortOrder click handler
//
procedure TK_FormCMScanSelectMedia.RGSortOrderClick(Sender: TObject);
var
  TopNode : TTreeNode;
  SelectParent : Boolean;
begin
  if SCSkipReorder then Exit;
  if (RGSortOrder.ItemIndex = SCCurSortOrder) and (Sender <> nil) then Exit;
  SCCurSortOrder := RGSortOrder.ItemIndex;

  // Clear Selected state
  SCSVTFOnSelect( VTreeFrame, nil, mbLeft, [] );

  // Save View Top 
  SelectParent := FALSE;
  TopNode := VTreeFrame.VTree.TreeView.TopItem;
  if TopNode <> nil then
  begin
    SCSTopUDNode := TN_VNode(VTreeFrame.VTree.TreeView.TopItem.Data).VNUDObj;
    while (SCSTopUDNode <> nil) and not (SCSTopUDNode is TN_UDCMSlide) do SCSTopUDNode := SCSTopUDNode.DirChild(0);
    SelectParent := SCSTopUDNode <> TN_VNode(VTreeFrame.VTree.TreeView.TopItem.Data).VNUDObj;
    if SCSTopUDNode <> nil then
      SCSTopUDNodeName := SCSTopUDNode.ObjName;
  end;

  // Rebuild TreeVeiw
  K_TreeViewsUpdateModeSet;
  UDRoot.ClearChilds();
  case SCCurSortOrder of
    0 : SCRebuildView1();
    1 : SCRebuildView2();
  end;

  // Set Veiw Top
  if TopNode <> nil then
  begin
  // Search for new TopNode
    SCSTopUDNode := nil;
    UDRoot.ScanSubTree(SCSTestUDObjName);
    TopNode := nil;
    if SCSTopUDNode <> nil then
    begin
      if SelectParent then
        SCSTopUDNode := SCSTopUDNode.Owner;
      if (SCSTopUDNode <> nil) and (SCSTopUDNode.LastVNode <> nil) then
        TopNode := SCSTopUDNode.LastVNode.VNTreeNode;
    end;
  end;

  if (TopNode = nil) and (VTreeFrame.VTree.TreeView.Items.Count > 0) then
    TopNode := VTreeFrame.VTree.TreeView.Items[0]; // Show Tre from the begin

  if TopNode <> nil then
    VTreeFrame.VTree.TreeView.TopItem := TopNode;

  K_TreeViewsUpdateModeClear( false );
end; // procedure TK_FormCMScanSelectMedia.RGSortOrderClick

//************************** TK_FormCMScanSelectMedia.ChBHideRecoveredClick ***
// ChBHideRecovered click handler
//
procedure TK_FormCMScanSelectMedia.ChBShowRecoveredClick(Sender: TObject);
begin
  if SCSkipReorder then Exit;
  N_Dump2Str( 'SC> ShowRecovered' );
  SCShowRecovered := ChBShowRecovered.Checked;
  RGSortOrderClick(nil);
end; // TK_FormCMScanSelectMedia.ChBShowRecoveredClick

//******************************* TK_FormCMScanSelectMedia.CurStateToMemIni ***
// Save current state to ini-file
//
procedure TK_FormCMScanSelectMedia.CurStateToMemIni;
var
  state : string;
begin
  inherited;
  state := '0100';
  if SCCurSortOrder > 0 then state[1] := '1';
  if SCShowOnline then state[2] := '1';
  if SCShowOffline then state[3] := '1';
  if SCShowRecovered then state[4] := '1';
  N_StringToMemIni( 'CMS_Main', 'RecoverMediaState', state );
end; // TK_FormCMScanSelectMedia.CurStateToMemIni

//******************************* TK_FormCMScanSelectMedia.MemIniToCurState ***
// Load current state from ini-file
//
procedure TK_FormCMScanSelectMedia.MemIniToCurState;
var
  state : string;
begin
  state := N_MemIniToString( 'CMS_Main', 'RecoverMediaState', '0100' );
  if state[1] = '1' then SCCurSortOrder := 1;
  if state[2] = '1' then SCShowOnline := TRUE;
  if state[3] = '1' then SCShowOffline := TRUE;
  if state[4] = '1' then SCShowRecovered := TRUE;
  SCSkipReorder := TRUE;
  RGSortOrder.ItemIndex := SCCurSortOrder;
  RBOnline.Checked := SCShowOnline;
  RBOffline.Checked := SCShowOffline;
  ChBShowRecovered.Checked := SCShowRecovered;
  inherited;
  SCSkipReorder := FALSE;

end; // TK_FormCMScanSelectMedia.MemIniToCurState

function TK_FormCMScanSelectMedia.SCSTestUDObjName(UDParent: TN_UDBase;
  var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
  const FieldName: string): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  if (UDChild is TN_UDCMSlide) then
  begin
    Result := K_tucSkipSubTree;
    if UDChild.ObjName <> SCSTopUDNodeName then Exit;
    SCSTopUDNode := UDChild;
    Result := K_tucSkipScan;
  end;
end;

//******************************** TK_FormCMScanSelectMedia.RBOfflineClick ***
// ChBHideOffline click handler
//
procedure TK_FormCMScanSelectMedia.RBOfflineClick(Sender: TObject);
var
  RebuildView : Boolean;
begin
  RebuildView := FALSE;
  if Sender = RBOffline then
  begin
    N_Dump2Str( 'SC> ShowOffline' );
    RebuildView := SCShowOffline <> RBOffline.Checked;
    RBOnline.Checked := not RBOffline.Checked;
    SCShowOffline := RBOffline.Checked;
    SCShowOnline := not SCShowOffline;
  end
  else
  if Sender = RBOnline then
  begin
    N_Dump2Str( 'SC> ShowOnline' );
    RebuildView := SCShowOnline <> RBOnline.Checked;
    RBOffline.Checked := not RBOnline.Checked;
    SCShowOnline := RBOnline.Checked;
    SCShowOffline := not SCShowOnline;
  end;
  if RebuildView then RGSortOrderClick(nil);
end; // procedure TK_FormCMScanSelectMedia.RBOfflineClick

end.


