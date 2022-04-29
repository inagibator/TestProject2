unit K_FCMDCMImport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ActnList, Menus, StdCtrls,
  N_BaseF, N_Rast1Fr, N_Gra2,
  K_CMDCM, K_UDT1;

type
  TK_FormCMDCMImport = class(TN_BaseForm)
    VTreeFrame: TN_VTreeFrame;
    PopupMenu: TPopupMenu;
    ActionList: TActionList;
    aAddMarkedPatients: TAction;
    aCheckAllMarkedObjs: TAction;
    aUncheckAllMarkedObjs: TAction;
    aImportChecked: TAction;
    AddMarkedPatientstoMediaSuite1: TMenuItem;
    Checkallmarkedobjectsforimport1: TMenuItem;
    Uncheckallmarkedobjects1: TMenuItem;
    Importcheckedobjects1: TMenuItem;
    RFrame: TN_Rast1Frame;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    LLLDCMDImport1: TLabel;
    LLLDCMDImport2: TLabel;
    ChBImportToCurPatient: TCheckBox;
    aChangeImportToCurPatient: TAction;
    procedure aAddMarkedPatientsExecute(Sender: TObject);
    procedure aCheckAllMarkedObjsExecute(Sender: TObject);
    procedure aUncheckAllMarkedObjsExecute(Sender: TObject);
    procedure aImportCheckedExecute(Sender: TObject);
    procedure aChangeImportToCurPatientExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
//    DCMDLib : TK_CMDCMDLib;

    PDCMDPatient : TK_PCMDCMDPatient;
    UDRoot : TN_UDBase;      // UDRoot for Patient UDNodes
    UDThumbRoot : TN_UDBase; // UDRoot for Dynamically created Thumbnails
    ImportedCount : Integer;
    procedure DCMDRebuildImportVTree( AUseCurPat, AddPatActionVis : Boolean );
    procedure DCMDDisableActions( );
    procedure DCMDVTFOnSelect( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
    procedure DCMDVTFOnMouseDown( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
    function  DCMDGetNodeDIB( APatInd, AStudyInd, ASeriesInd, AImageInd : Integer;
                              out ADIBObj : TN_DIBObj ) : Boolean;
    function  DCMDGetNodeFile( APatInd, AStudyInd, ASeriesInd, AImageInd: Integer): string;
end;

var
  K_FormCMDCMImport: TK_FormCMDCMImport;

function K_CMSlidesImportFromDCMFList( AFNames : TStrings ) : Integer;
function K_CMDCMSlidesImportFromDCMPatientsDlg( APDCMDPatient : TK_PCMDCMDPatient; ADCMDPatientCount : Integer ) : Integer;

implementation

uses K_CM0, K_UDConst, K_UDT2, K_Script1, K_CML1F, K_CMDCMGLibW, K_UDC, K_VFunc,
     N_Types, N_Gra0, N_CompCL, N_CompBase, N_Comp1, N_CM1, N_Lib0, N_CMMain5F;

{$R *.dfm}

var K_SavedCursor : TCursor;

//******************************************** K_CMSlidesImportFromDCMFList ***
// Import Data from selected Files or Folders List
//
//     Parameters
// AFNames - files o folders names list
// Result  - Returns number of imported files
//
function K_CMSlidesImportFromDCMFList( AFNames : TStrings ) : Integer;
var
  DCMDPatientsCount : Integer;
  ResCode : Integer;
  ImpData : TK_CMDCMDPatientArr;
begin
  N_Dump2Str( 'K_CMSlidesImportFromDCMFList:'#13#10 + AFNames.Text );
  K_SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  if (AFNames.Count = 1) and (UpperCase(ExtractFileName(AFNames[0])) = 'DICOMDIR') then
    ResCode := K_CMBuildImpDataFromDICOMDIR( AFNames[0], ImpData )
  else
    ResCode := K_CMBuildImpDataFromFFList( AFNames, ImpData );

  Result := 0;
  if ResCode = 0 then
  begin
    DCMDPatientsCount := Length(ImpData);
    if DCMDPatientsCount > 0 then
      Result := K_CMDCMSlidesImportFromDCMPatientsDlg( @ImpData[0], DCMDPatientsCount )
    else
    begin
      Screen.Cursor := K_SavedCursor;
      N_Dump1Str( 'K_CMSlidesImportFromDCMFList >> Patients list is empty' );
    end;
  end
  else
  begin
    Screen.Cursor := K_SavedCursor;
    N_Dump1Str( format( 'K_CMSlidesImportFromDCMFList ErrCode=%d', [ResCode] ) );
  end;
end; // function K_CMSlidesImportFromDCMFList

//*********************************** K_CMDCMSlidesImportFromDCMPatientsDlg ***
// Import Data from DCM Patients Array Dialog
//
//     Parameters
// APDCMDPatient - pointer to 1-st element in DCM Patients array
// ADCMDPatientCount - number of elements in DCM Patients array
// Result  - Returns number of imported files
//
function K_CMDCMSlidesImportFromDCMPatientsDlg( APDCMDPatient : TK_PCMDCMDPatient; ADCMDPatientCount : Integer ) : Integer;
begin
  with TK_FormCMDCMImport.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    PDCMDPatient := APDCMDPatient;
    UDRoot := nil;
    if Screen.Cursor <> crHourGlass then
    begin
      K_SavedCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
    end;

    aAddMarkedPatients.Visible :=  K_CMStandaloneGUIMode        and
                                   (K_CMStandaloneMode <> K_cmsaLink);
    K_CMCreateDCMUDTree( UDRoot, APDCMDPatient, ADCMDPatientCount,
                         K_CMEDAccess.EDADCMCheckPatient, N_CM_MainForm.CMMFShowString );
    DCMDRebuildImportVTree( ChBImportToCurPatient.Checked, aAddMarkedPatients.Visible );

    Screen.Cursor := K_SavedCursor;

//      VtreeFrame.CreateVTree( UDRoot, -1, 4 );
//      VtreeFrame.CreateVTree( UDRoot, K_fvSkipCurrent + K_fvDirSortedByObjName, 4 );
    VtreeFrame.CreateVTree( UDRoot, K_fvSkipCurrent + K_fvDirSortedByObjUName, 4 );
//    VTreeFrame.OnActionProcObj := OnAction;
//    VTreeFrame.OnSelectProcObj := OnSelect;
    VTreeFrame.MultiMark := true;
    VTreeFrame.VTree.TreeView.FullExpand;
    VTreeFrame.OnMouseDownProcObj := DCMDVTFOnMouseDown;
//      VTreeFrame.OnMouseUpProcObj := DCMDVTFOnMouseDown;
    VTreeFrame.OnSelectProcObj := DCMDVTFOnSelect;
    K_VTreeFrameShowFlags := K_VTreeFrameShowFlags + [K_vtfsSkipInlineEdit];

    RFrame.RFCenterInDst := True;
    RFrame.DstBackColor   := ColorToRGB( Color );
    RFrame.OCanvBackColor := ColorToRGB( Color );
    RFrame.RedrawAllAndShow();

    UDThumbRoot := TN_UDBase.Create;
    DCMDDisableActions();

//    DCMDLib := ADCMDLib;

    ShowModal;

    K_VTreeFrameShowFlags := K_VTreeFrameShowFlags - [K_vtfsSkipInlineEdit];

    Result := ImportedCount;
    UDRoot.UDDelete();
    UDThumbRoot.UDDelete();
    RFrame.RFFreeObjects();
  end; // with TK_FormCMDCMDImport.Create(Application) do

end; // function K_CMDCMSlidesImport

//********************************** TK_FormCMDCMDImport.DCMDVTFOnMouseDown ***
// implementation of TN_VTreeFrame OnMouseDownProc
//
procedure TK_FormCMDCMImport.DCMDVTFOnMouseDown( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
begin
  DCMDDisableActions();
  if Button = mbRight then
    with Mouse.CursorPos do
      PopupMenu.Popup( X, Y );
end; // end of procedure TK_FormCMDCMDImport.DCMDVTFOnMouseDown

//********************************** TK_FormCMDCMDImport.DCMDVTFOnSelect ***
// implementation of TN_VTreeFrame OnSelectProc
//
procedure TK_FormCMDCMImport.DCMDVTFOnSelect( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
var
  UDThumb, UDParent, UDChild : TN_UDBase;
  PatInd, StudyInd, SeriesInd, MediaInd : Integer;
  ThumbDIB : TN_DIBObj;
  ImgDIBObj : TN_DIBObj;
//  UDDIB : TN_UDDIB;
begin
  if (AVNode = nil ) or
     (AVNode.VNUDObj.ObjName[1] <> 'M') then
//     ((AVNode.VNUDObj.ObjFlags and K_fpObjTVAutoCheck) = 0) then
  begin
    RFrame.RFrInitByComp( nil );
    RFrame.ShowMainBuf();
    Exit;
  end;

  UDThumb := AVNode.VNUDObj.DirChild(0);
  if UDThumb = nil then
  begin
    UDChild := AVNode.VNUDObj;
    UDParent := UDChild.Owner;
    MediaInd := UDParent.IndexOfDEField( UDChild, K_DEFisChild );

    UDChild := UDParent;
    UDParent := UDChild.Owner;
    SeriesInd := UDParent.IndexOfDEField( UDChild, K_DEFisChild );

    UDChild := UDParent;
    UDParent := UDChild.Owner;
    StudyInd := UDParent.IndexOfDEField( UDChild, K_DEFisChild );

    UDChild := UDParent;
    UDParent := UDChild.Owner;
    PatInd := UDParent.IndexOfDEField( UDChild, K_DEFisChild );

    // Get Image DIBObj
    if not DCMDGetNodeDIB( PatInd, StudyInd, SeriesInd, MediaInd, ImgDIBObj ) then
    begin
      RFrame.RFrInitByComp( nil );
      RFrame.ShowMainBuf();
      Exit;
    end;

    // Get Image Thumbnail DIBObj
    ThumbDIB := K_CMBSlideCreateThumbnailDIBByDIBEx( ImgDIBObj );
    UDThumb := K_CMBSlideCreateThumbnailUDDIB( ThumbDIB );
    if ImgDIBObj.DIBExPixFmt = epfGray16 then
      UDThumb.ObjInfo := 'Gray16';

//  Put Image Thumbnail to Object UDTree
    UDThumbRoot.AddOneChild( UDThumb );
    AVNode.VNUDObj.AddOneChild( UDThumb );

    ImgDIBObj.Free;
{
//  Put Image DIBObj to Object UDTree
    UDDIB := N_CreateUDDIB( FRect(100,100), [], '', 'CurImg' );
    UDDIB.DIBObj := ImgDIBObj;
    AVNode.VNUDObj.AddOneChild( UDDIB );
}
  end;
  RFrame.RVCTFrInit3( TN_UDDIB(UDThumb) );
  RFrame.aFitInWindowExecute( nil );
  RFrame.RedrawAllAndShow();
// Show Thumbnail

end; // end of procedure TK_FormCMDCMDImport.DCMDVTFOnSelect

//*************************** TK_FormCMDCMDImport.aAddMarkedPatientsExecute ***
// Add Marked Patients to Media Suite event handler
//
procedure TK_FormCMDCMImport.aAddMarkedPatientsExecute(Sender: TObject);
var
  i, i1, i2, i3, i4, PatID, FCount : Integer;
  SAPatientDBData : TK_CMSAPatientDBData;
  PatSID : string;
  ScanUDSubTree : TK_ScanUDSubTree;

  function CheckDIB() : Boolean;
  var
    DI : TK_HDCMINST;
    WStr : WideString;
    PixBufLength : Integer;
    IWidth, IHeight, INumBits : TN_UInt2;
    IPixFmt : TPixelFormat;
    IExPixFmt : TN_ExPixFmt;
    DIBAtrsRes : Integer;

  begin
    with K_DCMGLibW do
    begin
      Result := FALSE;
      with TK_PCMDCMDPatient(TN_BytesPtr(PDCMDPatient) + I1 * SizeOf(TK_CMDCMDPatient) )^,
           DDStudies[I2], DDSeries[I3], DDMedias[I4] do
        WStr := N_StringToWide( DDMediaFile );
      DI := DLCreateInstanceFromFile( @WStr[1], 255 );
      if DI <> nil then
      begin
        DIBAtrsRes := K_CMDGetDIBAttrs( DI, PixBufLength, IWidth, IHeight,
                             IPixFmt, IExPixFmt, INumBits, nil );
        Result := DIBAtrsRes = 0;
      end;
    end;
  end; // function CheckDIB

begin
//
  with VTreeFrame.VTree do
  begin
    ScanUDSubTree := TK_ScanUDSubTree.Create;
    FCount := 0;
    for i := 0 to MarkedVNodesList.Count - 1 do
    begin
      with TN_VNode(MarkedVNodesList[i]) do
      begin
        i1 := StrToInt( VNUDObj.ObjName );
        N_Dump2Str( 'TK_FormCMDCMDImport.aAddMarkedPatients >> Ind=' + VNUDObj.ObjName );
        if (VNUDObj.ObjFlags and K_fpObjTVSpecMark1) = 0 then Continue; // precaution
        PatSID := '';
        with TK_UDStringList(VNUDObj) do
        begin
          // Add New Patient
          SAPatientDBData.APSurname := SL.Values['Surname'];
          SAPatientDBData.APFirstname := SL.Values['FirstName'];
          SAPatientDBData.APMiddle := SL.Values['Middle'];
          SAPatientDBData.APTitle := SL.Values['Title'];
          SAPatientDBData.APGender := SL.Values['Sex'];
          SAPatientDBData.APDOB := ObjDateTime;
{
          SAPatientDBData.APDOB :=  EncodeDate( StrToInt(SL.Values['DOBY']),
                                                StrToInt(SL.Values['DOBM']),
                                                StrToInt(SL.Values['DOBD']) );
}
          SAPatientDBData.APCardNum := SL.Values['ID'];
          SAPatientDBData.APDBFlags := 0;
          SAPatientDBData.APProvID := 0;
          SAPatientDBData.APIsLocked := FALSE;
          SAPatientDBData.APIsPMSSync := FALSE;

          K_CMEDAccess.EDASASetOnePatientInfo( PatSID, @SAPatientDBData, FALSE );
          Inc(FCount);
          ObjFlags := ObjFlags xor K_fpObjTVSpecMark1;
          VNUDObj.ImgInd := 102;

          ScanUDSubTree.ChangeNodesDisabledState( VNUDObj, -1 );

          // Set Patient to ImgNodes
          PatID := StrToInt( PatSID );
          for i2 := 0 to DirHigh() do
            with DirChild(i2) do
              for i3 := 0 to DirHigh() do
                with DirChild(i3) do
                  for i4 := 0 to DirHigh() do
                  begin
                    if CheckDIB() then
                      with DirChild(i4) do
                      begin
                        Marker := PatID;
                        ObjFlags := ObjFlags or K_fpObjTVAutoCheck;
                      end;
                  end;

        end; // with TK_UDStringList(VNUDObj) do
      end; // with TN_VNode(MarkedVNodesList[i]) do
    end; // for i := 0 to MarkedVNodesList.Count - 1 do

    ScanUDSubTree.Free();
    TreeView.Repaint;
    DCMDDisableActions();
    N_CM_MainForm.CMMFShowStringByTimer( Format( LLLDCMDImport1.Caption,
    //           ' %d Patient(s) are added'
                   [FCount] ) );
  end; // with VTreeFrame.VTree do
end; // procedure TK_FormCMDCMDImport.aAddMarkedPatientsExecute

//************************ TK_FormCMDCMDImport.aCheckAllMarkedImagesExecute ***
// Set all marked images checked state for future import event handler
//
procedure TK_FormCMDCMImport.aCheckAllMarkedObjsExecute(Sender: TObject);
var
  i : Integer;
begin
  with VTreeFrame.VTree do
  begin
    for i := MarkedVNodesList.Count - 1 downto 0 do
      with TN_VNode(MarkedVNodesList[i]) do
      begin
        if not ChBImportToCurPatient.Checked and ((VNUDObj.ObjFlags and K_fpObjTVSpecMark1) <> 0) then Continue;
        with TK_ScanUDSubTree.Create do
        begin
          ChangeNodesCheckedState( VNUDObj, 1 );
          Free();
        end;
      end;
  end;
  VTreeFrame.TreeView.Repaint;
  DCMDDisableActions();
end; // procedure TK_FormCMDCMDImport.aCheckAllMarkedImagesExecute

//********************** TK_FormCMDCMDImport.aUncheckAllMarkedImagesExecute ***
// Clear all marked images checked state to prevent future import event handler
//
procedure TK_FormCMDCMImport.aUncheckAllMarkedObjsExecute(Sender: TObject);
var
  i : Integer;
begin
  with VTreeFrame.VTree do
  begin
    for i := MarkedVNodesList.Count - 1 downto 0 do
      with TN_VNode(MarkedVNodesList[i]) do
      begin
        if not ChBImportToCurPatient.Checked and ((VNUDObj.ObjFlags and K_fpObjTVSpecMark1) <> 0) then Continue;
        with TK_ScanUDSubTree.Create do
        begin
          ChangeNodesCheckedState( VNUDObj, -1 );
          Free();
        end;
      end;
  end;
  VTreeFrame.TreeView.Repaint;
  DCMDDisableActions();
end; // procedure TK_FormCMDCMDImport.aUncheckAllMarkedImagesExecute

//******************************* TK_FormCMDCMDImport.aImportCheckedExecute ***
// Import all checked images event handler
//
procedure TK_FormCMDCMImport.aImportCheckedExecute(Sender: TObject);
var
  i1, i2, i3, i4, ImgCount, CurSelectedCount, Ind : Integer;
  UDPat : TN_UDBase;
  UDImg : TN_UDBase;
  UDThumb : TN_UDBase;
  UDThumb1 : TN_UDBase;
  UDImgArray : TN_UDArray;
  SavedCurSessionHistID : Integer;
  SavedCurSessionHistStartTS : TDateTime;
  SavePatID : Integer;
  SavedCurPatID : Integer;
  DIBObj : TN_DIBObj;
  UDCMSlide : TN_UDCMSlide;
  UDDIB : TN_UDDIB;
  CurImportCount : Integer;
  NotAllImported : Boolean;
  WStr : string;
  MediaFName : string;

  DI : TK_HDCMINST;
  TransferSyntax, WCMFName : WideString;
  WUInt2 : TN_UInt2;

  PatIDs, OrderedInds, PatCheckedCount : TN_IArray;


label LExit;
 
begin

  CurSelectedCount := VTreeFrame.VTree.CheckedUObjsList.Count;
  SetLength( UDImgArray, CurSelectedCount );

  // Set checked counter to UDPat Marker
  for i4 :=0 to CurSelectedCount - 1 do
  begin
    UDPat := TN_UDBase(VTreeFrame.VTree.CheckedUObjsList[i4]).Owner.Owner.Owner;
    Inc(UDPat.Marker);
  end;

  CurImportCount := 0;
  NotAllImported := FALSE;

  for i1 := 0 to UDRoot.DirHigh() do // Patients Loop
  begin
    UDPat := UDRoot.DirChild(i1);
    with TK_UDStringList(UDPat) do
    begin

      if (ObjFlags and K_fpObjTVSpecMark1) <> 0 then
      begin
        NotAllImported := TRUE;
        if (Marker > 0) and ChBImportToCurPatient.Checked then
        begin
          if mrOK <> K_CMShowMessageDlg( //sysout
      'The current patient details don''t match the DICOM data.'#13#10 +
      'Click OK to continue the Import, Cancel to stop it.',
          mtWarning, [mbOK,mbCancel] ) then
          begin
            N_Dump1Str( format( 'DICOM Patient: %s %s [%s], DOB=%s, Gender=%s',
            [SL.Values['Surname'],
             SL.Values['FirstName'],
             SL.Values['ID'],
             SL.Values['DOB'],
             SL.Values['Sex']] ) );
            NotAllImported := TRUE;
            goto LExit;
          end
        end
        else
          Continue; // Patient is absent
      end;

      // Select Objects for Import
      ImgCount :=  0;
      for i2 := 0 to DirHigh() do  // Studies Loop
      begin
        with DirChild(i2) do
          for i3 := 0 to DirHigh() do   // Series Loop
          begin
            with DirChild(i3) do
              for i4 := 0 to DirHigh() do // Slides Loop
              begin
                UDImg := DirChild(i4);
                if not NotAllImported                             and
                   ((UDImg.ObjFlags and K_fpObjTVAutoCheck) <> 0) and
                   ((UDImg.ObjFlags and K_fpObjTVChecked) = 0) then
                  NotAllImported := TRUE;

                if ((UDImg.ObjFlags and K_fpObjTVAutoCheck) = 0) or
                   ((UDImg.ObjFlags and K_fpObjTVChecked) = 0) then Continue;

                // Add to Import List
                TN_UDBase(UDDIB) := UDImg.DirChild(1);
                if UDDIB <> nil then // DIBObj was saved early
                  DIBObj := TN_UDDIB(UDDIB).DIBObj
                else                 // Get DIBObj from DLL
                if not DCMDGetNodeDIB( i1, i2, i3, i4, DIBObj ) then
                begin
                  NotAllImported := TRUE;
                  Continue;
                end;

                // Select Thumbnail
                UDThumb  := nil;
                UDThumb1 := UDImg.DirChild(0);
                if (not K_CMDemoModeFlag or N_CMSkipImgDEMOLabel) and
                   (UDThumb1 <> nil)                              and
                   (UDThumb1.ObjInfo = '') then
                  UDThumb := UDThumb1;

                // Create Slide
                UDCMSlide := K_CMSlideCreateFromDIBObj( DIBObj, nil, nil, uddfNotDef, UDThumb <> nil );
                with UDCMSlide.P()^, CMSDB, TK_UDStringList(UDImg) do
                begin
                  CMSDTTaken := UDImg.ObjDateTime;
                  MediaFName := SL.Values['File'];
                  if MediaFName <> '' then
                  begin
                    WStr := MediaFName;
                    Ind := Pos('/', WStr );
                    if Ind > 0 then
                      WStr[Ind] := '\';
                    CMSSourceDescr := 'DICOM ' + ExtractFileName(WStr);
                  end
                  else
                    CMSSourceDescr := 'DICOMDIR';
                  CMSPatId := UDImg.Marker; // Patient ID

                  DCMModality := SL.Values['Modality'];
                  if Length(DCMModality) <> 2 then DCMModality := '';

                  WStr := SL.Values['KVP'];
                  if WStr <> '' then
                  begin
                    DCMKVP := StrToFloatDef( WStr, 0 );
//                  if DCMKVP = K_CMSlideDefDCMKVP then
//                    DCMKVP := 0;
                  end;

                  WStr := SL.Values['ExposureTime'];
                  if WStr <> '' then
                  begin
                    DCMExpTime := StrToIntDef( WStr, 0 );
//                  if DCMExpTime = K_CMSlideDefDCMExpTime then
//                   DCMExpTime := 0;
                  end;

                  WStr := SL.Values['TubeCurrent'];
                  if WStr <> '' then
                  begin
                    DCMTubeCur := StrToIntDef( WStr, 0 );
//                  if DCMTubeCur = K_CMSlideDefDCMTubeCur then
//                    DCMTubeCur := 0;
                  end;

                  WStr := SL.Values['RadiationDose'];
                  if WStr <> '' then
                  begin
                    DCMRDose := StrToFloatDef( WStr, 0 );
                  end;

                  WStr := SL.Values['ExposureCtrlMode'];
                  if WStr <> '' then
                  begin
                    DCMECMode := 0;
                    WStr := UpperCase(WStr);
                    if WStr = 'MANUAL' then
                      DCMECMode := 1
                    else
                    if WStr = 'AUTOMATIC' then
                      DCMECMode := 2;
                  end; // if WStr <> '' then

                end; // with UDCMSlide.P()^, CMSDB, TK_UDStringList(UDImg) do

                if UDDIB <> nil then
                  TN_UDDIB(UDDIB).DIBObj := nil;

                if UDThumb <> nil then  // Use Existing Thumbnail
                  UDCMSlide.PutDirChildSafe(K_CMSlideIndThumbnail, UDThumb);

                K_CMEDAccess.EDAAddSlide( UDCMSlide );
                ////////////////////////////////////////
                // Add to EmCache File with DICOM Attrs
                //
                if K_CMDICOMNewFSFlag then
                begin
                  with K_DCMGLibW do
                  begin
                    WStr := DCMDGetNodeFile(i1,i2,i3,i4);
                    WCMFName := N_StringToWide( WStr );
                    DI := DLCreateInstanceFromFile( @WCMFName[1], 255 );
                    if DI <> nil then
                    begin
                      DLRemoveTag( DI, K_CMDCMTPixelData );

                      // Name in EmCache
                      WStr := UDCMSlide.CMSlideECFName;
                      WStr[Length(WStr) - 4] := 'D';
                      WCMFName := N_StringToWide( WStr );

                      TransferSyntax := K_CMDCMUID_LittleEndianExplicitTransferSyntax;
                      WUInt2 := DLSaveInstance( DI, @WCMFName[1], @TransferSyntax[1] );
                      if 0 <> WUInt2 then
                        N_Dump1Str( format( 'K_CMDCMExportDCMSlide >> wrong DCMAttrs DLSaveInstance [%s] %d', [TransferSyntax, WUInt2] ) );

                      N_Dump2Str( 'DeleteDcmObject before ');
                      WUInt2 := DLDeleteDcmObject( DI );
                      if 0 <> WUInt2 then
                        N_Dump1Str( format( 'aImportCheckedExecute >> wrong DLDeleteDcmObject %d', [WUInt2] ) );
                    end // if DI <> nil then
                    else
                      N_Dump1Str( 'aImportCheckedExecute >> DLCreateInstanceFromFile Error' );
                  end; // with K_DCMGLibW do
                end; // if K_CMDICOMNewFSFlag then
                //
                // Add to EmCache File with DICOM Attrs
                ////////////////////////////////////////
                UDImgArray[ImgCount] := UDImg;
                Inc(ImgCount);
              end; // for i4 := 0 to DirHigh() do // Slides Loop
          end; // for i3 := 0 to DirHigh() do   // Series Loop
      end; // for i2 := 0 to DirHigh() do  // Studies Loo
      if ImgCount = 0 then Continue;

      CurImportCount := CurImportCount + ImgCount;
      // Import Selected
      with K_CMEDAccess do
      begin
      //////////////////////////////////
      // Save History Session Context
      //
        SavedCurSessionHistID := -1;
        SavePatID := UDImgArray[0].Marker;
        SavedCurPatID := CurPatID;
        // Add new session if needed
        N_Dump2Str( format( 'DB>> DCMDImport to PatID=%5d ImgCount=%d',
                            [SavePatID, ImgCount]) );
        if (K_CMEDAccess is TK_CMEDDBAccess) and (CurPatID <> SavePatID) then
        begin
          SavedCurSessionHistID := CurSessionHistID;
          SavedCurSessionHistStartTS := CurSessionHistStartTS;
          TK_CMEDDBAccess(K_CMEDAccess).EDAAddSessionHistRecord( SavePatID );
          EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                                   Ord(K_shNCAStartSession) ) );
        end;
        CurPatID := SavePatID;

        // Save Slides
        K_CMDCMStoreAutoSkipFlag := TRUE;
        K_CMEDAccess.EDASaveSlidesArray( TN_PUDCMSlide(K_CMGetCurSlidesListLastSlides(ImgCount)), ImgCount );
        K_CMDCMStoreAutoSkipFlag := FALSE;


        // Return old Session
        if SavedCurSessionHistID <> -1 then
        begin
          EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                         Ord(K_shNCAFinishSession) ) );
          CurSessionHistID := SavedCurSessionHistID;
          CurSessionHistStartTS := SavedCurSessionHistStartTS;
        end;

        // Clear Checked and AutoCheck flags for imported
        for i2 := 0 to ImgCount - 1 do
        begin
          if CurPatID <> SavedCurPatID then
            with CurSlidesList do
              Delete(Count - 1);
          UDImg := UDImgArray[i2];
          UDImg.ObjFlags := UDImg.ObjFlags and not (K_fpObjTVAutoCheck or K_fpObjTVChecked);
          UDImg.RebuildVTreeCheckedState();
        end; // for i2 := 0 to ImgCount - 1 do
        CurPatID := SavedCurPatID;

      end; // with K_CMEDAccess do
    end; // with UDRoot.DirChild(i1) do
  end; // for i1 := 0 to UDRoot.DirHigh() do // Patients Loop

LExit: //*****
  for i1 := 0 to UDRoot.DirHigh() do // Clear Patients Marker Loop
    UDRoot.DirChild( i1 ).Marker := 0;

  DCMDDisableActions();
  VTreeFrame.TreeView.Repaint;
  ImportedCount := ImportedCount + CurImportCount;
  N_CM_MainForm.CMMFShowStringByTimer( Format( LLLDCMDImport2.Caption,
//                ' %d of %d selected image(s) are imported',
                   [CurImportCount,CurSelectedCount] ) );

  if not NotAllImported then Self.Close(); // Close Form if all is imported
//
end; // procedure TK_FormCMDCMDImport.aImportCheckedExecute

//******************** TK_FormCMDCMDImport.aChangeImportToCurPatientExecute ***
// Change Import to current patient
//
procedure TK_FormCMDCMImport.aChangeImportToCurPatientExecute( Sender: TObject );
begin
  K_SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  K_TreeViewsUpdateModeSet;

  DCMDRebuildImportVTree( ChBImportToCurPatient.Checked, aAddMarkedPatients.Visible );

  Screen.Cursor := K_SavedCursor;
  K_TreeViewsUpdateModeClear( false );
  DCMDDisableActions();
end; // procedure TK_FormCMDCMImport.aChangeImportToCurPatientExecute

//****************************** TK_FormCMDCMDImport.DCMDRebuildImportVTree ***
// Change Import to current patient
//
procedure TK_FormCMDCMImport.DCMDRebuildImportVTree( AUseCurPat, AddPatActionVis : Boolean );
var
  i1, i2, i3, i4 : Integer;
  UDPat, UDStudy, UDSeries, UDMedia : TN_UDBase;
  PatienIsAbsentFlag : Boolean;
  UsePatID : Integer;
begin

  UsePatID := 0;
  if AUseCurPat then
    UsePatID := K_CMEDAccess.CurPatID;
  for i1 := 0 to UDRoot.DirHigh do
  begin
    UDPat := UDRoot.DirChild( i1 );
    PatienIsAbsentFlag := (UDPat.ObjFlags and K_fpObjTVSpecMark1) <> 0;

    if PatienIsAbsentFlag and (UsePatID = 0) and not AddPatActionVis then
      UDPat.ObjFlags := UDPat.ObjFlags or K_fpObjTVDisabled
    else
      UDPat.ObjFlags := UDPat.ObjFlags or K_fpObjTVDisabled xor K_fpObjTVDisabled;
    for i2 := 0 to UDPat.DirHigh do
    begin
      UDStudy := UDPat.DirChild( i2 );
      if PatienIsAbsentFlag and (UsePatID = 0) then
        UDStudy.ObjFlags := UDStudy.ObjFlags or K_fpObjTVDisabled
      else
        UDStudy.ObjFlags := UDStudy.ObjFlags or K_fpObjTVDisabled xor K_fpObjTVDisabled;
      for i3 := 0 to UDStudy.DirHigh do
      begin
        UDSeries := UDStudy.DirChild( i3 );
        if PatienIsAbsentFlag and (UsePatID = 0) then
          UDSeries.ObjFlags := UDSeries.ObjFlags or K_fpObjTVDisabled
        else
          UDSeries.ObjFlags := UDSeries.ObjFlags or K_fpObjTVDisabled xor K_fpObjTVDisabled;

        for i4 := 0 to UDSeries.DirHigh do
        begin
          UDMedia := UDSeries.DirChild( i4 );
          if not PatienIsAbsentFlag or (UsePatID <> 0) then
            UDMedia.ObjFlags := UDMedia.ObjFlags or K_fpObjTVAutoCheck
          else
            UDMedia.ObjFlags := UDMedia.ObjFlags or (K_fpObjTVAutoCheck or K_fpObjTVChecked) xor (K_fpObjTVAutoCheck or K_fpObjTVChecked);

          if UsePatID <> 0 then
            UDMedia.Marker := UsePatID
          else
          if not PatienIsAbsentFlag then
            UDMedia.Marker := StrToInt(TK_UDStringList(UDPat).SL.Values['CMSuiteID'])
          else
            UDMedia.Marker := 0;
        end; // for i4 := 0 to UDSeries.DirHigh do
      end; // for i3 := 0 to UDStudy.DirHigh do
    end; // for i2 := 0 to UDPat.DirHigh do
  end; // for i1 := 0 to UDRoot.DirHigh do
end; // procedure TK_FormCMDCMImport.DCMDRebuildImportVTree

//********************************** TK_FormCMDCMDImport.DCMDDisableActions ***
// Check all actions enabled disabled state
//
procedure TK_FormCMDCMImport.DCMDDisableActions;
var
  i : Integer;
  UncheckEnable : Boolean;
  CheckEnable : Boolean;
  AddPatientsEnable : Boolean;
  UDNode : TN_UDBase;
begin
  with VTreeFrame.VTree do
  begin
    CheckEnable := FALSE;
    UncheckEnable := FALSE;
    AddPatientsEnable := FALSE;
    for i := 0 to MarkedVNodesList.Count - 1 do
    begin
      UDNode := TN_VNode(MarkedVNodesList[i]).VNUDObj;
      with UDNode do
      begin

        if not ChBImportToCurPatient.Checked and ((ObjFlags and K_fpObjTVSpecMark1) <> 0) then
          AddPatientsEnable := TRUE
        else
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
    aImportChecked.Enabled := CheckedUObjsList.Count <> 0;
//    aAddMarkedPatients.Visible := K_CMStandaloneGUIMode and
//                                  (K_CMStandaloneMode <> K_cmsaLink);
    aAddMarkedPatients.Enabled := aAddMarkedPatients.Visible and
                                  AddPatientsEnable          and
                                  not ChBImportToCurPatient.Checked;
  end;
end; // procedure TK_FormCMDCMDImport.DCMDDisableActions

//************************************** TK_FormCMDCMDImport.DCMDGetNodeDIB ***
// Get DIBObj from object given by Indexes
//
function TK_FormCMDCMImport.DCMDGetNodeDIB(APatInd, AStudyInd, ASeriesInd,
                     AImageInd: Integer; out ADIBObj: TN_DIBObj): Boolean;
var
  RCode : Integer;
  FName : string;

  procedure GetDIB();
  begin
    ADIBObj := nil;
    RCode := K_CMDCMImportDIB( FName, ADIBObj );
  end; // procedure GetDIB

begin
  FName := DCMDGetNodeFile(APatInd, AStudyInd, ASeriesInd, AImageInd);
  GetDIB();
  Result := RCode = 0;
  if not Result then
  begin
    FreeAndNil(ADIBObj);
    if RCode = -3 then
    begin
      N_Dump1Str('DCMDGetNodeDIB >> Out Of Memory 1' );
      // Free All Memory and Try again
      K_CMSCheckMemConstraints( nil, TRUE ); // try to free all
      GetDIB();
      Result := RCode = 0;
      if not Result then
      begin
        FreeAndNil(ADIBObj);
        if RCode = -3 then
        begin
          N_Dump1Str('DCMDGetNodeDIB >> Out Of Memory 2' );

          K_CMShowMessageDlg( K_CML1Form.LLLMemory6.Caption,
  //           There is not enough memory to import the object(s).
  // Please close the open image(s) and repeat the import or restart Media Suite.
                             mtWarning );
          K_CMOutOfMemoryFlag := TRUE;
        end; // if RCode = -3 then
      end; // if not Result then
    end; // if RCode = -3 then
  end; // if not Result then

end; // function TK_FormCMDCMDImport.DCMDGetNodeDIB

//************************************** TK_FormCMDCMDImport.DCMDGetNodeDIB ***
// Get DCM file by given Indexes
//
function TK_FormCMDCMImport.DCMDGetNodeFile(APatInd, AStudyInd, ASeriesInd, AImageInd: Integer): string;
begin
  with TK_PCMDCMDPatient(TN_BytesPtr(PDCMDPatient) + APatInd * SizeOf(TK_CMDCMDPatient) )^,
       DDStudies[AStudyInd], DDSeries[ASeriesInd], DDMedias[AImageInd] do
    Result := DDMediaFile;
end; // function TK_FormCMDCMDImport.DCMDGetNodeFile

end.

