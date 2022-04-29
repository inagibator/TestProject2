unit K_FCMPrefEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, ActnList,
  K_CM0, K_UDT1,
  N_BaseF, N_Types, N_Gra2;

type
  TK_FormPrefEdit = class(TN_BaseForm)
    PageControl: TPageControl;
    TSApplication: TTabSheet;
    GBMTypes: TGroupBox;
    LVMTypes: TListView;
    RGToothNumbering: TRadioGroup;
    BtCancel: TButton;
    BtOK: TButton;
    BtAdd: TButton;
    BtDel: TButton;
    ActionList1: TActionList;
    AddMType: TAction;
    DelMType: TAction;
    TSColorizeIsodensity: TTabSheet;
    GBColorise: TGroupBox;
    CmBPalsList: TComboBox;
    ChBShowEmbossDetails: TCheckBox;
    EdMTypeCName: TEdit;
    GBThumbTexts: TGroupBox;
    ChBDateTaken: TCheckBox;
    ChBTimeTaken: TCheckBox;
    ChBTeethChart: TCheckBox;
    ChBMediaSource: TCheckBox;
    GBFilters: TGroupBox;
    CmBFilters: TComboBox;
    LbFilter: TLabel;
    LbFHotKey: TLabel;
    CmBShortCuts: TComboBox;
    BtFilterSetup: TButton;
    GBSmooth: TGroupBox;
    ChBSmooth: TCheckBox;
    GBEEFilesNames: TGroupBox;
    ChBEEPatSurname: TCheckBox;
    ChBEEPatFirstName: TCheckBox;
    ChBEEPatTitle: TCheckBox;
    ChBEEPatCardNum: TCheckBox;
    ChBEEObjDateTaken: TCheckBox;
    ChBEEObjID: TCheckBox;
    ChBEEPatDOB: TCheckBox;
    ChBEEObjTeethChart: TCheckBox;
    EdFUDCaption: TEdit;
    LbFUDCaption: TLabel;
    GBIU: TGroupBox;
    RBIUInterval: TRadioGroup;
    CmBIUCMDLType: TComboBox;
    GBCTA: TGroupBox;
    LbCTA: TLabel;
    LbCTAHotKey: TLabel;
    LbCTACaption: TLabel;
    CmBCTA: TComboBox;
    CmBShortCuts1: TComboBox;
    BtCTASetup: TButton;
    EdCTACaption: TEdit;
    BtEmailSettings: TButton;
    GBImageUpdate: TGroupBox;
    ChBIUMouseStop: TCheckBox;
    CmBIUMouseDelay: TComboBox;
    LbIUDelayCapt: TLabel;
    CmBUseToolbarType: TComboBox;

    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure LVMTypesSelectItem( Sender: TObject; Item: TListItem; Selected: Boolean );
    procedure LVMTypesKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure BtDelEnter(Sender: TObject);
    procedure AddMTypeExecute(Sender: TObject);
    procedure DelMTypeExecute(Sender: TObject);
    procedure CmBPalsListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure CmBPalsListChange(Sender: TObject);
    procedure ChBShowEmbossDetailsClick(Sender: TObject);
    procedure EdMTypeCNameExit(Sender: TObject);
    procedure EdMTypeCNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CmBShortCutsChange(Sender: TObject);
    procedure CmBFiltersChange(Sender: TObject);
    procedure BtFilterSetupClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EdFUDCaptionChange(Sender: TObject);
    procedure BtCTASetupClick(Sender: TObject);
    procedure EdCTACaptionChange(Sender: TObject);
    procedure CmBShortCuts1Change(Sender: TObject);
    procedure CmBCTAChange(Sender: TObject);
    procedure BtEmailSettingsClick(Sender: TObject);
    procedure ChBIUMouseStopClick(Sender: TObject);
  private
    { Private declarations }
    AMTL   : TStrings;
    LEItem : TListItem; // last edited item

    SkipMTypeFinEdit  : Boolean;
//    RenamingStartFlag : Boolean;
    AddingStartFlag   : Boolean;
    ColorGradientCount : Integer;
    GradientColors : TN_IArray;
    CMUFilterProfiles : array of TK_CMUFilterProfile;
    CMGFiltersUseFlag : Boolean; // Global Filters Use Flag
{ // Skip Change Current Active Slide Colorize
    CurDIB : TN_DIBObj;
    EmbDIB1, EmbDIB2 : TN_DIBObj;
    WVCAttrs : TK_CMSImgViewConvData;
}
    CTAUDRoot : TN_UDBase;
    EMSettingsList : TStrings;
    EMUseCommonSettings : Boolean;
    EMChangeFlag : Boolean;

    ToolbarGlobalInitState : Integer;
    ToolbarGlobalWasChanged : Boolean;

    IUSLocID : string;
    IUSaveFlag : Boolean;

    procedure StartMTypeEdit();
    procedure ShowFilterState();
    procedure ShowCTAState();
  public
    { Public declarations }
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
  end;

var
  K_FormPrefEdit: TK_FormPrefEdit;

implementation

{$R *.dfm}

uses Math,
     K_CLib0, K_CLib, K_Script1, K_FCMImgFilterProcAttrs, K_CML1F, K_UDC, K_SBuf,
     K_FCMSTextAttrs, K_FCMMailCAttrs, K_CM1,
     N_Lib0, N_Lib1, N_CMMain5F, N_CMResF, N_Comp1, N_CompCL;

const
//  K_CMNewMediaTypeCaption = 'New Media Category';
  K_CMNewMediaTypeID = $FFFFFFF;
  K_CmCustToolbarStateToInd: array [0..3] of Integer = (0,2,3,1);
  K_CmCustToolbarIndToState: array [0..3] of Integer = (0,3,1,2);

//***********************************  TK_FormPrefEdit.FormShow ***
//
procedure TK_FormPrefEdit.FormShow(Sender: TObject);
var
  i, j : Integer;
  UDPat : TN_UDBase;
  UDCTA : TN_UDBase;
  CTASectName :  string;
  CTAUseFlag : Boolean;
  GTBSmallButtonsIni, GTBSmallButtonsIniPrev : Boolean;
  GTBStateTextIni, GTBStateTextIniPrev : string;
  MouseDelay, PrevMouseDelay : Double;
  SMouseState : string;
  SavedMouseDelay : Double;
  MouseDelayInd : Integer;

  procedure PrepCurToolbarStateByContext( const APref : string );
  var
    i : Integer;
  begin
    GTBSmallButtonsIni := N_MemIniToBool( 'CMS_Main', APref + 'CustToolbarSmallButtons',  FALSE );
    // Save Buttons
    GTBStateTextIni := '';
    for i := 0 to 3 do
    begin
      N_MemIniToStrings( APref + 'CMCustToolbar' + IntToStr(i), K_CMEDAccess.TmpStrings );
      GTBStateTextIni := GTBStateTextIni + K_CMEDAccess.TmpStrings.Text;
    end;
  end; // procedure PrepCurToolbarStateByContext

  procedure CreateCurToolbarStateForCompare( );
  begin
    GTBSmallButtonsIni := FALSE; // to prevent warning;
    GTBStateTextIni := '';
    if ToolbarGlobalInitState = 1 then
      PrepCurToolbarStateByContext( 'G' )
    else
    if ToolbarGlobalInitState = 2 then
      PrepCurToolbarStateByContext( 'GG' );
  end; // procedure CreateCurToolbarStateForCompare

begin
  inherited;
  // Get Last Common Context

  ToolbarGlobalInitState := K_CMUseCustToolbarInd;
  CreateCurToolbarStateForCompare();

  K_CMEDAccess.EDANotGAGlobalToCurState(); // Get Last Global Flags

  K_CMEDAccess.EDALocationToCurState(); // Get Last Global CTA

  if (ToolbarGlobalInitState > 0) and (ToolbarGlobalInitState < 3) then
  begin // Check if Toolbar State was Changed
    GTBSmallButtonsIniPrev := GTBSmallButtonsIni;
    GTBStateTextIniPrev := GTBStateTextIni;
    CreateCurToolbarStateForCompare();

    // Compare SmallButtons Flag
    ToolbarGlobalWasChanged := GTBSmallButtonsIni <> GTBSmallButtonsIniPrev;

    // Compare Buttons
    if not ToolbarGlobalWasChanged then
      ToolbarGlobalWasChanged := GTBStateTextIni <> GTBStateTextIniPrev;
  end; // if ToolbarGlobalInitState > 0 then

  ChBSmooth.Checked := K_CMStretchBltMode = HALFTONE;

  if K_CMToothNumSchemeFlag = K_CMTNumFDIScheme then
    RGToothNumbering.ItemIndex := 0
  else
    RGToothNumbering.ItemIndex := 1;

  AMTL := K_CMEDAccess.EDAGetAllMediaTypes0();
  for i := 1 to AMTL.Count - 1 do begin
    LVMTypes.AddItem( AMTL[i], AMTL.Objects[i] );
  end;
  EdMTypeCName.Enabled  := FALSE;

 // Colorization Init
  ColorGradientCount := 50;
  SetLength( GradientColors, ColorGradientCount );

{ // Skip Change Current Active Slide Colorize
  with N_CM_MainForm, CMMFActiveEdFrame do begin

    if (EdSlide <> nil) and
       (cmsfGreyScale in EdSlide.P()^.CMSDB.SFlags) then begin
      CurDIB   := EdSlide.GetCurrentImage.DIBObj;
      EdSlide.GetImgViewConvData( @WVCAttrs );
    end;

    CmBPalsList.Items.Clear;
    for i := 0 to High(K_CMColorizePalNames) do
      CmBPalsList.Items.Add( K_CMColorizePalNames[i] );

    if CurDIB <> nil then
      CmBPalsList.ItemIndex := EdSlide.P()^.CMSDB.ColPalInd
    else
      CmBPalsList.ItemIndex := K_CMColorizePalIndex;


  end;
}

//!!! (2013-02-17) Pal Names are staticaly added to CmBPalsList.Items for translation
//CmBPalsList.Items.Clear;
//for i := 0 to High(K_CMColorizePalNames) do
//  CmBPalsList.Items.Add( K_CMColorizePalNames[i] );
  CmBPalsList.ItemIndex := K_CMColorizePalIndex;


  ChBDateTaken.Checked := ttsObjDateTaken in K_CMSThumbTextFlags;
  ChBTimeTaken.Checked := ttsObjTimeTaken in K_CMSThumbTextFlags;
  ChBTeethChart.Checked := ttsObjTeethChart in K_CMSThumbTextFlags;
  ChBMediaSource.Checked := ttsObjSource in K_CMSThumbTextFlags;

  if ChBEEPatSurname.Enabled then
    ChBEEPatSurname.Checked    := K_efnPatSurname in K_CMSlideEEFNameFlagsSet;
  if ChBEEPatFirstName.Enabled then
    ChBEEPatFirstName.Checked  := K_efnPatFirstName in K_CMSlideEEFNameFlagsSet;
  if ChBEEPatTitle.Enabled then
    ChBEEPatTitle.Checked      := K_efnPatTitle in K_CMSlideEEFNameFlagsSet;
  if ChBEEPatCardNum.Enabled then
    ChBEEPatCardNum.Checked    := K_efnPatCardNum in K_CMSlideEEFNameFlagsSet;
  if ChBEEObjDateTaken.Enabled then
    ChBEEObjDateTaken.Checked  := K_efnObjDTaken in K_CMSlideEEFNameFlagsSet;
  if ChBEEObjID.Enabled then
    ChBEEObjID.Checked         := K_efnObjID in K_CMSlideEEFNameFlagsSet;
  if ChBEEPatDOB.Enabled then
    ChBEEPatDOB.Checked        := K_efnPatDOB in K_CMSlideEEFNameFlagsSet;
  if ChBEEObjTeethChart.Enabled then
    ChBEEObjTeethChart.Checked := K_efnObjChart in K_CMSlideEEFNameFlagsSet;

  i := K_CMEDAccess.GFiltersProfiles.ALength();
  CMGFiltersUseFlag := K_CMGAModeFlag and (i = 6);
  if CMGFiltersUseFlag then
    with K_CMEDAccess.GFiltersProfiles do
    begin
      SetLength( CMUFilterProfiles, i );
      K_MoveSPLVector( CMUFilterProfiles[0], -1,
                       PDE(0)^, -1, i, R.ElemSType );
      j := i;
    end
  else
  begin
    for i := 0 to 5 do
      CmBFilters.Items.Delete(0);
    j := 0;
    i := 0;
  end;

  with K_CMEDAccess.UFiltersProfiles do
  begin
    i := i + ALength();
    SetLength( CMUFilterProfiles, i );
    K_MoveSPLVector( CMUFilterProfiles[j], -1,
                     PDE(0)^, -1, ALength(), R.ElemSType );
  end;
  CmBFilters.ItemIndex := 0;
  CmBFiltersChange(Sender);

  GBIU.Visible := (K_CMEDAccess is TK_CMEDDBAccess);
  if GBIU.Visible then
  begin
    CmBIUCMDLType.ItemIndex := K_CMIUCheckUpdatesCMDLType;

    if K_CMIURemindeInDays = 0 then
      RBIUInterval.ItemIndex := 0
    else
    if K_CMIURemindeInDays = 1 then
      RBIUInterval.ItemIndex := 1
    else
    if K_CMIURemindeInDays <= 7 then
      RBIUInterval.ItemIndex := 2
    else
    if K_CMIURemindeInDays <= 14 then
      RBIUInterval.ItemIndex := 3
    else
    if K_CMIURemindeInDays <= 31 then
      RBIUInterval.ItemIndex := 4
    else
    if K_CMIURemindeInDays > 31 then
      RBIUInterval.ItemIndex := 5;
  end;

  CTAUDRoot := TN_UDBase.Create;
  UDPat := K_CMEDAccess.ArchMLibRoot.DirChildByObjName( 'Text' );

  GBCTA.Visible := N_CMResForm.aVTBCustToolBar.Visible; // Temp settings while func creation
  for i := 1 to 4 do
  begin
    K_SaveTreeToMem( UDPat, N_SerialBuf );
    UDCTA := K_LoadTreeFromMem(N_SerialBuf);
    TN_POneTextBlock(TN_UDParaBox(UDCTA).PSP.CParaBox.CPBTextBlocks.P()).OTBMText := '';

    CTASectName := K_CMVobjCTAGetMemIniContext( i, UDCTA.Marker );
    CTAUseFlag := FALSE;
    if K_CMGAModeFlag and ((UDCTA.Marker and 1) = 1) then
    begin
      CTASectName := 'G' + CTASectName;
      CTAUseFlag := TRUE;
    end
    else
    if not K_CMGAModeFlag and ((UDCTA.Marker = 2) or (UDCTA.Marker = 4)) then
      CTAUseFlag := TRUE;

    if CTAUseFlag then
    begin // CTA context exists - use it
      K_CMVobjTextAttrsFromMemIni( CTASectName, UDCTA, 0 );
      // Get Shortcut and Caption
      UDCTA.ObjInfo   := N_MemIniToString( CTASectName, 'ShortCut', '' );
      UDCTA.ObjAliase := N_MemIniToString( CTASectName, 'Caption', '' );
    end;

    CTAUDRoot.InsOneChild( -1, UDCTA ); // Add 
  end; // for i := 1 to 4 do // CTAs loop

  if K_CMGAModeFlag then
    GBCTA.Caption := TrimRight(GBCTA.Caption) + ' (common annotations)  '
  else
    GBCTA.Caption := TrimRight(GBCTA.Caption) + ' (dentist annotations)  ';

  CmBCTA.ItemIndex := 0;
  CmBCTAChange(Sender);

//  ChBUseGlobalToolbarSettings.Visible := N_CMResForm.aVTBCustToolBar.Visible; // Temp settings while func creation
//  if ChBUseGlobalToolbarSettings.Visible then
//    ChBUseGlobalToolbarSettings.Checked := K_CMUseCustToolbarGlobal;
  CmBUseToolbarType.Visible := N_CMResForm.aVTBCustToolBar.Visible;
  if CmBUseToolbarType.Visible then
    CmBUseToolbarType.ItemIndex := K_CmCustToolbarStateToInd[K_CMUseCustToolbarInd];


//  BtEmailSettings.Visible  := K_CMDesignModeFlag;

  CmBIUMouseDelay.Items.CommaText := N_MemIniToString( 'CMS_UserMain', 'MouseDelayList', '0.2,0.4,0.6,0.8,1.0' );
  CmBIUMouseDelay.ItemIndex := 0;
  IUSLocID := IntToStr(K_CMEDAccess.CurLocID);
  SMouseState := N_MemIniToString( 'CMIUMouseState', IUSLocID, '' );

  if K_CMVUIMode and (SMouseState = '') then // Init  MouseMove settings for WEB mode
    SMouseState := '1|' + CmBIUMouseDelay.Items[0];

  if SMouseState <> '' then
  begin
    ChBIUMouseStop.Checked := SMouseState[1] = '1';
    SavedMouseDelay := StrToFloat( Copy( SMouseState, 3, Length(SMouseState) ) );
    PrevMouseDelay := 0;
    MouseDelayInd := 0;
    MouseDelay := 0;
    for i := 0 to CmBIUMouseDelay.Items.Count - 1 do
    begin
      MouseDelayInd := i;
      MouseDelay := StrToFloat( CmBIUMouseDelay.Items[i] );
      if SavedMouseDelay <= MouseDelay then break;
      PrevMouseDelay := MouseDelay;
    end;
    
    if (MouseDelay >= SavedMouseDelay) and
       (MouseDelayInd > 0) and
       ((SavedMouseDelay - PrevMouseDelay) < (MouseDelay - SavedMouseDelay)) then
      Dec(MouseDelayInd);

    CmBIUMouseDelay.ItemIndex := MouseDelayInd;

  end; // if SMouseState <> '' then
  
  IUSaveFlag := FALSE;
  ChBIUMouseStop.Enabled  := K_CMGAModeFlag;
  CmBIUMouseDelay.Enabled := K_CMGAModeFlag;
  LbIUDelayCapt.Enabled   := K_CMGAModeFlag;

end; // end of TK_FormPrefEdit.FormShow

//***************************************** TK_FormPrefEdit.FormCloseQuery ***
//
procedure TK_FormPrefEdit.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
var
  i : Integer;
  CTASectName, CTASectNamePref : string;
  UDCTA : TN_UDBase;
  SMouseState : string;

label LExit;

begin
  K_CMRebuildSlidesFilterMTypes();

  if ModalResult <> mrOK then begin
{ // Skip Change Current Active Slide Colorize
    if CurDIB <> nil then
      with N_CM_MainForm, CMMFActiveEdFrame do begin
        EdSlide.RebuildMapImageByDIB( CurDIB, nil, @EmbDIB1, @EmbDIB2 );
        RFrame.RedrawAllAndShow();
      end;
}
    goto LExit;
  end;

  // Set Tooth Numbering mode
  if RGToothNumbering.ItemIndex = 0 then
    K_CMToothNumSchemeFlag := K_CMTNumFDIScheme
  else
    K_CMToothNumSchemeFlag := K_CMTNumUSAScheme;
  N_BoolToMemIni( 'CMS_Main', 'FDIToothScheme', K_CMToothNumSchemeFlag );

  // Set Colorize Pallete
//  K_CMColorizePalIndex := LBPalsList.ItemIndex;
  K_CMColorizePalIndex := CmBPalsList.ItemIndex;
  N_IntToMemIni( 'CMS_Main', 'ColorPalIndex', K_CMColorizePalIndex );

  // Set Show Emboss Details mode
  N_BoolToMemIni( 'CMS_Main', 'UIShowEmbossDetails', ChBShowEmbossDetails.Checked );

  // Set Thumbnails Text Flags
  if ChBDateTaken.Checked then
    Include( K_CMSThumbTextFlags, ttsObjDateTaken )
  else
    Exclude( K_CMSThumbTextFlags, ttsObjDateTaken );

  if ChBTimeTaken.Checked then
    Include( K_CMSThumbTextFlags, ttsObjTimeTaken )
  else
    Exclude( K_CMSThumbTextFlags, ttsObjTimeTaken );

  if ChBTeethChart.Checked then
    Include( K_CMSThumbTextFlags, ttsObjTeethChart )
  else
    Exclude( K_CMSThumbTextFlags, ttsObjTeethChart );

  if ChBMediaSource.Checked then
    Include( K_CMSThumbTextFlags, ttsObjSource )
  else
    Exclude( K_CMSThumbTextFlags, ttsObjSource );

  // Set Names of Exported Objects Flags
  if ChBEEPatSurname.Checked then
    Include( K_CMSlideEEFNameFlagsSet, K_efnPatSurname )
  else
    Exclude( K_CMSlideEEFNameFlagsSet, K_efnPatSurname );

  if ChBEEPatFirstName.Checked then
    Include( K_CMSlideEEFNameFlagsSet, K_efnPatFirstName )
  else
    Exclude( K_CMSlideEEFNameFlagsSet, K_efnPatFirstName );

  if ChBEEPatTitle.Checked then
    Include( K_CMSlideEEFNameFlagsSet, K_efnPatTitle )
  else
    Exclude( K_CMSlideEEFNameFlagsSet, K_efnPatTitle );

  if ChBEEPatCardNum.Checked then
    Include( K_CMSlideEEFNameFlagsSet, K_efnPatCardNum )
  else
    Exclude( K_CMSlideEEFNameFlagsSet, K_efnPatCardNum );

  if ChBEEObjDateTaken.Checked then
    Include( K_CMSlideEEFNameFlagsSet, K_efnObjDTaken )
  else
    Exclude( K_CMSlideEEFNameFlagsSet, K_efnObjDTaken );

  if ChBEEObjID.Checked then
    Include( K_CMSlideEEFNameFlagsSet, K_efnObjID )
  else
    Exclude( K_CMSlideEEFNameFlagsSet, K_efnObjID );

  if ChBEEPatDOB.Checked then
    Include( K_CMSlideEEFNameFlagsSet, K_efnPatDOB )
  else
    Exclude( K_CMSlideEEFNameFlagsSet, K_efnPatDOB );

  if ChBEEObjTeethChart.Checked then
    Include( K_CMSlideEEFNameFlagsSet, K_efnObjChart )
  else
    Exclude( K_CMSlideEEFNameFlagsSet, K_efnObjChart );


  // Set User Filter
  for i := 0 to High(CMUFilterProfiles) do
    if CMUFilterProfiles[i].CMUFPShortCut = K_CML1Form.LLLShortcutNone.Caption then
        CMUFilterProfiles[i].CMUFPShortCut := '';

  i := 0;
  if CMGFiltersUseFlag then
  begin
    i := 6;
    with K_CMEDAccess.GFiltersProfiles do
      K_MoveSPLVector( PDE(0)^, -1,
                       CMUFilterProfiles[0], -1, ALength(), R.ElemSType );
  end;

  with K_CMEDAccess.UFiltersProfiles do
    K_MoveSPLVector( PDE(0)^, -1,
                     CMUFilterProfiles[i], -1, ALength(), R.ElemSType );


  // Set Image View Smooth Mode
  if ChBSmooth.Checked xor (K_CMStretchBltMode = HALFTONE) then
  begin
    if ChBSmooth.Checked then
      K_CMStretchBltMode := HALFTONE
    else
      K_CMStretchBltMode := COLORONCOLOR;
    N_UDDIBRectStretchBltMode := K_CMStretchBltMode;
    N_CM_MainForm.CMMFSetEdFramesStretchBltMode();
  end;

  // Set CheckUpdates Reminder
  K_CMIUCheckUpdatesCMDLType := CmBIUCMDLType.ItemIndex;
  case RBIUInterval.ItemIndex of
  0 : K_CMIURemindeInDays := 0;
  1 : K_CMIURemindeInDays := 1;
  2 : K_CMIURemindeInDays := 7;
  3 : K_CMIURemindeInDays := 14;
  4 : K_CMIURemindeInDays := 30;
  5 : K_CMIURemindeInDays := 90;
  end;

  // Set CTA
  CTASectNamePref := 'VObjCTA';
  if K_CMGAModeFlag then
    CTASectNamePref := 'GVObjCTA';
  for i := 0 to CTAUDRoot.DirHigh do
  begin
    CTASectName := CTASectNamePref + IntToStr( i + 1 );
    UDCTA := CTAUDRoot.DirChild(i);
    if TN_POneTextBlock(TN_UDParaBox(UDCTA).PSP.CParaBox.CPBTextBlocks.P()).OTBMText = '' then
      N_CurMemIni.EraseSection( CTASectName )
    else
    begin
//      N_StringToMemIni( CTASectName, 'ShortCut', UDCTA.ObjInfo );
//      N_StringToMemIni( CTASectName, 'Caption', UDCTA.ObjAliase );
      K_CMVobjCTAAttrsToMemIni( CTASectName, '', UDCTA, TRUE );
    end;
  end;
  CTAUDRoot.Free;

//  if ChBUseGlobalToolbarSettings.Visible then
//    K_CMUseCustToolbarGlobal := ChBUseGlobalToolbarSettings.Checked;
  if CmBUseToolbarType.Visible then
    K_CMUseCustToolbarInd := K_CmCustToolbarIndToState[CmBUseToolbarType.ItemIndex];

  if EMSettingsList <> nil then
  begin
    if EMChangeFlag then
    begin
      K_CMEmailSettingsSaveContext( EMSettingsList, EMUseCommonSettings );
      K_CMEDAccess.EDAHidePasswordForDump( EMSettingsList );
      if not K_CMGAModeFlag then
      begin
        EMSettingsList.Insert( 0, 'CMS_Email' );
        EMSettingsList.Add( 'CMS_Main.UseEMailLocalSettings=' + N_B2S(EMUseCommonSettings) );
      end
      else
        EMSettingsList.Insert( 0, 'GCMS_Email' );
//      N_Dump2Str( 'Changed Email Context:' );
//      N_Dump2Strings( EMSettingsList, 5 );
      N_Dump1Str( '     Changed Email Context:'#13#10 + EMSettingsList.Text );
    end;

    EMSettingsList.Free;
  end; // if EMSettingsList <> nil then

  if IUSaveFlag then
  begin
    if ChBIUMouseStop.Checked then
      SMouseState := '1|'
    else
      SMouseState := '0|';
    SMouseState := SMouseState + CmBIUMouseDelay.Items[CmBIUMouseDelay.ItemIndex];
    N_StringToMemIni( 'CMIUMouseState', IUSLocID, SMouseState );
    K_CMInitMouseMoveRedraw();
  end; // if IUSaveFlag then                |

//  K_CMEDAccess.DumpSavingContext := TRUE; // DEBUG
  K_CMEDAccess.EDASaveContextsData( [K_cmssSkipSlides,K_cmssSaveGlobal2Info] );// Save Contexts
//  K_CMEDAccess.DumpSavingContext := FALSE;

  N_CM_MainForm.CMMInitThumbFrameTexts();
  N_CM_MainForm.CMMFRebuildVisSlides(TRUE);  // is it really needed???

LExit: //************
// Rebuild View if nothing was changed because Common State was reload in FormShow

  // for future Apply new Location Bynary Context to Interface becaue GlobalFilters will be saved in location binary context
  N_CM_MainForm.CMMUpdateUIByFilterProfiles();

  // Apply Toolbar state to Interface
  if (ToolbarGlobalInitState <> K_CMUseCustToolbarInd) or
     ((ToolbarGlobalInitState > 0) and
      (ToolbarGlobalInitState < 3) and
      ToolbarGlobalWasChanged) then
  begin
    K_CMInitIniFileCustToolbarCont();
    N_CM_MainForm.CMMCurUpdateCustToolBar();
  end;

  N_CM_MainForm.CMMUpdateUIByCTA();

{ // Skip Change Current Active Slide Colorize
  EmbDIB1.Free;
  EmbDIB2.Free;
}
  Inherited;

end; // end of procedure TK_FormPrefEdit.FormCloseQuery

//***************************************** TK_FormPrefEdit.BtDelEnter ***
//
procedure TK_FormPrefEdit.BtDelEnter(Sender: TObject);
begin
  LEItem := nil; // Clear Editing Item for preventing Warning if editing Item with wrong caption is deleted
end; // end of procedure TK_FormPrefEdit.BtDelEnter

//***************************************** TK_FormPrefEdit.LVMTypesSelectItem ***
//
procedure TK_FormPrefEdit.LVMTypesSelectItem( Sender: TObject;
                                          Item: TListItem; Selected: Boolean);
var
  AllowEdit : Boolean;
begin
  if Selected then
  begin
    if AddingStartFlag then
    begin
      if LEItem <> Item then
        LEItem.Selected := TRUE;
      Exit;
    end;
    LEItem := Item;
    AllowEdit := (Integer(Item.Data) >= K_CMEDMTypeInitID) or
                 (Integer(Item.Data) =  K_CMNewMediaTypeID);
    EdMTypeCName.Enabled := AllowEdit;
    EdMTypeCName.Text  := LEItem.Caption;
//    RenamingStartFlag  := TRUE;
  end
  else
  begin
    if AddingStartFlag then Exit;
    EdMTypeCName.Text := '';
    EdMTypeCName.Enabled  := FALSE;
    LEItem := nil;
  end;
end; // end of procedure TK_FormPrefEdit.LVMTypesSelectItem

//***************************************** TK_FormPrefEdit.LVMTypesKeyDown ***
//
procedure TK_FormPrefEdit.LVMTypesKeyDown( Sender: TObject; var Key: Word;
                                           Shift: TShiftState );
var
  WItem: TListItem;

begin
  case Key of
    Ord('R') : if ssAlt in Shift then begin
      WItem := LVMTypes.Selected;
      if WItem = nil then Exit;
      StartMTypeEdit();
    end;
  end;
end; // end of procedure TK_FormPrefEdit.LVMTypesKeyDown

//***************************************** TK_FormPrefEdit.AddMTypeExecute ***
//  Add MediaType Action Execute
//
procedure TK_FormPrefEdit.AddMTypeExecute(Sender: TObject);
var
  WItem: TListItem;
begin
  LEItem := nil;
  AMTL := K_CMEDAccess.EDAGetAllMediaTypes0();
  if AMTL.Count = LVMTypes.Items.Count then begin
  // Use previous "Wrong" Item
    WItem := LVMTypes.Items[LVMTypes.Items.Count - 1];
    WItem.Caption := K_CML1Form.LLLNewMediaType.Caption; // K_CMNewMediaTypeCaption;
  end else begin
  // Add new Item
    LVMTypes.AddItem( K_CML1Form.LLLNewMediaType.Caption, // K_CMNewMediaTypeCaption,
                      TObject(K_CMNewMediaTypeID) );
    WItem := LVMTypes.Items[LVMTypes.Items.Count - 1];
  end;
  WItem.Selected := TRUE;

  StartMTypeEdit();
  AddingStartFlag   := TRUE;
//  RenamingStartFlag := FALSE;

end; // end of procedure TK_FormPrefEdit.AddMTypeExecute

//***************************************** TK_FormPrefEdit.DelMTypeExecute ***
//  Delete MediaType Action Execute
//
procedure TK_FormPrefEdit.DelMTypeExecute(Sender: TObject);
var
  SItem: TListItem;
  WItem: TListItem;
  DelMTResult : TK_CMEDResult;
  PatID : Integer;
  PatInfo : string;
  ML : TStrings;

begin
  SItem := LVMTypes.Selected;
  WItem := SItem;
  if WItem = nil then Exit;
  if Integer(WItem.Data) < K_CMEDMTypeInitID then Exit;
  LEItem := nil;
  if Integer(WItem.Data) <> K_CMNewMediaTypeID then
  begin
  // Try to delete Real MediaType
//    if mrYes <> K_CMShowMessageDlg( 'Are you sure you want to delete this ''' + WItem.Caption +
//                        '''?', mtConfirmation ) then Exit;
    if mrYes <> K_CMShowMessageDlg( format( K_CML1Form.LLLPrefEdit1.Caption,
//         'Are you sure you want to delete this ''%s'' Media Category?',
//         'Are you sure you want to delete this'#13#10 + '''Media Category''?',
                [WItem.Caption] ),mtConfirmation ) then Exit;

    DelMTResult := K_CMEDAccess.EDADeleteMediaTypeByID( Integer(WItem.Data), PatID );

    if DelMTResult = K_edUsedMediaType then
    begin
      ML := K_CMEDAccess.EDAGetPatientMacroInfo( PatID );
      if (ML.Count < 2) and (PatID > 0) then
      begin // Patient Info Is Absent
        K_CMEDAccess.EDASAGetPatientsInfo( FALSE );
        ML := K_CMEDAccess.EDAGetPatientMacroInfo( PatID );
      end;

//      PatInfo := K_StringMListReplace( K_CMENPTDelMTypePatientDetails, ML, K_ummRemoveMacro );
      PatInfo := K_StringMListReplace( K_CML1Form.LLLMPatPrintPatDetails1.Caption, ML, K_ummRemoveMacro );
      K_CMShowMessageDlg( format( K_CML1Form.LLLPrefEdit3.Caption,
//                          'You can''t delete this ''%s'' Media Category because it is'#13#10 +
//                          'used in patient''s %s Media Objects',
                          [WItem.Caption, PatInfo] ), mtWarning );
      Exit;
    end
    else
    if DelMTResult <> K_edOK then
    begin
      K_CMShowMessageDlg(  // sysout
                           'Database Error detected >> '#13#10 +
                           '"' + K_CMEDAccess.ExtDataErrorString  + '".', mtWarning );
      Exit;
    end;
    if K_CMCurSlideFilterAttrs.FAMediaType = Integer(WItem.Data) then
    // MedaType Selected for slide filtering is deleted correct filter
      K_CMCurSlideFilterAttrs.FAMediaType := K_CMFilterAllMTypesVal;
  end;
  LVMTypes.DeleteSelected();
end; // end of procedure TK_FormPrefEdit.DelMTypeExecute

//***************************************** TK_FormPrefEdit.CmBPalsListDrawItem ***
//  On Colorize Palettes List (CmBPalsList) Item Draw Handler
//
procedure TK_FormPrefEdit.CmBPalsListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LRect: TRect;
  Str : string;
  TextSize : TSize;
  CY, LW : Float;
  i : Integer;
begin
  with CmBPalsList, Items do begin
    LRect := Rect;
    CY := (LRect.Top + LRect.Bottom) / 2;
    Str := Items[Index];
    TextSize := Canvas.TextExtent(Str);

    LRect.Left  := LRect.Left + 5;
    LRect.Right := LRect.Left + ColorGradientCount + 5;
    LW := 8;
    LRect.Top    := Floor(CY - LW / 2);
    LRect.Bottom :=  Ceil(CY + LW / 2);

    N_HDCRectDraw( Canvas.Handle, Rect, $FFFFFF );
    Canvas.TextRect( Rect, LRect.Right + 5, Round(CY - TextSize.cy / 2), Str );
    K_CMColorizeBuildColors( @GradientColors[0], ColorGradientCount, Index );
    for i := 0 to ColorGradientCount - 1  do begin
      LRect.Right := LRect.Left + 1;
      N_HDCRectDraw( Canvas.Handle, LRect, GradientColors[i] );
      Inc(LRect.Left);
    end;
  end;
end; // procedure TK_FormPrefEdit.CmBPalsListDrawItem

//***************************************** TK_FormPrefEdit.LBPalsListDrawItem ***
//  On Colorize Palettes List (CmBPalsList) Item Change Handler
//
procedure TK_FormPrefEdit.CmBPalsListChange(Sender: TObject);
begin
{ // Skip Change Current Active Slide Colorize
  if CurDIB = nil then Exit;
  with N_CM_MainForm, CMMFActiveEdFrame do begin
    EdSlide.GetImgViewConvData( @WVCAttrs, [vcifFlipRotate,vcifBriCoGam,vcifIsodensity] );
    WVCAttrs.VCColPalInd := CmBPalsList.ItemIndex;
    EdSlide.RebuildMapImageByDIB( CurDIB, @WVCAttrs, @EmbDIB1, @EmbDIB2 );
    RFrame.RedrawAllAndShow();
  end;
}
end; // procedure TK_FormPrefEdit.CmBPalsListChange

//***************************************** TK_FormPrefEdit.ChBShowEmbossDetailsClick ***
//  On Show Emboss Details Flag Change Handler
//
procedure TK_FormPrefEdit.ChBShowEmbossDetailsClick(Sender: TObject);
begin
  N_CMResForm.aToolsEmbossAttrs.Visible := ChBShowEmbossDetails.Checked;
end; // procedure TK_FormPrefEdit.ChBShowEmbossDetailsClick

//***************************************** TK_FormPrefEdit.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormPrefEdit.CurStateToMemIni;
begin
  inherited;
  N_IntToMemIni( 'CMS_Forms', 'PrefEdit_PageInd', PageControl.ActivePageIndex );
  N_BoolToMemIni( 'CMS_Main', 'UIShowEmbossDetails', ChBShowEmbossDetails.Checked );
end; // procedure TK_FormPrefEdit.CurStateToMemIni;

//***************************************** TK_FormPrefEdit.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormPrefEdit.MemIniToCurState;
begin
  inherited;
  PageControl.ActivePageIndex := N_MemIniToInt( 'CMS_Forms', 'PrefEdit_PageInd', 0 );
  ChBShowEmbossDetails.Checked := N_MemIniToBool( 'CMS_Main', 'UIShowEmbossDetails', false );
end; // procedure TK_FormPrefEdit.MemIniToCurState

//***************************************** TK_FormPrefEdit.EdMTypeCNameExit ***
// Exit MediaType Caption Edit Control
//
// Check MediaType Caption for duplication
//
procedure TK_FormPrefEdit.EdMTypeCNameExit(Sender: TObject);
var
  NewMTTitle : string;
  AMTypID : Integer;
  WStr : string;
  AddMTResult : TK_CMEDResult;
  AddMTypeFlag : Boolean;
  ExitFlag : Boolean;

  procedure ReturnPreviousState();
  begin
    if not AddMTypeFlag then begin
      SkipMTypeFinEdit := TRUE; // to skip EdMTypeCNameExit event envoked by next statement
      LEItem.Selected := FALSE;
    end else
      LVMTypes.DeleteSelected();
    EdMTypeCName.Text := '';
    LEItem := nil;
    AddingStartFlag   := FALSE;
//    RenamingStartFlag := FALSE;
  end;

begin
  ExitFlag := SkipMTypeFinEdit;
  SkipMTypeFinEdit := FALSE;
  if ExitFlag or (LEItem = nil) then Exit;
// Check New Value

  NewMTTitle := EdMTypeCName.Text;
  if NewMTTitle = '' then
    NewMTTitle := K_CML1Form.LLLNewMediaType.Caption; // K_CMNewMediaTypeCaption;

  AddMTypeFlag := Integer(LEItem.Data) = K_CMNewMediaTypeID;

  AMTypID := Integer(LEItem.Data);

//  if RenamingStartFlag and (LEItem.Caption = NewMTTitle) then begin
  if not AddingStartFlag and (LEItem.Caption = NewMTTitle) then begin
    AddMTResult := K_edOK
  end
  else
  begin
  // Check if exists in DB
    AMTL := K_CMEDAccess.EDAGetAllMediaTypes0();
//    AMTypID := Integer(LEItem.Data);
    AddMTResult := K_edExistedMediaType;
    if AMTL.IndexOf( NewMTTitle ) < 0 then begin
    // if Item Title is absent in Local MediaTypes List then try to ADD or RENAME
      if AddMTypeFlag then
        AddMTResult := K_CMEDAccess.EDAddNewMediaType( AMTypID, NewMTTitle )
      else
        AddMTResult := K_CMEDAccess.EDARenameMediaType( Integer(LEItem.Data), NewMTTitle );
     end;
  end;

  case AddMTResult of
  K_edOK               : begin
    LEItem.Caption := NewMTTitle; // Set Item Caption if Handler is called by FinEdit Timer
    LEItem.Data := Pointer(AMTypID);
//    RenamingStartFlag := FALSE;
    AddingStartFlag   := FALSE;
    SkipMTypeFinEdit := TRUE; // to skip EdMTypeCNameExit event envoked by next statement
    LEItem.Selected := FALSE;
    LEItem := nil;
  end;
  K_edExistedMediaType : begin
    if mrCancel <> K_CMShowMessageDlg( format( K_CML1Form.LLLPrefEdit2.Caption,
//                                       'The Media Category ''%s'' already exists.'#13#10+
//                                       '       Please enter another name.',
                                       [NewMTTitle] ), mtWarning, [mbOK,mbCancel] ) then
    begin
      StartMTypeEdit();
//      SkipMTypeFinEdit  := FALSE;
      Exit;
    end
    else
      ReturnpreviousState();
  end;
  else
  //**** External Data Base Error
    if not AddMTypeFlag then
      WStr := 'previous value will be returned'
    else
      WStr := 'New media category will be deleted';

    SkipMTypeFinEdit := TRUE;
    K_CMShowMessageDlg( //sysout
                         'Database Error detected >> '#13#10 +
                         '"' + K_CMEDAccess.ExtDataErrorString  + '".'#13#10 +
                         WStr, mtWarning );
    ReturnPreviousState();
  end;
//  LEItem.Caption := EdMTypeCName.Text;

// Finish Editing
  SkipMTypeFinEdit  := FALSE;
  EdMTypeCName.Enabled  := FALSE;

end; // end of procedure TK_FormPrefEdit.EdMTypeCNameExit

//***************************************** TK_FormPrefEdit.EdMTypeCNameKeyDown ***
// MediaType Item Caption Edit Control KeyDown Handler
//
procedure TK_FormPrefEdit.EdMTypeCNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    EdMTypeCNameExit(Sender)
  else if Key = VK_ESCAPE then
    EdMTypeCName.Text := LEItem.Caption;
end; // end of procedure TK_FormPrefEdit.EdMTypeCNameKeyDown

//***************************************** TK_FormPrefEdit.StartMTypeEdit ***
// Start MediaType Item Caption Editing
//
procedure TK_FormPrefEdit.StartMTypeEdit();
begin
  if LEItem = nil then Exit;
  EdMTypeCName.Enabled  := TRUE;
  EdMTypeCName.SetFocus();
  EdMTypeCName.SelStart := 0;
  EdMTypeCName.SelLength := Length(LEItem.Caption);
end; // end of procedure TK_FormPrefEdit.StartMTypeEdit

//***********************************  TK_FormPrefEdit.CmBShortCutsChange ***
//
procedure TK_FormPrefEdit.CmBShortCutsChange(Sender: TObject);
var
  PrevShortCut : string;
  Ind : Integer;
begin
  with CMUFilterProfiles[CmBFilters.ItemIndex] do
  begin
    PrevShortCut := CMUFPShortCut;
    CMUFPShortCut := CmBShortcuts.Text;
    Ind := K_CMUnUsedShortCuts.IndexOf( CMUFPShortCut );
    if Ind > 0 then
      K_CMUnUsedShortCuts.Delete( Ind );
    Ind := K_CMUnUsedShortCuts.IndexOf( PrevShortCut );
    if Ind < 0 then
      K_CMUnUsedShortCuts.Insert( 1, PrevShortCut );
  end;
end; // TK_FormPrefEdit.CmBShortCutsChange

//***********************************  TK_FormPrefEdit.CmBFiltersChange ***
//
procedure TK_FormPrefEdit.CmBFiltersChange(Sender: TObject);
var
  Ind : Integer;
begin
  with CMUFilterProfiles[CmBFilters.ItemIndex] do
  begin
    with CmBShortcuts do
    begin
      Items.Assign( K_CMUnUsedShortCuts );
        if CMUFPShortCut = '' then
          CMUFPShortCut := K_CML1Form.LLLShortcutNone.Caption; // 'None';
        Ind := Items.IndexOf( CMUFPShortCut );
        if (CMUFPShortCut <> '') and (Ind < 0) then
          Items.Insert( 0, CMUFPShortCut );
        ItemIndex := Items.IndexOf( CMUFPShortCut );
    end;
    EdFUDCaption.Text := CMUFPCaption;
    ShowFilterState();
  end;

end; // TK_FormPrefEdit.CmBFiltersChange

//***********************************  TK_FormPrefEdit.BtFilterSetupClick ***
//
procedure TK_FormPrefEdit.BtFilterSetupClick(Sender: TObject);
var
  PrevLeft, PrevTop : Integer;
  PIniAttrs : TK_PCMAutoImgProcAttrs;
  StatEventCode : Integer;
begin
  with CmBFilters, N_CM_MainForm do
  begin
    ///////////////////////////////////////////////////////////
    // Move Self out of screen to open Viewports for filter setup
    PrevLeft := Self.Left;
    PrevTop  := Self.Top;
    Self.Left := N_WholeWAR.Right + 100;  //
    Self.Top  := N_WholeWAR.Bottom + 100; //
//    Self.Left := CMMCurFMainForm.Left + CMMCurFMainForm.Width;
//    Self.Top  := CMMCurFMainForm.Top  + CMMCurFMainForm.Height;

    PIniAttrs := nil;
    if CMGFiltersUseFlag and (ItemIndex < 6) then
      PIniAttrs := TK_PCMAutoImgProcAttrs(K_CMEDAccess.GFiltersImgProcAttrs.PDE(ItemIndex));

    if (ItemIndex < 6) and (Items.Count > 6) then
      StatEventCode := Ord(K_shNCA1GAFilterChange)  // Global Filter Change
    else
      StatEventCode := Ord(K_shNCA1UAFilterChange); // User Filter Change

    if K_CMImgFilterProcAttrsDlg( @CMUFilterProfiles[ItemIndex].CMUFPAutoImgProcAttrs,
                                  Text + ' ' + K_CML1Form.LLLPrefEdit4.Caption, PIniAttrs ) then
//                                  Text + ' Setup', PIniAttrs ) then
    begin
      with K_CMEDAccess do
        EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                           Ord(K_shNCAOther1),
                                           StatEventCode,
//                                           Ord(K_shNCA1UAFilterChange),
                                           ItemIndex ) );
    end;

    ////////////////////////
    // Restore Self position
    Self.Left := PrevLeft;
    Self.Top  := PrevTop;
    ShowFilterState();
  end;
end; // TK_FormPrefEdit.BtFilterSetupClick

//************************************** TK_FormPrefEdit.EdFUDCaptionChange ***
//
procedure TK_FormPrefEdit.EdFUDCaptionChange(Sender: TObject);
begin
  with CMUFilterProfiles[CmBFilters.ItemIndex] do
    CMUFPCaption := EdFUDCaption.Text;
end; // procedure TK_FormPrefEdit.EdFUDCaptionChange

//*********************************************  TK_FormPrefEdit.FormCreate ***
//
procedure TK_FormPrefEdit.FormCreate(Sender: TObject);
//var
//  i : Integer;
begin
  inherited;
  K_SetStringsByNames( CmBPalsList.Items, K_CMSColorizePalettes );
{
  if Length(K_CMColorizePalNames) = 0 then
    K_CMColorizeInitData();
  CmBPalsList.Items.Clear;
  for i := 0 to High(K_CMColorizePalNames) do
    CmBPalsList.Items.Add( K_CMColorizePalNames[i] );
}
end; // TK_FormPrefEdit.FormCreate

//***************************************** TK_FormPrefEdit.ShowFilterState ***
//
procedure TK_FormPrefEdit.ShowFilterState;
var
  FilterStateFlag : Boolean;
begin
  with CMUFilterProfiles[CmBFilters.ItemIndex] do
  begin
    FilterStateFlag := '' <> K_CMGetUIHintByAutoImgProcAttrs( @CMUFPAutoImgProcAttrs );
    LbFHotKey.Enabled := FilterStateFlag;
    CmBShortcuts.Enabled := FilterStateFlag;
    LbFUDCaption.Enabled := FilterStateFlag;
    EdFUDCaption.Enabled := FilterStateFlag;
  end;

end; // procedure TK_FormPrefEdit.ShowFilterState

procedure TK_FormPrefEdit.BtCTASetupClick(Sender: TObject);
var
  UDCTA : TN_UDBase;
  NoSetCTA, EmptyTextFlag : Boolean;
  CTASectName : string;

begin
  UDCTA := CTAUDRoot.DirChild(CmBCTA.ItemIndex);
  NoSetCTA := TN_POneTextBlock(TN_UDParaBox(UDCTA).PSP.CParaBox.CPBTextBlocks.P()).OTBMText = '';
  if NoSetCTA then
  begin // Init CTA Values
    CTASectName := 'VObjCTA' + IntToStr(CmBCTA.ItemIndex + 1);
    if (K_CMGAModeFlag and (UDCTA.Marker = 4)) or (not K_CMGAModeFlag and (UDCTA.Marker = 1)) then
    // Use Existing Global CTA to init
      K_CMVobjTextAttrsFromMemIni( 'G' + CTASectName, UDCTA, 0 )
    else
    if (K_CMGAModeFlag and (UDCTA.Marker = 2)) or (not K_CMGAModeFlag and (UDCTA.Marker = 3)) then
    // Use Existing Local CTA info to init
      K_CMVobjTextAttrsFromMemIni( CTASectName, UDCTA, 0 )
    else
    // Use Ordinary Text Annotation Context
      K_CMVobjCTAAttrsFromCTA( K_CMEDAccess.ArchMLibRoot.DirChildByObjName( 'Text' ), UDCTA );
  end;

  // Edit CTA Values
  if not K_CMSlideTextAttrsDlg( nil, EmptyTextFlag, TRUE, UDCTA) then
  begin // Cancel changes
    if NoSetCTA then // Clear Start Value
      TN_POneTextBlock(TN_UDParaBox(UDCTA).PSP.CParaBox.CPBTextBlocks.P()).OTBMText := '';
    Exit;
  end;

  ShowCTAState();
end; // procedure TK_FormPrefEdit.BtCTASetupClick

procedure TK_FormPrefEdit.EdCTACaptionChange(Sender: TObject);
var
  UDCTA : TN_UDBase;
begin
  UDCTA := CTAUDRoot.DirChild(CmBCTA.ItemIndex);
  UDCTA.ObjAliase := EdCTACaption.Text;
end; // procedure TK_FormPrefEdit.EdCTACaptionChange

procedure TK_FormPrefEdit.CmBShortCuts1Change(Sender: TObject);
var
  UDCTA : TN_UDBase;
  PrevShortCut : string;
  Ind : Integer;
begin
  UDCTA := CTAUDRoot.DirChild(CmBCTA.ItemIndex);
  PrevShortCut := UDCTA.ObjInfo;
  UDCTA.ObjInfo := CmBShortcuts1.Text;
  Ind := K_CMUnUsedShortCuts.IndexOf( UDCTA.ObjInfo );
  if Ind > 0 then
    K_CMUnUsedShortCuts.Delete( Ind );
  Ind := K_CMUnUsedShortCuts.IndexOf( PrevShortCut );
  if Ind < 0 then
    K_CMUnUsedShortCuts.Insert( 1, PrevShortCut );
end; // procedure TK_FormPrefEdit.CmBShortCuts1Change

procedure TK_FormPrefEdit.CmBCTAChange(Sender: TObject);
var
  Ind : Integer;
  UDCTA : TN_UDBase;
begin
  UDCTA := CTAUDRoot.DirChild(CmBCTA.ItemIndex);
  with CmBShortcuts1 do
  begin
    Items.Assign( K_CMUnUsedShortCuts );
    if UDCTA.ObjInfo = '' then
      UDCTA.ObjInfo := K_CML1Form.LLLShortcutNone.Caption; // 'None';
    Ind := Items.IndexOf( UDCTA.ObjInfo );
    if (UDCTA.ObjInfo <> '') and (Ind < 0) then
      Items.Insert( 0, UDCTA.ObjInfo );
    ItemIndex := Items.IndexOf( UDCTA.ObjInfo );
  end;
  EdCTACaption.Text := UDCTA.ObjAliase;
  ShowCTAState();
end; // procedure TK_FormPrefEdit.CmBCTAChange

//******************************************** TK_FormPrefEdit.ShowCTAState ***
//
procedure TK_FormPrefEdit.ShowCTAState;
var
  CTAStateFlag : Boolean;
  UDCTA : TN_UDBase;
begin
  UDCTA := CTAUDRoot.DirChild(CmBCTA.ItemIndex);
  with TN_POneTextBlock(TN_UDParaBox(UDCTA).PSP.CParaBox.CPBTextBlocks.P())^ do
  begin
    CTAStateFlag := OTBMText <> '';
    LbCTAHotKey.Enabled := CTAStateFlag;
    CmBShortcuts1.Enabled := CTAStateFlag;
    LbCTACaption.Enabled := CTAStateFlag;
    EdCTACaption.Enabled := CTAStateFlag;
  end;
end; // procedure TK_FormPrefEdit.ShowCTAState

procedure TK_FormPrefEdit.BtEmailSettingsClick(Sender: TObject);
begin
  if EMSettingsList = nil then
    K_CMEmailSettingsCreateEditContext( EMSettingsList, EMUseCommonSettings );
  EMChangeFlag := K_CMEmailSettingsDlg1( EMSettingsList, EMUseCommonSettings ) or EMChangeFlag;
end; // procedure TK_FormPrefEdit.BtEmailSettingsClick

procedure TK_FormPrefEdit.ChBIUMouseStopClick(Sender: TObject);
begin
  IUSaveFlag := TRUE;
end; // procedure TK_FormPrefEdit.ChBIUMouseStopClick

end.
