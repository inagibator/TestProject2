unit K_FCMSetSlidesAttrs3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, ComCtrls, ToolWin, ExtCtrls, StdCtrls, Contnrs,
  K_CM0, K_FCMSetSlidesAttrs2, K_FrCMTeethChart1,
  N_Types, N_Rast1Fr, N_CMREd3Fr;

type
  TK_FormCMSetSlidesAttrs3 = class(TK_FormCMSetSlidesAttrs2)
    CMStudyFrame: TN_CMREdit3Frame;
    LbStudyNote: TLabel;
    procedure CMStudyFrameMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CMStudyFrameMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function K_CMSetSlidesAttrs3( out AMountedInds : TN_IArray; ASlidesCount: Integer;
                             APDCMAttrs : TK_PCMDCMAttrs;
                             AUDStudy : TN_UDCMStudy = nil;
                             ACaption : string = '';
                             ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                             AIniMediaType : Integer = 0 ) : Integer; overload;

function K_CMSetSlidesAttrs3( out AMountedInds : TN_IArray; APSlides: TN_PUDCMSlide; ACount : Integer;
                             APDCMAttrs : TK_PCMDCMAttrs;
                             AUDStudy : TN_UDCMStudy = nil;
                             ACaption : string = '';
                             ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                             AIniMediaType : Integer = 0 ) : Integer; overload;
implementation

uses K_UDT1, K_CM1, N_SGComp,N_CMMain5F;

{$R *.dfm}

//***************************************************** K_CMSetSlidesAttrs3 ***
// Set properties to last added new Slides
//
//    Parameters
// AMountedInds - Mounted Slides Indexes in Study
// ASlidesCount - number of last added new Slide  to edit properties
// AUDStudy - study to mount, if nil use current active study
// ACaption - form caption
// ASkipProcessDate - skip date while change Objects Properties
// AIniMediaType - initial Media Type
//
function K_CMSetSlidesAttrs3( out AMountedInds : TN_IArray; ASlidesCount: Integer;
                             APDCMAttrs : TK_PCMDCMAttrs;
                             AUDStudy : TN_UDCMStudy = nil;
                             ACaption : string = '';
                             ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                             AIniMediaType : Integer = 0 ) : Integer; overload;
var
  Slides : TN_UDCMSArray;
begin
  Result := ASlidesCount;
  AMountedInds := nil;
  Slides := nil;
  if ASlidesCount = 0 then Exit;

  Slides := K_CMGetCurSlidesListLastSlides( ASlidesCount );

  Result := K_CMSetSlidesAttrs3( AMountedInds, @Slides[0], ASlidesCount, APDCMAttrs,
                   AUDStudy, ACaption, ASSAFlags, AIniMediaType );
end; // function K_CMSetSlidesAttrs3

//***************************************************** K_CMSetSlidesAttrs3 ***
// Set properties to given Slides
//
//    Parameters
// AMountedInds - Mounted Slides Indexes in Study
// APSlides - pointer to Slides array first element
// ACount - number of elements in Slides array
// AUDStudy - study to mount, if nil use current active study
// ACaption - form caption
// ASkipProcessDate - skip date while change Objects Properties
// AIniMediaType - initial Media Type
//
function K_CMSetSlidesAttrs3( out AMountedInds : TN_IArray;
                              APSlides: TN_PUDCMSlide; ACount : Integer;
                              APDCMAttrs : TK_PCMDCMAttrs;
                              AUDStudy : TN_UDCMStudy = nil;
                              ACaption : string = '';
                              ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                              AIniMediaType : Integer = 0 ) : Integer; overload;
var
  FForm : TK_FormCMSetSlidesAttrs3;
  i, SInd, MInd : Integer;
  PUDCMSlide : TN_PUDCMSlide;
  UseDBMode : Boolean;
  UDStudy : TN_UDCMBSlide;
begin
  N_Dump2Str( 'Start K_CMSetSlidesAttrs3' );
  Result := 0;
  AMountedInds := nil;
  if (APSlides = nil) or (ACount = 0) then Exit;

  FForm := TK_FormCMSetSlidesAttrs3.Create(Application);

  K_CMInitSetSlidesAttrsForm( FForm,  APSlides, ACount, APDCMAttrs,
                              ACaption, ASSAFlags, AIniMediaType );
  with FForm do
  begin
    with SSAThumbsDGrid do
    begin
//      DGMultiMarking  := False; //
      DGMarkSingleItem( 0 );
    end; // with ThumbsDGrid do

    with CMStudyFrame do
    begin
      RFrame.RFDebName := Name;
      RFrame.PaintBox.OnDblClick := nil;
      EdVObjsGroup := TN_SGComp.Create( RFrame );
      with EdVObjsGroup do
      begin
        GName := 'VOGroup';
        PixSearchSize := 15;
        SGFlags := $02 + // search lines even out of UDPolyline and UDArc components
                   $04;  // do redraw actions loop witout objects
      end;
      RFrame.RFSGroups.Add( EdVObjsGroup );

      UDStudy := AUDStudy;
      if UDStudy = nil then
        UDStudy := N_CM_MainForm.CMMFActiveEdFrame.EdSlide;
      EdSlide := TN_UDCMSlide(UDStudy);
      RFrame.DstBackColor := ColorToRGB( RFrame.PaintBox.Color );
      RFrame.OCanvBackColor := RFrame.DstBackColor;
      RFrame.RFCenterInDst := True;
      RFrame.RVCTFrInit3( EdSlide.GetMapRoot() );
      RFrame.aFitInWindowExecute( nil );
      RebuildStudySearchList();
//      RFrame.RedrawAllAndShow();
    end; // with RFrame do
//

    N_Dump1Str( 'Before TK_FormCMSetSlidesAttrs3.ShowModal' );
    ShowModal;
    N_Dump1Str( 'After TK_FormCMSetSlidesAttrs3.ShowModal' );
  end; // with TK_FormCMSetSlidesAttrs2.Create(Application) do

  if K_CMD4WAppFinState then Exit; // Application is already finished

  if K_CMSMainUIShowMode = 1 then
  begin  // Special process of remained slides in Photometry mode
    with FForm, SSAThumbsDGrid, DGMarkedList do
    begin
      for i := 0 to High(SSASlides) - DGMarkedList.Count do
        DGMarkedList.Add(nil);
      for i := 0 to High(SSASlides) do
        DGMarkedList[i] := Pointer(i);
    end;
    FForm.DeleteSelectedExecute( nil );
  end;

  FForm.CMStudyFrame.RFrame.RFFreeObjects();

  Result := K_CMFinSlidesAttrsForm(FForm);

  N_CM_MainForm.CMMCurFMainForm.Refresh(); // To Clear Modal Form Window

  if Result > 0 then
  begin
    TN_UDCMStudy(UDStudy).UnSelectAll();
    UseDBMode := K_CMEDAccess is TK_CMEDDBAccess;
  // Save Init ObjName Before Saving for DB Slide->Study Link Info Rebuild
    with K_CMEDAccess, CurSlidesList do
    begin
      if UseDBMode then
      begin
        PUDCMSlide := TN_PUDCMSlide(@List[Count - Result]);
        for i := 0 to Result - 1 do
        begin
          PUDCMSlide.ObjAliase := PUDCMSlide.ObjName;
          Inc(PUDCMSlide);
        end;
      end; // if K_CMEDAccess is TK_CMEDDBAccess then

      Result := K_CMSaveLastInCurSlidesList( Result );

      if Result > 0 then
      begin
        PUDCMSlide := TN_PUDCMSlide(@List[Count - Result]);
        MInd := 0;
        SetLength( AMountedInds, Result );
        for i := 0 to Result - 1 do
        begin
          with PUDCMSlide^ do
          begin
            if CMSStudyID <> 0 then
            begin
              AMountedInds[MInd] := CMSStudyItemID;
              Inc(MInd);
              if UseDBMode then
                // Rebuild DB Slide->Study Link Info by SLides Real IDs after Slides Saving
                with TK_CMEDDBAccess(K_CMEDAccess).SlideStudyInfoUpdateStrings do
                begin
                  SInd := IndexOfName(ObjAliase);
                  Strings[SInd] := ObjName + '=' + ValueFromIndex[SInd];
                end;
            end;
            ObjAliase := ''; // Clear Obj ALiase
          end; // with PUDCMSlide^ do
          Inc(PUDCMSlide);
        end; // for i := 0 to Result - 1 do
        SetLength( AMountedInds, MInd );
      end; // if Result > 0 then
    end; // with K_CMEDAccess, CurSlidesList do

  end; // if Result > 0 then
  N_Dump2Str( 'Fin K_CMSetSlidesAttrs3' );
end; // end of K_CMSetSlidesAttrs3

//*************************** TK_FormCMSetSlidesAttrs3.CMStudyFrameMouseUp ***
//
//
procedure TK_FormCMSetSlidesAttrs3.CMStudyFrameMouseUp(Sender: TObject;
                Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  inherited;
  if SSACloseOnMouseUp then CloseCancelExecute(Sender);
end; // procedure TK_FormCMSetSlidesAttrs3.CMStudyFrameMouseUp

//*************************** TK_FormCMSetSlidesAttrs3.CMStudyFrameMouseDown ***
//
//
procedure TK_FormCMSetSlidesAttrs3.CMStudyFrameMouseDown(Sender: TObject;
                Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  RCount : Integer;
  Item : TN_UDBase;
  Slide : TN_UDCMSlide;
  SInd : Integer;

  procedure SaveSlideChangeContext();
  begin
    RCount := RCount + TN_UDCMStudy(CMStudyFrame.EdSlide).SelectItem( Item );

    SSACloseOnMouseUp := Length(SSASlides) = 1;
    // Set SLide Attrs and Remove from  Thumbnails Frame
    SaveSelectedExecute(Sender);

    // Select Next Slide to mount
    if Length(SSASlides) > 0 then
      SSAThumbsDGrid.DGMarkSingleItem(0);
  end; // procedure SaveSlideChangeContext

begin
//  inherited;
  with SSAThumbsDGrid, DGMarkedList do
  begin
    if Count = 0 then Exit; // Nothing to do
  // set selected slides attributes
    SInd := Integer(List[Count-1]);
    Slide := SSASlides[SInd];
    DGMarkSingleItem(SInd);
  end;

  with CMStudyFrame, EdVObjsGroup, OneSR do
  begin
    RCount := 0;
    if (ssLeft in Shift) then
    begin
      RCount := TN_UDCMStudy(EdSlide).UnSelectAll();
      if SRType <> srtNone then
      begin
        Item := TN_UDBase(SComps[SRCompInd].SComp);
        if (K_CMEDDBVersion >= 39) and (K_CMSMainUIShowMode < 1) then
        begin // Add Slide to Study Item - if Addition is available and not Photometry UI mode
          SaveSlideChangeContext();
          // Mount Slide - should be done after SaveSelected because CMSDateTaken may be changed
          K_CMEDAccess.EDAStudyMountAddSlideToItem( Item, Slide, TN_UDCMStudy(EdSlide), FALSE );
        end
        else
        if K_CMStudyGetOneSlideByItem( Item ) = nil then
        begin
          SaveSlideChangeContext();
          // Mount Slide - should be done after SaveSelected because CMSDateTaken may be changed
          K_CMEDAccess.EDAStudyMountOneSlideToEmptyItem( Item, Slide, TN_UDCMStudy(EdSlide) );
        end;
      end
    end;
    if RCount > 0 then
      RFrame.RedrawAllAndShow();
  end;

end; // TK_FormCMSetSlidesAttrs3.CMStudyFrameMouseDown

end.
