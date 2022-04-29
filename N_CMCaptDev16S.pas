unit N_CMCaptDev16S;
// CSH ( Kodak ) device interface

// 2014.05.16 Created by Valery Ovechkin
// 2014.08.22 Fixes and Standartization by Valery Ovechkin
// 2014.09.01 Filter name substitution fixed by Valery Ovechkin
// 2014.09.15 Fixed File exceptions processing ( like i/o 32, etc. ) by Valery Ovechkin
// 2014.09.15 Standartizing ( All functions parameters name starts from 'A' ) by Valery Ovechkin
// 2015.05.14 Change parameters K_CMSlideCreateFromDeviceDIBObj and K_CMSlideReplaceByDeviceDIBObj by Alex Kovalev
// 2018.04.15 HideFiltersFlag for 'IO' type sesor
// 2018.11.07 CDSGetDefaultDevIconInd function added
// 2019.05.28 dll updates, async information is used now

interface
uses
  Windows, Classes, Forms, Graphics, StdCtrls, ExtCtrls, Controls,
  K_CM0, K_CMCaptDevReg,
  N_Types, N_CMCaptDev0, N_CMCaptDev16SF, N_CMCaptDev16aF, N_CompBase;

const MAX_FILTER_LENGTH = 20; // Maximum filter name length

// Filter captions substitution
type TCSHFilterSubst = record
  OldName, NewName: String;
end;

type TCSHFilterSubsts = Array of TCSHFilterSubst;

// Sensor types
type TCSHSensorType = (
  stIO,
  stPANO,
  stCEPH,
  stVL,
  stOther
);

// Device Line
type TN_CMV_CSHDeviceLine = record
  id:               String;
  name:             String;
  SerialNumber:     String;
  Async:            Boolean;
  SensorTypes:      Array of String;
  DisplayModeName:  String;
  DisplayModeValue: String;
end;

// Device info
type TN_CMV_CSHDevice = record
  id: String;
  Lines: Array of TN_CMV_CSHDeviceLine;
end;

type TN_CMV_CSHDevices = Array of TN_CMV_CSHDevice; // Array of devices

type TN_CMV_CSHAlg = record // Algorithm
  id, name:  String;
  en, dg:    Boolean;
  v, mn, mx: Integer;
  ch: TCheckBox;
  cm: TComboBox;
end;

type TN_CMV_CSHFilter = record // Filter
  id, name: String;
  lb: TLabel;
  algs: Array of TN_CMV_CSHAlg;
end;

type TN_CMV_CSHFilters = Array of TN_CMV_CSHFilter; // Array of filters

type TN_CMV_CSHFilterParam = record // Filter parameters
  en, dg, st, al, v: Integer;
end;

type TN_CMV_CSHFilterParams = Array of TN_CMV_CSHFilterParam;

type TN_CMCDServObj16 = class( TK_CMCDServObj )
  CDSDllHandle, CDSDllHandle2: THandle;             // DLL Windows Handle
  Devices:                     TN_CMV_CSHDevices;   // Devices Array
  CurrentDevice, CurrentLine:  Integer;             // Current Device
  PProfile:                    TK_PCMDeviceProfile; // CMS Profile Pointer
  PSlideArr:                   TN_PUDCMSArray;      // Pointer to slides array
  Handle2D:                    Pointer;             // Processing2D handle
  FilterPanel:                 TPanel;              // Filter panel
  CSHFilters:                  TN_CMV_CSHFilters;   // Filters
  FilterSubsts:                TCSHFilterSubsts;    // Filters substitutions

  Acquisition_ext:           TN_CMV_cdeclPtrFuncPtr;
  AcquisitionDllInit_ext:    TN_cdeclIntFuncPAChar;
  AcquisitionDllRelease_ext: TN_cdeclIntFuncPAChar;
  AcquisitionInfo_ext:       TN_CMV_cdeclPACharPPACharFuncInt;
  AcquisitionXMLCreate_ext:  TN_cdeclPtrFuncVoid;
  AcquisitionXMLDestroy_ext: TN_CMV_cdeclProcPtr;
  AcquisitionXMLGet_ext:     TN_CMV_cdeclPACharFuncPtr;
  AcquisitionXMLSet_ext:     TN_CMV_cdeclProcPtrPAChar;

  XMLHandleRequest, XMLHandleResponse: Pointer;

  ImageProcessor2DCreate_ext:        function (): Pointer;cdecl;
  ImageProcessor2DDestroy_ext:       procedure( APtr: Pointer );cdecl;
  ImageProcessor2DGetState_ext:      function( APtr: Pointer ): PAnsiChar;cdecl;
  ImageProcessor2DLoadImage_ext:     function( APtr: Pointer; APAChar: PAnsiChar ): Boolean;cdecl;
  ImageProcessor2DSaveImage_ext:     function( APtr: Pointer; APAChar: PAnsiChar ): Boolean;cdecl;
  ImageProcessor2DGetFloatValue_ext: function( APtr: Pointer; APAChar: PAnsiChar; APDouble: PDouble ): Boolean;cdecl;
  ImageProcessor2DGetProcessedHBITMAP_ext: function( APtr: Pointer ): Pointer;cdecl;
  ImageProcessor2DGetOriginalHBITMAP_ext:  function( APtr: Pointer ): Pointer;cdecl;
  ImageProcessor2DEnableAlgo_ext:          function( APtr: Pointer; AStepId: Integer; AAlgId: Integer; AEnable: Integer ): Boolean;cdecl;
  ImageProcessor2DSetAlgoParameter_ext:    function( APtr: Pointer; AStepId: Integer; AAlgId: Integer; ANumber: Integer ): Boolean;cdecl;


  BufSlidesArray: TN_UDCMSArray;
  HideFiltersFlag : Boolean;

  function  SubstFilter             ( AOldFilterName: String ): String;
  procedure ShowUpdatedImage        ();
  procedure FillCSHFilter           ( ADicomFile: String );
  procedure CSHFilterApply          ( Sender: TObject );
  function  IsGoodDevice            ( ADevPos, ALinePos: Integer ): Boolean;
  function  GetSensorType           ( ADevStr: String ): TCSHSensorType;
  function  GetSensorSType          ( ADevStr: String ): string;
  function  CMOFCaptureSlide        ( AAdd: Boolean; APDevProfile: TK_PCMDeviceProfile; AFrm: TN_CMCaptDev16Form; AFilePath: AnsiString ): Integer;
  function  CaptureById             ( APDevProfile: TK_PCMDeviceProfile; AFrm: TN_CMCaptDev16Form; ADevNum, ALineNum: Integer ): Integer;
  procedure FillDevPos              ( ADevStr: String; out ADevPos: Integer; out ALinePos: Integer );
  procedure CDSInitAll              ();
  procedure CDSFreeAll              ();
  function  CDSGetGroupDevNames     ( AGroupDevNames: TStrings ): Integer; override;
  function  CDSGetDevProfileCaption ( ADevName: string ): string; override;
  function  CDSGetDevCaption        ( ADevName: string ): string; override;
  procedure CDSCaptureImages        ( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg          ( APDevProfile: TK_PCMDeviceProfile ); override;
  function  CDSStartCaptureToStudy  ( APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState; override;

  destructor  Destroy; override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;

private
  function  FCapturePrepare( APDevProfile: TK_PCMDeviceProfile; ACaptToStudyMode : Boolean ) : string;
  procedure FCaptureAutoStart();
  procedure FCaptureDisable();
  procedure FCaptureEnable();

end; // end of type TN_CMCDServObj16 = class( TK_CMCDServObj )

var
  N_CMCDServObj16: TN_CMCDServObj16;
  DicomFileName:   String;

const
    // IO_Xray Usb devices
  N_E2V_XRAY_FLAGS_SENSOR_IO_900 = $0001;
  N_E2V_XRAY_FLAGS_SENSOR_IO_750 = $0002;
  N_E2V_XRAY_FLAGS_SENSOR_IO_600 = $0004;
  N_E2V_XRAY_FLAGS_ALL_SENSORS   = $00FF;
  N_E2V_XRAY_FLAGS_FREE_DEVICES  = $0100;
  N_E2V_XRAY_FLAGS_USED_DEVICES  = $0200;
  N_E2V_XRAY_FLAGS_ALL_DEVICES   = $0F00;

  N_E2V_MAX_DEVICE_NAME = 260;


implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, StrUtils;

var
  CaptForm: TN_CMCaptDev16Form;  // Capture form


//*************************************************************** LogFilter ***
// Log filters attributes to special file ( own for each device )
//
//    Parameters
// AXMLResp - XML Response
//
procedure LogFilter( AXMLResp: String );
var
  i, j, l, n: Integer;
  fn, ens, dgs: String;
  tf: TextFile;
begin
  fn := N_CMV_GetLogDir() + 'csh_filter' + N_CMCDServObj16.PProfile.CMDPProductName + '.txt';
  AssignFile( tf, fn );
  ReWrite( tf );
  WriteLn( tf, 'XML:' );
  WriteLn( tf, AXMLResp );
  WriteLn( tf, '' );
  WriteLn( tf, 'Filters:' );
  l := length( N_CMCDServObj16.CSHFilters );
  WriteLn( tf, 'Steps Count = ' + IntToStr( l ) );

  for i := 0 to l - 1 do // for each step
  begin
    n := length( N_CMCDServObj16.CSHFilters[i].algs );
    WriteLn( tf, '  Step[' + IntToStr( i ) + ']: id = ' +
                    N_CMCDServObj16.CSHFilters[i].id +
                    '; name = ' + N_CMCDServObj16.CSHFilters[i].name +
                    '; Algo Count = ' + IntToStr( n ) );

    for j := 0 to n - 1 do // for each algorithm in the step
    begin
      ens := '-';
      dgs := '-';

      if N_CMCDServObj16.CSHFilters[i].algs[j].en then
        ens := '+';

      if N_CMCDServObj16.CSHFilters[i].algs[j].dg then
        dgs := '+';

      WriteLn( tf, '    Algo[' + IntToStr( j ) + ']: id = ' +
                   N_CMCDServObj16.CSHFilters[i].algs[j].id +
                   '; name = '  + N_CMCDServObj16.CSHFilters[i].algs[j].name +
                   '; en = '    + ens + '; dg = ' + dgs +
                   '; value = ' + IntToStr( N_CMCDServObj16.CSHFilters[i].algs[j].v ) +
                   '; min = '   + IntToStr( N_CMCDServObj16.CSHFilters[i].algs[j].mn ) +
                   '; max = '   + IntToStr( N_CMCDServObj16.CSHFilters[i].algs[j].mx ) );
    end; // for j := 0 to n - 1 do // for each algorithm in the step

  end; // for i := 0 to l - 1 do // for each step

  CloseFile( tf );
end; // procedure LogFilter

//************************************************************** LogFilter2 ***
// Log filters attributes to special file ( own for each device )
//
//    Parameters
// AXMLResp - XML Response
//
procedure LogFilter2( AXMLResp: String );
var
  i, j, l, n: Integer;
  fn: String;
  tf: TextFile;
begin
  fn := N_CMV_GetLogDir() + 'csh_filters.txt';
  AssignFile( tf, fn );

  if FileExists( fn ) then
  begin

    try
      Append( tf );
    except on e: Exception do
    begin
      N_CMV_ShowCriticalError( 'CSH', 'Log file "csh_filters.txt" can not be appended' );
      Exit;
    end;
    end;

  end
  else
  begin

    try
      ReWrite( tf );
    except on e: Exception do
    begin
      N_CMV_ShowCriticalError( 'CSH', 'Log file "csh_filters.txt" can not be rewritten' );
      Exit;
    end;
    end;
  end; // if FileExists( fn ) then

  WriteLn( tf, 'Device = ' + N_CMCDServObj16.PProfile.CMDPProductName );
  l := length( N_CMCDServObj16.CSHFilters );

  for i := 0 to l - 1 do // for each step
  begin
    n := length( N_CMCDServObj16.CSHFilters[i].algs );
    WriteLn( tf, '  ' + N_CMCDServObj16.CSHFilters[i].name +
                 ' ( '+ N_CMCDServObj16.CSHFilters[i].id + ' )' );

    for j := 0 to n - 1 do // for each algorithm in the step
    begin
      WriteLn( tf, '    ' + N_CMCDServObj16.CSHFilters[i].algs[j].name +
                     ' ( '+ N_CMCDServObj16.CSHFilters[i].algs[j].id + ' )' );
    end; // for j := 0 to n - 1 do // for each algorithm in the step

  end; // for i := 0 to l - 1 do // for each step

  CloseFile( tf );
end; // procedure LogFilter2

//***************************************************** CSHFilterApplyEvent ***
// Event handler for filters controls ( CheckBoxes and ComboBoxes )
//
//    Parameters
// Sender   - Sender object
//
procedure CSHFilterApplyEvent( Sender: TObject );
begin
  N_CMCDServObj16.CSHFilterApply( Sender );
end; // procedure CSHFilterApplyEvent

//**************************************** TN_CMCDServObj16 **********

//******************************************** TN_CMCDServObj16.SubstFilter ***
// Substitute filter names by special names array and crop other
//
//    Parameters
// OldFilterName - filter name wanted to substitutes
// Result        - Corrected filter name
//
function TN_CMCDServObj16.SubstFilter( AOldFilterName: String ): String;
var
  i, c: Integer;
  u: String;
begin
  Result := AOldFilterName;
  u := UpperCase( AOldFilterName );
  c := Length( FilterSubsts );

  for i := 0 to c - 1 do
    if ( u = UpperCase( FilterSubsts[i].OldName ) ) then // filter name found
      Result := FilterSubsts[i].NewName; // Substitute the filter name

  if ( MAX_FILTER_LENGTH < Length( Result ) ) then  // filter name too long
    Result := Copy( Result, 1, MAX_FILTER_LENGTH ); // crop filter name

end; // function TN_CMCDServObj16.SubstFilter

//*************************************** TN_CMCDServObj16.ShowUpdatedImage ***
// Show images in the Capture form and their icons
//
procedure TN_CMCDServObj16.ShowUpdatedImage();
var
  fn:  String;
  fna: AnsiString;
  hb:  HBITMAP;
  bm:  TBitmap;
begin
  fn  := N_CMV_GetWrkDir() + 'cshproc.bmp'; // BMP file name
  fna := N_StringToAnsi( fn );              // Ansi BMP file name
  // Get Bitmap from Processing2D
  hb := HBITMAP( N_CMCDServObj16.ImageProcessor2DGetProcessedHBITMAP_ext( Handle2D ) );
  bm := TBitmap.Create();
  bm.Handle := hb;
  bm.SaveToFile( fn ); // save Bitmap to the file specified above
  bm.Free;             // Close Bitmap handle
//  CMOFCaptureSlide( False, N_CMCDServObj16.PProfile, CaptForm,
//                    N_StringToAnsi( N_CMV_GetWrkDir() + 'cshproc.bmp' ) );
  CMOFCaptureSlide( False, PProfile, CaptForm,
                    N_StringToAnsi( N_CMV_GetWrkDir() + 'cshproc.bmp' ) );
end; // procedure TN_CMCDServObj16.ShowUpdatedImage

//****************************************** TN_CMCDServObj16.FillCSHFilter ***
// Fill Filters array from Dicom file
//
//    Parameters
// ADicomFile - Dicom file for current image
//
procedure TN_CMCDServObj16.FillCSHFilter( ADicomFile: String );
var
  XMLRespAnsi, DicomAnsi: AnsiString;
  XMLRespStr: String;
  i, j, k, StepCount, AlgCount, mn, mx, ArrSz, StrSz, StrPs, ProfSz: Integer;
  st, al, en, dg, v, ProfPos, cnt: Integer;
  XMLDoc: TN_CMV_XML;
  Req,  Req2:  TN_CMV_XMLRequest;
  Resp, Resp2: TN_CMV_XMLResponse;
  s: String;
  arr: Array of Integer;
  GoodStep: Boolean;
  FilterParams: TN_CMV_CSHFilterParams;
begin
  s := PProfile.CMDPStrPar1;
  StrSz := Length( s );
  ArrSz := 0;
  SetLength( arr, ArrSz );
  ProfSz := 0;
  SetLength( FilterParams, 0 );

  if ( 1 < StrSz ) then
  begin
    Dec( StrSz );
    s := Copy( s, 2, StrSz );
    StrPs := Pos( ';', s );

    while ( 0 < StrPs ) do
    begin
      Inc( ArrSz );
      SetLength( arr, ArrSz );
      arr[ArrSz - 1] := StrToIntDef( Copy( s, 1, StrPs - 1 ), 0 );
      StrSz := StrSz - StrPs;
      s := Copy( s, StrPs + 1, StrSz );
      StrPs := Pos( ';', s );
    end; // while ( 0 < StrPs ) do

    if ( 0 <> ( ArrSz mod 5 ) ) then
    begin
      N_CMV_ShowCriticalError( 'CSH', '0 <> ( ArrSz mod 5 )' );
      Exit;
    end; // if ( 0 <> ( ArrSz mod 5 ) ) then

    ProfSz := ArrSz div 5;
    SetLength( FilterParams, ProfSz );

    for i := 0 to ProfSz - 1 do // for each filter from Profile
    begin
      st := arr[(5 * i) + 0];
      al := arr[(5 * i) + 1];
      en := arr[(5 * i) + 2];
      dg := arr[(5 * i) + 3];
      v  := arr[(5 * i) + 4];

      FilterParams[i].st := st;
      FilterParams[i].al := al;
      FilterParams[i].en := en;
      FilterParams[i].dg := dg;
      FilterParams[i].v  := v;

      if not N_CMCDServObj16.ImageProcessor2DEnableAlgo_ext( Handle2D, st, al, en ) then
        N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

      if ( ( 1 = en ) and ( 1 = dg ) ) then
        if not N_CMCDServObj16.ImageProcessor2DSetAlgoParameter_ext( Handle2D, st, al, v ) then
          N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DSetAlgoParameter_ext error' );

    end; // for i := 0 to ProfSz - 1 do // for each filter from Profile

  end; // if ( 1 < StrSz ) then

  if ( nil <> FilterPanel ) then // clear filter panel
  begin
    //FilterPanel.Free;
    //sFilterPanel.Destroy;
    FilterPanel := nil;
  end; // if ( nil <> FilterPanel ) then // clear filter panel

  cnt := 0;
//  FilterPanel := TPanel.Create( nil );
  FilterPanel := TPanel.Create( CaptForm );
  FilterPanel.Parent := CaptForm.pnFilter;
  FilterPanel.Left   := 0;
  FilterPanel.Top    := 0;
  FilterPanel.Width  := 600;
  FilterPanel.Height := CaptForm.pnFilter.Height;
  StepCount          := 0;
  SetLength( CSHFilters, StepCount );
  DicomAnsi   := N_StringToAnsi( ADicomFile );
  XMLRespAnsi := ImageProcessor2DGetState_ext( Handle2D );
  XMLRespStr  := N_AnsiToString( XMLRespAnsi );
  XMLDoc      := N_CMV_XMLDocLoad( XMLRespStr, False );

  if ( nil = XMLDoc ) then
  begin
    N_Dump1Str( 'CSH >> XMLDoc = nil ( GetState )' );
    Exit;
  end; // if ( nil = XMLDoc ) then

  Req.tag := 'Step';
  SetLength( Req.path, 2 );
  Req.path[0].name := 'trophy';
  Req.path[0].position := 0;
  Req.path[1].name := 'Steps';
  Req.path[1].position := 0;

  if not N_CMV_XMLDocToResult( XMLDoc, Req, Resp ) then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'not d2res for steps' );
    Exit;
  end; // if not N_CMV_XMLDocToResult( XMLDoc, Req, Resp ) then

  StepCount := Length( Resp );
  SetLength( CSHFilters, StepCount );

  for i := 0 to StepCount - 1 do // for each step
  begin
    CSHFilters[i].id   := N_CMV_XMLGet( i, 'id',   Resp );
    CSHFilters[i].name := N_CMV_XMLGet( i, 'name', Resp );
    GoodStep := ( ( '1' = CSHFilters[i].id ) or ( '2' = CSHFilters[i].id ) );
    AlgCount := 0;
    SetLength( CSHFilters[i].algs, AlgCount );
    Req2.tag := 'Algo';
    SetLength( Req2.path, 3 );
    Req2.path[0].name := 'trophy';
    Req2.path[0].position := 0;
    Req2.path[1].name := 'Steps';
    Req2.path[1].position := 0;
    Req2.path[2].name := 'Step';
    Req2.path[2].position := i;

    if not N_CMV_XMLDocToResult( XMLDoc, Req2, Resp2 ) then
    begin
      N_CMV_ShowCriticalError( 'CSH', 'not d2res for algo' );
      Exit;
    end; // if not N_CMV_XMLDocToResult( XMLDoc, Req2, Resp2 ) then

    AlgCount := Length( Resp2 );
    SetLength( CSHFilters[i].algs, AlgCount );

    for j := 0 to AlgCount - 1 do // for each algorithm
    begin
      CSHFilters[i].algs[j].id   := N_CMV_XMLGet( j, 'id', Resp2 );
      ProfPos := -1;
      CSHFilters[i].algs[j].name := N_CMV_XMLGet( j, 'name', Resp2 );
      CSHFilters[i].algs[j].en   := ( 'TRUE' = UpperCase( N_CMV_XMLGet( j, 'enabled', Resp2 ) ) );
      CSHFilters[i].algs[j].v    := StrToIntDef( N_CMV_XMLGet( j, 'value',    Resp2 ), 0 );
      CSHFilters[i].algs[j].mn   := StrToIntDef( N_CMV_XMLGet( j, 'minvalue', Resp2 ), 0 );
      CSHFilters[i].algs[j].mx   := StrToIntDef( N_CMV_XMLGet( j, 'maxvalue', Resp2 ), 0 );
      CSHFilters[i].algs[j].dg   := ( CSHFilters[i].algs[j].mn < CSHFilters[i].algs[j].mx );
      CSHFilters[i].algs[j].ch   := nil;
      CSHFilters[i].algs[j].cm   := nil;

      for k := 0 to ProfSz - 1 do
        if ( ( StrToIntDef( CSHFilters[i].id, 0 ) = FilterParams[k].st ) and
             ( StrToIntDef( CSHFilters[i].algs[j].id, 0 ) = FilterParams[k].al ) ) then
          ProfPos := k;

      if ( 0 <= ProfPos ) then
      begin
        CSHFilters[i].algs[j].en := ( 1 = FilterParams[ProfPos].en );
        CSHFilters[i].algs[j].dg := ( 1 = FilterParams[ProfPos].dg );
        CSHFilters[i].algs[j].v  :=       FilterParams[ProfPos].v;
      end; // if ( 0 <= ProfPos ) then

      if GoodStep then // visible filter ( showed on capture form )
      begin
        Inc( cnt );
      end; // if GoodStep then // visible filter ( showed on capture form )

//      CSHFilters[i].algs[j].ch          := TCheckBox.Create( nil );
      CSHFilters[i].algs[j].ch          := TCheckBox.Create( CaptForm );
      CSHFilters[i].algs[j].ch.Parent   := FilterPanel; //FormFilter.Panel;
      CSHFilters[i].algs[j].ch.Left     := ( cnt * 145 ) - 140;
      CSHFilters[i].algs[j].ch.Top      := 10;
      CSHFilters[i].algs[j].ch.Width    := 140;
      CSHFilters[i].algs[j].ch.Caption  := SubstFilter( CSHFilters[i].algs[j].name );
      CSHFilters[i].algs[j].ch.Checked  := CSHFilters[i].algs[j].en;
      @CSHFilters[i].algs[j].ch.OnClick := @CSHFilterApplyEvent;
      CSHFilters[i].algs[j].ch.Visible  := GoodStep;

      if CSHFilters[i].algs[j].dg then // digital
      begin
//        CSHFilters[i].algs[j].cm         := TComboBox.Create( nil );
        CSHFilters[i].algs[j].cm         := TComboBox.Create( CaptForm );
        CSHFilters[i].algs[j].cm.Parent  := FilterPanel; //FormFilter.Panel;
        CSHFilters[i].algs[j].cm.Left    := ( cnt * 145 ) - 140;
        CSHFilters[i].algs[j].cm.Top     := 35;
        CSHFilters[i].algs[j].cm.Width   := 60;
        CSHFilters[i].algs[j].cm.Enabled := CSHFilters[i].algs[j].en;

        CSHFilters[i].algs[j].cm.Clear;
        mn := CSHFilters[i].algs[j].mn;
        mx := CSHFilters[i].algs[j].mx;

        for k := mn to mx do
          CSHFilters[i].algs[j].cm.Items.Add( IntToStr( k ) );

        CSHFilters[i].algs[j].cm.ItemIndex := CSHFilters[i].algs[j].v - mn;
        @CSHFilters[i].algs[j].cm.OnChange := @CSHFilterApplyEvent;
        CSHFilters[i].algs[j].cm.Visible   := GoodStep;
      end; // if CSHFilters[i].algs[j].dg then // digital

    end; // for j := 0 to AlgCount - 1 do // for each algorithm

  end; // for i := 0 to StepCount - 1 do // for each step

  LogFilter( XMLRespStr );  // Special log for current device
  LogFilter2( XMLRespStr ); // Common CSH log
  //ImageProcessor2DDestroy_ext( Handle2D );

end; // procedure TN_CMCDServObj16.FillCSHFilter

//***************************************** TN_CMCDServObj16.CSHFilterApply ***
// Apply CSH Filters to the last captured image
//
//    Parameters
// Sender   - Sender object
//
procedure TN_CMCDServObj16.CSHFilterApply( Sender: TObject );
var
  i, j, l, n, v, en, dg, st, al: Integer;
  s:  String;
begin
  l := length( N_CMCDServObj16.CSHFilters ); // count filters
  s := PProfile.CMDPStrPar1;                 // Profile string

  if ( 1 <> Length( s ) ) then
    s := '0'; // default value

  for i := 0 to l - 1 do // for each filter
  begin
    n := length( CSHFilters[i].algs );

    for j := 0 to n - 1 do // for each algorithm
    begin
      CSHFilters[i].algs[j].en := CSHFilters[i].algs[j].ch.Checked;

      if CSHFilters[i].algs[j].dg then // digital value ( ComboBox )
      begin
        CSHFilters[i].algs[j].cm.Enabled := CSHFilters[i].algs[j].en;
        v := CSHFilters[i].algs[j].cm.ItemIndex;

        if ( 0 <= v ) then
          CSHFilters[i].algs[j].v := CSHFilters[i].algs[j].mn + v;

      end; // if CSHFilters[i].algs[j].dg then // digital value ( ComboBox )

      en := 0;
      dg := 0;

      if CSHFilters[i].algs[j].en then // enable
        en := 1;

      if CSHFilters[i].algs[j].dg then // digital
        dg := 1;

      st := StrToIntDef( CSHFilters[i].id, 0 );
      al := StrToIntDef( CSHFilters[i].algs[j].id, 0 );
      v  := CSHFilters[i].algs[j].v;

      // enable or disable the filter
      if not N_CMCDServObj16.ImageProcessor2DEnableAlgo_ext( Handle2D, st, al, en ) then
        N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

      // set digital value for the filter if needed
      if CSHFilters[i].algs[j].en and CSHFilters[i].algs[j].dg then
        if not N_CMCDServObj16.ImageProcessor2DSetAlgoParameter_ext( Handle2D, st, al, v ) then
          N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DSetAlgoParameter_ext error' );

      s := s + IntToStr( st ) + ';' + IntToStr( al ) + ';' + IntToStr( en ) + ';' +
               IntToStr( dg ) + ';' + IntToStr( v )  + ';';

    end; // for j := 0 to n - 1 do // for each algorithm

  end; // for i := 0 to l - 1 do // for each filter

  ShowUpdatedImage();        // Show updated last captured image and icon
  PProfile.CMDPStrPar1 := s; // save new filters state into the Profile string
  N_Dump1Str( 'CSH >> Profile = ' + s );
end; // procedure TN_CMCDServObj16.CSHFilterApply

//******************************************* TN_CMCDServObj16.IsGoodDevice ***
// Check is the device is visible for users
//
//    Parameters
// ADevPos  - Device position
// ALinePos - Device Line position
// Result   - True if it is visible device
//
function TN_CMCDServObj16.IsGoodDevice( ADevPos, ALinePos: Integer ): Boolean;
begin
  Result := False;

  if ( ( 0 > ADevPos ) or ( 0 > ALinePos ) ) then // wrong device or line number
    Exit;

  Result := ( N_MemIniToBool( 'CMS_UserDeb', 'TrophySimulator', False ) or
              ( ( 1 > Pos( 'ImgFiles', Devices[ADevPos].Lines[ALinePos].name ) ) and
                ( 1 > Pos( 'FMS GUI', Devices[ADevPos].Lines[ALinePos].DisplayModeName ) )
              ) );

end; // function TN_CMCDServObj16.IsGoodDevice

//****************************************** TN_CMCDServObj16.GetSensorType ***
// Define sensor type by it's string
//
//    Parameters
// ADevStr - Device string
// Result  - Sensor type
//
function TN_CMCDServObj16.GetSensorType( ADevStr: String ): TCSHSensorType;
var
  DevPos, LinePos: Integer;
  t: String;
begin
  Result := stOther; // Unknown sensor type
  FillDevPos( ADevStr, DevPos, LinePos );

  if ( ( 0 > DevPos ) or ( 0 > LinePos ) ) then // wrong device or line number
    Exit;

  if ( 1 > Length( Devices[DevPos].Lines[LinePos].SensorTypes ) ) then
    Exit;

  // the 1st sensor type from the arrays
  t := UpperCase( Devices[DevPos].Lines[LinePos].SensorTypes[0] );

  if ( 'IO' = t ) then // IO
    Result := stIO
  else if ( 'PANO' = t ) then // Panoramic
    Result := stPANO
  else if ( 'CEPH' = t ) then // Cephalometric
    Result := stCEPH
  else if ( 'VL' = t ) then   // Video
    Result := stVL;

end; // function TN_CMCDServObj16.GetSensorType

//****************************************** TN_CMCDServObj16.GetSensorType ***
// Define sensor type by it's string
//
//    Parameters
// ADevStr - Device string
// Result  - Sensor type
//
function TN_CMCDServObj16.GetSensorSType( ADevStr: String ): string;
//var
//  DevPos, LinePos: Integer;
//  t: String;
begin
  Result := ''; // Unknown sensor type
  FillDevPos( ADevStr, CurrentDevice, CurrentLine );

  if ( ( 0 > CurrentDevice ) or ( 0 > CurrentLine ) ) then // wrong device or line number
    Exit;

  if ( 1 > Length( Devices[CurrentDevice].Lines[CurrentLine].SensorTypes ) ) then
    Exit;

  // the 1st sensor type from the arrays
  Result := Devices[CurrentDevice].Lines[CurrentLine].SensorTypes[0];

end; // function TN_CMCDServObj16.GetSensorSType

//*************************************** TN_CMCDServObj16.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// AAdd         - if True then the image edited, else a new one added
// APDevProfile - Device Profile
// AFrm         - Capture form
// AFilePath    - Image file path
// Result       - 0 if OK
//
function TN_CMCDServObj16.CMOFCaptureSlide( AAdd: Boolean;
                                            APDevProfile: TK_PCMDeviceProfile;
                                            AFrm: TN_CMCaptDev16Form;
                                            AFilePath: AnsiString ): Integer;
var
  i, SlideCount: Integer;
  CapturedDIB: TN_DIBObj;
  filter: Boolean;
  ActualImagePath: AnsiString;
  hb: HBITMAP;
  bm: TBitmap;
  RootComp: TN_UDCompVis;
  s: String;
begin
  Result := 0;
  ActualImagePath := AFilePath;
  SlideCount := Length( PSlideArr^ ); // count of slides

  filter := True;
  s := APDevProfile.CMDPStrPar1;

  if ( 0 < Length( s ) ) then
    filter := ( '1' <> Copy( s, 1, 1 ) );

  if AAdd then
    DicomFileName := N_AnsiToString( AFilePath );

  if ( nil <> AFrm ) then
    AFrm.CMOFNumCaptured := SlideCount;

  if ( filter and AAdd ) then // not raw image
  begin
    Handle2D := N_CMCDServObj16.ImageProcessor2DCreate_ext();
    ActualImagePath := N_StringToAnsi( N_CMV_GetWrkDir() ) + 'trophy.bmp';

    if not N_CMCDServObj16.ImageProcessor2DLoadImage_ext( Handle2D, @AFilePath[1] ) then
    begin
      N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DLoadImage error' );
      Exit;
    end; // if not N_CMCDServObj16.ImageProcessor2DLoadImage_ext( Handle2D, @AFilePath[1] ) then

    hb := HBITMAP( N_CMCDServObj16.ImageProcessor2DGetProcessedHBITMAP_ext( Handle2D ) );
    bm := TBitmap.Create();
    bm.Handle := hb;
    bm.SaveToFile( N_AnsiToString( ActualImagePath ) );
    bm.Free;
    //N_CMCDServObj16.ImageProcessor2DDestroy_ext( Handle2D );
  end; // if ( filter and AAdd ) then // not raw image

  CapturedDIB := nil;
  N_LoadDIBFromFileByImLib( CapturedDIB, N_AnsiToString( ActualImagePath ) );

  CapturedDIB.DIBInfo.bmi.biXPelsPerMeter := 1000000 div 20;
  CapturedDIB.DIBInfo.bmi.biYPelsPerMeter := CapturedDIB.DIBInfo.bmi.biXPelsPerMeter;

  if AAdd then // new image
  begin
    SetLength( PSlideArr^, SlideCount + 1 );   // add slide

    for i := SlideCount downto 1 do
      PSlideArr^[i] := PSlideArr^[i - 1];

  end
  else // edited image
    Dec( SlideCount );

  if ( 0 > SlideCount ) then // error - negative slide count
  begin
    N_CMV_ShowCriticalError( 'CSH', 'Slide count = ' + IntToStr( SlideCount ) );
    Exit;
  end; // if ( 0 > SlideCount ) then // error - negative slide count


  // add image to appropriate slide
  if AAdd then // new image
    PSlideArr^[0] :=
    K_CMSlideCreateFromDeviceDIBObj( CapturedDIB, APDevProfile, SlideCount + 1, 0 )
  else // edited image
    K_CMSlideReplaceByDeviceDIBObj( PSlideArr^[0], CapturedDIB, APDevProfile, SlideCount + 1, 0 );
//    K_CMReplaceSlideDIB( PSlideArr^[0], CapturedDIB );

{ !!! not needed all done in K_CMSlideCreateFromDeviceDIBObj
  with PSlideArr^[0].P()^ do
  begin
    CMSSourceDescr   := APDevProfile^.CMDPCaption;
    CMSMediaType     := APDevProfile^.CMDPMTypeID;
  end; // with PSlideArr^[0].P()^ do
}
  if ( nil = AFrm ) then
    Exit;

  // Add NewSlide to CMOFThumbsDGrid
  if AAdd then
    Inc( AFrm.CMOFThumbsDGrid.DGNumItems );

  AFrm.CMOFThumbsDGrid.DGInitRFrame();
  AFrm.CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  RootComp := PSlideArr^[0].GetMapRoot();

  if ( nil <> AFrm ) then
    AFrm.SlideRFrame.RFrShowComp( RootComp );

end; // end of TN_CMCDServObj16.CMOFCaptureSlide

//******************************************** TN_CMCDServObj16.CaptureById ***
// Subscribe application's windows on USB events
//
//    Parameters
// APDevProfile - Device profile
// AFrm         - Capture form
// ADevNum      - Device number
// ALineNum     - Device Line number
// Result       - Images count captured
//
function TN_CMCDServObj16.CaptureById( APDevProfile: TK_PCMDeviceProfile;
                                       AFrm: TN_CMCaptDev16Form;
                                       ADevNum, ALineNum: Integer ): Integer;
var
  i: Integer;

  XMLDoc: TN_CMV_XML;
  XMLRequestStr, XMLResponseStr: AnsiString;
  Req:  TN_CMV_XMLRequest;
  Resp: TN_CMV_XMLResponse;
  PatId, PatName, PatSurname, PatDOB, PatGender: String;
  PatDay, PatMonth, PatYear: Integer;
begin
  Result := 0;
  DicomFileName := '';

  if ( ( ADevNum < 0 ) or ( ALineNum < 0 ) ) then // wrong device or line number
  begin
    N_CMV_ShowCriticalError( 'CSH',
                             'Device not found.' +
                             'Please install the device. Press OK to continue.' );
    Exit;
  end; // if ( ( ADevNum < 0 ) or ( ALineNum < 0 ) ) then // wrong device or line number

  // Get Patients info from CMS Database
  PatId      := K_CMGetPatientDetails( -1, '(#PatientCardNumber#)' );
  PatName    := K_CMGetPatientDetails( -1, '(#PatientFirstName#)' );
  PatSurname := K_CMGetPatientDetails( -1, '(#PatientSurname#)' );
  PatDOB     := K_CMGetPatientDetails( -1, '(#PatientDOB#)' );
  PatGender  := K_CMGetPatientDetails( -1, '(#PatientGender#)' );

  PatDay := 1;
  PatMonth := 1;
  PatYear := 2000;

  if ( 10 = Length( PatDOB ) ) then
  begin
    PatDay   := StrToIntDef( Copy( PatDOB, 1, 2 ), 1 );
    PatMonth := StrToIntDef( Copy( PatDOB, 4, 2 ), 1 );
    PatYear  := StrToIntDef( Copy( PatDOB, 7, 4 ), 1 );
  end; // if ( 10 = Length( PatDOB ) ) then

  with N_CMCDServObj16 do
  begin

  // ***** set async information command
  XMLHandleRequest := AcquisitionXMLCreate_ext();

  if ( nil = XMLHandleRequest ) then // Empty XML request
  begin
    N_CMV_ShowCriticalError( 'CSH', 'AcquisitionXMLCreate = nil' );
    Exit;
  end; // if ( nil = XMLHandleRequest ) then // Empty XML request

  XMLRequestStr := N_StringToAnsi(
  '<?xml version="1.0" encoding="utf-8" ?>' +
  '<trophy type="acquisition">' +
  '<acquisition command="setasyncinformation" version="1.0" >' +
  '<parameters>' +
  '<device id="' + N_CMCDServObj16.Devices[N_CMCDServObj16.CurrentDevice].id + '" />' +
  '<line id="' + N_CMCDServObj16.Devices[N_CMCDServObj16.CurrentDevice].Lines[N_CMCDServObj16.CurrentLine].id + '" />' + #13#10 +
  '<outputdirectory path="' + N_CMV_GetWrkDir() + '" />' +
  '<outputencoding language="unicode" />' +
  '<compression on="0"/>' +
  '</parameters>' +
  '<information>' +
  '<patient>' +
  '<date key="birthdate" day="' + IntToStr( PatDay ) + '" month="' + IntToStr( PatMonth ) + '" year="' + IntToStr( PatYear ) + '" />' +
  '<name key="patient" family="' + PatSurname + '" given="' + PatName + '" middle="" prefix="" suffix="" />' +
  '<string key="id" value="' + PatId + '" />' +
  '<string key="sex" value="' + PatGender + '" />' +
  '</patient>' +
  '</information>' +
  '</acquisition>' +
  '</trophy>' );

  AcquisitionXMLSet_ext( XMLHandleRequest, @XMLRequestStr[1] );
  XMLHandleResponse := Acquisition_ext( XMLHandleRequest );

  XMLResponseStr := AcquisitionXMLGet_ext( XMLHandleResponse );
  XMLDoc := N_CMV_XMLDocLoad( N_AnsiToString( XMLResponseStr ), False );

  N_Dump1Str(N_AnsiToString(XMLResponseStr));

 { // ***** first need to unregister notifications
  XMLRequestStr := N_StringToAnsi(
  '<?xml version="1.0" encoding="utf-8" ?>' +
  '<trophy type="acquisition">' +
  '<acquisition command="unregisternotificationport" version="1.0" >' +
  '<notification port="' + '50000' + '" />' +
  '</acquisition>' +
  '</trophy>' );

  AcquisitionXMLSet_ext( XMLHandleRequest, @XMLRequestStr[1] );
  XMLHandleResponse := Acquisition_ext( XMLHandleRequest );

  XMLResponseStr := AcquisitionXMLGet_ext( XMLHandleResponse );
  XMLDoc := N_CMV_XMLDocLoad( N_AnsiToString( XMLResponseStr ), False );

  N_Dump1Str(N_AnsiToString(XMLResponseStr));   }

  // ***** then to register it once again
  XMLRequestStr := N_StringToAnsi(
  '<?xml version="1.0" encoding="utf-8" ?>' +
  '<trophy type="acquisition">' +
  '<acquisition command="registernotificationport" version="1.0" >' +
  '<notification port="' + '50000' + '" />' +
  '</acquisition>' +
  '</trophy>' );

  AcquisitionXMLSet_ext( XMLHandleRequest, @XMLRequestStr[1] );
  XMLHandleResponse := Acquisition_ext( XMLHandleRequest );

  XMLResponseStr := AcquisitionXMLGet_ext( XMLHandleResponse );
  XMLDoc := N_CMV_XMLDocLoad( N_AnsiToString( XMLResponseStr ), False );

  N_Dump1Str(N_AnsiToString(XMLResponseStr));

  end;

  // Make XML Request string
  XMLRequestStr := N_StringToAnsi(
  '<?xml version="1.0" encoding="utf-8" ?>' +
  '<trophy type="acquisition">' +
  '<acquisition command="acquire" version="1.0">' +
 	'<parameters>' +
  '<device id="' + N_CMCDServObj16.Devices[ADevNum].id + '" />' +
  '<line id="' + N_CMCDServObj16.Devices[ADevNum].Lines[ALineNum].id + '" />' +
  '<outputdirectory path="' + N_CMV_GetWrkDir() + '" />' +
  '<outputencoding language="unicode" />' +
  '<compression on="0"/>' +
	'</parameters>' +
  '<information>' +
  '<patient>' +
  '<date key="birthdate" day="' + IntToStr( PatDay ) + '" month="' + IntToStr( PatMonth ) + '" year="' + IntToStr( PatYear ) + '" />' +
  '<name key="patient" family="' + PatSurname + '" given="' + PatName + '" middle="" prefix="" suffix="" />' +
  '<string key="id" value="' + PatId + '" />' +
  '<string key="sex" value="' + PatGender + '" />' +
  '</patient>' +
  '</information>' +
  '</acquisition>' +
  '</trophy>' );

  N_CMCDServObj16.AcquisitionXMLSet_ext( XMLHandleRequest, @XMLRequestStr[1] );
  XMLHandleResponse := N_CMCDServObj16.Acquisition_ext( XMLHandleRequest );
  XMLResponseStr := N_CMCDServObj16.AcquisitionXMLGet_ext( XMLHandleResponse );
  XMLDoc := N_CMV_XMLDocLoad( N_AnsiToString( XMLResponseStr ), False );

  N_Dump1Str(N_AnsiToString(XMLResponseStr));

  if ( nil = XMLDoc ) then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'XMLDoc = nil ( CaptureById )' );
    Exit;
  end; // if ( nil = XMLDoc ) then

  Req.tag := 'imagefile';
  SetLength( Req.path, 3 );
  Req.path[0].name := 'trophy';
  Req.path[0].position := 0;
  Req.path[1].name := 'acquisition';
  Req.path[1].position := 0;
  Req.path[2].name := 'imagefiles';
  Req.path[2].position := 0;

  N_Dump1Str('tag - '+Req.tag);
  //N_Dump1Str();

  if not N_CMV_XMLDocToResult( XMLDoc, Req, Resp ) then
  begin
    N_Dump1Str( 'CSH >> not d2res for devices ( CaptureById )' );
    //N_CMCDServObj16.AcquisitionXMLDestroy_ext( XMLHandleRequest );
    //N_CMCDServObj16.AcquisitionDllRelease_ext( nil );
    Exit;
  end; // if not N_CMV_XMLDocToResult( XMLDoc, Req, Resp ) then

  Result := Length( Resp );

  for i := 0 to Result - 1 do
  begin
    CMOFCaptureSlide( True, APDevProfile, AFrm,
                      N_StringToAnsi( N_CMV_XMLGet( i, 'path', Resp ) ) );
  end; // for i := 0 to Result - 1 do

  
end; // function TN_CMCDServObj16.CaptureById

//********************************************* TN_CMCDServObj16.FillDevPos ***
// Define devices position in array by it's string
//
//    Parameters
// ADevStr  - Device string
// ADevPos  - Device position
// ALinePos - Device Line position
//
procedure TN_CMCDServObj16.FillDevPos( ADevStr: String; out ADevPos: Integer;
                                       out ALinePos: Integer );
var
  DeviceCount, LineCount, i, j: Integer;
begin
  ADevPos  := -1;
  ALinePos := -1;
  DeviceCount := Length( Devices );

  for i := 0 to DeviceCount - 1 do // for each device
  begin
    LineCount := Length( Devices[i].Lines );

    for j := 0 to LineCount - 1 do // for each line
    begin

      if ( ADevStr = Devices[i].Lines[j].name ) then // names coincide
      begin

        if IsGoodDevice( i, j ) then // visible device
        begin
          ADevPos  := i;
          ALinePos := j;
        end; // if IsGoodDevice( i, j ) then // visible device

        Exit;
      end; // if ( ADevStr = Devices[i].Lines[j].name ) then // names coincide

    end; // for j := 0 to LineCount - 1 do // for each line

  end; // for i := 0 to DeviceCount - 1 do // for each device

end; // procedure TN_CMCDServObj16.FillDevPos

//********************************************* TN_CMCDServObj16.CDSInitAll ***
// Load all e2v DLL functions
//
procedure TN_CMCDServObj16.CDSInitAll();
var
  i, j, k, DevCount, LineCount, SensorTypesCount, ResCode: Integer;
  IsFunctionsLoaded:   Boolean;
  XMLHandleRequest, XMLHandleResponse: Pointer;
  XMLDoc: TN_CMV_XML;
  XMLRequestStr, XMLResponseStr: AnsiString;
  ReqDevices, ReqLines, ReqSensorTypes, ReqDisplayMode: TN_CMV_XMLRequest;
  ResDevices, ResLines, ResSensorTypes, ResDisplayMode: TN_CMV_XMLResponse;
begin

  if ( 0 <> CDSDllHandle ) then  // If DLL already loaded
    Exit;

  // Load CSH DLL
  CDSDllHandle := LoadLibrary( 'acquisition.dll' ); // Acquisition DLL

  if ( 0 = CDSDllHandle ) then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'acquisition.dll not loaded' );
    Exit;
  end; // if ( 0 = CDSDllHandle ) then

  CDSDllHandle2 := LoadLibrary( 'processings2D.dll' ); // Processings2D DLL

  if ( 0 = CDSDllHandle2 ) then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'processings2D.dll not loaded' );
    Exit;
  end; // if ( 0 = CDSDllHandle2 ) then

  // Load all needed CSH functions from DLL
  IsFunctionsLoaded :=
  N_CMV_LoadFunc( CDSDllHandle, @Acquisition_ext,           'Acquisition'           ) and
  N_CMV_LoadFunc( CDSDllHandle, @AcquisitionDllInit_ext,    'AcquisitionDllInit'    ) and
  N_CMV_LoadFunc( CDSDllHandle, @AcquisitionDllRelease_ext, 'AcquisitionDllRelease' ) and
  N_CMV_LoadFunc( CDSDllHandle, @AcquisitionInfo_ext,       'AcquisitionInfo'       ) and
  N_CMV_LoadFunc( CDSDllHandle, @AcquisitionXMLCreate_ext,  'AcquisitionXMLCreate'  ) and
  N_CMV_LoadFunc( CDSDllHandle, @AcquisitionXMLDestroy_ext, 'AcquisitionXMLDestroy' ) and
  N_CMV_LoadFunc( CDSDllHandle, @AcquisitionXMLGet_ext,     'AcquisitionXMLGet'     ) and
  N_CMV_LoadFunc( CDSDllHandle, @AcquisitionXMLSet_ext,     'AcquisitionXMLSet'     ) and
  N_CMV_LoadFunc( CDSDllHandle2, @ImageProcessor2DCreate_ext,        'ImageProcessor2DCreate'        ) and
  N_CMV_LoadFunc( CDSDllHandle2, @ImageProcessor2DDestroy_ext,       'ImageProcessor2DDestroy'       ) and
  N_CMV_LoadFunc( CDSDllHandle2, @ImageProcessor2DGetState_ext,      'ImageProcessor2DGetState'      ) and
  N_CMV_LoadFunc( CDSDllHandle2, @ImageProcessor2DLoadImage_ext,     'ImageProcessor2DLoadImage'     ) and
  N_CMV_LoadFunc( CDSDllHandle2, @ImageProcessor2DSaveImage_ext,     'ImageProcessor2DSaveImage'     ) and
  N_CMV_LoadFunc( CDSDllHandle2, @ImageProcessor2DGetFloatValue_ext, 'ImageProcessor2DGetFloatValue' ) and
  N_CMV_LoadFunc( CDSDllHandle2, @ImageProcessor2DEnableAlgo_ext,    'ImageProcessor2DEnableAlgo'    ) and
  N_CMV_LoadFunc( CDSDllHandle2, @ImageProcessor2DSetAlgoParameter_ext,    'ImageProcessor2DSetAlgoParameter'    ) and
  N_CMV_LoadFunc( CDSDllHandle2, @ImageProcessor2DGetProcessedHBITMAP_ext, 'ImageProcessor2DGetProcessedHBITMAP' ) and
  N_CMV_LoadFunc( CDSDllHandle2, @ImageProcessor2DGetOriginalHBITMAP_ext,  'ImageProcessor2DGetOriginalHBITMAP'  );


  if not IsFunctionsLoaded then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'Some functions not loaded from DLL' );
    Exit;
  end; // if not IsFunctionsLoaded then

  DevCount := 0;
  SetLength( Devices, DevCount );
  ResCode := AcquisitionDllInit_ext( nil );

  if ( ResCode <> 1 ) then // DLL Initialization error
  begin
    N_CMV_ShowCriticalError( 'CSH', 'DLL Initialization error = ' + IntToStr( ResCode ) );
    Exit;
  end; // if ( ResCode <> 1 ) then // DLL Initialization error

  XMLHandleRequest := AcquisitionXMLCreate_ext();

  if ( nil = XMLHandleRequest ) then // Empty XML request
  begin
    N_CMV_ShowCriticalError( 'CSH', 'AcquisitionXMLCreate = nil' );
    Exit;
  end; // if ( nil = XMLHandleRequest ) then // Empty XML request

  XMLRequestStr :=
  '<?xml version="1.0" encoding="utf-8" ?>' + #13#10 +
  '<trophy type="acquisition">' + #13#10 +
  '<acquisition command="querydevices" version="1.0" >' + #13#10 +
  '<sensortypes>' + #13#10 +
      '<sensortype id="PANO" />' + #13#10 +
      '<sensortype id="CEPH" />' + #13#10 +
      '<sensortype id="3D" />' + #13#10 +
      '<sensortype id="CR" />' + #13#10 +
      '<sensortype id="IO" />' + #13#10 +
      '<sensortype id="SC" />' + #13#10 +
      '<sensortype id="VL" />' + #13#10 +
      '<sensortype id="3DVL" />' + #13#10 +
    '</sensortypes>' + #13#10 +
  '</acquisition>' + #13#10 +
  '</trophy>' + #13#10;

  AcquisitionXMLSet_ext( XMLHandleRequest, @XMLRequestStr[1] );
  XMLHandleResponse := Acquisition_ext( XMLHandleRequest );
  XMLResponseStr := AcquisitionXMLGet_ext( XMLHandleResponse );
  XMLDoc := N_CMV_XMLDocLoad( N_AnsiToString( XMLResponseStr ), False );

  if ( nil = XMLDoc ) then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'XMLDoc = nil ( Init1 )' );
    Exit;
  end; // if ( nil = XMLDoc ) then

  ReqDevices.tag := 'device';
  SetLength( ReqDevices.path, 3 );
  ReqDevices.path[0].name := 'trophy';
  ReqDevices.path[0].position := 0;
  ReqDevices.path[1].name := 'acquisition';
  ReqDevices.path[1].position := 0;
  ReqDevices.path[2].name := 'devices';
  ReqDevices.path[2].position := 0;

  if not N_CMV_XMLDocToResult( XMLDoc, ReqDevices, ResDevices ) then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'not d2res for devices( Init )' );
    Exit;
  end; // if not N_CMV_XMLDocToResult( XMLDoc, ReqDevices, ResDevices ) then

  DevCount := Length( ResDevices );
  SetLength( Devices, DevCount );

  for i := 0 to DevCount - 1 do
    Devices[i].id := N_CMV_XMLGet( i, 'id', ResDevices );

  XMLRequestStr :=
  '<?xml version="1.0" encoding="utf-8" ?>' + #13#10 +
  '<trophy type="acquisition">' + #13#10 +
  '<acquisition command="querylines" version="1.0" >' + #13#10 +
  '<devices>' + #13#10;

  for i := 0 to DevCount - 1 do
    XMLRequestStr := XMLRequestStr + '<device id="' +
                     N_StringToAnsi( Devices[i].id ) + '" />' + #13#10;

  XMLRequestStr := XMLRequestStr + #13#10 +
  '</devices>' + #13#10 +
  '</acquisition>' + #13#10 +
  '</trophy>' + #13#10;

  AcquisitionXMLSet_ext( XMLHandleRequest, @XMLRequestStr[1] );
  XMLHandleResponse := Acquisition_ext( XMLHandleRequest );
  XMLResponseStr := AcquisitionXMLGet_ext( XMLHandleResponse );
  XMLDoc := N_CMV_XMLDocLoad( N_AnsiToString( XMLResponseStr ), False );

  if ( nil = XMLDoc ) then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'XMLDoc = nil ( Init2 )' );
    Exit;
  end; // if ( nil = XMLDoc ) then

  for i := 0 to DevCount - 1 do // for each device
  begin
    ReqLines.tag := 'line';
    SetLength( ReqLines.path, 5 );
    ReqLines.path[0].name := 'trophy';
    ReqLines.path[0].position := 0;
    ReqLines.path[1].name := 'acquisition';
    ReqLines.path[1].position := 0;
    ReqLines.path[2].name := 'devices';
    ReqLines.path[2].position := 0;
    ReqLines.path[3].name := 'device';
    ReqLines.path[3].position := i;
    ReqLines.path[4].name := 'lines';
    ReqLines.path[4].position := 0;

    SetLength( Devices[i].Lines, 0 );

    if not N_CMV_XMLDocToResult( XMLDoc, ReqLines, ResLines ) then
    begin
      Continue;
    end; // if not N_CMV_XMLDocToResult( XMLDoc, ReqLines, ResLines ) then

    LineCount := Length( ResLines );
    SetLength( Devices[i].Lines, LineCount );

    for j := 0 to LineCount - 1 do // for each line
    begin
      Devices[i].Lines[j].id           := N_CMV_XMLGet( j, 'id', ResLines );
      Devices[i].Lines[j].name         := N_CMV_XMLGet( j, 'name', ResLines );
      Devices[i].Lines[j].SerialNumber := N_CMV_XMLGet( j, 'serialnumber', ResLines );
      Devices[i].Lines[j].Async        := ( '1' = N_CMV_XMLGet( j, 'asyncsupport', ResLines ) );

      ReqSensorTypes.tag := 'sensortype';
      SetLength( ReqSensorTypes.path, 7 );
      ReqSensorTypes.path[0].name := 'trophy';
      ReqSensorTypes.path[0].position := 0;
      ReqSensorTypes.path[1].name := 'acquisition';
      ReqSensorTypes.path[1].position := 0;
      ReqSensorTypes.path[2].name := 'devices';
      ReqSensorTypes.path[2].position := 0;
      ReqSensorTypes.path[3].name := 'device';
      ReqSensorTypes.path[3].position := i;
      ReqSensorTypes.path[4].name := 'lines';
      ReqSensorTypes.path[4].position := 0;
      ReqSensorTypes.path[5].name := 'line';
      ReqSensorTypes.path[5].position := j;
      ReqSensorTypes.path[6].name := 'sensortypes';
      ReqSensorTypes.path[6].position := 0;

      if not N_CMV_XMLDocToResult( XMLDoc, ReqSensorTypes, ResSensorTypes ) then
      begin
        N_CMV_ShowCriticalError( 'CSH', 'not d2res for sensortypes' );
        Exit;
      end; // if not N_CMV_XMLDocToResult( XMLDoc, ReqSensorTypes, ResSensorTypes ) then

      SensorTypesCount := Length( ResSensorTypes );
      SetLength( Devices[i].Lines[j].SensorTypes, SensorTypesCount );

      for k := 0 to SensorTypesCount - 1 do // for each sensor type supported
        Devices[i].Lines[j].SensorTypes[k] := N_CMV_XMLGet( k, 'id', ResSensorTypes );

      ReqDisplayMode.tag := 'displaymode';
      SetLength( ReqDisplayMode.path, 6 );
      ReqDisplayMode.path[0].name := 'trophy';
      ReqDisplayMode.path[0].position := 0;
      ReqDisplayMode.path[1].name := 'acquisition';
      ReqDisplayMode.path[1].position := 0;
      ReqDisplayMode.path[2].name := 'devices';
      ReqDisplayMode.path[2].position := 0;
      ReqDisplayMode.path[3].name := 'device';
      ReqDisplayMode.path[3].position := i;
      ReqDisplayMode.path[4].name := 'lines';
      ReqDisplayMode.path[4].position := 0;
      ReqDisplayMode.path[5].name := 'line';
      ReqDisplayMode.path[5].position := j;

      if not N_CMV_XMLDocToResult( XMLDoc, ReqDisplayMode, ResDisplayMode ) then
      begin
        N_CMV_ShowCriticalError( 'CSH', 'not d2res for DisplayMode' );
        Exit;
      end; // if not N_CMV_XMLDocToResult( XMLDoc, ReqDisplayMode, ResDisplayMode ) then

      Devices[i].Lines[j].DisplayModeName  := N_CMV_XMLGet( 0, 'name', ResDisplayMode );
      Devices[i].Lines[j].DisplayModeValue := N_CMV_XMLGet( 0, 'value', ResDisplayMode );
    end; // for j := 0 to LineCount - 1 do // for each line

  end; // for i := 0 to DevCount - 1 do // for each device

  AcquisitionXMLDestroy_ext( XMLHandleRequest );
  AcquisitionDllRelease_ext( nil );
end; // function TN_CMCDServObj16.CDSInitAll

//********************************************* TN_CMCDServObj16.CDSFreeAll ***
// Unload all CSH DLL functions
//
procedure TN_CMCDServObj16.CDSFreeAll();
begin
  N_Dump1Str( 'Start TN_CMCDServObj16.CDSFreeAll' );

  if CDSDLLHandle <> 0 then // If CSH DLL loaded
  begin
    N_Dump1Str( 'Before acquisition.dll FreeLibrary' );
    N_b := FreeLibrary( CDSDLLHandle ); /// Free CSH DLL

    if not N_b then
      N_Dump1Str( ' From CDSFreeAll: ' + SysErrorMessage( GetLastError() ) );

    N_Dump1Str( 'After acquisition.dll FreeLibrary' );
    CDSDLLHandle := 0; // initialize the handle
  end; // if CDSDLLHandle <> 0 then // If CSH DLL loaded

  if CDSDLLHandle2 <> 0 then // If CSH DLL loaded
  begin
    N_Dump1Str( 'Before processings2D.dll FreeLibrary' );
    N_b := FreeLibrary( CDSDLLHandle2 ); /// Free CSH DLL

    if not N_b then
      N_Dump1Str( ' From CDSFreeAll: ' + SysErrorMessage( GetLastError() ) );

    N_Dump1Str( 'After processings2D.dll FreeLibrary' );
    CDSDLLHandle2 := 0; // initialize the handle
  end; // if CDSDLLHandle2 <> 0 then // If CSH DLL loaded

end; // procedure TN_CMCDServObj16.CDSFreeAll

// ************* CSH interface begin **************

// CSH interface end

//************************************ TN_CMCDServObj16.CDSGetGroupDevNames ***
// Get CSH Device Name
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj16.CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer;
var
  i, j, k, DevCount, LineCount, SensorCount, TotalLines: Integer;
  tf: TextFile;
  s, fn: String;
  names: Array of String;
begin
  CDSInitAll();
  DevCount := Length( Devices );
  fn := N_CMV_GetLogDir() + 'csh.txt';
  Result := 0;
  SetLength( names, Result );

  TotalLines := 0;
  AssignFile( tf, fn );
  ReWrite( tf );
  s := 'Device Count = ' + IntToStr( DevCount ) + #13#10;
  WriteLn( tf, s );

  for i := 0 to DevCount - 1 do // for each device
  begin
    LineCount := Length( Devices[i].Lines );
    TotalLines := TotalLines + LineCount;
    s := '  Device Number = ' + IntToStr( i ) +
         '; id = ' + Devices[i].id +
         '; Line Count = ' + IntToStr( LineCount );
    WriteLn( tf, s );

    for j := 0 to LineCount - 1 do // for each device line
    begin
      s := '    Line Number = ' + IntToStr( j ) +
      '; id = ' + Devices[i].Lines[j].id +
      '; name = ' + Devices[i].Lines[j].name +
      '; sn = ' + Devices[i].Lines[j].SerialNumber;

      if Devices[i].Lines[j].Async then
        s := s + '; Async '
      else
        s := s + '; Sync ';

      SensorCount := Length( Devices[i].Lines[j].SensorTypes );
      s := s + ' Mode Name = ' + Devices[i].Lines[j].DisplayModeName +
           '; Mode Value = ' + Devices[i].Lines[j].DisplayModeValue;
      WriteLn( tf, s );

      for k := 0 to SensorCount - 1 do // for each sensor type supported
      begin
        s := '      Sensor Type[' + IntToStr( k ) + '] = ' +
        Devices[i].Lines[j].SensorTypes[k];
        WriteLn( tf, s );
      end; // for k := 0 to SensorCount - 1 do // for each sensor type supported

      if IsGoodDevice( i, j ) then
      begin
        inc( Result );
        SetLength( names, Result );
        N_Dump1Str('names');
        names[Result - 1] := Devices[i].Lines[j].name;
      end; // if IsGoodDevice( i, j ) then


    end; // for j := 0 to LineCount - 1 do // for each device line

  end; // for i := 0 to DevCount - 1 do // for each device

  s := 'Total Lines Count = ' + IntToStr( TotalLines );
  WriteLn( tf, s );
  CloseFile( tf );

  if ( 1 > Result) then // if no devices found
  begin
    N_CMV_ShowCriticalError( 'CSH',
                             'There is no CSH devices installed on this PC. ' +
                             'Please install the device. Press OK to continue.' );
    Result := 0;
    Exit;
  end; // if ( 1 > Result) then // if no devices found

  for i := 0 to Result - 1 do // fill devices list in dialog
    AGroupDevNames.Add( names[i] );

end; // procedure TN_CMCDServObj16.CDSGetGroupDevNames

//******************************** TN_CMCDServObj16.CDSGetDevProfileCaption ***
// Get Capture Device Profile Caption by Name
//
//     Parameters
// ADevName - given Device Name
//
// Result   - Returns Device Caption
//
function  TN_CMCDServObj16.CDSGetDevProfileCaption( ADevName: String ): String;
begin
  Result := ADevName; // ADevName is not used because group has only one device
end; // procedure TN_CMCDServObj16.CDSGetDevProfileCaption

//*************************************** TN_CMCDServObj16.CDSGetDevCaption ***
// Get Capture Device Caption by Name
//
//     Parameters
// ADevName - given Device Name
//
// Result   - Returns Device Caption
//
function  TN_CMCDServObj16.CDSGetDevCaption( ADevName: String ): String;
var
  Dev, Line, DevCount, LineCount, SensTypesCount, i, j, k: Integer;
  CurrentDev, CurrentLine: String;
begin
  CDSInitAll();
  Result := 'Device not found';
  FillDevPos( ADevName, Dev, Line );

  N_Dump1Str('caption');

  if ( ( Dev >= 0 ) and ( Line >= 0 ) ) then
    Result := Devices[Dev].Lines[Line].name;

  DevCount := Length( Devices );

  N_Dump1Str( 'CSH >> FillDevPos: ADevName = "' + ADevName + '" DevPos = ' +
              IntToStr( Dev ) + ' LineCount = ' + IntToStr( Line ) );

  N_Dump1Str( 'CSH >> DevCount = ' + IntToStr( DevCount ) );

  for i := 0 to DevCount - 1 do
  begin
    CurrentDev := IntToStr( i );
    LineCount := Length( Devices[i].Lines );
    N_Dump1Str( 'CSH >> Devices[' + CurrentDev + '].id = ' + Devices[i].id );

    for j := 0 to LineCount - 1 do
    begin
      CurrentLine := IntToStr( j );
      N_Dump1Str( 'CSH >> Lines[' + CurrentLine + '].id = ' + Devices[i].Lines[j].id );
      N_Dump1Str( 'CSH >> Lines[' + CurrentLine + '].name = ' + Devices[i].Lines[j].name );
      N_Dump1Str( 'CSH >> Lines[' + CurrentLine + '].SerialNumber = ' + Devices[i].Lines[j].SerialNumber );

      if Devices[i].Lines[j].Async then
        N_Dump1Str( 'CSH >> Lines[' + CurrentLine + '].Async' )
      else
        N_Dump1Str( 'CSH >> Lines[' + CurrentLine + '].Sync' );

      N_Dump1Str( 'CSH >> Lines[' + CurrentLine + '] = ' + Devices[i].Lines[j].DisplayModeName );
      N_Dump1Str( 'CSH >> Lines[' + CurrentLine + '] = ' + Devices[i].Lines[j].DisplayModeValue );

      SensTypesCount := Length( Devices[i].Lines[j].SensorTypes );
      N_Dump1Str( 'CSH >> SensTypesCount = ' + IntToStr( SensTypesCount ) );

      for k := 0 to SensTypesCount - 1 do
        N_Dump1Str( 'CSH >> SensTypes[' + IntToStr( k ) + ']' + Devices[i].Lines[j].SensorTypes[k] );

    end; // for j := 0 to LineCount - 1 do

  end; // for i := 0 to DevCount - 1 do

end; // procedure TN_CMCDServObj16.CDSGetDevCaption

//*************************************** TN_CMCDServObj16.CDSCaptureImages ***
// Capture images
//
//     Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj16.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
var
//  CMCaptDev16Form: TN_CMCaptDev16SForm;
//  SensType: TCSHSensorType;
  SensorSType : string;
begin
//  SensType := FCapturePrepare( APDevProfile );
  N_Dump1Str( 'CSH >> CDSCaptureImages begin' );
  SensorStype := FCapturePrepare( APDevProfile, FALSE );
  if SensorSType = '' then Exit; // Wrong Sensor Detection

  PSlideArr := @ASlidesArray;
  SetLength  ( ASlidesArray, 0 );

{
  PProfile  := APDevProfile;
  PSlideArr := @ASlidesArray;
  Handle2D  := nil;

  if ( nil = PSlideArr ) then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'PSlideArr = nil' );
    Exit;
  end;

  CDSInitAll ();
  SetLength  ( ASlidesArray, 0 );
  FillDevPos ( APDevProfile^.CMDPProductName, CurrentDevice, CurrentLine );
  SensType := GetSensorType( APDevProfile^.CMDPProductName );

  if ( stOther = SensType ) then // unknown sensor type
  begin
    N_Dump1Str( 'CSH >> Unknown device type' );
  end; // if ( stOther = SensType ) then // unknown sensor type


  if ( stVL = SensType ) then // video sensor
  begin
    CaptureById( APDevProfile, nil, CurrentDevice, CurrentLine );
    Exit;
  end; // if ( stVL = SensType ) then // video sensor

  FillDevPos( APDevProfile.CMDPProductName, CurrentDevice, CurrentLine );
  if ( ( CurrentDevice < 0 ) or ( CurrentLine < 0 ) ) then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'Device "' +  APDevProfile.CMDPProductName + '" not presented' );
    Exit;
  end; // if ( ( CurrentDevice < 0 ) or ( CurrentLine < 0 ) ) then
}

  if ( 'VL' = SensorSType ) then // video sensor
  begin
    CaptureById( APDevProfile, nil, CurrentDevice, CurrentLine );
    Exit;
  end; // if ( stVL = SensType ) then // video sensor

  CaptForm.CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDev16Form methods


{
  CMCaptDev16Form          := TN_CMCaptDev16SForm.Create( Application );
  CaptForm                 := CMCaptDev16Form;

  with CMCaptDev16Form, APDevProfile^ do
  begin

    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    CMOFPProfile    := TK_PCMOtherProfile( APDevProfile ); // set CMCaptDev16Form.CMOFPProfile field
    Caption         := CMDPCaption;
    CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDev16Form methods
    CMOFNumCaptured := 0;
    ShowModal();
  end; // with CMCaptDev16Form, APDevProfile^ do
}
  N_Dump1Str( 'CSH >> CDSCaptureImages before ShowModal' );
  CaptForm.ShowModal();
  N_Dump1Str( 'CSH >> CDSCaptureImages end' );

end; // procedure TN_CMCDServObj16.CDSCaptureImages

//***************************************** TN_CMCDServObj16.CDSSettingsDlg ***
// call settings dialog
//
//     Parameters
// APDevProfile - pointer to profile
//
procedure TN_CMCDServObj16.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  frm: TN_CMCaptDev16aForm; // CSH Settings form
  raw: Boolean;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'CSH >> CDSSettingsDlg begin' );
  frm := TN_CMCaptDev16aForm.Create( application );
  frm.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
  frm.CMOFPDevProfile := APDevProfile; // link form variable to profile
  frm.Caption := APDevProfile.CMDPCaption; // set form caption
  frm.CMOFPDevProfile := PProfile;
  raw := False;

  if ( 0 < Length( PProfile.CMDPStrPar1 ) ) then
    raw := ( '1' = Copy( PProfile.CMDPStrPar1, 1, 1 )  );

  frm.cbRaw.Checked := raw;
  frm.ShowModal(); // Show setup form
  N_Dump1Str( 'CSH >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj16.CDSSettingsDlg

//********************************* TN_CMCDServObj16.CDSStartCaptureToStudy ***
// Start Capture to study
//
//     Parameters
// APDevProfile - pointer to device profile record
// AStudyDevCaptAttrs - resulting Device Capture Interface
// Result - Returns Study Capture State code (TK_CMStudyCaptState)
//
function TN_CMCDServObj16.CDSStartCaptureToStudy(  APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState;
var
  SensorSType: string;
  
begin
  Result := inherited CDSStartCaptureToStudy( APDevProfile, AStudyDevCaptAttrs );
  SensorSType := FCapturePrepare( APDevProfile, TRUE );
  if SensorSType <> '' then
    with AStudyDevCaptAttrs do
    begin
      SetLength(BufSlidesArray,0);
      PSlideArr := @BufSlidesArray;
      CMSDCDDlg := CaptForm;
      CMSDCDDlgCPanel := CaptForm.CtrlsPanel;
      CaptForm.CMOFPNewSlides  := @BufSlidesArray; // for using in CMCaptDev16Form methods
      Result := K_cmscOK;
  //    if False then // DEBUG CODE for CR sensor type simulation
      if SensorSType = 'IO' then
      begin
//        HideFiltersFlag := False;
        CMSDCDCaptureSlideProc := FCaptureAutoStart;
      end else
      begin
        HideFiltersFlag := True;
        Result := K_cmscSkipPreview; // for CR Sensor Type
      end;
      CMSDCDCaptureDisableProc := FCaptureDisable; // Device CMS Capture Dlg enable  procedure of object
      CMSDCDCaptureEnableProc := FCaptureEnable; // Device CMS Capture Dlg enable  procedure of object
    end;

  N_Dump1Str( 'CSH >> CDSStartCaptureToStudy Res=' + IntToStr(Ord(Result)) );

end; // function TN_CMCDServObj16.CDSStartCaptureToStudy

//************************************************ TN_CMCDServObj16.Destroy ***
// destructor TN_CMCDServObj16.Destroy
//
destructor TN_CMCDServObj16.Destroy();
begin
  CDSFreeAll();
end; // destructor TN_CMCDServObj16.Destroy

//******************************** TN_CMCDServObj16.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj16.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin

  if AProductName = 'Milan' then
    Result := 44
  else if AProductName = 'Stella AG' then
    Result := 34
  else if AProductName = 'RVGSkinLiteGUI' then
    Result := 45
  else if AProductName = 'Panoramic' then
    Result := 32
  else if AProductName = 'Cephalometric' then
    Result := 33
  else if ContainsText( AProductName, 'CS') then
    Result := 48
  else if AProductName = 'Image Video Acquisition' then
    Result := 48
  else
    Result := 47;

end; // function TN_CMCDServObj16.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj16.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj16.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin

   if AProductName = 'Milan' then
    Result := 'CR'
  else if AProductName = 'Stella AG' then
    Result := 'CR'
  else if AProductName = 'RVGSkinLiteGUI' then
    Result := 'IO'
  else if AProductName = 'Panoramic' then
    Result := 'PX'
  else if AProductName = 'Cephalometric' then
    Result := 'DX'
  else if ContainsText( AProductName, 'CS') then
    Result := 'ES'
  else if AProductName = 'Image Video Acquisition' then
    Result := 'ES';

end; // function TN_CMCDServObj16.CDSGetDefaultDevDCMMod

//**************************************** TN_CMCDServObj16.FCapturePrepare ***
// Capture Prepare
//
//     Parameters
// APDevProfile - pointer to profile
// Result - Returns SensorType
//
function TN_CMCDServObj16.FCapturePrepare( APDevProfile: TK_PCMDeviceProfile; ACaptToStudyMode : Boolean ) : string;
begin
  HideFiltersFlag := False;
  PProfile  := APDevProfile;
  Handle2D  := nil;

  CDSInitAll ();

  FillDevPos ( APDevProfile^.CMDPProductName, CurrentDevice, CurrentLine );
  Result := GetSensorSType( APDevProfile^.CMDPProductName );
  N_Dump1Str( 'CSH >> device type = ' + Result );
  if ( ( CurrentDevice < 0 ) or ( CurrentLine < 0 ) ) then
  begin
    N_CMV_ShowCriticalError( 'CSH', 'Device "' +  APDevProfile.CMDPProductName + '" not presented' );
    Exit;
  end; // if ( ( CurrentDevice < 0 ) or ( CurrentLine < 0 ) ) then
  Result := UpperCase( Result );
  if not ACaptToStudyMode then
  begin
    if Result = 'VL' then Exit;
  end
  else if not (Result = 'IO') and not (Result = 'CR') then
  begin
    Result := '';
    Exit;
  end;
{
  if ( stOther = Result ) then // unknown sensor type
  begin
    N_Dump1Str( 'CSH >> Unknown device type' );
  end; // if ( stOther = SensType ) then // unknown sensor type

  if ( stVL = Result ) then Exit;// video sensor

  FillDevPos( APDevProfile.CMDPProductName, CurrentDevice, CurrentLine );

}
  CaptForm := TN_CMCaptDev16Form.Create( Application );
  with CaptForm, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    CMOFPProfile    := TK_PCMOtherProfile( APDevProfile ); // set CMCaptDev16Form.CMOFPProfile field
    Caption         := CMDPCaption;
    CMOFNumCaptured := 0;
  end; // with CaptForm, APDevProfile^ do
 //
end; // function TN_CMCDServObj16.FCapturePrepare

//************************************** TN_CMCDServObj16.FCaptureAutoStart ***
// Capture routine with
//
procedure TN_CMCDServObj16.FCaptureAutoStart;
begin
  CaptForm.bnCaptureClick( CaptForm.bnCapture );
end; // procedure TN_CMCDServObj16.FCaptureAutoStart

//**************************************** TN_CMCDServObj16.FCaptureDisable ***
// Capture disable
//
procedure TN_CMCDServObj16.FCaptureDisable;
begin
  CaptForm.bnCapture.Enabled := FALSE;
  CaptForm.bnSetup.Enabled := FALSE;
end; // procedure TN_CMCDServObj16.FCaptureDisable

//***************************************** TN_CMCDServObj16.FCaptureEnable ***
// Capture enable
//
procedure TN_CMCDServObj16.FCaptureEnable;
begin
  CaptForm.bnCapture.Enabled := TRUE;
  CaptForm.bnSetup.Enabled := TRUE;
end; // procedure TN_CMCDServObj16.FCaptureEnable


Initialization

  // Create and Register E2V Service Object
  N_CMCDServObj16 := TN_CMCDServObj16.Create( N_CMECD_CSH_Name );
  N_CMCDServObj16.PSlideArr := nil;
  N_CMCDServObj16.Handle2D := nil;
  N_CMCDServObj16.FilterPanel := nil;
  SetLength( N_CMCDServObj16.CSHFilters, 0 );
  // Fill Filters substitutions array
  SetLength( N_CMCDServObj16.FilterSubsts, 67 );
  N_CMCDServObj16.FilterSubsts[0].OldName  := 'RVG5PERIO';
  N_CMCDServObj16.FilterSubsts[0].NewName  := 'Perio';
  N_CMCDServObj16.FilterSubsts[1].OldName  := 'RVG5ENDO';
  N_CMCDServObj16.FilterSubsts[1].NewName  := 'Endo';
  N_CMCDServObj16.FilterSubsts[2].OldName  := 'RVG5DEJ';
  N_CMCDServObj16.FilterSubsts[2].NewName  := 'DEJ';
  N_CMCDServObj16.FilterSubsts[3].OldName  := 'ENHANCEFILTERRVG5HS';
  N_CMCDServObj16.FilterSubsts[3].NewName  := 'Enhance';
  N_CMCDServObj16.FilterSubsts[4].OldName  := 'RVG5PERIO';
  N_CMCDServObj16.FilterSubsts[4].NewName  := 'Perio';
  N_CMCDServObj16.FilterSubsts[5].OldName  := 'RVG5ENDO';
  N_CMCDServObj16.FilterSubsts[5].NewName  := 'Endo';
  N_CMCDServObj16.FilterSubsts[6].OldName  := 'RVG5DEJ';
  N_CMCDServObj16.FilterSubsts[6].NewName  := 'DEJ';
  N_CMCDServObj16.FilterSubsts[7].OldName  := 'ENHANCEFILTERRVG5HR';
  N_CMCDServObj16.FilterSubsts[7].NewName  := 'Enhance';
  N_CMCDServObj16.FilterSubsts[8].OldName  := 'RVG6PERIO';
  N_CMCDServObj16.FilterSubsts[8].NewName  := 'Perio';
  N_CMCDServObj16.FilterSubsts[9].OldName  := 'RVG6ENDO';
  N_CMCDServObj16.FilterSubsts[9].NewName  := 'Endo';
  N_CMCDServObj16.FilterSubsts[10].OldName := 'RVG6DEJ';
  N_CMCDServObj16.FilterSubsts[10].NewName := 'DEJ';
  N_CMCDServObj16.FilterSubsts[11].OldName := 'ENHANCEFILTERRVG6';
  N_CMCDServObj16.FilterSubsts[11].NewName := 'Enhance';
  N_CMCDServObj16.FilterSubsts[12].OldName := 'ENHANCEFILTER';
  N_CMCDServObj16.FilterSubsts[12].NewName := 'Enhance';
  N_CMCDServObj16.FilterSubsts[13].OldName := 'RVG7PERIO';
  N_CMCDServObj16.FilterSubsts[13].NewName := 'Perio';
  N_CMCDServObj16.FilterSubsts[14].OldName := 'RVG7ENDO';
  N_CMCDServObj16.FilterSubsts[14].NewName := 'Endo';
  N_CMCDServObj16.FilterSubsts[15].OldName := 'RVG7DEJ';
  N_CMCDServObj16.FilterSubsts[15].NewName := 'DEJ';
  N_CMCDServObj16.FilterSubsts[16].OldName := 'ENHANCEFILTER';
  N_CMCDServObj16.FilterSubsts[16].NewName := 'Enhance';
  N_CMCDServObj16.FilterSubsts[17].OldName := 'RVG8PERIO';
  N_CMCDServObj16.FilterSubsts[17].NewName := 'Perio';
  N_CMCDServObj16.FilterSubsts[18].OldName := 'RVG8ENDO';
  N_CMCDServObj16.FilterSubsts[18].NewName := 'Endo';
  N_CMCDServObj16.FilterSubsts[19].OldName := 'RVG8DEJ';
  N_CMCDServObj16.FilterSubsts[19].NewName := 'DEJ';
  N_CMCDServObj16.FilterSubsts[20].OldName := 'ENHANCEFILTER';
  N_CMCDServObj16.FilterSubsts[20].NewName := 'Enhance';
  N_CMCDServObj16.FilterSubsts[21].OldName := 'CRIOPERIO';
  N_CMCDServObj16.FilterSubsts[21].NewName := 'Perio';
  N_CMCDServObj16.FilterSubsts[22].OldName := 'CRIOENDO';
  N_CMCDServObj16.FilterSubsts[22].NewName := 'Endo';
  N_CMCDServObj16.FilterSubsts[23].OldName := 'CRIODEJ';
  N_CMCDServObj16.FilterSubsts[23].NewName := 'DEJ';
  N_CMCDServObj16.FilterSubsts[24].OldName := 'CRIOV2PERIO';
  N_CMCDServObj16.FilterSubsts[24].NewName := 'Perio';
  N_CMCDServObj16.FilterSubsts[25].OldName := 'CRIOV2ENDO';
  N_CMCDServObj16.FilterSubsts[25].NewName := 'Endo';
  N_CMCDServObj16.FilterSubsts[26].OldName := 'CRIOV2DEJ';
  N_CMCDServObj16.FilterSubsts[26].NewName := 'DEJ';
  N_CMCDServObj16.FilterSubsts[27].OldName := 'PANOLINEAR';
  N_CMCDServObj16.FilterSubsts[27].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[28].OldName := 'PANOBEST';
  N_CMCDServObj16.FilterSubsts[28].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[29].OldName := 'PANOHIGH';
  N_CMCDServObj16.FilterSubsts[29].NewName := 'Strong Contrast';
  N_CMCDServObj16.FilterSubsts[30].OldName := 'ENHANCEFILTERPANOV1';
  N_CMCDServObj16.FilterSubsts[30].NewName := 'Enhance';
  N_CMCDServObj16.FilterSubsts[31].OldName := 'PANOV2LINEAR';
  N_CMCDServObj16.FilterSubsts[31].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[32].OldName := 'PANOV2BEST';
  N_CMCDServObj16.FilterSubsts[32].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[33].OldName := 'PANOV2HIGH';
  N_CMCDServObj16.FilterSubsts[33].NewName := 'Strong Contrast';
  N_CMCDServObj16.FilterSubsts[34].OldName := 'PANOV3LINEAR';
  N_CMCDServObj16.FilterSubsts[34].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[35].OldName := 'PANOV3BEST';
  N_CMCDServObj16.FilterSubsts[35].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[36].OldName := 'PANOV3HIGH';
  N_CMCDServObj16.FilterSubsts[36].NewName := 'Strong Contrast';
  N_CMCDServObj16.FilterSubsts[37].OldName := 'PANOV4LINEAR';
  N_CMCDServObj16.FilterSubsts[37].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[38].OldName := 'PANOV4BEST';
  N_CMCDServObj16.FilterSubsts[38].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[39].OldName := 'PANOV4HIGH';
  N_CMCDServObj16.FilterSubsts[39].NewName := 'Strong Contrast';
  N_CMCDServObj16.FilterSubsts[40].OldName := 'PANOV5LINEAR';
  N_CMCDServObj16.FilterSubsts[40].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[41].OldName := 'PANOV5BEST';
  N_CMCDServObj16.FilterSubsts[41].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[42].OldName := 'PANOV5HIGH';
  N_CMCDServObj16.FilterSubsts[42].NewName := 'Strong Contrast';
  N_CMCDServObj16.FilterSubsts[43].OldName := 'PANOV6LINEAR';
  N_CMCDServObj16.FilterSubsts[43].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[44].OldName := 'PANOV6BEST';
  N_CMCDServObj16.FilterSubsts[44].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[45].OldName := 'PANOV6HIGH';
  N_CMCDServObj16.FilterSubsts[45].NewName := 'Strong Contrast';
  N_CMCDServObj16.FilterSubsts[46].OldName := 'CEPHV1LINEAR';
  N_CMCDServObj16.FilterSubsts[46].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[47].OldName := 'CEPHV1OPTIMIZED';
  N_CMCDServObj16.FilterSubsts[47].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[48].OldName := 'CEPHV2LINEAR';
  N_CMCDServObj16.FilterSubsts[48].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[49].OldName := 'CEPHV2OPTIMIZED';
  N_CMCDServObj16.FilterSubsts[49].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[50].OldName := 'CEPHV2BONEDENSITY';
  N_CMCDServObj16.FilterSubsts[50].NewName := 'Bone Density';
  N_CMCDServObj16.FilterSubsts[51].OldName := 'CEPHV2EDGES';
  N_CMCDServObj16.FilterSubsts[51].NewName := 'Edges Enhancement';
  N_CMCDServObj16.FilterSubsts[52].OldName := 'CEPHV3LINEAR';
  N_CMCDServObj16.FilterSubsts[52].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[53].OldName := 'CEPHV3OPTIMIZED';
  N_CMCDServObj16.FilterSubsts[53].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[54].OldName := 'CEPHV3BONEDENSITY';
  N_CMCDServObj16.FilterSubsts[54].NewName := 'Bone Density';
  N_CMCDServObj16.FilterSubsts[55].OldName := 'CEPHV3EDGES';
  N_CMCDServObj16.FilterSubsts[55].NewName := 'Edges Enhancement';
  N_CMCDServObj16.FilterSubsts[56].OldName := 'ENHANCEFILTER';
  N_CMCDServObj16.FilterSubsts[56].NewName := 'Enhance';
  N_CMCDServObj16.FilterSubsts[57].OldName := 'CRPANOLINEAR';
  N_CMCDServObj16.FilterSubsts[57].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[58].OldName := 'CRPANOBEST';
  N_CMCDServObj16.FilterSubsts[58].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[59].OldName := 'CRPANOHIGH';
  N_CMCDServObj16.FilterSubsts[59].NewName := 'Strong Contrast';
  N_CMCDServObj16.FilterSubsts[60].OldName := 'CRCEPHLINEAR';
  N_CMCDServObj16.FilterSubsts[60].NewName := 'Linear';
  N_CMCDServObj16.FilterSubsts[61].OldName := 'CRCEPHOPTIMIZED';
  N_CMCDServObj16.FilterSubsts[61].NewName := 'Optimized Contrast';
  N_CMCDServObj16.FilterSubsts[62].OldName := 'CRCEPHBONEDENSITY';
  N_CMCDServObj16.FilterSubsts[62].NewName := 'Bone Density';
  N_CMCDServObj16.FilterSubsts[63].OldName := 'CRCEPHEDGES';
  N_CMCDServObj16.FilterSubsts[63].NewName := 'Edges Enhancement';
  N_CMCDServObj16.FilterSubsts[64].OldName := 'ENHANCEFILTER';
  N_CMCDServObj16.FilterSubsts[64].NewName := 'Enhance';
  N_CMCDServObj16.FilterSubsts[65].OldName := 'DXFILTER';
  N_CMCDServObj16.FilterSubsts[65].NewName := 'DX Filter';
  N_CMCDServObj16.FilterSubsts[66].OldName := 'ENHANCEFILTER';
  N_CMCDServObj16.FilterSubsts[66].NewName := 'Enhance';

  // Ininialize CSH variables
  with K_CMCDRegisterDeviceObj( N_CMCDServObj16 ) do
  begin
    CDSCaption      := 'CSH';
    IsGroup         := True;
    ShowSettingsDlg := True;
    DicomFileName   := '';
  end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj16 ) do

end.
