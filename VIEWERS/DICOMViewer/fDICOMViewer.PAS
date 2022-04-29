unit fDICOMViewer;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls,
  Menus, StdCtrls, Dialogs, Buttons, Messages, ExtCtrls,
  ComCtrls, Registry, ToolWin, ExtDlgs, Spin, dicom, JPEG, define_types,
  K_CMDCMGLibW, FileCtrl, IOUtils, Types, N_BaseF, System.Generics.Collections,
  fSeriesGraphicViewer, Vcl.Grids, Vcl.ValEdit, Vcl.CustomizeDlg, Vcl.DBActns,
  System.Actions, Vcl.ActnList, Vcl.RibbonSilverStyleActnCtrls, Vcl.ActnMan,
  Vcl.ActnCtrls, Vcl.ImgList;

type
  TPageControlHack = class(TPageControl);
  TCategoryPanelHack = class(TCategoryPanel);
  TToolButtonHack = class(TToolButton);
  TButtonHack = class(TButton);

  TDICOMViewer = class;

  TSeriesViewerChangeEvent = procedure(AOldSeries, ANewSeries: TSeriesGraphicViewer);

  TStudy = class(TComponent)
  private
    type
      TStudyLoadMode = (slmFile, slmFolder, slmNotSupported);
  strict private
    FUID: string;
    FInitialDir: string;

    FViewerForm: TDICOMViewer;
    FSeries: TObjectDictionary<string, TSeriesGraphicViewer>;

    FAutoLoad: Boolean;
    FSeriesChangeEvent: TSeriesViewerChangeEvent;
  private
    procedure DoSeriesViewerChange(APrevSeries, ANewSeries: TSeriesGraphicViewer);

    function GetActiveSerie: TSeriesGraphicViewer;
    procedure SetActiveSerie(const AValue: TSeriesGraphicViewer);

    function GetActiveSerieUID: string;
    procedure SetActiveSerieUID(const AValue: string);

    function GetActiveSerieIndex: integer;
    procedure SetActiveSerieIndex(AValue: integer);
  public
    function Load(const APath: string): Boolean;
    procedure Reset;

    function GetSeries(AIndex: Integer): TSeriesGraphicViewer; overload;
    function GetSeries(const ASeriesUID: string): TSeriesGraphicViewer; overload;
  public
    constructor Create(AViewerForm: TDICOMViewer); reintroduce;
    destructor Destroy; override;

    procedure PrepareStudyUI;
    procedure LoadInfo;

    property UID: string read FUID;
    property InitialDir: string read FInitialDir;

    property Series: TObjectDictionary<string, TSeriesGraphicViewer> read FSeries;
    property ViewerForm: TDICOMViewer read FViewerForm;

    property ActiveSeries: TSeriesGraphicViewer read GetActiveSerie write SetActiveSerie;
    property ActiveSeriesUID: string read GetActiveSerieUID write SetActiveSerieUID;
    property ActiveSeriesIndex: integer read GetActiveSerieIndex write SetActiveSerieIndex;

    function ActiveViewer: TSeriesGraphicViewer;

    property AutoLoad: Boolean read FAutoLoad write FAutoLoad;
    property OnSeriesViewerChange: TSeriesViewerChangeEvent read FSeriesChangeEvent write FSeriesChangeEvent;
  end;

  TDICOMViewer = class(TN_BaseForm)
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    FileOpenItem: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowMenu: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    HelpMenu: TMenuItem;
    PGOpenDialog: TOpenDialog;
    Opengraphic1: TMenuItem;
    dlgOpenx: TOpenDialog;
    OpenAnz: TMenuItem;
    OpenECAT: TMenuItem;
    PGSaveDialog: TSaveDialog;
    StatusBar: TStatusBar;
    Print1: TMenuItem;
    Exportaspicture1: TMenuItem;
    Close1: TMenuItem;
    MaximizeAll1: TMenuItem;
    OpenRaw1: TMenuItem;
    ConverttoDICOM1: TMenuItem;
    Convertto1: TMenuItem;
    ConvertMenu: TMenuItem;
    Convertraw1: TMenuItem;
    Convert2Ana: TMenuItem;
    Hints1: TMenuItem;
    pnlDetails: TCategoryPanelGroup;
    grpStudyDetails: TCategoryPanel;
    grpSeriesDetails: TCategoryPanel;
    miOpenFolder: TMenuItem;
    splMain: TSplitter;
    cbbSeriesList: TComboBox;
    pgcSeriesDetails: TPageControl;
    tsSeriesThumbNail: TTabSheet;
    tsSeriesInfo: TTabSheet;
    pnlPreviewOverlay: TPanel;
    pnlDetailsOverlay: TPanel;
    grpPatientDetails: TCategoryPanel;
    imgSeriesPreview: TImage;
    hintMain: TBalloonHint;
    PopupMenu1: TPopupMenu;
    pnlSerieViewerHolder: TPanel;
    OpenDialog: TOpenDialog;
    ilDicomViewer: TImageList;
    tlbDICOMImgTools: TToolBar;
    btnDICOMHeader: TToolButton;
    btn5: TToolButton;
    btnBestFit: TToolButton;
    btnZoom100: TToolButton;
    trackZoomSlider: TTrackBar;
    trackSliceSlider: TTrackBar;
    udSliceControl: TUpDown;
    btnVideo: TToolButton;
    btnAutoBal: TToolButton;
    btnContrast: TToolButton;
    btn7: TToolButton;
    btnApplyBright: TToolButton;
    btn14: TToolButton;
    seWinWidEdit: TSpinEdit;
    btn12: TToolButton;
    btnApplyCon: TToolButton;
    btn13: TToolButton;
    seWinCenEdit: TSpinEdit;
    pnl1: TPanel;
    cbb1: TComboBox;
    btn4: TButton;
    btn6: TToolButton;
    btnKeepPresets: TToolButton;
    pnl2: TPanel;
    cbbSchemeDrop: TComboBox;
    btn1: TButton;
    btn10: TButton;
    btn11: TButton;
    lstStudyDetails: TValueListEditor;
    lstSeriesNavigator: TValueListEditor;
    lstPatientInfo: TValueListEditor;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure ContrastPreset(lPreset: integer);
    function AddMRU(lFilename: string): boolean;
    procedure FormCreate(Sender: TObject);
    procedure WindowCascadeItemClick(Sender: TObject);
    procedure WindowTileItemClick(Sender: TObject);
    procedure WindowArrangeItemClick(Sender: TObject);
    procedure AppLaunch;
    procedure FileExitItemClick(Sender: TObject);
    procedure WindowMinimizeItemClick(Sender: TObject);
    procedure Opengraphic1Click(Sender: TObject);
    procedure trackSliceSlider1Change(Sender: TObject);
    procedure ColUpdate;
   //rocedure cbbSchemeDropChange(Sender: TObject);
    procedure btnApplyConClick(Sender: TObject);
    procedure LoadDropFile(var lFilename: string);
    procedure PrintImg;
    procedure ConLabelClick;
    procedure FormResize(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Exportaspicture1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure GetRegistryData;
    procedure PutRegistryData;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure trackZoomSlider1Change(Sender: TObject);
    procedure btnZoom100Click(Sender: TObject);
    procedure btnDICOMHeaderClick(Sender: TObject);
    procedure btnBestFitClick(Sender: TObject);
    procedure MaximizeAll1Click(Sender: TObject);
    procedure HintBtnClick(Sender: TObject);
    procedure btnHdrBtnClick(Sender: TObject);
    procedure Convertto1Click(Sender: TObject);
    procedure seWinCenEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure VideoBtnClick(Sender: TObject);
    procedure btnVideoBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure grpStudyDetailsDblClick(Sender: TObject);
    procedure btnScanFolderClick(Sender: TObject);
    procedure btnSelectFileClick(Sender: TObject);
    procedure pgcSeriesDetailsDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure cbbSeriesListEnter(Sender: TObject);
    procedure cbbSeriesListCloseUp(Sender: TObject);
    procedure grpSeriesDetailsCollapse(Sender: TObject);
    procedure cbbSeriesListSelect(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure act1Execute(Sender: TObject);
    procedure udSliceControlChangingEx(Sender: TObject; var AllowChange: Boolean;
      NewValue: Integer; Direction: TUpDownDirection);
    procedure udSliceControlClick(Sender: TObject; Button: TUDBtnType);
    procedure ZoomSliderChange(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn10Click(Sender: TObject);
    procedure btn11Click(Sender: TObject);
    procedure lstStudyDetailsStringsChanging(Sender: TObject);
    procedure lstSeriesNavigatorGetEditText(Sender: TObject; ACol,
      ARow: Integer; var Value: string);
    procedure lstSeriesNavigatorSetEditText(Sender: TObject; ACol,
      ARow: Integer; const Value: string);
    procedure ToolButton1Click(Sender: TObject);
//    procedure btnApplyCon1Click(Sender: TObject);
  private
    { Private declarations }
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    function CreateMDIChild(Name: string; lAnz, lECAT, l2dImage, lRaw: boolean; ADICOMData: TDICOMData = nil): TSeriesGraphicViewer;
    procedure MRUClick(Sender: TObject);
    procedure UpdateMRUMenu; { Public declarations }
    function ConvertImg(lInName: string; lDICOMdata: TDICOMdata; l3ForInterfile4ForAna: integer): boolean;
  strict private
    FStudy: TStudy;
  public
    property Study: TStudy read FStudy;
  end;

const
  FileNotFound = 'File not found';
  DirNotFound = 'Directory does not exist';

var
  DICOMViewer: TDICOMViewer;

implementation

uses ShellAPI, N_Types,
     fProgress;

const
  kMaxMRU = 8;
  // gFastCheck: boolean = true;

  knMenup1 = 11;
  gKeyRoot: string = '\Software\ezDICOM';

var
  gMRUra: array [1 .. kMaxMRU] of string = (
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
  );
{$R *.DFM}

procedure TDICOMViewer.ContrastPreset(lPreset: integer);
var
  lWid, lCen: integer;
begin
  if Self.MDIChildCount = 0 then
    exit;
  case lPreset of
    0:
      begin
        lCen := 400;
        lWid := 2000;
      end; // bone
    1:
      begin
        lCen := 50;
        lWid := 350;
      end; // chest
    2:
      begin
        lCen := -600;
        lWid := 1500;
      end; // lung
  end;
  if Study.ActiveSeries.gBuff16sz > 0 then
    Study.ActiveSeries.Scale16to8bit(lCen, lWid)
  else
  begin
    Study.ActiveSeries.gFastCen := lCen;
    Study.ActiveSeries.UpdatePalette(true, lWid);
  end;
  // Study.ActiveSeries.RefreshZoom;
  ConLabelClick;
  // Study.ActiveSeries.RefreshZoom;
end;

procedure TDICOMViewer.MRUClick(Sender: TObject);
var
  lFilename: string;
begin;
  lFilename := gMRUra[(Sender as TMenuItem).tag];
  if AddMRU(lFilename) then
    LoadDropFile(lFilename)
  else
    showmessage('Unable to find the file ' + lFilename);
end;

procedure TDICOMViewer.UpdateMRUMenu;
var
  lF, lN: integer;
  NewItem: TMenuItem;
begin
  {lF := FileMenu.Count;
  if lF > (knMenup1 - 1) then
    for lN := lF downto knMenup1 do
      FileMenu.Delete(lN - 1);
  lF := 0;
  repeat
    inc(lF);
  until (lF = kMaxMRU) or (gMRUra[lF] = '');
  if gMRUra[lF] = '' then
    lF := lF - 1;
  if lF = 0 then
    exit;
  NewItem := TMenuItem.Create(Self);
  NewItem.Caption := '-';
  FileMenu.Add(NewItem);
  for lN := 1 to lF do
  begin
    NewItem := TMenuItem.Create(Self);
    NewItem.Caption := gMRUra[lN];
    NewItem.tag := lN;
    NewItem.Onclick := MRUClick;
    FileMenu.Add(NewItem);
  end;       }
end;

procedure TDICOMViewer.WMDropFiles(var Msg: TWMDropFiles);
var
  lInc: integer;
  lFilename: string;
  CFileName: array [0 .. MAX_PATH] of Char;
begin
  try
    lInc := 0;
    while DragQueryFile(Msg.Drop, lInc, CFileName, MAX_PATH) > 0 do
    begin
      lFilename := CFileName;
      if AddMRU(lFilename) then
        LoadDropFile(lFilename);
      Msg.Result := 0;
      inc(lInc);
    end;
  finally
    DragFinish(Msg.Drop);
  end;
end;

procedure TDICOMViewer.ZoomSliderChange(Sender: TObject);
var
  lZoomPct: integer;
begin
  // gZoomSlider := true;
  // lTMp := WindowmaximizeItem.checked;
  // WindowmaximizeItem.checked := false;
  if not Assigned(Study.ActiveSeries) then
    Exit;

  lZoomPct := trackZoomSlider.position;

  if Study.ActiveSeries.gZoomPct = lZoomPct then
    Exit;

  Study.ActiveSeries.gZoomPct := lZoomPct;
  Study.ActiveSeries.RefreshZoom;
end;

(* procedure TMainForm.WMDropFiles(var Msg: TWMDropFiles);
  var
  lInc: integer;
  CFileName: array[0..MAX_PATH] of Char;
  begin
  try
  if DragQueryFile(Msg.Drop, 0, CFileName, MAX_PATH) > 0 then
  begin
  OpenDialog.FileName := CFileName;
  LoadDropFile;
  Msg.Result := 0;
  end;
  finally
  DragFinish(Msg.Drop);
  end;
  end;
*)
procedure TDICOMViewer.act1Execute(Sender: TObject);
begin
  inherited;
   //
end;

procedure TDICOMViewer.AppLaunch;
var
  lStr: String;
  I: integer;
begin
  if (ParamCount > 0) then
  begin
    I := 0;
    repeat
      lStr := '';
      repeat
        inc(I);
        if I = 1 then
          lStr := ParamStr(I)
        else
        begin
          if lStr <> '' then
            lStr := lStr + ' ' + ParamStr(I)
          else
            lStr := ParamStr(I);
        end;
      until (I = ParamCount) or (fileexists(lStr));
      if fileexists(lStr) then
      begin
        LoadDropFile(lStr);
      end
      else
        showmessage('Unable to find the file: *' + lStr + '*');
    until I >= ParamCount;
  end; { param count > 0 }
  { lStr := 'C:\TEST.DCM';
    if fileexists(lStr) then
    LoadDropFile(lStr); { }

end;

function ParseFileName(lFilewExt: String): string;
var
  lLen, lInc: integer;
  lName: String;
begin
  lName := '';
  lLen := length(lFilewExt);
  lInc := lLen + 1;
  if lLen > 0 then
    repeat
      dec(lInc);
    until (lFilewExt[lInc] = '.') or (lInc = 1);
  if lInc > 1 then
    for lLen := 1 to (lInc - 1) do
      lName := lName + lFilewExt[lLen]
  else
    lName := lFilewExt; // no extension
  ParseFileName := lName;
end;

function TDICOMViewer.AddMRU(lFilename: string): boolean;
var
  lI, lSlot: integer;
  lAbort: boolean;
begin
  if not fileexists(lFilename) then
  begin
    // showmessage('Unable to find the file '+ lHdrName);
    lAbort := true;
  end
  else
    lAbort := false; { }
  lSlot := 1;
  for lI := 1 to kMaxMRU do
  begin
    if (gMRUra[lI] <> '') and (gMRUra[lI] <> lFilename) and (lSlot <= kMaxMRU)
    then
    begin
      gMRUra[lSlot] := gMRUra[lI];
      inc(lSlot);
    end;
  end;
  if lSlot < kMaxMRU then
    for lI := lSlot to kMaxMRU do
      gMRUra[lI] := '';
  if lAbort then
  begin
    UpdateMRUMenu;
    Result := false;
    exit;
  end;
  Result := true;
  for lI := (kMaxMRU) downto 2 do
    gMRUra[lI] := gMRUra[lI - 1];
  gMRUra[1] := lFilename;
  UpdateMRUMenu;
end;

procedure TDICOMViewer.LoadDropFile(var lFilename: string);
var
  lExt, lHDrName: string;
  lF: file of byte;
  lI, lLen: integer;
begin
  lExt := ExtractFileExt(lFilename);
  if length(lExt) > 0 then

    for lI := 1 to length(lExt) do
      lExt[lI] := upcase(lExt[lI]);
  if (lExt = '.BMP') or (lExt = '.JPG') then
  begin
//    PGOpenDialog.FileName := '';
//    PGOpenDialog.InitialDir := extractfiledir(lFilename);
    CreateMDIChild(lFilename, false, false, true, false);
    exit;
  end;
//  OpenDialog.InitialDir := extractfiledir(lFilename);
  if (lExt = '.IMG') or (lExt = '.HDR') then
  begin
    lHDrName := ExtractFilePath(lFilename) +
      ParseFileName(ExtractFileName(lFilename)) + '.hdr';
    if fileexists(lHDrName) then
    begin
      AssignFile(lF, lHDrName);
      Reset(lF);
      lLen := filesize(lF);
      closefile(lF);
      if lLen = (348) then
      begin
        CreateMDIChild(lHDrName, true, false, false, false);
        exit;
      end;
    end;
  end; // try analyze format
  CreateMDIChild(lFilename, false, false, false, false);
end;

procedure TDICOMViewer.lstSeriesNavigatorGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: string);
begin
  inherited;
  ShowMessage(Value);
end;

procedure TDICOMViewer.lstSeriesNavigatorSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  inherited;
  ShowMessage(Value);
end;

procedure TDICOMViewer.lstStudyDetailsStringsChanging(Sender: TObject);
begin
  inherited;

end;

(* procedure Snoop;
  //FileSnooper => compares bytes of two files for differences
  label 767;
  var I,lLen,lTag : Integer;
  lF,lF2: file of byte;
  lBuff,lBuff2: bytep;
  lStart,lEnd,lPos,lVal,lSz: integer;
  begin
  lStart := 1;
  lEnd := 3055;
  lSz :=  lEnd-lStart+1;
  AssignFile(lF,'C:\efilm\heart16ori.dcm');
  reset(lF);
  GetMem( lBuff,lSz );
  Seek(lF,lStart);
  BlockRead(lF, lBuff^, lSz);
  CloseFile(lF);
  AssignFile(lF2,'C:\efilm\heart16.dcm');
  reset(lF2);
  GetMem( lBuff2, lSz);
  Seek(lF2,lStart);
  BlockRead(lF2, lBuff2^, lSz);
  CloseFile(lF2);
  lPos := 0;
  lVal := 0;
  while lPos < lEnd do begin
  inc(lPos);
  if (lBuff[lPos] <> lBuff2[lPos]) then begin
  showmessage(inttostr(lPos+lStart-1)+'abba:'+inttostr(lBuff[lPos]) +'/'+inttostr(lBuff2[lPos]));
  inc(lVal);
  if lVal > 10 then
  goto 767;
  //lPos := lEnd;
  end;
  end;
  767:
  FreeMem( lBuff2);
  FreeMem( lBuff);
  showmessage('filesnooper is done');
  end; Snoop utility(* *)

procedure TDICOMViewer.FormCreate(Sender: TObject);
var
  lSearchRec: TSearchRec;
  lDICOMdata: TDICOMdata;
  lHdrOK, lIMgOK: boolean;
  lDynStr, lFile: string;
begin
  TPageControlHack(pgcSeriesDetails).Color := clGray;

  FStudy := TStudy.Create(Self);
  { convert an image to dicom at startup->
    lFile := 'c:\efilm\rgb.dcm' ;
    if fileexists(lFile) then deletefile(lFile);
    lFile := 'c:\efilm\rgb.dc' ;
    read_dicom_data(false,false,true,false,true,true,true, lDICOMdata, lHdrOK, lImgOK, lDynStr,lFile );
    ConvertImg(lFile, lDICOMdata,1); }
  FormatSettings.DecimalSeparator := '.';

//  SchemeDrop.Items.Clear;
//  SchemeDrop.Items.Add('White & Black');
//  SchemeDrop.Items.Add('Black & White');
//  SchemeDrop.Items.Add('Hot Metal');
//  SchemeDrop.ItemIndex := 1;

  //DragAcceptFiles(Handle, true);
  //GetRegistryData;
//  if BestFitItem.checked then
//  begin
//    trackZoomSlider.enabled := false;
//    btnZoom100.enabled := false;
//  end
//  else
//  begin
//    trackZoomSlider.enabled := true;
//    btnZoom100.enabled := true;
//  end;
//  if FindFirst(ExtractFilePath(ParamStr(0)) + '\*.lut', faAnyFile, lSearchRec)
//    <> 0 then
//  begin
//    FindClose(lSearchRec);
//    exit;
//  end;
//  SchemeDrop.Items.Add(ParseFileName(ExtractFileName(lSearchRec.Name)));
//  while (FindNext(lSearchRec) = 0) do
//  begin
//    ///SchemeDrop.Items.Add(ParseFileName(ExtractFileName(lSearchRec.Name)));
//  end;
//  FindClose(lSearchRec);
  Study.DoSeriesViewerChange(nil, nil);

  ColUpdate;
end;

function TDICOMViewer.CreateMDIChild(Name: string; lAnz, lECAT, l2dImage, lRaw: boolean;  ADICOMData: TDICOMData = nil): TSeriesGraphicViewer;
var
  Child: TSeriesGraphicViewer;
begin
  Result := nil;

  Child := TSeriesGraphicViewer.Create(Self);

  if Assigned(ADICOMData) then
    Child.gStringList.AddObject(Name, ADICOMData);

  try
    Child.Parent := Self;
    Child.SendToBack;

    //Child.Parent := pnlSerieViewerHolder;
    Child.Caption := Name;

//    if lRaw then
//    begin
//      clear_dicom_data(Child.gDicomData);
//      Child.gDicomData.XYZdim[1] := RawForm.WidEdit.value;
//      Child.gDicomData.XYZdim[2] := RawForm.HtEdit.value;
//      Child.gDicomData.XYZdim[3] := RawForm.SliceEdit.value;
//      Child.gDicomData.XYZdim[4] := 1;
//      Child.gDicomData.ImageStart := RawForm.OffsetEdit.value;
//      if RawForm.LittleEndCheck.checked then
//        Child.gDicomData.little_endian := 1
//      else
//        Child.gDicomData.little_endian := 0;
//      Child.gDicomData.Allocbits_per_pixel := RawForm.BitsEdit.value;
//      if Child.gDicomData.Allocbits_per_pixel = 24 then
//      begin
//        Child.gDicomData.SamplesPerPixel := 3;
//        Child.gDicomData.Allocbits_per_pixel := 8;
//        if RawForm.PlanarRGBCheck.checked then
//          Child.gDicomData.PlanarConfig := 1
//        else
//          Child.gDicomData.PlanarConfig := 0;
//      end;
//      Child.gDicomData.Storedbits_per_pixel :=
//        Child.gDicomData.Allocbits_per_pixel;
//    end;
    if NOT Child.LoadData(Name, lAnz, lECAT, l2dImage, lRaw) then
    begin
      FreeAndNil(Child);
      Exit;
    end
    else
      Child.OverlayData;

    Child.PositionImage;
  finally
    Result := Child;
  end;
end;

procedure TDICOMViewer.grpSeriesDetailsCollapse(Sender: TObject);
begin
  inherited;

  try
    grpSeriesDetails.Expand;
  finally
  end;
end;

procedure TDICOMViewer.pgcSeriesDetailsDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  Text: string;
  Point: TPoint;
begin
  inherited;

  Text := TPageControl(Control).Pages[TabIndex].Caption;

  with Control.Canvas do
  begin
    Point.x := (Rect.Right - Rect.Left) div 2 - TextWidth(Text) div 2;
    Point.y := (Rect.Bottom - Rect.Top) div 2 - TextHeight(Text) div 2;
    TextRect(Rect, Rect.Left + Point.x, Rect.Top + Point.y, Text);
  end;
end;

procedure TDICOMViewer.grpStudyDetailsDblClick(Sender: TObject);
begin
  ShowMessage('ololo');
end;

procedure TDICOMViewer.FileExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TDICOMViewer.WindowCascadeItemClick(Sender: TObject);
begin
  Cascade;

  // if (not BestFitItem.checked) or (Self.MDIChildCount = 0) then exit;
  { for I :=  (MDIChildCount - 1) downto 0 do
    MDIChildren[I]. }
  // AutoMaximise;
end;

procedure TDICOMViewer.WindowTileItemClick(Sender: TObject);
begin
  Tile;
end;

procedure TDICOMViewer.WindowArrangeItemClick(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TDICOMViewer.WindowMinimizeItemClick(Sender: TObject);
var
  I: integer;
begin
  if MDIChildCount = 0 then
    exit;
  for I := MDIChildCount - 1 downto 0 do
    MDIChildren[I].WindowState := wsMinimized;
end;

procedure TDICOMViewer.Opengraphic1Click(Sender: TObject);
var
  I: integer;
begin
  // PGOpenDialog1.filename := '';
  // OpenDialog.Filter := 'Images (*.bmp;*.jpg)|*.bmp;*.jpg|Bitmaps (*.bmp)|*.bmp|JPEGs (*.jpg]|*.jpg';
  // PGOpenDialog.Filter := GraphicFilter(TGraphic);
  if PGOpenDialog.Execute then
  begin
    for I := 0 to PGOpenDialog.Files.Count - 1 do
    begin
      if AddMRU(PGOpenDialog.Files[I]) then
      begin
        PGOpenDialog.InitialDir := ExtractFilePath(PGOpenDialog.Files[I]);
        PGSaveDialog.InitialDir := PGOpenDialog.InitialDir;
        // PGSaveDialog.FileName := extractfilename(PGOpenDialog.FileName);
        // PGOpenDialog.FileName := extractfilename(PGOpenDialog.FileName);
        CreateMDIChild(PGOpenDialog.Files[I], false, false, true, false);
      end;
    end; // for I..nfiles
  end; // if execute
  // OpenDialog.Filter :='Medical Image|*.*';
end;

procedure TDICOMViewer.trackSliceSlider1Change(Sender: TObject);
begin
  if not Assigned(Study.ActiveSeries) then
    Exit;

  if not trackSliceSlider.Enabled then
    Exit;

  try
    Study.ActiveViewer.ShowSlice(trackSliceSlider.Position);
    Study.ActiveViewer.RefreshZoom;
  finally
    {if not btnKeepPresets.Down then
    begin
      btnSmooth.Down := False;
      btnBestFit.Down := False;
      trackZoomSlider.Position := 100;
    end;     }

    ColUpdate;
  end;
end;

procedure TDICOMViewer.udSliceControlChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Integer; Direction: TUpDownDirection);
var
  ActiveViewer: TSeriesGraphicViewer;
begin
  inherited;

  if NewValue < udSliceControl.Min then
    NewValue := udSliceControl.Max
  else
  if NewValue > udSliceControl.Max then
    NewValue := udSliceControl.Min;

  AllowChange := (NOT (NewValue < trackSliceSlider.Min)) AND
                 (not (NewValue > trackSliceSlider.Max));



  {ActiveViewer := Study.ActiveViewer;

  if NOT Assigned(ActiveViewer) then
    Exit;

  AllowChange := (NOT (NewValue < trackSliceSlider.Min)) AND
                 (not (NewValue > trackSliceSlider.Max));


  if AllowChange then
    trackSliceSlider.Position := NewValue
  else
  if not AllowChange then
    try
      if NewValue < trackSliceSlider.Min then
        NewValue := trackSliceSlider.Max
      else
        NewValue := trackSliceSlider.Min;
    finally
      udSliceControlChangingEx(Sender, AllowChange, NewValue, Direction);
    end;    }
end;


procedure TDICOMViewer.udSliceControlClick(Sender: TObject; Button: TUDBtnType);
var
  SliderPos: integer;
begin
  inherited;

  trackSliceSlider.Position := udSliceControl.Position;

  btnVideoBtnMouseDown(nil, mbMiddle, [], 0, 0);
//
//  if not string(btnVideo.Caption).Equals('0') then
//  begin
//    btnVideo.Caption := '0';
//    Study.ActiveViewer.Timer1.Enabled := False;
//    Study.ActiveViewer.gVideoSpeed := 0;
//  end;

  //trackSliceSlider.Position := udSliceControl.Position;
//  if not string(btnVideo.Caption).Equals('0') then
//  begin
//    btnVideo.Caption := '0';
//    Study.ActiveViewer.Timer1.Enabled := False;
//
//    Study.ActiveViewer.gVideoSpeed := 0;
//  end;
//
//  try
//    case Button of
//      btNext: SliderPos := trackSliceSlider.Position + 1;
//      btPrev: SliderPos := trackSliceSlider.Position - 1;
//    end;
//
//    if SliderPos < trackSliceSlider.Min then
//      SliderPos := trackSliceSlider.Max
//    else
//    if SliderPos > trackSliceSlider.Max then
//      SliderPos := trackSliceSlider.Min;
//  finally
//    trackSliceSlider.Position := SliderPos;
//  end;
end;

procedure TDICOMViewer.ColUpdate;
var
  CurSeriesViewer: TSeriesGraphicViewer;
begin
  CurSeriesViewer := Study.ActiveViewer;

  if not Assigned(CurSeriesViewer) or
     (Length(Study.UID) = 0) or
     (Study.Series.Count = 0) then
  begin
    btnApplyCon.enabled := false;
    btnApplyBright.enabled := false;
    btnContrast.enabled := false;
    btnAutoBal.enabled := false;
//    SchemeDrop.enabled := false;
    seWinWidEdit.enabled := false;
    seWinCenEdit.enabled := false;
    btnVideo.enabled := false;
    trackSliceSlider.Position := 1;
    trackSliceSlider.enabled := false;
    udSliceControl.Min := 0;
    udSliceControl.Max := 0;
    udSliceControl.Position := 0;
    udSliceControl.Enabled := False;
    trackZoomSlider.Enabled := False;
    trackZoomSlider.Position := 100;
    btnZoom100.Enabled := False;
    btnBestFit.Enabled := False;
    btnDICOMHeader.Enabled := False;
    btnDICOMHeader.Down := False;
    btnKeepPresets.Down := False;
    btnKeepPresets.Enabled := False;

    Exit;
  end
  else
  begin
    udSliceControl.Enabled := True;
    trackZoomSlider.Enabled := True;
//    trackZoomSlider.Position := 100;
    btnZoom100.Enabled := not btnBestFit.Down;
    btnBestFit.Enabled := True;

    btnDICOMHeader.Enabled := True;
//    btnDICOMHeader.Down := True;
    //btnSmooth.Enabled := True;
  end;
  (* StatusBar.Panels[1].text := inttostr(Self.MDIChildCount)+'x'+inttostr(random(255));
    if Self.MDIChildCount = 0 then begin
    btnApplyCon.visible := false;
    btnApplyBright.visible := false;
    btnContrast.visible := false;
    btnAutoBal.visible := false;
    SchemeDrop.visible:= false;
    WinWidEdit.visible := false;
    seWinCenEdits.visible := false;
    exit;
    end; *)
  // Self.ZoomBox.ItemIndex := CurSeriesViewer.gZoom;
  //Self.MainMenu1.Merge(CurSeriesViewer.MainMenu1);
  //if not Assigned(Self.CurSeriesViewer) then Exit;


//  if TSeriesGraphicViewer(CurSeriesViewer).gFileListSz > 0 then
//    TSeriesGraphicViewer(CurSeriesViewer).StudyMenu.Enabled := True
//  else
//    TSeriesGraphicViewer(CurSeriesViewer).StudyMenu.Enabled := False;

  //btnDICOMHeader.Down := CurSeriesViewer.Memo1.visible;

  // Self.Caption := inttostr(CurSeriesViewer.gCustomPalette);
  if (not CurSeriesViewer.FDICOM) then
  begin
    // or  (CurSeriesViewer.gDICOMdata.SamplesPerPixel > 1) or (CurSeriesViewer.gCustomPalette > 0) {or ((lVox > 7) and (lVox < 17)) }then begin
    btnApplyCon.enabled := false;
    btnApplyBright.enabled := false;
    btnContrast.enabled := false;
    btnAutoBal.enabled := false;
    // Self.caption := 'NOT_DICOM'+inttostr(random(32));
//    SchemeDrop.enabled := false;
    seWinWidEdit.enabled := false;
    seWinCenEdit.enabled := false;
  end
  else
  begin
//    Self.SchemeDrop.ItemIndex := CurSeriesViewer.gScheme;

    seWinCenEdit.value := CurSeriesViewer.gWinCen;
    seWinWidEdit.value := CurSeriesViewer.gWinWid;

    btnContrast.enabled := true;

    if (CurSeriesViewer.gDicomData.Allocbits_per_pixel < 9) then
    begin
      btnApplyCon.enabled := false;
      btnApplyBright.enabled := false;
      seWinWidEdit.enabled := false;
      seWinCenEdit.enabled := false;
    end
    else
    begin
      if CurSeriesViewer.gDicomData.WindowWidth <> 0 then
        btnContrast.enabled := true
      else
        btnContrast.enabled := false;

      btnApplyCon.enabled := true;
      btnApplyBright.enabled := true;
      seWinWidEdit.enabled := true;
      seWinCenEdit.enabled := true;
    end;
    btnAutoBal.enabled := true;
//    SchemeDrop.enabled := true;
  end;

  ConLabelClick;

  btnBestFit.Enabled := not btnDICOMHeader.Down;
  btnZoom100.Enabled := not btnDICOMHeader.Down;
  trackZoomSlider.Enabled := not btnDICOMHeader.Down;

  // if CurSeriesViewer.gWinWid = 0 then   ConLabel.caption := '';
  if (btnDICOMHeader.Down) OR
     (not TSeriesGraphicViewer(CurSeriesViewer).FDICOM) OR
     ((CurSeriesViewer.gFileListSz = 0) AND (TSeriesGraphicViewer(CurSeriesViewer).gDicomData.XYZdim[3] < 2)) then
  begin
    trackSliceSlider.enabled := false;
    btnVideo.enabled := false;
    trackSliceSlider.position := 1;
  end
  else
  begin
    trackSliceSlider.enabled := true;

    btnVideo.enabled := true;
    btnVideo.Caption := CurSeriesViewer.gVideoSpeed.ToString;

    if (CurSeriesViewer.gDicomData.XYZdim[3] > 1) then
    begin
      trackSliceSlider.Max := CurSeriesViewer.gDicomData.XYZdim[3];
      trackSliceSlider.position := CurSeriesViewer.gSlice;
    end
    else
    if (CurSeriesViewer.gStringList.Count > 0) then
    begin
      CurSeriesViewer.gMultiCol := 1;
      CurSeriesViewer.gMultiRow := 1;

      trackSliceSlider.Max := CurSeriesViewer.gFileListSz;
      trackSliceSlider.Position := CurSeriesViewer.gCurrentPosInFileList;
    end;

    if trackSliceSlider.enabled then
    begin
      udSliceControl.Max := trackSliceSlider.Max;
      udSliceControl.Position := trackSliceSlider.Position;
    end;
  end;
end;

//procedure TMainForm.cbbSchemeDropChange(Sender: TObject);
//var
//  lStr: string;
//  lSearchRec: TSearchRec;
//begin
//  if not Assigned(Study.ActiveSeries) then
//    Exit;
//
////  if chemeDrop.ItemIndex > 2 then
//  begin
//    lStr := ExtractFilePath(ParamStr(0)) { +'\' } + SchemeDrop.Items.Strings
//      [SchemeDrop.ItemIndex] + '.lut';
//    if FindFirst(lStr, faAnyFile, lSearchRec) <> 0 then
//    begin
//      SchemeDrop.ItemIndex := 0;
//      FindClose(lSearchRec);
//      exit;
//    end;
//    FindClose(lSearchRec);
//    Study.ActiveSeries.LoadColorScheme(lStr,
//      SchemeDrop.ItemIndex);
//  end
//  else
//    Study.ActiveSeries.LoadColorScheme('',
//      SchemeDrop.ItemIndex);
//  Study.ActiveSeries.UpdatePalette(true, 0);
//  // Study.ActiveSeries.DisplayImage(false,trackSliceSlider.position,WinWidEdit.value,seWinCenEdits.value,Self.SchemeDrop.itemindex);
//  // zap conlabelclick;
//end;



procedure TDICOMViewer.btnApplyConClick(Sender: TObject);
var
  lMin, lWid, lCen: integer;
begin
  if not Assigned(Study.ActiveSeries) then
    Exit;

case (Sender as TToolButton).Tag of
  1:  begin
        lMin := Study.ActiveSeries.gImgMin;
        lWid := Study.ActiveSeries.gImgMax - lMin;
        lCen := lMin + (lWid shr 1);
        // self.caption := inttostr(lMin)+'abba'+inttostr(lCen)+'aaa'+inttostr(Study.ActiveSeries.gImgMax);

        seWinWidEdit.value := lWid;
        seWinCenEdit.value := lCen;
        Study.ActiveSeries.gWinWid := lWid;
        Study.ActiveSeries.gWinCen := lCen;

        Study.ActiveViewer.DisplayImage(True, True, Study.ActiveViewer.gSlice, lWid, lCen);
          // Study.ActiveSeries.gWinCen := lMin + (lWid shr 1);
          //Study.ActiveSeries.gFastCen := lMin + (lWid shr 1);
          // Study.ActiveSeries.gWinWid :=lWid;
          //Study.ActiveSeries.UpdatePalette(true, lWid);

        ConLabelClick;

      end;
    2:
      begin
        seWinWidEdit.value := (Study.ActiveSeries
          .gDicomData.WindowWidth);
        seWinCenEdit.value := (Study.ActiveSeries
          .gDicomData.WindowCenter);
        Study.ActiveSeries.gWinWid :=
          (Study.ActiveSeries.gDicomData.WindowWidth);
        Study.ActiveSeries.gWinCen :=
          (Study.ActiveSeries.gDicomData.WindowCenter);
        Study.ActiveViewer.DisplayImage(True, True, Study.ActiveViewer.gSlice, seWinWidEdit.value, seWinCenEdit.value);
      end;
  else
    begin
      Study.ActiveSeries.gWinWid := seWinWidEdit.value;
      Study.ActiveSeries.gWinCen := seWinCenEdit.value;
      Study.ActiveViewer.DisplayImage(True, True, Study.ActiveViewer.gSlice, Study.ActiveSeries.gWinWid, Study.ActiveSeries.gWinCen);
    end;
  end;
  Study.ActiveSeries.RefreshZoom;
  //Study.ActiveSeries.DisplayImage(true,false,trackSliceSlider.position,WinWidEdit.value,seWinCenEdits.value);
  ConLabelClick;
end;

PROCEDURE PrintBitmap(Canvas: TCanvas; DestRect: TRect; Bitmap: TBitmap);
VAR
  BitmapHeader: pBitmapInfo;
  BitmapImage: POINTER;
  HeaderSize: DWORD; // Use DWORD for D3-D5 compatibility
  ImageSize: DWORD;
BEGIN
  GetDIBSizes(Bitmap.Handle, HeaderSize, ImageSize);
  GetMem(BitmapHeader, HeaderSize);
  GetMem(BitmapImage, ImageSize);
  TRY
    GetDIB(Bitmap.Handle, Bitmap.Palette, BitmapHeader^, BitmapImage^);
    StretchDIBits(Canvas.Handle, DestRect.Left, DestRect.Top,
      // Destination Origin
      DestRect.Right - DestRect.Left, // Destination Width
      DestRect.Bottom - DestRect.Top, // Destination Height
      0, 0, // Source Origin
      Bitmap.Width, Bitmap.Height, // Source Width & Height
      BitmapImage, TBitmapInfo(BitmapHeader^), DIB_RGB_COLORS, SRCCOPY)
  FINALLY
    FreeMem(BitmapHeader);
    FreeMem(BitmapImage)
  END
END { PrintBitmap };

procedure TDICOMViewer.PrintImg;
VAR
  Bitmap: TBitmap;
  liHt, liWid, iFromLeftMargin, iPrintedImageWidth, jDelta, jFromTopOfPage,
    jPrintedImageHeight: integer;
begin
//  if Self.MDIChildCount = 0 then
//    exit;
//  if not PrintDialog1.Execute then
//    exit;
//  liHt := Study.ActiveSeries.image.Picture.Height;
//  liWid := Study.ActiveSeries.image.Picture.Width;
//  if (liHt = 0) or (liWid = 0) then
//    exit;
//  Screen.Cursor := crHourGlass;
//  TRY
//    { if liHt >= liWid then
//      Printer.Orientation := poPortrait //image is taller than wide
//      else
//      Printer.Orientation := poLandscape; //image is wider than tall
//    }
//    Printer.BeginDoc;
//    Printer.Canvas.Font.Size := 12;
//    Printer.Canvas.Font.Name := 'Arial';
//    jDelta := Printer.Canvas.TextHeight('X');
//    // jFromTopOfPage := 3*jDelta;
//    // s := 'Image Title';
//    // Printer.Canvas.TextOut(CenterText(s), jFromTopOfPage, s);
//    // 5th line from top
//    jFromTopOfPage := 5 * jDelta;
//
//    // Image position and size
//    // 12% left and right margin
//    iFromLeftMargin := MulDiv(Printer.PageWidth, 12, 100); // 12%
//    if (liHt / liWid) > (Printer.PageHeight / Printer.PageWidth) then
//    begin
//      // Paper HEIGHT is constrained aspect ration
//      // Set printed bitmap with to be 76% of paper HEIGHT
//      jPrintedImageHeight := MulDiv(Printer.PageHeight, 76, 100); // 76%
//      // Set printed bitmap WIDTH to maintain aspect ratio
//      iPrintedImageWidth := liWid * jPrintedImageHeight DIV liHt;
//      // maintain aspect ratio of bitmap
//    end
//    else
//    begin
//      // Paper WIDTH is constrained aspect ration
//      // Set printed bitmap with to be 76% of paper WIDTH
//      iPrintedImageWidth := MulDiv(Printer.PageWidth, 76, 100); // 76%
//      // Set printed bitmap height to maintain aspect ratio
//      jPrintedImageHeight := liHt * iPrintedImageWidth DIV liWid;
//    end;
//    Bitmap := TBitmap.Create;
//    TRY
//      Bitmap.Width := liWid;
//      Bitmap.Height := liHt;
//      Bitmap.PixelFormat := pf24bit;
//      // Convert JPEG to BMP
//      Bitmap.Canvas.Draw(0, 0, Study.ActiveSeries
//        .image.Picture.Graphic);
//      PrintBitmap(Printer.Canvas, Rect(iFromLeftMargin, jFromTopOfPage,
//        iFromLeftMargin + iPrintedImageWidth,
//        jFromTopOfPage + jPrintedImageHeight), Bitmap)
//    FINALLY
//      Bitmap.free
//    END;
//    Printer.EndDoc;
//  FINALLY
//    Screen.Cursor := crDefault
//  END;
end;

procedure TDICOMViewer.ConLabelClick;
var
  CurActiveSeries: TSeriesGraphicViewer;
begin
  CurActiveSeries := Study.ActiveViewer;

  if not Assigned(CurActiveSeries) then
    Exit;

  with CurActiveSeries do
  begin
    StatusBar.Panels[1].text := gZoomPct.ToString + '%';

    if gDicomData.XYZdim[3] < 2 then
      StatusBar.Panels[2].text := Format('%dx%d', [gDicomData.XYZdim[1], gDicomData.XYZdim[2]])
    else
      StatusBar.Panels[2].text := Format('%d/%d  %dx%d', [gSlice, gDicomData.XYZdim[3], gDicomData.XYZdim[1], gDicomData.XYZdim[2]]);

    if (gImgMin = 0) and (gImgMax = 0) then
      StatusBar.Panels[3].text := ''
    else
      StatusBar.Panels[3].text := Format('Image  Cen/Wid: %d/%d', [gimgCen, gimgWid]);

    StatusBar.Panels[4].text := gContrastStr;
  end;
end;

procedure TDICOMViewer.btn10Click(Sender: TObject);
var
  Dir: string;
begin
  inherited;
  SelectDirectory('Please select dir with study', '', Dir);

  if Dir.IsEmpty then
    Dir := 'C:\Users\nagibator\Desktop\3D_13\A\B';

  try
    Study.Load(Dir);
  except

  end;
end;

procedure TDICOMViewer.btn11Click(Sender: TObject);
begin
  Study.ActiveViewer.N1x11Click(Study.ActiveViewer.N4x41);
end;

procedure TDICOMViewer.btn1Click(Sender: TObject);
begin
  inherited;
  Study.ActiveSeries.DisplayImage(false, false, 1, 100, 500);
end;

procedure TDICOMViewer.btn4Click(Sender: TObject);
begin
  inherited;

  Study.Reset;
  Study.Load(cbb1.Items[cbb1.ItemIndex]);
end;

procedure TDICOMViewer.btnScanFolderClick(Sender: TObject);
var
  Dir, FileName: string;
  FileList: TStringDynArray;

  i,j: integer;
  //NewChild: TSeriesGraphicViewer;                                                      0

  lHdrOK, lImgOK: boolean;
  fn, lDynStr: string;

  lDicomData: TDICOMData;

  Skip: Boolean;
begin
  if not SelectDirectory('Please select dir with study', '', Dir) then
    Exit;

  Study.Reset;

  try
    Study.Load('fdgsd');
  except
    on E:Exception do


  end;

   {j := 1;
  LockWindowUpdate(Self.Handle);

  try
    FileList := TDirectory.GetFiles(Dir);

    for FileName in FileList do
    begin
      pnlSerieViewerHolder.Caption := Format('Processing files (%d of %d)', [j, Length(FileList)]);
      //Application.ProcessMessages;

      Skip := False;

      fn := FileName;
      read_dicom_data( false, false, true, true,
                       true, true, false, lDicomData, lHdrOK, lImgOK, lDynStr, fn);

      if Self.MDIChildCount > 0 then
        for i := 0 to Self.MDIChildCount - 1 do
          if SameText(TSeriesGraphicViewer(Self.MDIChildren[i]).gDicomData.SerieUID, lDicomData.SerieUID) then
          begin
            Skip := True;
            break;
          end;

      if not Skip then
       NewChild := TSeriesGraphicViewer(CreateMDIChild(FileName, false, false, false, false));

      Inc(j);
    end;
  finally
    pnlSerieViewerHolder.Caption := '';
    LockWindowUpdate(0);
  end;}
end;

procedure TDICOMViewer.btnSelectFileClick(Sender: TObject);
var
  I, lLen, lTag: integer;
  lF: file of byte;
  tag: string;
begin
  LockWindowUpdate(Self.Handle);

  try
    lTag := (Sender as TSpeedButton).tag;
    if lTag = 1 then
//      OpenDialog.Filter := 'Analyze Header (*.hdr)|*.hdr'
      { else
        OpenDialog.Filter := 'Medical Image|*.*' };
    if OpenDialog.Execute then
    begin
      for I := 0 to OpenDialog.Files.Count - 1 do
      begin
        if AddMRU(OpenDialog.Files[I]) then
        begin
          OpenDialog.InitialDir := extractfiledir(OpenDialog.Files[I]);
          Filemode := 0;
          AssignFile(lF, OpenDialog.Files[I]);
          Reset(lF);
          lLen := filesize(lF);
          closefile(lF);
          Filemode := 2;
          if lTag = 2 then // ecat
            CreateMDIChild(OpenDialog.Files[I], false, true, false, false)
          else if (lLen = 348) and (ExtractFileExt(OpenDialog.FileName) = '.hdr')
          then
            CreateMDIChild(OpenDialog.Files[I], true, false, false, false)
          else
            CreateMDIChild(OpenDialog.Files[I], false, false, false, false);
        end; // fileexists
      end;
    end;
    // OpenDialog.Filter := 'Medical Image|*.*';
    OpenDialog.Filter := 'Medical Image|*.*';
    ConLabelClick;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TDICOMViewer.cbbSeriesListCloseUp(Sender: TObject);
begin
  inherited;

  pgcSeriesDetails.ActivePage.SetFocus;
end;

procedure TDICOMViewer.cbbSeriesListEnter(Sender: TObject);
begin
  inherited;

  PostMessage(cbbSeriesList.Handle, CB_SETEDITSEL, Cardinal(-1), 0);
end;

procedure TDICOMViewer.cbbSeriesListSelect(Sender: TObject);
begin
  inherited;

  LockWindowUpdate(Self.Handle);

  try
    if not SameText((cbbSeriesList.Items.Objects[cbbSeriesList.ItemIndex] as TSeriesGraphicViewer).gDicomData.SerieUID, Study.ActiveSeriesUID) then
      trackSliceSlider.Position := 1;

    if (cbbSeriesList.Items.Objects[cbbSeriesList.ItemIndex] as TSeriesGraphicViewer).gDicomData.SerieUID.IsEmpty then
      Study.ActiveSeries := (cbbSeriesList.Items.Objects[cbbSeriesList.ItemIndex] as TSeriesGraphicViewer)
    else
      Study.ActiveSeriesUID := (cbbSeriesList.Items.Objects[cbbSeriesList.ItemIndex] as TSeriesGraphicViewer).gDicomData.SerieUID;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TDICOMViewer.FormResize(Sender: TObject);
begin
  if Assigned(Study.ActiveSeries) and
     btnBestFit.Down then
    Study.ActiveSeries.AutoMaximise;
end;

procedure TDICOMViewer.Print1Click(Sender: TObject);
begin
  PrintImg;
end;

procedure TDICOMViewer.Exportaspicture1Click(Sender: TObject);
var
  JPG: TJPEGImage;
  BMP: TBitmap;
  lExt: string;
  lS: integer;
begin
  // Study.ActiveSeries.Image = nil then exit;
  if not Self.PGSaveDialog.Execute then
    exit;
  PGOpenDialog.InitialDir := ExtractFilePath(PGSaveDialog.FileName);
  PGSaveDialog.InitialDir := PGOpenDialog.InitialDir;
  lExt := ExtractFileExt(Self.PGSaveDialog.FileName);
  if length(lExt) > 0 then
    for lS := 1 to length(lExt) do
      lExt[lS] := upcase(lExt[lS]);
  if ('.JPG' = lExt) or (lExt = '.JPEG') then
  begin
    JPG := TJPEGImage.Create;
    TRY
      JPG.CompressionQuality := 80;
      // if Study.ActiveSeries.FDICOM and Study.ActiveSeries.gImgOK then
      // Study.ActiveSeries.DisplayImage(true,false,false,trackSliceSlider.position,WinWidEdit.value,seWinCenEdits.value{,Self.SchemeDrop.itemindex});
      // JPG.Assign(Study.ActiveSeries.Image.Picture.Bitmap);
      // following code ensures color palette is saved
      BMP := TBitmap.Create;
      try
        BMP.Height := Study.ActiveSeries.image.Picture.Height;
        BMP.Width := Study.ActiveSeries.image.Picture.Width;
        BMP.PixelFormat := pf24bit;
        BMP.Canvas.Draw(0, 0, Study.ActiveSeries
          .image.Picture.Graphic);
        JPG.Assign(BMP);
      finally
        BMP.free;
      end;
      JPG.SaveToFile(ChangeFileExt(Self.PGSaveDialog.FileName, '.jpg'));
    FINALLY
      JPG.free
    END;
  end
  else
    Study.ActiveSeries.image.Picture.Bitmap.SaveToFile
      (ChangeFileExt(Self.PGSaveDialog.FileName, '.bmp'));
  PGSaveDialog.FileName := '';
end;

procedure TDICOMViewer.Close1Click(Sender: TObject);
begin
  if Self.MDIChildCount = 0 then
    Study.DoSeriesViewerChange(nil, nil);

  Study.ActiveSeries.Close;
end;

procedure TDICOMViewer.GetRegistryData;
var
  reg: TRegistry;
  lInc: integer;
  lStr: STRING;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(gKeyRoot, true) then
    begin
      if reg.ValueExists('OpenDir') then
        lStr := reg.ReadString('OpenDir');
      OpenDialog.InitialDir := lStr;
      if reg.ValueExists('PixDir') then
        lStr := reg.ReadString('PixDir');
      PGOpenDialog.InitialDir := lStr;
      PGSaveDialog.InitialDir := lStr;
//      if reg.ValueExists('RawWid') then
//        gRawWid := reg.ReadInteger('RawWid');
//      if reg.ValueExists('RawHt') then
//        gRawHt := reg.ReadInteger('RawHt');
//      if reg.ValueExists('RawSlice') then
//        gRawSlice := reg.ReadInteger('RawSlice');
//      if reg.ValueExists('RawOffset') then
//        gRawOffset := reg.ReadInteger('RawOffset');
//      if reg.ValueExists('RawBits') then
//        gRawBits := reg.ReadInteger('RawBits');
//      if reg.ValueExists('RawLittleEnd') then
//        gRawLittleEnd := reg.ReadBool('RawLittleEnd');
//      if reg.ValueExists('RawPlanarRGB') then
//        gRawPlanarRGB := reg.ReadBool('RawPlanarRGB');
      //if reg.ValueExists('Maximize') then
      //  BestFitItem.checked := reg.ReadBool('Maximize');
      //btnBestFit.Down := BestFitItem.checked;
      for lInc := 1 to kMaxMRU do
        if reg.ValueExists('MRU' + inttostr(lInc)) then
        begin
          lStr := reg.ReadString('MRU' + inttostr(lInc));
          if (length(lStr) > 0) { and (fileexistsex(lStr)) } then
          begin
            gMRUra[lInc] := lStr;
          end;
        end;
    end;
  finally
    reg.free;
  end;
  UpdateMRUMenu;

end;

procedure TDICOMViewer.PutRegistryData;
var
  reg: TRegistry;
  lInc: integer;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(gKeyRoot, true) then
    begin
      reg.WriteString('OpenDir', OpenDialog.InitialDir);
      reg.WriteString('PixDir', PGOpenDialog.InitialDir);
//      reg.WriteInteger('RawWid', gRawWid);
//      reg.WriteInteger('RawHt', gRawHt);
//      reg.WriteInteger('RawSlice', gRawSlice);
//      reg.WriteInteger('RawOffset', gRawOffset);
//      reg.WriteInteger('RawBits', gRawBits);
//      reg.WriteBool('RawLittleEnd', gRawLittleEnd);
//      reg.WriteBool('RawPlanarRGB', gRawPlanarRGB);
     // reg.WriteBool('Maximize', BestFitItem.checked);
      for lInc := 1 to kMaxMRU do
      begin
        reg.WriteString('MRU' + inttostr(lInc), gMRUra[lInc]);
      end;
      reg.CloseKey;
    end;
  finally
    reg.free;
  end;
end;

procedure TDICOMViewer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // PutRegistryData;
  Study.Reset;

  Action := caHide;;
end;

procedure TDICOMViewer.trackZoomSlider1Change(Sender: TObject);
var
  lZoomPct: integer;
begin
  // gZoomSlider := true;
  // lTMp := WindowmaximizeItem.checked;
  // WindowmaximizeItem.checked := false;
  if not Assigned(Study.ActiveSeries) then
    Exit;

  lZoomPct := trackZoomSlider.position;

  if Study.ActiveSeries.gZoomPct = lZoomPct then
    Exit;

  Study.ActiveSeries.gZoomPct := lZoomPct;
  Study.ActiveSeries.RefreshZoom;
end;


procedure TDICOMViewer.btnDICOMHeaderClick(Sender: TObject);
begin
  if Assigned(Study.ActiveSeries) then
    with Study.ActiveSeries do
    begin
      //Memo1.visible := btnDICOMHeader.Down;

      //if Memo1.Visible then
      //  btnVideoBtnMouseDown(nil, mbMiddle, [], 0, 0);

      ColUpdate;

//      if btnDICOMHeader.Down AND
//         (gVideoSpeed > 0) then
//      begin
//        gVideoSpeed := 0;
//        Self.btnVideo.Caption := '0';
//        Timer1.Enabled := False;
//        Self.btnVideo.Enabled := False;
//        Self.trackSliceSlider.Enabled := False;
//        udSliceControl.Enabled := False;
//      end
//      else
//      begin
//        Self.btnVideo.Enabled := (gDicomData.XYZdim[3] > 1) or
//                                 (gFileListSz > 0);
//        Self.trackSliceSlider.Enabled := Self.btnVideo.Enabled;
//        udSliceControl.Enabled := trackSliceSlider.Enabled;
//      end;
    end;
end;

procedure TDICOMViewer.btnBestFitClick(Sender: TObject);
begin
  if not Assigned(Study.ActiveSeries) then
    Exit;

  trackZoomSlider.enabled := not btnBestFit.Down;
  btnZoom100.enabled := not btnBestFit.Down;

  if btnBestFit.Down then
  begin
    Study.ActiveSeries.AutoMaximise;
    Study.ActiveSeries.PositionImage;
  end;
end;

procedure TDICOMViewer.MaximizeAll1Click(Sender: TObject);
var
  I: integer;
begin
  if Self.MDIChildCount = 0 then
    exit;
  for I := (MDIChildCount - 1) downto 0 do
    MDIChildren[I].WindowState := wsMaximized;
  { }
end;

procedure TDICOMViewer.HintBtnClick(Sender: TObject);
begin
  showmessage('You can drag the mouse over an image to change the view. ' + kCR
    + ' Dragging changes the contrast.' + kCR +
    ' Alt+dragging pans the scrollbars.' + kCR +
    ' Shift+dragging magnifies the region under the mouse.' + kCR +
    ' Ctrl+dragging selects a region for contrast optimization.' + kCR +
    'When multiple windows are open, use Ctrl+Tab to select an image.');
end;

procedure TDICOMViewer.btnHdrBtnClick(Sender: TObject);
var
  I: integer;
  lConv, lConvAny: boolean;
  lDICOMdata: TDICOMdata;
begin
  // Memo1.lines.add(inttostr(gDicomData.ImageStart));
//  if MDIChildCount <> 0 then
//  begin
//    gRawOffset := Study.ActiveSeries.gDicomData.ImageStart;
//    gRawWid := Study.ActiveSeries.gDicomData.XYZdim[1];
//    gRawHt := Study.ActiveSeries.gDicomData.XYZdim[2];
//    gRawSlice := Study.ActiveSeries.gDicomData.XYZdim[3];
//
//    if Study.ActiveSeries.gDicomData.SamplesPerPixel = 3 then
//      gRawBits := 24
//    else
//      gRawBits := Study.ActiveSeries
//        .gDicomData.Storedbits_per_pixel;
//    if Study.ActiveSeries.gDicomData.little_endian = 1 then
//      gRawLittleEnd := true
//    else
//      gRawLittleEnd := false;
//    if Study.ActiveSeries.gDicomData.PlanarConfig = 1 then
//      gRawPlanarRGB := true
//    else
//      gRawPlanarRGB := false;
//  end;
//  // }ditChange(nil);
//  RawForm.showmodal;
//  if gRawOK = 0 then
//    exit; // cancel
//  if gRawOK > 1 then // user wants to convert file
//    showmessage
//      ('Note that ezDICOM does not same voxel size [mm] for converted raw files. If required, use MRIcro to convert files.');
//  if (RawForm.BitsEdit.value = 20) then
//  begin
//    showmessage
//      ('The current version of the software is unable to view or convert 20-bit images.');
//    exit;
//  end;
//  if (gRawOK > 2) and (RawForm.BitsEdit.value = 24) then
//  begin
//    showmessage
//      ('The current version of the software is unable to convert 24-bit images to Analyze/Interfile.');
//    exit;
//  end;
//  lConvAny := false;
//  if OpenDialog.Execute then
//  begin
//    for I := 0 to OpenDialog.Files.Count - 1 do
//    begin
//      if fileexists(OpenDialog.Files[I]) then
//      begin // do NOT add to MRU!
//        OpenDialog.InitialDir := extractfiledir(OpenDialog.Files[I]);
//        if gRawOK = 1 then // view
//          CreateMDIChild(OpenDialog.Files[I], false, false, false, true)
//        else
//        begin // convert raw to dicom or interfile
//          clear_dicom_data(lDICOMdata);
//          lDICOMdata.XYZdim[1] := RawForm.WidEdit.value;
//          lDICOMdata.XYZdim[2] := RawForm.HtEdit.value;
//          lDICOMdata.XYZdim[3] := RawForm.SliceEdit.value;
//          lDICOMdata.XYZdim[4] := 1;
//          lDICOMdata.ImageStart := RawForm.OffsetEdit.value;
//          if RawForm.LittleEndCheck.checked then
//            lDICOMdata.little_endian := 1
//          else
//            lDICOMdata.little_endian := 0;
//          lDICOMdata.Allocbits_per_pixel := RawForm.BitsEdit.value;
//          if lDICOMdata.Allocbits_per_pixel = 24 then
//          begin
//            lDICOMdata.SamplesPerPixel := 3;
//            lDICOMdata.Allocbits_per_pixel := 8;
//            if RawForm.PlanarRGBCheck.checked then
//              lDICOMdata.PlanarConfig := 1
//            else
//              lDICOMdata.PlanarConfig := 0;
//          end;
//          lDICOMdata.Storedbits_per_pixel := RawForm.BitsEdit.value;
//          lDICOMdata.ImageSz :=
//            (lDICOMdata.SamplesPerPixel * (lDICOMdata.XYZdim[1] *
//            lDICOMdata.XYZdim[2] * lDICOMdata.Allocbits_per_pixel + 7) div 8) *
//            lDICOMdata.XYZdim[3];
//          lConv := ConvertImg(OpenDialog.Files[I], lDICOMdata, gRawOK);
//          if lConv then
//            lConvAny := true;
//        end; // convert raw
//      end; // fileexists
//    end;
//  end;
//  ConLabelClick;
//  if lConvAny then
//  begin
//    showmessage('Converted images have been placed in the folder ' +
//      ExtractFilePath(OpenDialog.FileName));
//  end;
end;

function TDICOMViewer.ConvertImg(lInName: string; lDICOMdata: TDICOMdata;
  l3ForInterfile4ForAna: integer): boolean;
var
  lOffset, lSliceSz, lOutHdrSz, lInc: integer;
  lHdrOK: boolean;
  lOutHdr, lOutImg: String;
  lF, lOutF: file of byte;
  lBuff: bytep0;
begin
//  Result := false;
//  lOffset := lDICOMdata.ImageStart;
//  if (lDICOMdata.SamplesPerPixel > 1) and
//    ((l3ForInterfile4ForAna = 3) or (l3ForInterfile4ForAna = 4)) then
//  begin
//    showmessage
//      ('Error: This software can not convert 24-bit RGB images to Analyze or Interfile formats.');
//    exit;
//  end;
//  lDICOMdata.ImageStart := 0;
//  if l3ForInterfile4ForAna = 4 then
//  begin // interfile
//    lOutHdr := ChangeFileExt(lInName, '.hdr');
//    lOutImg := ChangeFileExt(lInName, '.img');
//  end
//  else if l3ForInterfile4ForAna = 3 then
//  begin // interfile
//    lOutHdr := ChangeFileExt(lInName, '.i3h');
//    lOutImg := ChangeFileExt(lInName, '.i3i');
//  end
//  else
//  begin // tag <> interfile
//    lOutHdr := ChangeFileExt(lInName, '.dcm');
//    lOutImg := lOutHdr;
//  end; // save DCM
//  if fileexists(lOutHdr) then
//    showmessage('The file ' + lOutHdr + ' already exists.')
//  else if fileexists(lOutImg) then
//    showmessage('The file ' + lOutImg + ' already exists.')
//  else
//  begin // file does not exist
//    lOutHdrSz := 0;
//    lHdrOK := true;
//    lDICOMdata.ImageSz := lDICOMdata.XYZdim[1] * lDICOMdata.XYZdim[2] *
//      lDICOMdata.XYZdim[3] * (lDICOMdata.Storedbits_per_pixel div 8) *
//      lDICOMdata.SamplesPerPixel;
//    if l3ForInterfile4ForAna = 4 then
//      lHdrOK := SaveAnalyzeHdr(lOutHdr, lDICOMdata)
//      // write_interfile_hdr (lOutHdr,lOutImg, lDICOMdata)
//    else if l3ForInterfile4ForAna = 3 then
//      //write_interfile_hdr(lOutHdr, lOutImg, lDICOMdata)
//    else
//      //write_dicom(lOutHdr, lDICOMdata, lOutHdrSz, { true } true);
//    if (lDICOMdata.XYZdim[3] > 0) and (lHdrOK) then
//    begin
//      Result := true;
//      lSliceSz :=
//        ((lDICOMdata.XYZdim[1] * lDICOMdata.XYZdim[2] { height * width } *
//        lDICOMdata.Allocbits_per_pixel + 7) div 8) * lDICOMdata.SamplesPerPixel;
//      AssignFile(lF, lInName);
//      Filemode := 0; // read Only
//      Reset(lF);
//      if ((lSliceSz * lDICOMdata.XYZdim[3]) + lOffset) > filesize(lF) then
//      begin
//        showmessage('The input file is too small. Unable to convert data.');
//        closefile(lF);
//        exit;
//      end;
//      GetMem(lBuff, lSliceSz);
//      Seek(lF, lOffset);
//      Filemode := 2; // read/write
//      AssignFile(lOutF, lOutImg);
//      if lOutHdrSz = 0 then
//        Rewrite(lOutF)
//      else
//      begin
//        Reset(lOutF);
//        Seek(lOutF, lOutHdrSz);
//      end; // hdrsz
//      for lInc := 1 to lDICOMdata.XYZdim[3] do
//      begin
//        Filemode := 0; // read only
//        BlockRead(lF, lBuff^, lSliceSz);
//        Filemode := 2; // read/write
//        BlockWrite(lOutF, lBuff^, lSliceSz);
//      end; // for each slice
//      closefile(lF);
//      closefile(lOutF);
//    end; // if > 0 slices
//  end; // filenames are unique
//  Filemode := 2; // read/write
end;

procedure TDICOMViewer.Convertto1Click(Sender: TObject);
var
  I, lLen, lTag: integer;
  lHdrOK, lIMgOK, lConv, lConvAny: boolean;
  lDICOMdata: TDICOMdata;
  lFilename { ,lOutHdr,lOutImg } , lDynStr: String;
  lF: file of byte;
begin
//  lTag := (Sender as TMenuItem).tag;
//  lConv := false;
//  lConvAny := false;
//  if OpenDialog.Execute then
//  begin
//    for I := 0 to OpenDialog.Files.Count - 1 do
//    begin
//      if AddMRU(OpenDialog.Files[I]) then
//      begin
//        OpenDialog.InitialDir := extractfiledir(OpenDialog.Files[I]);
//        Filemode := 0;
//        AssignFile(lF, OpenDialog.Files[I]);
//        Reset(lF);
//        lLen := filesize(lF);
//        closefile(lF);
//        Filemode := 2;
//        lFilename := OpenDialog.Files[I];
//        if (lLen = 348) then
//          OpenAnalyze(lHdrOK, lIMgOK, lDynStr, lFilename, lDICOMdata)
//        else
//          read_dicom_data(false, false, true, false, true, true, true,
//            lDICOMdata, lHdrOK, lIMgOK, lDynStr, lFilename);
//        if (not lIMgOK) or (not lHdrOK) then
//          showmessage('Unable to read this image: try using MRIcro.')
//        else if (not lIMgOK) or (not lHdrOK) or (lDICOMdata.RunLengthEncoding)
//          or (lDICOMdata.JPEGlosslessCpt) or (lDICOMdata.JPEGlossyCpt) or
//          (lDICOMdata.GenesisCpt) or (lDICOMdata.GenesisPackHdr <> 0) then
//        begin
//          showmessage
//            ('Unable to convert compressed image data: try using MRIcro.');
//        end
//        else
//        begin
//          if fileexists(lFilename) then
//            lConv := ConvertImg(lFilename, lDICOMdata, lTag);
//          if lConv then
//            lConvAny := true;
//        end;
//      end; // fileexists
//    end;
//  end;
//  ConLabelClick;
//  if lConvAny then
//  begin
//    showmessage('Converted images have been placed in the folder ' +
//      ExtractFilePath(OpenDialog.FileName));
//  end;
end;

procedure TDICOMViewer.seWinCenEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Self.MDIChildCount = 0 then
    exit;
  // if (ssShift in Shift) then StatusBar.Panels[1].text := inttostr(random(1024));
  if Key = 13 then
    btnApplyCon.Click;
end;

procedure TDICOMViewer.ToolButton1Click(Sender: TObject);
begin
  inherited;

  LockWindowUpdate(Self.Handle);

  try
    btnBestFit.Down := False;
    btnBestFitClick(btnBestFit);

    trackZoomSlider.Position := 100;

    seWinWidEdit.Value := Study.ActiveViewer.gDicomData.WindowWidth;
    seWinCenEdit.Value := Study.ActiveViewer.gDicomData.WindowCenter;

    Study.ActiveViewer.DisplayImage(True, True, trackSliceSlider.Position, seWinWidEdit.Value, seWinCenEdit.Value);
    Study.ActiveViewer.OverlayData;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TDICOMViewer.VideoBtnClick(Sender: TObject);
// var lSpeed: integer;
begin
  (* if Self.MDIChildCount > 0 then begin
    lSpeed := Study.ActiveSeries.gvideospeed;
    if lSpeed > 4 then
    lSpeed := 0
    else
    inc(lSpeed);
    Study.ActiveSeries.gMultiRow := 1;
    Study.ActiveSeries.gMultiCol := 1;
    Study.ActiveSeries.gVideoSpeed := lSpeed;
    if lSpeed > 0 then begin
    Study.ActiveSeries.Timer1.Interval := 100 * lSpeed;
    Study.ActiveSeries.Timer1.enabled := true;
    end else
    Study.ActiveSeries.Timer1.enabled := false;
    VideoBtn.Caption := inttostr(lSpeed);
    end; *)
end;

procedure TDICOMViewer.btnVideoBtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  lSpeed: integer;
  ActiveViewer: TSeriesGraphicViewer;
begin
  ActiveViewer := Study.ActiveViewer;

  if Assigned(ActiveViewer) then
    with ActiveViewer do
    begin
      lSpeed := gVideoSpeed;

      try
        case Button of
          mbLeft: begin
                    if lSpeed > 4 then
                      lSpeed := 0
                    else
                      inc(lSpeed);
                  end;

          mbRight: begin
                     if lSpeed < 1 then
                       lSpeed := 5
                     else
                       dec(lSpeed);
                   end;

          mbMiddle: if lSpeed <> 0 then
                      lSpeed := 0;
        end;

        gMultiRow := 1;
        gMultiCol := 1;
        gVideoSpeed := lSpeed;

        case lSpeed of
          0: begin
               TToolButtonHack(btnVideo).Font.Color := clBlack;
               Timer1.enabled := false;
             end;

          else
          begin
            TToolButtonHack(btnVideo).Font.Color := $0000FF80;

            Timer1.Interval := 100 * lSpeed;
            Timer1.enabled := true;
          end;
        end;
      finally
        btnVideo.Caption := lSpeed.ToString;
      end;
    end;
end;

procedure TDICOMViewer.btnZoom100Click(Sender: TObject);
begin
  trackZoomSlider.position := 100;
  ZoomSliderChange(nil);
  Study.ActiveSeries.PositionImage;
end;

{ TStudy }

function TStudy.ActiveViewer: TSeriesGraphicViewer;
begin
  Result := nil;

  for Result in FSeries.Values.ToArray do
    if Result.IsViewerActive  then
      Break;
end;

constructor TStudy.Create(AViewerForm: TDICOMViewer);
begin
  inherited Create(AViewerForm as TComponent);
  FViewerForm := AViewerForm;

  SetLength(FUID, 0);
  FAutoLoad := True;

  FSeries := TObjectDictionary<string, TSeriesGraphicViewer>.Create([doOwnsValues]);
end;

destructor TStudy.Destroy;
begin
  SetLength(FUID, 0);
  FreeAndNil(FSeries);

  inherited;
end;

procedure TStudy.DoSeriesViewerChange(APrevSeries, ANewSeries: TSeriesGraphicViewer);
begin
  if Assigned(FSeriesChangeEvent) then
    FSeriesChangeEvent(APrevSeries, ANewSeries);

  if Assigned(ViewerForm) then
    with ViewerForm do
    begin
      WindowCascadeItem.enabled := Assigned(ActiveSeries);
      WindowTileItem.enabled := Assigned(ActiveSeries);
      WindowArrangeItem.enabled := Assigned(ActiveSeries);
      WindowMinimizeItem.enabled := Assigned(ActiveSeries);
      Print1.enabled := Assigned(ActiveSeries);
      Exportaspicture1.enabled := Assigned(ActiveSeries);
      Close1.enabled := Assigned(ActiveSeries);

      ColUpdate;

      if Assigned(ActiveSeries) and
         grpSeriesDetails.Visible then
        imgSeriesPreview.Picture := ActiveSeries.Image.Picture;
    end;
end;

function TStudy.GetActiveSerie: TSeriesGraphicViewer;
var
  i: Integer;
begin
  Result := nil;

  with ViewerForm do
    for i := 0 to pnlSerieViewerHolder.ControlCount - 1 do
      if (pnlSerieViewerHolder.Controls[i] is TSeriesGraphicViewer) then
      begin
        Result := (pnlSerieViewerHolder.Controls[i] as TSeriesGraphicViewer);
        Break;
      end;
end;

function TStudy.GetActiveSerieIndex: integer;
var
  Serie: TSeriesGraphicViewer;
begin
  for Serie in FSeries.Values.ToArray do
  begin
    if SameText(Serie.gDicomData.SerieUID, GetActiveSerieUID) then
      Break;

    inc(Result);
  end;
end;

function TStudy.GetActiveSerieUID: string;
var
  CurActiveSerie: TSeriesGraphicViewer;
begin
  CurActiveSerie := GetActiveSerie;

  if Assigned(CurActiveSerie) then
    Result := CurActiveSerie.gDicomData.SerieUID;
end;

function TStudy.GetSeries(AIndex: Integer): TSeriesGraphicViewer;
begin
  Result := nil;

  if not Assigned(FSeries) OR
     (FSeries.Count = 0) OR
     not (AIndex >= 0) OR
     not (AIndex < FSeries.Count) then
    Exit;

  Result := FSeries.Values.ToArray[AIndex];
end;

function TStudy.GetSeries(const ASeriesUID: string): TSeriesGraphicViewer;
begin
  Result := nil;

  if ASeriesUID.IsEmpty then
    Exit;

  FSeries.TryGetValue(ASeriesUID, Result);
end;

function TStudy.Load(const APath: string): Boolean;

  function IsDICOM(AFileName: string): Boolean;
  var
    FP: file;
    lDICMcode: integer;
  begin
    Result := false;
    if ('.DCM' = ExtractFileExt(AFileName)) then
      Result := true;

    if ('.DCM' <> ExtractFileExt(AFileName)) then
    begin
      Filemode := 0;
      AssignFile(FP, AFileName);
      try
        Filemode := 0; // read only - might be CD
        System.Reset(FP, 1);

        if FileSize(FP) <= 132 then Exit;

        Seek(FP, 128);

        BlockRead(FP, lDICMcode, 4);

        Result := (lDICMcode = 1296255300);
      finally
        CloseFile(FP);
      end; // try..finally open file
      Filemode := 2; // read/write
    end; // Ext <> DCM
  end;

  procedure ScanForFiles(AFileList: TStringList; const APath: string);
  var
    FileName, Dir: string;
  begin
    for FileName in TDirectory.GetFiles(APath) do
      if IsDICOM(FileName) then
        if not ExtractFileName(FileName).Equals('DICOMDIR') then
          AFileList.Add(FileName);

    for Dir in TDirectory.GetDirectories(APath) do
      ScanForFiles(AFileList, Dir);
  end;
var
  i: integer;

  Mode: TStudyLoadMode;

  FileList: TStringList;
  FileName, lDynStr: string;
  lHdrOK, lImgOK: Boolean;

  lDicomData: TDICOMdata;

  NewChild: TSeriesGraphicViewer;
  CurChild: TSeriesGraphicViewer;

  OD: TOpenDialog;

  ErrorText: string;
begin
  Mode := slmNotSupported;
  Result := False;

  if TFile.Exists(APath) then
    Mode := slmFile
  else
  begin
    if TDirectory.Exists(APath) then
      Mode := slmFolder;
  end;

  case Mode of
    slmNotSupported: begin
                       raise Exception.Create('Study.Load: NOT SUPPORTED or file\directory does not exist');
                       Exit;
                     end;

    slmFile: begin
               LockWindowUpdate(FViewerForm.Handle);

               try
                 NewChild := ViewerForm.CreateMDIChild(APath, false, false, false, false);

                 if Assigned(NewChild) then
                 begin
                   if Self.FUID.Trim.IsEmpty then
                     if not NewChild.gDicomData.StudyUID.IsEmpty then
                       Self.FUID := NewChild.gDicomData.StudyUID
                     else
                       Self.FUID := 'ANONYMIZED';

                   FSeries.Add(NewChild.gDicomData.SerieUID, NewChild);
                 end;

                 ViewerForm.ConLabelClick;

//                 lTag := (Sender as TToolButton).tag;
//
//                 if lTag = 1 then
//                  OpenDialog.Filter := 'Analyze Header (*.hdr)|*.hdr'
//                  { else
//                    OpenDialog.Filter := 'Medical Image|*.*' };
//                 if OpenDialog.Execute then
//                 begin
//                   for I := 0 to OpenDialog.Files.Count - 1 do
//                   begin
//                     if AddMRU(OpenDialog.Files[I]) then
//                     begin
//                       OpenDialog.InitialDir := extractfiledir(OpenDialog.Files[I]);
//                       Filemode := 0;
//                       AssignFile(lF, OpenDialog.Files[I]);
//                       Reset(lF);
//                       lLen := filesize(lF);
//                       closefile(lF);
//                       Filemode := 2;
//                       if lTag = 2 then // ecat
//                          CreateMDIChild(OpenDialog.Files[I], false, true, false, false)
//                       else if (lLen = 348) and (ExtractFileExt(OpenDialog.FileName) = '.hdr')
//                       then
//                         CreateMDIChild(OpenDialog.Files[I], true, false, false, false)
//                       else
//                         CreateMDIChild(OpenDialog.Files[I], false, false, false, false);
//                     end; // fileexists
//                    end;
//                 end;
                // OpenDialog.Filter := 'Medical Image|*.*';
        //         OpenDialog.Filter := 'Medical Image|*.*';
   //              ConLabelClick;
               finally
                 LockWindowUpdate(0);
               end;
             end;

    slmFolder: begin
                 LockWindowUpdate(FViewerForm.Handle);

                 try
                   FInitialDir := APath;

                   FileList := TStringList.Create;
                   ScanForFiles(FileList, APath);

                   ShowProgress(ViewerForm, FileList.Count.ToString + ' files found', 0, FileList.Count+1);

                   try
                     for i := 0 to FileList.Count - 1 do
                     begin
                       Progress.StepIt(Format('Processing [%s]', [ExtractFileName(FileList[i])]),
                                       Format('%d/%d', [i, FileList.Count]));

                       FileName := FileList[i];

                       lDicomData := TDICOMData.Create;
                       ReadDicomData(FileName, lDicomData);
                       //read_dicom_data( false, false, true, true,
                       //                 true, true, false, lDicomData, lHdrOK, lImgOK, lDynStr, FileName);

                       if not Self.FSeries.ContainsKey(lDicomData.SerieUID) and
                          ((FUID.IsEmpty) OR (SameText(lDicomData.StudyUID, FUID))) then
                       begin
                         NewChild := ViewerForm.CreateMDIChild(FileName, false, false, false, false, lDicomData);

                         if Assigned(NewChild) then
                         begin
                           if Self.FUID.Trim.IsEmpty then
                             if not NewChild.gDicomData.StudyUID.IsEmpty then
                               Self.FUID := NewChild.gDicomData.StudyUID
                             else
                               Self.FUID := 'ANONYMIZED';

                           FSeries.Add(NewChild.gDicomData.SerieUID, NewChild);
                         end;
                       end
                       else
                       if Self.FSeries.ContainsKey(lDicomData.SerieUID) then
                         Self.FSeries.Items[lDicomData.SerieUID].gStringList.AddObject(FileName, lDicomData);
                     end;

                     for CurChild in Self.FSeries.Values.ToArray do
                       CurChild.LoadFileList;
                   finally
                     FreeAndNil(FileList);
                     FreeAndNil(Progress);
                   end;
                 finally
                   FViewerForm.pnlSerieViewerHolder.Caption := '';
                   LockWindowUpdate(0);
                 end;
               end;
    else
    begin
      raise Exception.Create('Error Message');
      Exit;
    end;
  end;

  PrepareStudyUI;
  LoadInfo;
end;

procedure TStudy.LoadInfo;
var
  CurSerie: TSeriesGraphicViewer;

  StudyInfo,
  SeriesInfo,
  PatientInfo: TStringList;

  ValueIndex: integer;
begin
  CurSerie := ActiveSeries;

  if not Assigned(FViewerForm) or
     not Assigned(CurSerie) then
    Exit;

  StudyInfo := TStringList.Create;
  SeriesInfo := TStringList.Create;
  PatientInfo := TStringList.Create;

  with Self.ActiveSeries.gDicomData do
  begin
    if not StudyDate.IsEmpty then
      StudyInfo.Add('Date=' + DICOMDateToDate(StudyDate));
    if not StudyTime.IsEmpty then
      StudyInfo.Add('Time=' + DICOMTimeToTime(StudyTime));
    if not StudyID.IsEmpty then
      StudyInfo.Add('ID=' + StudyID);
    if not Modality.IsEmpty then
      StudyInfo.Add('Modality=' + modality);
    if not StudyDescription.IsEmpty then
      StudyInfo.Add('Description=' + StudyDescription);
    if not InstitutionName.IsEmpty then
      StudyInfo.Add('Institution Name=' + InstitutionName);
    if not PhysicianName.IsEmpty then
      StudyInfo.Add('Physician''s Name=' + PhysicianName);
  end;

  FViewerForm.lstStudyDetails.Strings.Text := StudyInfo.Text;

  with Self.ActiveSeries.gDicomData do
  begin
    if not PatientName.IsEmpty then
      PatientInfo.Add('Name=' + PatientName);
    if not PatientID.IsEmpty then
      PatientInfo.Add('ID=' + PatientID);
    if not PatientBirthDate.IsEmpty then
      PatientInfo.Add('Birth date=' + DICOMDateToDate(PatientBirthDate));
    if not PatientAge.IsEmpty then
      PatientInfo.Add('Age=' + PatientAge);
    if not PatientSex.IsEmpty then
      PatientInfo.Add('Sex=' + PatientSex);
  end;

  FViewerForm.lstPatientInfo.Strings.Text := PatientInfo.Text;

  FreeAndNil(StudyInfo);
  FreeAndNil(SeriesInfo);
  FreeAndNil(PatientInfo);
end;

procedure TStudy.PrepareStudyUI;

const
  StudyHeaderText = 'STUDY';
  SeriesHeaderText = 'SERIES';
  PatientHeaderText = 'PATIENT';

  procedure FillSeriesComboList;
  var
    CurSerie: TSeriesGraphicViewer;
  begin
    CurSerie := ActiveSeries;

    if not Assigned(FViewerForm) or
       not Assigned(CurSerie) then
      Exit;

    with FViewerForm do
    begin
      TCategoryPanelHack(grpStudyDetails).Caption := StudyHeaderText + ': ' + CurSerie.gDicomData.modality + ' (' + CurSerie.gDicomData.StudyDate.Insert(6, '-').Insert(4, '-') + ')';
      TCategoryPanelHack(grpStudyDetails).Canvas.Font.Color := clBlack;
      TCategoryPanelHack(grpStudyDetails).Canvas.Font.Size := 10;
      TCategoryPanelHack(grpStudyDetails).Canvas.Font.Style := [fsBold];

      pnlDetails.Width := TCategoryPanelHack(grpStudyDetails).Canvas.TextWidth(grpStudyDetails.Caption) * 2;

      cbbSeriesList.Clear;

      for CurSerie in FSeries.Values.ToArray do
        cbbSeriesList.AddItem(CurSerie.gDicomData.SeriesDescription, CurSerie);
    end;
  end;

begin
  if not Assigned(ViewerForm) then
    Exit;

  with ViewerForm do
  begin
    //grpStudyDetails.Visible := not (FSeries.Count = 0);
    grpSeriesDetails.Visible := not (FSeries.Count = 0);
    //grpPatientDetails.Visible := not (FSeries.Count = 0);
    cbbSeriesList.Enabled := not (FSeries.Count = 0);

    if (FSeries.Count = 0) then
    begin
      cbbSeriesList.Clear;
      grpSeriesDetails.Caption := SeriesHeaderText;
    end
    else
    if (FSeries.Count > 0) then
    begin
      ActiveSeriesIndex := 0;

      grpSeriesDetails.Caption := Format(SeriesHeaderText + ' (%d)', [FSeries.Count]);
      FillSeriesComboList;
      cbbSeriesList.ItemIndex := 0;

      if (cbbSeriesList.Items.Objects[cbbSeriesList.ItemIndex] as TSeriesGraphicViewer).gDicomData.SerieUID.IsEmpty then
        Study.ActiveSeriesIndex := 0
      else
        Study.ActiveSeriesUID := (cbbSeriesList.Items.Objects[cbbSeriesList.ItemIndex] as TSeriesGraphicViewer).gDicomData.SerieUID;
    end;
  end;
end;

procedure TStudy.Reset;
begin
  LockWindowUpdate(ViewerForm.Handle);

  try
    SetLength(FUID, 0);
    FSeries.Clear;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TStudy.SetActiveSerie(const AValue: TSeriesGraphicViewer);
var
  CurActiveSeries: TSeriesGraphicViewer;
begin
  LockWindowUpdate(ViewerForm.Handle);

  try
    CurActiveSeries := GetActiveSerie;

    if Assigned(CurActiveSeries) then
      if not Assigned(AValue) or
         not SameText(CurActiveSeries.gDicomData.SerieUID, AValue.gDicomData.SerieUID) then
      begin
        CurActiveSeries.Parent := ViewerForm;
        CurActiveSeries.SendToBack;
      end;

    if Assigned(AValue) then
    begin
      AValue.Parent := FViewerForm.pnlSerieViewerHolder;
    end;
  finally
    DoSeriesViewerChange(CurActiveSeries, AValue);

    LockWindowUpdate(0);
  end;
end;

procedure TStudy.SetActiveSerieIndex(AValue: integer);
begin
  SetActiveSerie(GetSeries(AValue));
end;

procedure TStudy.SetActiveSerieUID(const AValue: string);
var
  SerieForm: TSeriesGraphicViewer;
begin
  SetActiveSerie(GetSeries(AValue));
end;

end.
