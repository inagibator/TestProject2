unit K_FrCMSlideFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  K_CM0;

type
  TK_FrameCMSlideFilter = class(TFrame)
    CmBFilterAttrs: TComboBox;
    procedure CmBFilterAttrsChange(Sender: TObject);
  private
    { Private declarations }
    SFLastFAttrs : TK_CMSlideFilterAttrs; // Last Advanced filtering attributes
    SFCurFAttrs  : TK_CMSlideFilterAttrs; // Curent filtering attributes
    SFLastItemIndex : Integer; // for storing ComboBox.ItemIndex before call Advanced Filter Form
    function BuildFilterText( APFilterAttrs : TK_PCMSlideFilterAttrs ) : string;
    procedure SFRebuildFiltersList();
  public
    { Public declarations }
    SFPFilterAttrs : TK_PCMSlideFilterAttrs; // pointer to resulting filtering attributes
    SFChangeNotify : procedure ( A : Boolean ) of object; // pointer to change filtering attributes notify procedure
    procedure SFInit();
  end;

implementation

{$R *.dfm}

uses K_CLib0,
     K_FCMSUDefFilters1,
     N_Types, N_CMResF, N_CMMain5F, K_CML1F;

{*** TK_FrameCMSlideFilter ***}

//******************************* TK_FrameCMSlideFilter.SFRebuildFiltersList ***
// Rebuild Filters List
//
procedure TK_FrameCMSlideFilter.SFRebuildFiltersList;
var
  i : Integer;
  WFAttrs : TK_CMSlideFilterAttrs; // Last Advanced filtering attributes
begin

  with CmBFilterAttrs do
  begin
//////////////////////////////////////////////////////////////////
// MediaTypes Special Codes:
//    K_CMFilterAllMTypesVal   (-2) - All MediaTypes are available
//    K_CMFilterAllMTypesVal-1 (-3) - Advanced Filtering Dialog
//    K_CMFilterAllMTypesVal-2 (-4) - Last Advanced Filtering Dialog Result
//    K_CMFilterAllMTypesVal-3 (-5) - User Define Filtering Dialog
//    UserDefineFilter       (-100) - User Define Filter
//

    K_CMEDAccess.EDAGetAllMediaTypes( Items );
    K_CMEDAccess.TmpStrings.Assign( Items );
    K_CMEDAccess.TmpStrings.Sort();
    Items.Assign( K_CMEDAccess.TmpStrings );
//    N_CurMemIni.DeleteKey( 'UserMediaFilters', 'Bitewing' );
    N_CurMemIni.ReadSection( 'UserMediaFilters', K_CMEDAccess.TmpStrings );
    if K_CMEDAccess.TmpStrings.Count = 0 then
    begin
    // Init UserDefined MediaFilters List
      K_CMFilterAttrsClear( @WFAttrs );
      WFAttrs.FAMediaType := K_CMFilterAllMTypesVal;
      WFAttrs.FATeethFlags := $3000000030000000;
      WFAttrs.FAOpenCount := 4;
      K_CMEDAccess.EDAPutUserDefineMediaFilter( K_CML1Form.LLLUDViewFilters5.Caption,
            //  'BiteWing',
                         @WFAttrs );
      N_CurMemIni.ReadSection( 'UserMediaFilters', K_CMEDAccess.TmpStrings );
    end;

    for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
       Items.InsertObject( i, K_CMEDAccess.TmpStrings[i], TObject(K_CMFilterUDViewFilter) );

    Items.InsertObject( 0, K_CML1Form.LLLUDViewFilters3.Caption,
//                  'All',
                  TObject(K_CMFilterAllMTypesVal) );
    Items.InsertObject( 1, K_CML1Form.LLLUDViewFilters4.Caption,
//                  'User defined',
                  TObject(K_CMFilterAllMTypesVal - 3) );

{ // UserDefineFilter after Simple Media Filter
    N_CurMemIni.ReadSection( 'UserMediaFilters', K_CMEDAccess.TmpStrings );
    for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
       Items.AddObject( K_CMEDAccess.TmpStrings[i], TObject(K_CMFilterUDViewFilter) );
}
  end;


end; // end of TK_FrameCMSlideFilter.SFRebuildFiltersList

//******************************* TK_FrameCMSlideFilter.SFInit ***
// Init Frame Controls
//
procedure TK_FrameCMSlideFilter.SFInit;
var
  WStr : string;
  {WInd,} WInd1 : Integer;
  SkipAdvanced : Boolean;
begin

  SFRebuildFiltersList();
  with CmBFilterAttrs do
  begin
    SkipAdvanced := TRUE;

    WInd1 := 0;
    K_CMFilterAttrsClear( @SFCurFAttrs );
    SFLastFAttrs := SFCurFAttrs;

    if not SkipAdvanced then
      Items.InsertObject( 2, 'Advanced Filter', TObject(K_CMFilterAllMTypesVal - 1) );

    if SFPFilterAttrs <> nil then
    begin
      SFCurFAttrs := SFPFilterAttrs^;
      SFLastFAttrs := SFCurFAttrs;
      if not SkipAdvanced then
      begin
        WStr := K_StrCutByWidth( Canvas.Handle, BuildFilterText( SFPFilterAttrs ), '...', Width - 24 );
        with SFPFilterAttrs^ do
        begin
          if FAMediaType >= 0 then
            WInd1 := Items.IndexOfObject( TObject(FAMediaType) )
          else
            WInd1 := 0;
          if FATeethFlags <> 0 then
          begin
            Items.AddObject( WStr, TObject(K_CMFilterAllMTypesVal - 2) );
            WInd1 := Items.Count - 1;
          end;
        end;
      end;
    end;

    if WInd1 < 0 then WInd1 := 0;
    ItemIndex := WInd1;
    SFLastItemIndex := WInd1; // for Advanced Filter
  end;


end; // end of TK_FrameCMSlideFilter.SFInit

//******************************* TK_FrameCMSlideFilter.CmBFilterAttrsChange ***
// Filter Attributes ComboBox Change Handler
//
procedure TK_FrameCMSlideFilter.CmBFilterAttrsChange(Sender: TObject);
var
  WasChanged : Boolean;
  WInt : Integer;
  WFAttrs : TK_CMSlideFilterAttrs; // Last Advanced filtering attributes

Label SelectFilter;
begin
  if K_CMShowGUIFlag then Exit;
  with CmBFilterAttrs do begin
SelectFilter:
    WInt := Integer(Items.Objects[ItemIndex]);
    if WInt = K_CMFilterAllMTypesVal - 2 then
  //*** Last Advanced Filter Results (not used if User Defined Filter)
      WFAttrs := SFLastFAttrs
    else
    if WInt = K_CMFilterAllMTypesVal - 3 then
    begin
  //*** User Defined Filter Setup
      Inc(K_CMD4WWaitApplyDataCount);
      with TK_FormCMSUDefFilters1.Create(Application) do
      begin
        BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
        ShowModal();
        SFRebuildFiltersList();
        ItemIndex := 0;
      end;
      Dec(K_CMD4WWaitApplyDataCount);
      if K_CMD4WWaitApplyDataCount = 0 then
        K_CMD4WApplyBufContext( );

      goto SelectFilter;
//      WFAttrs := SFCurFAttrs;
    end
    else if WInt = K_CMFilterUDViewFilter then
    begin
  //*** User Defined Filter Select
      K_CMEDAccess.EDAGetUserDefineMediaFilter( Items[ItemIndex], @WFAttrs );
    end
    else
    begin
  //*** Simple MediaType filtering only was selected
      K_CMFilterAttrsClear( @WFAttrs );
      WFAttrs.FAMediaType := WInt;
    end;

    WasChanged := WFAttrs.FATeethFlags <> SFCurFAttrs.FATeethFlags;
    if not WasChanged then
    begin
      WasChanged := WFAttrs.FAMediaType <> SFCurFAttrs.FAMediaType;
      if not WasChanged then
      begin
        WasChanged := WFAttrs.FAOpenCount <> SFCurFAttrs.FAOpenCount;
        if not WasChanged then
        begin
          WasChanged := WFAttrs.FADateMode <> SFCurFAttrs.FADateMode;
          if not WasChanged then
          begin
            if WFAttrs.FADateMode = K_sfdsmDatesRange then
              WasChanged := (WFAttrs.FADate1 <> SFCurFAttrs.FADate1) or
                            (WFAttrs.FADate2 <> SFCurFAttrs.FADate2);
          end;
        end;
      end;
    end;

    if WasChanged then
    begin
      SFCurFAttrs := WFAttrs;
      if SFPFilterAttrs <> nil then
        SFPFilterAttrs^ := SFCurFAttrs;
      if Assigned(SFChangeNotify) then SFChangeNotify( TRUE );
      with K_CMEDAccess do
        if StateSaveMode = K_cmetImmediately then
          EDASaveContextsData( [K_cmssSkipSlides] );// Save Contexts
    end;
  end;
end; // end of TK_FrameCMSlideFilter.CmBFilterAttrsChange

//******************************* TK_FrameCMSlideFilter.BuildFilterText ***
// Build Filter Attributes text representation
//
//     Parameters
// APFilterAttrs - pointer to to filter attributes record
// Result - Returns Filter Attributes text representation
//
function TK_FrameCMSlideFilter.BuildFilterText( APFilterAttrs : TK_PCMSlideFilterAttrs ) : string;
var
  WInt : Integer;
begin
  with APFilterAttrs^ do begin
    Result := '';
    with CmBFilterAttrs do
      if FAMediaType >= 0 then begin
        WInt := Items.IndexOfObject( TObject(FAMediaType) );
        if WInt >= 0 then
          Result := Items[WInt];
      end;
    if FATeethFlags <> 0 then begin
      if Result <> '' then Result := Result +  ',';
      Result := Result + K_CMSTeethChartStateToText( FATeethFlags );
    end;
  end;

end; // end of TK_FrameCMSlideFilter.BuildFilterText

{*** end of TK_FrameCMSlideFilter ***}

end.
