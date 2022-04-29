unit K_FCMDCMDImport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ActnList, Menus, StdCtrls,
  N_BaseF, N_Rast1Fr, N_Gra2,
  K_CMDCMDLib, K_UDT1;

type
  TK_FormCMDCMDImport = class(TN_BaseForm)
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
    procedure aAddMarkedPatientsExecute(Sender: TObject);
    procedure aCheckAllMarkedObjsExecute(Sender: TObject);
    procedure aUncheckAllMarkedObjsExecute(Sender: TObject);
    procedure aImportCheckedExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DCMDLib : TK_CMDCMDLib;
    UDRoot : TN_UDBase;      // UDRoot for Patient UDNodes
    UDThumbRoot : TN_UDBase; // UDRoot for Dynamically created Thumbnails
    ImportedCount : Integer;
    procedure DCMDDisableActions( );
    procedure DCMDVTFOnSelect( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
    procedure DCMDVTFOnMouseDown( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
    function  DCMDGetNodeDIB( APatInd, AStudyInd, ASeriesInd, AImageInd : Integer;
                              out ADIBObj : TN_DIBObj ) : Boolean;
  end;

var
  K_FormCMDCMDImport: TK_FormCMDCMDImport;

function K_CMSlidesImportFromDICOMDIR( AFNames : TStrings ) : Integer;
function K_CMDCMSlidesImport( APDCMDPatientIn : TK_PCMDCMDPatientIn; ADCMDPatientCount : Integer;
                              ADCMDLib : TK_CMDCMDLib ) : Integer;

implementation

uses K_CM0, K_UDConst, K_UDT2, K_Script1, K_CML1F,
     N_Types, N_Gra0, N_CompCL, N_CompBase, N_Comp1, N_CM1, N_Lib0, N_CMMain5F;

{$R *.dfm}

function K_CMSlidesImportFromDICOMDIR( AFNames : TStrings ) : Integer;
var
  PDCMDPatientIn : TK_PCMDCMDPatientIn;
  DCMDPatientCount : Integer;
  FDCMDLib : TK_CMDCMDLib;
  ResCode : Integer;
begin

  FDCMDLib := TK_CMDCMDLib.Create;
  N_Dump1Str( 'ImportFromDICOMDIR >> before DDStartImport Files:' );
  N_Dump2Strings( AFNames, 5 );
  N_CM_MainForm.CMMFShowString( 'DICOM import is preparing. Please wait ...' );
  ResCode := FDCMDLib.DDStartImport( AFNames, PDCMDPatientIn, DCMDPatientCount );
  Result := 0;
  if ResCode <> 0 then
    K_CMShowMessageDlg( 'Errors in given DICOM file(s).',
                        mtWarning )
  else
    Result := K_CMDCMSlidesImport( PDCMDPatientIn, DCMDPatientCount, FDCMDLib );

  FDCMDLib.DDFinImport;
  FDCMDLib.Free;

end; // function K_CMSlidesImportFromDICOMDIR

function K_CMDCMSlidesImport( APDCMDPatientIn : TK_PCMDCMDPatientIn; ADCMDPatientCount : Integer;
                              ADCMDLib : TK_CMDCMDLib ) : Integer;
begin
  with TK_FormCMDCMDImport.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    UDRoot := nil;
    K_CMCreateDCMDUDTree( UDRoot, APDCMDPatientIn, ADCMDPatientCount,
                          K_CMEDAccess.EDADCMCheckPatient );

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

    DCMDLib := ADCMDLib;

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
procedure TK_FormCMDCMDImport.DCMDVTFOnMouseDown( AVTreeFrame: TN_VTreeFrame;
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
procedure TK_FormCMDCMDImport.DCMDVTFOnSelect( AVTreeFrame: TN_VTreeFrame;
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
//    DCMDLib.DDGetDIB( PatInd, StudyInd, SeriesInd, MediaInd, ImgDIBObj );
    if not DCMDGetNodeDIB( PatInd, StudyInd, SeriesInd, MediaInd, ImgDIBObj ) then
    begin
      RFrame.RFrInitByComp( nil );
      RFrame.ShowMainBuf();
      Exit;
    end;

    // Get Image Thumbnail DIBObj
    DCMDLib.DDGetThumbDIB( ImgDIBObj, ThumbDIB );
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
procedure TK_FormCMDCMDImport.aAddMarkedPatientsExecute(Sender: TObject);
var
  i, i1, i2, i3, i4, PatID, FCount : Integer;
  SAPatientDBData : TK_CMSAPatientDBData;
  PatSID : string;
  ScanUDSubTree : TK_ScanUDSubTree;
  DIBInfo: TN_DIBInfo;

begin
//
  ZeroMemory( @DIBInfo, SizeOf(TN_PDIBInfo) );
  DIBInfo.bmi.biSize := SizeOf(DIBInfo.bmi);

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
                    if 0 = DCMDLib.DDGetDIBInfo( i1, i2, i3, i4, @DIBInfo ) then
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
procedure TK_FormCMDCMDImport.aCheckAllMarkedObjsExecute(Sender: TObject);
var
  i : Integer;
begin
  with VTreeFrame.VTree do
  begin
    for i := MarkedVNodesList.Count - 1 downto 0 do
      with TN_VNode(MarkedVNodesList[i]) do
      begin
        if (VNUDObj.ObjFlags and K_fpObjTVSpecMark1) <> 0 then Continue;
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
procedure TK_FormCMDCMDImport.aUncheckAllMarkedObjsExecute(Sender: TObject);
var
  i : Integer;
begin
  with VTreeFrame.VTree do
  begin
    for i := MarkedVNodesList.Count - 1 downto 0 do
      with TN_VNode(MarkedVNodesList[i]) do
      begin
        if (VNUDObj.ObjFlags and K_fpObjTVSpecMark1) <> 0 then Continue;
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
procedure TK_FormCMDCMDImport.aImportCheckedExecute(Sender: TObject);
var
  i1, i2, i3, i4, ImgCount, CurSelectedCount, Ind : Integer;
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
begin

  SetLength( UDImgArray, VTreeFrame.VTree.CheckedUObjsList.Count );

  CurImportCount := 0;
  NotAllImported := FALSE;
  CurSelectedCount := 0;
  for i1 := 0 to UDRoot.DirHigh() do // Patients Loop
  begin
    with UDRoot.DirChild(i1) do
    begin

      if (ObjFlags and K_fpObjTVSpecMark1) <> 0 then
      begin
        NotAllImported := TRUE;
        Continue; // Patient is absent
      end;

      // Select Objects for Import
      ImgCount := 0;
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

                Inc(CurSelectedCount);
                TN_UDBase(UDDIB) := UDImg.DirChild(1);
                if UDDIB <> nil then // DIBObj was saved early
                  DIBObj := TN_UDDIB(UDDIB).DIBObj
                else                 // Get DIBObj from DLL
                if not DCMDGetNodeDIB( i1, i2, i3,i4, DIBObj ) then
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
                    DCMKVP := StrToIntDef( WStr, 0 );
//                  if DCMKVP = K_CMSlideDefDCMKVP then
//                    DCMKVP := 0;
                  end;

                  WStr := SL.Values['ExposureTime'];
                  if WStr <> '' then
                  begin
                    DCMExpTime := StrToIntDef( WStr, 0 );
//                  if DCMExpTime = K_CMSlideDefDCMExpTime then
//                    DCMExpTime := 0;
                  end;

                  WStr := SL.Values['TubeCurrent'];
                  if WStr <> '' then
                  begin
                    DCMTubeCur := StrToIntDef( WStr, 0 );
//                  if DCMTubeCur = K_CMSlideDefDCMTubeCur then
//                    DCMTubeCur := 0;
                  end;
                end;
                if UDDIB <> nil then
                  TN_UDDIB(UDDIB).DIBObj := nil;

                if UDThumb <> nil then  // Use Existing Thumbnail
                  UDCMSlide.PutDirChildSafe(K_CMSlideIndThumbnail, UDThumb);

                K_CMEDAccess.EDAAddSlide( UDCMSlide );

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
        K_CMEDAccess.EDASaveSlidesArray( TN_PUDCMSlide(K_CMGetCurSlidesListLastSlides(ImgCount)), ImgCount );


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
  DCMDDisableActions();
  VTreeFrame.TreeView.Repaint;
  ImportedCount := ImportedCount + CurImportCount;
  N_CM_MainForm.CMMFShowStringByTimer( Format( LLLDCMDImport2.Caption,
//                ' %d of %d selected image(s) are imported',
                   [CurImportCount,CurSelectedCount] ) );

  if not NotAllImported then Self.Close(); // Close Form if all is imported
//
end; // procedure TK_FormCMDCMDImport.aImportCheckedExecute

//********************************** TK_FormCMDCMDImport.DCMDDisableActions ***
// Check all actions enabled disabled state
//
procedure TK_FormCMDCMDImport.DCMDDisableActions;
var
  i : Integer;
  UncheckEnable : Boolean;
  CheckEnable : Boolean;
  AddPatienrsEnable : Boolean;
  UDNode : TN_UDBase;
begin
  with VTreeFrame.VTree do
  begin
    CheckEnable := FALSE;
    UncheckEnable := FALSE;
    AddPatienrsEnable := FALSE;
    for i := 0 to MarkedVNodesList.Count - 1 do
    begin
      UDNode := TN_VNode(MarkedVNodesList[i]).VNUDObj;
      with UDNode do
      begin
        if (ObjFlags and K_fpObjTVSpecMark1) <> 0 then
          AddPatienrsEnable := TRUE
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
    aAddMarkedPatients.Enabled := AddPatienrsEnable and
                                  K_CMStandaloneGUIMode and
                                  (K_CMStandaloneMode <> K_cmsaLink);
  end;
end; // procedure TK_FormCMDCMDImport.DCMDDIsableActions;

//************************************** TK_FormCMDCMDImport.DCMDGetNodeDIB ***
// Get DIBObj from object given by Indexes
//
function TK_FormCMDCMDImport.DCMDGetNodeDIB(APatInd, AStudyInd, ASeriesInd,
                     AImageInd: Integer; out ADIBObj: TN_DIBObj): Boolean;
var
  RCode : Integer;
begin
  ADIBObj := nil;
  RCode := DCMDLib.DDGetDIB( APatInd, AStudyInd, ASeriesInd, AImageInd, ADIBObj );
  Result := RCode = 0;
  if not Result then
  begin
    FreeAndNil(ADIBObj);

    N_Dump1Str( Format(
      'Err DDGetDIB %dx%d, R=%d',
               [DCMDLib.DDLastImageSize.X, DCMDLib.DDLastImageSize.Y,RCode] ));

    if RCode = -3 then
    begin
      N_Dump2Str('DCMDGetNodeDIB >> Out Of Memory 1' );
      // Free All Memory and Try again
      K_CMSCheckMemConstraints( nil, TRUE ); // try to free all
      RCode := DCMDLib.DDGetDIB( APatInd, AStudyInd, ASeriesInd, AImageInd, ADIBObj );
      Result := RCode = 0;
      if not Result then
      begin
        FreeAndNil(ADIBObj);
        if RCode = -3 then
        begin
          N_Dump2Str('DCMDGetNodeDIB >> Out Of Memory 2' );

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

end.

