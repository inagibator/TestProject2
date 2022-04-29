unit K_FCMImport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_FNameFr,
  K_CM0;

type
  TK_FormCMImport = class(TN_BaseForm)
    PBProgress: TProgressBar;
    BtReverse: TButton;
    BtProc: TButton;
    FNameFrame: TN_FileNameFrame;
    LEdTotal: TLabeledEdit;
    LEdProcessed: TLabeledEdit;
    LEdImported: TLabeledEdit;
    LEdErrors: TLabeledEdit;
    LEdDate: TLabeledEdit;
    LEdTime: TLabeledEdit;
    BtExit: TButton;
    BtReImport: TButton;
    CloseTimer: TTimer;
    procedure FormShow(Sender: TObject);
    procedure BtProcClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtReverseClick(Sender: TObject);
    procedure BtReImportClick(Sender: TObject);
    procedure CloseTimerTimer(Sender: TObject);
  private
    { Private declarations }
    LIState : TK_CMImportState; // Last Import State
    CIState : TK_CMImportState; // Cur  Import State
    ActMode : Integer; // Action  Mode: 0 - ready to start new Import
                       //               1 - ready to reverse last
                       //               2 - ready to continue or reverse last
                       //               3 - Import is started
    SaveCursor : TCursor;
    LastImportExistsOnShow : Boolean;
    StopImportFlag : Boolean;
    ImportErrSlidesMode : Boolean;
    UseImageFolders : Boolean;
    CheckImageFolders : Boolean;
    FStream : TFileStream;
    CheckDiskSpaceCount : Integer;

    procedure OnFileChange();
    procedure ShowProgress();
    function  GetUILastImportFile() : string;
    function  CheckLowDiskFreeSpace( ) : Boolean;
  public
    { Public declarations }
    function  CMSImport( ) : Boolean;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMImport: TK_FormCMImport;

procedure K_CMSlideImportDlg( );

implementation

{$R *.dfm}
uses IniFiles, GDIPAPI, Math,
     N_Types, N_Lib0, N_Lib1, N_Gra2, N_CM1, N_CMMain5F,
     K_RImage, K_CLib0, K_Gra0, K_UDT1, K_UDC, K_Script1,
     K_FCMImportReverseEnter, K_FCMImportReverse, K_CML1F;

//******************************************************* K_CMSlideImportDlg ***
// Files Import Dialog
//
procedure K_CMSlideImportDlg(  );
//var
//  i : Integer;
begin

  with TK_FormCMImport.Create(Application) do begin
//    BaseFormInit(nil);
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    FNameFrame.OnChange := OnFileChange;
    ShowModal();
{
    LbFNum.Caption := IntToStr(ASlidesCount);
    PSlide := APSlide;
    SlidesCount := ASlidesCount;
    RebuildNeededSpace( APSlide, ASlidesCount );
    ShowModal();
    Result := ExportCount;
}
  end;
end; // K_CMSlideExportDlg

//***********************************  TK_FormCMImport.FormCloseQuery ***
//
procedure TK_FormCMImport.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ActMode = 3 then
   // Ask if stop process
    CanClose := mrYes = K_CMShowMessageDlg( K_CML1Form.LLLDBImport1.Caption,
//            'Do you really want to interrupt import?',
            mtConfirmation, [], TRUE, K_CML1Form.LLLDBImport2.Caption );
//                                    'Import interrupt confirmation'

end; // end of TK_FormCMImport.FormCloseQuery

//***********************************  TK_FormCMImport.MemIniToCurState  ******
//
procedure TK_FormCMImport.BtReverseClick(Sender: TObject);
var
  Ind : Integer;
begin
  if not K_CMReverseImportConfirmDlg( ) then Exit;
  if K_CMReverseImportDlg( ) then begin
    with FNameFrame.mbFileName.Items do begin
      Ind := IndexOf( GetUILastImportFile() );
      if Ind >= 0 then
        Delete(Ind);
    end;
    FormShow(Sender);
  end;
end; // end of TK_FormCMImport.MemIniToCurState

//***********************************  TK_FormCMImport.BtReImportClick ***
//
procedure TK_FormCMImport.BtReImportClick(Sender: TObject);
begin
  ImportErrSlidesMode := TRUE;
  BtProcClick(Sender);
  ImportErrSlidesMode := FALSE;
end; // end of TK_FormCMImport.BtReImportClick

//*********************************************** TK_FormCMImport.BtProcClick ***
//
procedure TK_FormCMImport.BtProcClick(Sender: TObject);
begin

  if ActMode <> 3 then begin
  // Start or Continue Import
    ActMode := 3;

    BtExit.Enabled := FALSE;
    BtReverse.Enabled := FALSE;
    BtReImport.Enabled := FALSE;
    BtProc.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';


    SaveCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;

    // Disable CMS UI
    N_CM_MainForm.CMMSetUIEnabled( FALSE );
{
    Include( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled);
    N_CM_MainForm.CMMFDisableActions( Self );
    N_AppSkipEvents := TRUE;
    K_CMD4WSkipCloseUI := TRUE;
}

    CMSImport( );

    if K_CMD4WAppFinState then Exit;

    // Enable CMS UI
    N_CM_MainForm.CMMSetUIEnabled( TRUE );
{
    K_CMD4WSkipCloseUI := FALSE;
    N_AppSkipEvents := FALSE;
    Exclude( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled);
    N_CM_MainForm.CMMFDisableActions( Self );
}
    Screen.Cursor := SaveCursor;

    StopImportFlag := FALSE;

    BtExit.Enabled := TRUE;
    BtReImport.Enabled := CIState.CMIImpCount <> CIState.CMIProcCount;
    if CIState.CMIAllCount = 0 then
    begin
      ActMode := 0;
      BtProc.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
    end
    else
    begin
      ActMode := 2;
      BtProc.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
      LIState := CIState;
      if CIState.CMIAllCount = CIState.CMIProcCount then begin
        ActMode := 1;
        BtProc.Enabled := FALSE;
      end;
    end;
    BtReverse.Enabled := ActMode > 0;

  end
  else
  begin
   // Stop Import
     StopImportFlag := TRUE;
  end;
end; // TK_FormCMImport.BtProcClick

//*********************************************** TK_FormCMImport.FormShow ***
//
function TK_FormCMImport.GetUILastImportFile() : string;
begin
  Result := LIState.CMIXMLSlidesFName;
  if Result <> '' then Exit;
  Result := format( 'Import DB ID=%d', [LIState.CMIDBID] );
  N_Dump1Str( '!!!Last Import XML file is undefined' );
end; // function TK_FormCMImport.GetUILastImportFile

//********************************************* TK_CMEDDBAccess.CheckLowDiskFreeSpace ***
// Ñheñk Minimal Server Free Space
//
function TK_FormCMImport.CheckLowDiskFreeSpace( ) : Boolean;
var
  FreeSpaceAvailable : Int64;
begin
  Result := TRUE;
  if not (K_CMEDAccess is TK_CMEDDBAccess ) or
     K_CMDisableDiskFreeSpaceCheck then Exit;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    EDAGetImgDiskFreeSpace( FreeSpaceAvailable );
    if FreeSpaceAvailable < K_CMSLowServerFreeSpace then
    begin
      K_CMShowMessageDlg1( EDAPrepFreeSpaceWarnText( FreeSpaceAvailable, '' ) +
                           K_CML1Form.LLLDBImport3.Caption,
//        '                Media Suite cannot continue the import.'#13#10 +
//        'Please free up more space on your Server PC Hard Drive and resume the import.',
                           mtWarning, [mbOK] );
      Result := FALSE;
    end;
  end;

end; // procedure TK_FormCMImport.CheckLowDiskFreeSpace


//*********************************************** TK_FormCMImport.FormShow ***
//
procedure TK_FormCMImport.FormShow(Sender: TObject);
var
  FreeSpaceAvailable : Int64;
  Res : Word;
begin
  K_CMEDAccess.EDAGetLastImportHistory1( @LIState, nil );

  if (K_CMEDAccess is TK_CMEDDBAccess ) and
     not K_CMDisableDiskFreeSpaceCheck then
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    EDAGetImgDiskFreeSpace( FreeSpaceAvailable );
    if FreeSpaceAvailable >= 2 * K_CMSNormServerFreeSpace then  // >= 4GB
      CheckDiskSpaceCount := 100
    else if FreeSpaceAvailable >= K_CMSNormServerFreeSpace then // >= 2GB
      CheckDiskSpaceCount := 50
    else
      CheckDiskSpaceCount := 10;

    if FreeSpaceAvailable < K_CMSLowServerFreeSpace then
    begin
      CheckDiskSpaceCount := -1;
      if LIState.CMIImpCount <= 0 then
      begin
        CheckDiskSpaceCount := -2;
        K_CMShowMessageDlg1( EDAPrepFreeSpaceWarnText( FreeSpaceAvailable, '' ) +
                             K_CML1Form.LLLDBImport4.Caption + #13#10 + K_CML1Form.LLLDBImport5.Caption,
//          'CMS requires minimum 1,000.00Mb of free space to import objects after conversion.'#13#10 +
//          'Please free up more space on your Server PC Hard Drive and start the import again.',
                             mtWarning, [mbOK] );
      end   // if LIState.CMIImpCount <= 0 then
      else
      begin // if LIState.CMIImpCount > 0 then
        Res := K_CMShowMessageDlg1( EDAPrepFreeSpaceWarnText( FreeSpaceAvailable, '' ) +
                                    K_CML1Form.LLLDBImport4.Caption + #13#10 + K_CML1Form.LLLDBImport6.Caption,
//          'CMS requires minimum 1,000.00Mb of free space to import objects after conversion.'#13#10 +
//          '     You can only undo your last conversion. Do you still wish to proceed?',
                                    mtWarning, [mbYes,mbNo] );
        if Res <> mrYes then
          CheckDiskSpaceCount := -2;
      end; // if LIState.CMIImpCount > 0 then
    // Close Import Form
//      Close(); // !!! Close doesn't work - Close by CloseTimer.OnTimer
      if CheckDiskSpaceCount = -2 then
      begin
        CloseTimer.Enabled := TRUE;
        Exit;
      end;
    end; // if FreeSpaceAvailable < K_CMSLowServerFreeSpace then
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do

//  K_CMEDAccess.EDAGetLastImportHistory1( @LIState, nil );
  LastImportExistsOnShow := LIState.CMIDBID <> -1;
  if LastImportExistsOnShow then
    FNameFrame.AddFileNameToTop( GetUILastImportFile() );
  OnFileChange();

end; // TK_FormCMImport.FormShow

//*********************************************** TK_FormCMImport.OnPathChange ***
// Rebuild View after File Change
//
procedure TK_FormCMImport.OnFileChange();
begin
  with CIState do
  begin
    if LastImportExistsOnShow                                   or
       (FNameFrame.mbFileName.Text = LIState.CMIXMLSlidesFName) or
       (FNameFrame.mbFileName.Text = GetUILastImportFile()) then
      CIState := LIState
    else
    begin
      K_CMImportClear(@CIState);
      CMIXMLSlidesFName := FNameFrame.mbFileName.Text;
    end;

  // Rebuild View
    LEdDate.Text := '';
    LEdTime.Text := '';
    if CMIDBID <> -1 then begin
      LEdDate.Text := K_DateTimeToStr( CMIDate, 'dd"/"mm"/"yyyy' );
      LEdTime.Text := K_DateTimeToStr( CMIDate, 'hh":"nn AM/PM' );
    end;

    ActMode := 0;
    BtProc.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
    BtProc.Enabled := (CMIXMLSlidesFName <> '') and (CheckDiskSpaceCount >= 0);
    BtReverse.Enabled := CMIImpCount > 0;
    BtReImport.Enabled := (CMIImpCount <> CMIProcCount) and (CheckDiskSpaceCount >= 0);
    if BtReverse.Enabled then
      ActMode := 1;
    if CMIAllCount > 0 then
    begin
      BtProc.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
      if CMIAllCount = CMIProcCount then
      begin
        ActMode := 2;
        BtProc.Enabled := FALSE;
      end;
    end; // if CMIAllCount > 0 then
    ShowProgress();
  end; // with CIState do
  LastImportExistsOnShow := FALSE;

end; // TK_FormCMImport.OnFileChange

//*********************************************** TK_FormCMImport.ShowCurState ***
// Show Import Progress
//
procedure TK_FormCMImport.ShowProgress();
begin
  with CIState do
  begin
    LEdTotal.Text :=     '      ?';
    LEdProcessed.Text := '      ?';
    LEdErrors.Text :=    '      ?';
    if CMIXMLSlidesFName <> '' then
    begin
      LEdTotal.Text :=     format( '%7d', [CMIAllCount] );
      LEdProcessed.Text := format( '%7d', [CMIProcCount] );
      LEdErrors.Text :=    format( '%7d', [CMIErrCount] );

      LEdTotal.Refresh;
      LEdProcessed.Refresh;
      LEdErrors.Refresh;
    end; // if CMIXMLSlidesFName <> '' then

    LEdImported.Text := format( '%7d', [CMIImpCount] );
    PBProgress.Position := 0;
    if CMIAllCount > 0 then
      PBProgress.Position := Round( 100 * CMIProcCount / CMIAllCount );
    PBProgress.Refresh;
    LEdImported.Refresh;
  end; // with CIState do

end; // TK_FormCMImport.OnFileChange

//************************************** TK_FormCMImport.CMSImport ***
// Impopt Slides from External DB
//
//     Parameters
// ASlidesXMLFName - XML file name with slides Info
//
function TK_FormCMImport.CMSImport( ) : Boolean;
const
  K_CMSImportLogChanInd = 1;
var
  ImportNotes : TK_CMSImportNotes;
  TmpUDRoot, SlidesUDRoot : TN_UDBase;
  TmpUDSlide : TN_UDCMSlide;
  SlideUDInfo : TK_UDStringList;
  PatientsCrossTab, ProvidersCrossTab : THashedStringList;
  FPath : string;
  i : Integer;
  SVal : string;
  ImpImageFlag : Boolean;
  VideoFExtList : TStringList;
  F: TSearchRec;
  FName : string;
  FNameR : string;
  FNameN : string;
  SSlideID : string;
  FSlide : TN_UDCMSlide;
  DIB1StoreFormat : TN_UDDIBDataFormat;

  SPatID : string;
  IPatID : Integer;
  SDTCr  : string;
  SkipLoadMes, WMes, Mes : string;
  FilesDir: string;

  DIB1, DIB2: TN_DIBObj;
  SavedCurSlidesList : TList;
  SavedVisSlidesArray  : TN_UDCMSArray; // Current Visible Slides Array
  ProperXMLFlag : Boolean;
  AddFileExistFlag : Boolean;

//  GPCWrapper : TK_GPDIBCodecsWrapper;
//  GPStatus: TStatus;

  SkipAbsID : Boolean;
  SkipPatIDErr : Boolean;
  SkipDTCrErr : Boolean;
  SkipIMGFileFormatErr : Boolean;
  SkipIMGFileAbsErr : Boolean;
  SkipVideoFileFormatErr : Boolean;
  SkipVideoFileAbsErr : Boolean;
  SkipWrongTagErr : Boolean;
  Skip3DPathErr   : Boolean;
  PSkipErrorFlag : PBoolean;

  ErrSlidesIndsSL : TStringList;
  ErrSlidesIndsFName : string;
  ErrSlideInd : Integer;
  ErrSlideImpCount : Integer;

  CheckDiskSpaceInd : Integer;
  CheckMemSpaceInd : Integer;
  ImportErrCode : Integer;

Label LoopCont1, LExit0;


  procedure AddLogError( AErr : string; ASkipErrCount : Boolean = FALSE );
  begin
    N_Dump2Str( 'Import Error >> ' + SkipLoadMes + Mes + ' ' + AErr );
    if not ASkipErrCount and not ImportErrSlidesMode then
      Inc(CIState.CMIErrCount);
    N_LCAdd( K_CMSImportLogChanInd, SkipLoadMes + AErr + Mes );
  end; // procedure AddLogError

  procedure AddLogCrossError( AFieldName : string );
  begin
    N_Dump2Str( 'Import Error >> ' + SkipLoadMes + ' Cross Code for ' + AFieldName + '=' +
                SVal + ' not found' + Mes );
    if not ImportErrSlidesMode then
      Inc(CIState.CMIErrCount);
    N_LCAdd( K_CMSImportLogChanInd, SkipLoadMes + 'D4W Patient Cross Code for ' +
               AFieldName + '=' + SVal + ' not found' + Mes );
  end; // procedure AddLogCrossError

  procedure AddLogFieldError( AFieldName : string; AddInfo : string = '' );
  begin
    N_Dump2Str( 'Import Error >> ' + SkipLoadMes +  ' Field ' + AFieldName + '="' + SVal + '"' + AddInfo + Mes );
    if not ImportErrSlidesMode then
      Inc(CIState.CMIErrCount);
    N_LCAdd( K_CMSImportLogChanInd, SkipLoadMes + 'Field ' +
               AFieldName + '="' + SVal + '"' + AddInfo + Mes );
  end; // procedure AddLogFieldError

  function ParseIntField( AFieldName : string; APField : PInteger ) : Integer;
  begin
    Result := StrToIntDef( SVal, -1 );
    if Result <> -1 then
      APField^ := Result
    else
      AddLogFieldError( AFieldName, ' is not Integer ' );
  end; // function ParseIntField

  procedure ParseDateField( AFieldName : string; APField : PDateTime );
  var
    WDateTime : TDateTime;
    ErrFlag : Boolean;
  begin
    WDateTime := K_StrToDateTime( SVal, FALSE, @ErrFlag );
    if ErrFlag then
      AddLogFieldError( AFieldName, ' has wrong date format ' )
    else
      APField^ := WDateTime;
  end; // procedure ParseDateField

  procedure SetSLideFields();
  var
    WDbl : Double;
    WI64 : Int64;
    SProvID : string;
  begin
    // Set Import Fields
    SkipLoadMes := '';
    with FSlide, P()^ do
    begin
      ObjName := SSlideID;

//      CMSPatId := StrToIntDef( SPatID, CMSPatId );
      if not K_CMDemoModeFlag then
      begin
{
        SVal := SPatID;
        if PatientsCrossTab <> nil then begin
          SVal := PatientsCrossTab.Values[SPatID];
          if SVal = '' then begin
            SVal := SPatID;
            AddLogCrossError( 'PatID' );
          end;
        end;
        if ParseIntField( 'PatID', @CMSPatId ) = -1 then begin
          CMSPatId := 999999999;
          N_LCAdd( K_CMSImportLogChanInd, 'D4W Patient Code was set to 999999999' + Mes );
        end;
}
        CMSPatId := IPatID;
      end;

//      CMSDTCreated := K_StrToDateTime( SDTCr );
      SVal := SDTCr;
      if SVal <> '' then
        ParseDateField( 'DTCr', @CMSDTCreated );
      CMSDTImgMod    := CMSDTCreated; // Slide DateTime Img Modified
      CMSDTMapRootMod:= CMSDTCreated; // Slide DateTime MapRoot Modified
      CMSDTPropMod   := CMSDTCreated; // Slide DateTime Prop Modified
      CMSDTTaken     := CMSDTCreated; // Slide DateTime Taken

      SVal := SlideUDInfo.SL.Values['DTTaken'];
      if SVal <> '' then
        ParseDateField( 'DTTaken', @CMSDTTaken );
//        CMSDTTaken := K_StrToDateTime( SVal, @ErrFlag );

      SVal := SlideUDInfo.SL.Values['RTeethFlags'];
      if SVal <> '' then
        ParseIntField( 'RTeethFlags', PInteger(@CMSTeethFlags) );
//        CMSTeethFlags := StrToIntDef( SVal, 0 );

      SVal := SlideUDInfo.SL.Values['LTeethFlags'];
      if SVal <> '' then
      begin
        ParseIntField( 'LTeethFlags', PInteger(@WI64) );
//        WI64 := StrToIntDef( SVal, 0 );
        CMSTeethFlags := (WI64 shl 32) or CMSTeethFlags;
      end;

      SVal := SlideUDInfo.SL.Values['CompCr'];
      if SVal <> '' then
        CMSCompIDCreated := SVal;

      SVal := SlideUDInfo.SL.Values['ProvIDCr'];
      if SVal <> '' then
      begin
        if ProvidersCrossTab <> nil then
        begin
          SProvID := ProvidersCrossTab.Values[SVal];
          if SProvID <> '' then
            SVal := SProvID
          else
            AddLogCrossError( 'ProvIDCr' );
        end;
        ParseIntField( 'ProvIDCr', PInteger(@CMSProvIDCreated) );
      end;
//        CMSProvIDCreated := StrToIntDef( SVal, CMSProvIDCreated );

      SVal := SlideUDInfo.SL.Values['Diagn'];
      if SVal <> '' then
        CMSDiagn := SVal;

      SVal := SlideUDInfo.SL.Values['Resolution'];
      if SVal <> '' then
      begin
        WDbl := StrToFLoatDef( SVal, -1);
        if WDbl = -1 then
          AddLogFieldError( 'Resolution', ' is not number ' )
        else
        begin
          CMSDB.PixPermm := WDbl / 25.4;
          CMSDB.SFlags := CMSDB.SFlags + [cmsfUserCalibrated];
        end;
//        CMSDB.PixPermm := StrToFLoatDef( SVal, CMSDB.PixPermm ) / 25.4;
      end;

      SVal := Trim(SlideUDInfo.SL.Values['SDescr']);
      if SVal <> '' then
        CMSSourceDescr := SVal
      else
        CMSSourceDescr := 'IDB: ' + ExtractFileName( FName );

      SVal := SlideUDInfo.SL.Values['DTMod'];
      if SVal <> '' then
      begin
//        CMSDTImgMod := K_StrToDateTime( SVal );
        ParseDateField( 'DTMod', @CMSDTImgMod );
        CMSDTMapRootMod := CMSDTImgMod;
        CMSDTPropMod := CMSDTImgMod;
      end;

      SVal := SlideUDInfo.SL.Values['CompMod'];
      if SVal <> '' then
        CMSCompIDModified := SVal;

      SVal := SlideUDInfo.SL.Values['ProvIDMod'];
      if SVal <> '' then
      begin
        if ProvidersCrossTab <> nil then
        begin
          SProvID := ProvidersCrossTab.Values[SVal];
          if SProvID <> '' then
            SVal := SProvID
          else
            AddLogCrossError( 'ProvIDMod' );
        end;
        ParseIntField( 'ProvIDMod', PInteger(@CMSProvIDModified) );
      end;
//        CMSProvIDModified := StrToIntDef( SVal, CMSProvIDModified );

      SVal := SlideUDInfo.SL.Values['MTypeName'];
      if SVal <> '' then  //  Add New Media Type
        K_CMEDAccess.EDAddNewMediaType( CMSMediaType, SVal );

      SVal := SlideUDInfo.SL.Values['LocIDCr'];
      if SVal <> '' then
        ParseIntField( 'LocIDCr', PInteger(@CMSLocIDCreated) );
//        CMSLocIDCreated := StrToIntDef( SVal, CMSLocIDCreated );

      SVal := SlideUDInfo.SL.Values['LocIDMod'];
      if SVal <> '' then
        ParseIntField( 'LocIDMod', PInteger(@CMSLocIDModified) );
//        CMSLocIDModified := StrToIntDef( SVal, CMSLocIDModified );

    end;
  end; // procedure SetSLideFields

  procedure FinSlideStoring();
  var
    Flags : Integer;
    Folder3D : string;
  begin
    SetSLideFields();
    Flags := Word(FSlide.P.CMSDB.SFlags);
    N_Dump2Str( Format(
              '%s Flags=$%x', [FSlide.ObjInfo, Flags] ));
    K_CMEDAccess.EDAAddSlide( FSlide, TRUE );
    K_CMEDAccess.EDASaveSlidesList( nil );

    // Copy 3D files
    if cmsfIsImg3DObj in TN_CMSlideSFlags(word(Flags)) then
    begin // Copy 3D files
      Folder3D := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( FSlide ) +
                                          K_CMSlideGetImg3DFolderName( FSlide.ObjName );
      K_CopyFolderFiles( FName, Folder3D + 'SrcFiles\' );
    end; // Copy 3D files

    CIState.CMILastSlideSID := FSlide.ObjName;
    Inc(CIState.CMIImpCount);
    if ImportErrSlidesMode then
      Dec( CIState.CMIErrCount );
    K_CMEDAccess.EDAChangeImportInfo1( @CIState );

    K_CMEDAccess.EDAClearCurSlidesSet();
    if (CIState.CMIImpCount mod 10) = 0 then
    begin
      K_CMEDAccess.TmpStrings.Clear;
      N_DelphiHeapInfo( K_CMEDAccess.TmpStrings, $0080 );
      N_Dump2Str( format( 'Memory >> %s %s ',
         [K_CMEDAccess.TmpStrings[0], K_CMEDAccess.TmpStrings[1]] ));
    end;

  end; // procedure FinSlideStoring

  function ImportFromFile( var AFName : string ) : Integer;
  // Result 0 - OK, 1 - format error 2 - out of memory
  var
    RIRCODE : TK_RIResult;

    procedure DumpExceptionInfo( const AExceptMes : string );
    begin
      N_Dump2Str( Format(
        'File "%s" import error >> %s', [ExtractFileName(AFName), AExceptMes] ));
      FreeAndNil( FStream );
      DIB2.Free();
    end;

  begin
    Result := 1;
    DIB1StoreFormat := uddfNotDef;
    DIB2 := nil;
    if FileExists( AFName ) then
    begin
    // Import from *.cmsi
      try
        DIB2 := N_CreateDIBFromCMSI( AFName );
        DIB1 := DIB2;
{
        if DIB2.DIBExPixFmt = epfGray16 then
        begin
        // 16-bit Grey
          DIB2 := N_CreateGray8DIBFromGray16( DIB1 );
          DIB1.Free;
        end
        else
}
        if K_CMImgMaxPixelsSize < DIB2.DIBSize.X * DIB2.DIBSize.Y then
          DIB1StoreFormat := uddfJPEG; // Big Image Store as JPEG
        N_Dump2Str( Format(
          'From CMSI Image %dx%d DIBPixFmt=%d DIBExPixFmt=%d, F=%s',
                     [DIB2.DIBSize.X, DIB2.DIBSize.Y,
                      Ord(DIB2.DIBPixFmt), Ord(DIB2.DIBExPixFmt),
                      ExtractFileName(AFName)] ));
      except
        on E: Exception do
        begin
          DumpExceptionInfo( E.Message );
          Exit;
        end;
      end;
    end
    else
    begin
    // Import from *.bmp
      AFName := ChangeFileExt( AFName, '.bmp' );
      if not FileExists( AFName ) then
      begin
        AFName := ChangeFileExt( AFName, '.jpg' );
        if not FileExists( AFName ) then
        begin
          AFName := ChangeFileExt( AFName, '.jpeg' );
          if not FileExists( AFName ) then
          begin
            AFName := ChangeFileExt( AFName, '.tif' );
            if not FileExists( AFName ) then
            begin
              AFName := ChangeFileExt( AFName, '.tiff' );
              if not FileExists( AFName ) then
              begin
                AFName := ChangeFileExt( FName, '.gif' );
                if not FileExists( AFName ) then
                begin
                  AFName := ChangeFileExt( AFName, '.png' );
                  if not FileExists( AFName ) then
                  begin
                    AFName := ChangeFileExt( AFName, '.*' );
                    Exit;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;

      try
        FStream := TFileSTream.Create( AFName, fmOpenRead, fmShareDenyNone );
        RIRCODE := K_RIObj.RIOpenStream( FStream );
        if (K_RIObj is TK_RIGDIP) and (RIRCODE <> rirOK) then
        begin
          if K_RIObj.RIGetLastNativeErrorCode() = Ord(Win32Error) then
          begin
            N_Dump2Str( 'Import GDI+ stream error, try from ' + ExtractFileName(AFName) );
  //          FreeAndNil(FStream); // Needed to Skip Image Initial Data Save
  //          DIB1StoreFormat := K_CMEDAccess.SlidesDIBFormat; // Set Default Initial Image Data Save Format
            K_CMSCheckMemFreeDump();
            RIRCODE := K_RIObj.RIOpenFile( AFName );
          end;
        end;

        if RIRCODE <> rirOK then
        begin
          DumpExceptionInfo( format( 'RImage %s LoadError Res=%d', [K_RIObj.ClassName, K_RIObj.RIGetLastNativeErrorCode()] ) );
          Exit;
        end;
        DIB2 := nil;
        K_RIObj.RIMaxPixelsCount := K_CMImgMaxPixelsSize;
        RIRCODE := K_RIObj.RIGetDIB( 0, DIB2 );
        K_RIObj.RIMaxPixelsCount := 0;
        if RIRCODE <> rirOK then
        begin
          if RIRCODE = rirOutOfMemory then Result := 2;
          DumpExceptionInfo( format( 'RImage %s GetDIB %dx%d Error Res=%d',
                              [K_RIObj.ClassName,
                               K_RIObj.RILastImageSize.X,K_RIObj.RILastImageSize.Y,
                               K_RIObj.RIGetLastNativeErrorCode()] ) );
          K_RIObj.RIClose();
          Exit;
        end;

        N_Dump2Str( format( 
          'From RImage %s %dx%d create %dx%d, F=%s',
                     [K_RIObj.ClassName,
                      K_RIObj.RILastImageSize.X, K_RIObj.RILastImageSize.Y,
                      DIB2.DIBSize.X, DIB2.DIBSize.Y,
                      ExtractFileName(AFName)] ));

        if (K_RIObj.RILastImageSize.X <> DIB2.DIBSize.X) or
           (K_RIObj.RILastImageSize.Y <> DIB2.DIBSize.Y) then
        begin
          FreeAndNil( FStream ); // Skip Image Initial Data Save
          DIB1StoreFormat := uddfJPEG;
        end
        else
        if SameText( ExtractFileExt(AFName), '.bmp' ) then
        begin
          FreeAndNil( FStream ); // Skip Image Initial Data Save
          DIB1StoreFormat := K_CMEDAccess.SlidesDIBFormat;
        end;

        K_RIObj.RIClose();

      except
        on E: Exception do
        begin
          DumpExceptionInfo( E.Message );
          K_CMSCheckMemFreeDump();
          Exit;
        end;
      end;
    end;
    Result := 0;
  end; // function ImportFromFile

  function ImportOneSlide( ASlideInd : Integer ) : Boolean;
  var
    ObjLPath : string;
    INN1, INN2, INN3, INN4, INN5, INNF: Integer;
  label LoopCont2;
  begin
    Result := TRUE;
    ShowProgress();
    Application.ProcessMessages();

    // Check Disk Free Space
    Inc(CheckDiskSpaceInd);
    if (CheckDiskSpaceCount > 0) and
       (CheckDiskSpaceInd >= CheckDiskSpaceCount) then
    begin
      CheckDiskSpaceInd := 0;
      if not CheckLowDiskFreeSpace( ) then
      begin
    // Close Import Form
        ActMode := 0;
        Self.Close();
        N_Dump2Str( 'Close Import by Free Space Control' );
        Result := FALSE;
        Exit;
      end;
    end;

    // Dump Mem Free Space
    Inc(CheckMemSpaceInd);
    if CheckMemSpaceInd >= 1000 then
    begin
      K_CMSCheckMemFreeDump();
      CheckMemSpaceInd := 0;
    end;

    if StopImportFlag then
    begin
      if mrYes = K_CMShowMessageDlg( K_CML1Form.LLLDBImport7.Caption,
//          'Are you sure you want to stop import?',
                                     mtConfirmation, [], TRUE ) then
      begin
        WMes := 'Import was stopped by user';
        N_LCAdd( K_CMSImportLogChanInd, WMes );
        N_Dump2Str( 'Import Error >> ' + WMes );
        Result := FALSE;
        Exit;
      end;
    end;
    if K_CMD4WAppFinState then
    begin
      N_LCAdd( K_CMSImportLogChanInd, 'Import terminated because CMS Application is closed' );
      N_Dump2Str( 'Import Error >> Terminated by Application close' );
      Result := FALSE;
      Exit; // Aplication is terminated
    end;

    PSkipErrorFlag := nil;
    SlideUDInfo := TK_UDStringList(SlidesUDRoot.DirChild(ASlideInd));
    Mes := '';
    SkipLoadMes := 'Slide is not loaded >> ';
    if SameText( SlideUDInfo.ObjName, 'Slide' ) then
    begin
      if not ImportErrSlidesMode then
          Inc(CIState.CMIProcCount);
      SSlideID := SlideUDInfo.SL.Values['ID'];

      if SSlideID = '' then
      begin
//        WMes := 'ID is absent in slide Number=' + IntToStr(CIState.CMIProcCount);
        WMes := 'ID is absent in slide Number=' + IntToStr(ASlideInd);
        PSkipErrorFlag := @SkipAbsID;
        AddLogError( WMes );

LoopCont2:
        if not ImportErrSlidesMode then
        begin
//        ErrSlidesIndsSL.Add( IntToStr(CIState.CMIProcCount) );
          ErrSlidesIndsSL.Add( IntToStr(ASlideInd) );
          ErrSlidesIndsSL.SaveToFile( ErrSlidesIndsFName );
        end;
        N_CM_MainForm.CMMFShowString( //sysout
                                      WMes );
        if (PSkipErrorFlag = nil) or (PSkipErrorFlag^ = FALSE) then
        begin
          WMes := WMes + '. Do you want to continue?';
          if mrYes <> K_CMShowMessageDlg( //sysout
                                 WMes,  mtConfirmation, [], TRUE ) then
          begin
            Result := FALSE;
            Exit;
          end;
          if PSkipErrorFlag <> nil then
            PSkipErrorFlag^ := TRUE;
        end;
        Exit;
      end;

      Mes := ' in slide ID=' + SSlideID;
      if not K_CMDemoModeFlag then
      begin
        SPatID := SlideUDInfo.SL.Values['PatID'];
        if SPatID = '' then
        begin
          WMes := 'Patient ID is absent';
          AddLogError( WMes );
          WMes := WMes + Mes;
          PSkipErrorFlag := @SkipPatIDErr;
          goto LoopCont2;
        end;

        SVal := PatientsCrossTab.Values[SPatID];
        if SVal = '' then
        begin
          SVal := SPatID;
          AddLogCrossError( 'PatID' );
          WMes := 'D4W Patient Code for PatID=' + SPatID + ' not found' + Mes;
          PSkipErrorFlag := @SkipPatIDErr;
          goto LoopCont2;
        end;

        if ParseIntField( 'PatID', @IPatID ) = -1 then
        begin
          WMes := 'D4W Patient Code for PatID=' + SPatID + ' (' + SVal + ') is not Number' + Mes;
          PSkipErrorFlag := @SkipPatIDErr;
          goto LoopCont2;
        end;
      end;

      SDTCr := SlideUDInfo.SL.Values['DTCr'];
      if SDTCr = '' then
      begin
        WMes := 'Slide Creation Date is absent';
        SkipLoadMes := '';
        AddLogError( WMes );
        SkipLoadMes := 'Slide is not loaded >> ';
        WMes := WMes + Mes;
        N_CM_MainForm.CMMFShowString( WMes );
        if not SkipDTCrErr then begin
          WMes := WMes + '. Do you want to continue?';
          SkipDTCrErr := mrYes = K_CMShowMessageDlg( //sysout
                                    WMes,  mtConfirmation, [], TRUE );
          if not SkipDTCrErr then begin
            Result := FALSE;
            Exit;
          end;
        end;
      end;

      INN1 := StrToIntDef(SSlideID, -1);
      if INN1 <= 0 then
      begin
        WMes := 'wrong ID in slide Number=' + IntToStr(ASlideInd);
        PSkipErrorFlag := @SkipAbsID;
        AddLogError( WMes );
        goto LoopCont2;
      end;

      INN3 := (INN1 - 1) div 10000;
      INN2 := INN3 * 10000 + 1;
      INN3 := INN2 + 10000 - 1;
      if not CheckImageFolders then
      begin
        CheckImageFolders := TRUE;
        UseImageFolders := DirectoryExists( format( '%s[%.6d-%.6d]', [FilesDir,INN2,INN3]) );
      end;

      ObjLPath := FilesDir;
      if UseImageFolders then
      begin
        INN5 := (INN1 - 1) div 100;
        INN4 := INN5 * 100 + 1;
        INN5 := INN4 + 100 - 1;
        INNF := Trunc( Log10(INN3) );
        ObjLPath := format( '%s[%.6d-%.6d]\[%.*d-%.*d]\', [FilesDir,INN2,INN3,
                                                           INNF,INN4,INNF,INN5] );
      end;

      TmpUDSlide.ObjName := SSlideID;
      FName := TmpUDSlide.GetIDForFileName( );
      SVal := SlideUDInfo.SL.Values['NotImgFile'];
      ImpImageFlag := (SVal = '') or (SVal = '0');
      if ImpImageFlag then
      begin
      // Import Image
        FNameR := ObjLPath + 'RF_' + FName + 'r.cmsi';
        FName := ObjLPath + 'RF_' + FName + '.cmsi';
        ImportErrCode := ImportFromFile( FName );
        if ImportErrCode <> 0 then
        begin
          WMes := 'Image File "' + FName + '"';
          if FName[Length(FName)] = '*' then
          begin
            PSkipErrorFlag := @SkipIMGFileAbsErr;
            WMes := WMes + ' with proper format is not found or is absent'
          end
          else
          begin
            PSkipErrorFlag := @SkipIMGFileFormatErr;
            if ImportErrCode = 2 then
              WMes := WMes + ' out of memory'
            else
              WMes := WMes + ' has not proper format';
          end;
          AddLogError( WMes );
          goto LoopCont2;
        end; // if ImportErrCode <> 0 then

        // Create Slide from DIB
        if FStream <> nil then
          FStream.Seek( 0, soFromBeginning );

        FSlide := K_CMSlideCreateFromDIBObj( DIB2, nil, FStream, DIB1StoreFormat, TRUE );
        FreeAndNil( FStream );
        FSlide.ObjInfo := 'Imported from Ext DB Image ' + IntToStr(CIState.CMIImpCount);
        ImportNotes.SINAddSlideNotes( FSlide, SSlideID );
        FSlide.CreateThumbnail();
        FSlide.ClearMapImage; //!!! Clear Map Image before Saving
        FinSlideStoring();
      end   // if ImpImageFlag then
      else
      begin // not if ImpImageFlag then
        if SVal <> '3D' then
        begin // Import Video
          WMes := '';
          FName := ObjLPath + 'MF_' + FName + '*.*';
          if FindFirst( FName, faAnyFile, F ) = 0 then
          begin
          // Video File Exist
            FName := ObjLPath + F.Name;
            // Check Proper Extensions
            if VideoFExtList.IndexOf( ExtractFileExt(F.Name) ) >= 0 then
            begin
            // Create New Slide From Video File
              FSlide := K_CMSlideCreateFromMediaFile( FName );
              if FSlide <> nil then
              begin
                FSlide.ObjInfo := 'Imported from Ext DB Video ' + IntToStr(CIState.CMIImpCount);
                FinSlideStoring();
              end
              else
              begin
                PSkipErrorFlag := @SkipVideoFileFormatErr;
                WMes := 'Video File "' + FName + '" has some problems';
              end;
            end   // if VideoFExtList.IndexOf( ExtractFileExt(F.Name) ) >= 0 then
            else
            begin // not if VideoFExtList.IndexOf( ExtractFileExt(F.Name) ) >= 0 then
              PSkipErrorFlag := @SkipVideoFileFormatErr;
              WMes := 'Video File "' + FName + '" has unknown extension';
            end;  // not if VideoFExtList.IndexOf( ExtractFileExt(F.Name) ) >= 0 then
          end   // if FindFirst( FName, faAnyFile, F ) = 0 then
          else
          begin // if not FindFirst( FName, faAnyFile, F ) = 0 then
            PSkipErrorFlag := @SkipVideoFileAbsErr;
            WMes := 'Video File "' + FName + '" is not found';
          end;

          FindClose( F );

          if WMes <> '' then
          begin
            AddLogError( WMes );
            goto LoopCont2;
          end;
        end   // if SVal <> '3D' then
        else
        begin // if SVal = '3D' then
        // Import 3D
          WMes := '';
          FName := ObjLPath + '3F_' + FName;
          if not DirectoryExists( FName ) then
          begin
            PSkipErrorFlag := @Skip3DPathErr;
            WMes := '3D Folder "' + FName + '" is absent';
          end
          else
          begin
          // Create New 3D Slide
            FSlide := K_CMSlideCreateForImg3DObject();
            FSlide.CreateThumbnail(); // create TMP  thubmnail
            FSlide.ObjInfo := 'Imported from Ext DB 3D ' + IntToStr(CIState.CMIImpCount);

            // Calc Files Size
            K_CMEDAccess.Int64Data := 0;
            FName := FName + '\';
            K_ScanFilesTree( FName, K_CMEDAccess.EDACalcFilesSize, '*.*' );
            with FSlide.P^ do
            begin
              CMSDB.BytesSize := K_CMEDAccess.Int64Data;
              CMSDB.MediaFExt := '';
            end;
            FinSlideStoring();
          end;

          if WMes <> '' then
          begin
            AddLogError( WMes );
            goto LoopCont2;
          end;
        end;  // if SVal = '3D' then
      end; // // not if ImpImageFlag then
    end    // if SameText( SlideUDInfo.ObjName, 'Slide' ) then
    else
    begin  // if not SameText( SlideUDInfo.ObjName, 'Slide' ) then
//      WMes := 'Wrong Tag=' + SlideUDInfo.ObjName + ' is found instead of slide Number=' + IntToStr(CIState.CMIProcCount);
      WMes := 'Wrong Tag=' + SlideUDInfo.ObjName + ' is found instead of slide Number=' + IntToStr(ASlideInd);
      AddLogError( WMes );
      PSkipErrorFlag := @SkipWrongTagErr;
      goto LoopCont2;
    end; // if not SameText( SlideUDInfo.ObjName, 'Slide' ) then
    N_CM_MainForm.CMMFShowString( format( K_CML1Form.LLLDBImport15.Caption,
//      ' %d slide(s) were imported, %d error(s) were found.',
              [CIState.CMIImpCount, CIState.CMIErrCount] ) );

  end; // function ImportOneSlide

begin
  Result := FALSE;
  SavedVisSlidesArray := nil; // for skip compiler warning
  FPath := ExtractFilePath( CIState.CMIXMLSlidesFName );
  FilesDir := FPath + 'MediaFiles';
  if not DirectoryExists( FilesDir ) then
  begin
    FilesDir := FPath + 'Images';
    if not DirectoryExists( FilesDir ) then
    begin
      K_CMShowMessageDlg1( //sysout
         'Folder with Media Files for ' + CIState.CMIXMLSlidesFName + ' is not found', mtWarning );
      Exit;
    end;
  end;
  FilesDir := IncludeTrailingPathDelimiter(FilesDir);

  FName := ExtractFilePath( CIState.CMIXMLSlidesFName );
  FNameR := FName + 'Patient.txt';
  AddFileExistFlag := FileExists( FNameR );
  if not AddFileExistFlag then
  begin
    Mes := K_CML1Form.LLLDBImport8.Caption;
//           '     File "Patient.txt" is not found. The import is not possible.'#13#10 +
//           'Please locate the file "Patient.txt" and copy it to the converter folder'
    N_LCAdd( K_CMSImportLogChanInd, 'Warning!' + Mes
//      'Warning! File "Patient.txt" is not found'#13#10 +
//      'Please copy the file to converter folder'
           );
    K_CMShowMessageDlg( Mes,
//                        '     File "Patient.txt" is not found. The import is not possible.'#13#10 +
//                        'Please locate the file "Patient.txt" and copy it to the converter folder',
                        mtWarning );
    Exit;
  end;


//patient.txt è provider.t

  TmpUDRoot := TN_UDBase.Create;
  TmpUDSlide := TN_UDCMSlide.Create;
  Mes := 'Start ';
  if CIState.CMIProcCount <> 0 then
    Mes := 'Continue ';
  N_Dump1Str( Mes + 'Import from ' + CIState.CMIXMLSlidesFName );
  N_LCAdd( K_CMSImportLogChanInd, #13#10'**** ' + Mes + 'Import on ' +
                   K_DateTimeToStr( Now(), 'dd.mm.yyyy hh:nn AM/PM' ) +
                   ' from ' + CIState.CMIXMLSlidesFName );

  K_DFStreamReadShareFlags := fmShareDenyNone;
  K_ParseXMLFromFile( TmpUDRoot, CIState.CMIXMLSlidesFName );
  K_DFStreamReadShareFlags := 0;


  SlidesUDRoot := TmpUDRoot.DirChild(0);
  ProperXMLFlag := SameText( SlidesUDRoot.ObjName, 'Slide' );
  if ProperXMLFlag then
    SlidesUDRoot := TmpUDRoot
  else
    ProperXMLFlag := (SlidesUDRoot <> nil) and  SameText(SlidesUDRoot.ObjName, 'slides' );

  if ProperXMLFlag then
  begin

    ErrSlidesIndsFName := ChangeFileExt( ExtractFileName( CIState.CMIXMLSlidesFName ), '' );
    ErrSlidesIndsFName := FName + ErrSlidesIndsFName + '!!!NotImpInds.txt';

    if CIState.CMIAllCount <> SlidesUDRoot.DirLength then
    begin
    // Clear Unlload slides Inds
      if CIState.CMIAllCount > 0 then
      begin

        Mes := format( K_CML1Form.LLLDBImport9.Caption,
//                       'Total objects number in file %d differs from previous %d.',
                       [SlidesUDRoot.DirLength, CIState.CMIAllCount] );
        if mrYes <> K_CMShowMessageDlg( format( K_CML1Form.LLLDBImport10.Caption + #13#10 +
                                        Mes + #13#10 + K_CML1Form.LLLDBImport11.Caption,
//          'Try to continue import from %s' + #13#10 +
//           Mes + #13#10 +
//          'If you select "Yes" new import will be started.'#13#10 +
//          'Are you sure you want to start new import?',
                                     [CIState.CMIXMLSlidesFName] ), mtConfirmation ) then
        begin
          N_LCAdd( K_CMSImportLogChanInd, Mes + ' Import is stopped!' );
          N_Dump1Str( Mes + ' Import is stopped!' );
          goto LExit0;
        end;
        N_Dump1Str( Mes + ' New import is started!' );
        N_LCAdd( K_CMSImportLogChanInd, Mes + ' New import is started!' );
      end;
      CIState.CMIAllCount := SlidesUDRoot.DirLength;
      CIState.CMIImpCount := 0;
      CIState.CMIErrCount := 0;
      CIState.CMIProcCount := 0;
      CIState.CMILastSlideID := -1;
      CIState.CMILastSlidesInfo := '';
      CIState.CMILastSlidesInfoM1 := '';
      K_DeleteFile( ErrSlidesIndsFName );
    end;

    PatientsCrossTab := nil;
    if AddFileExistFlag then
    begin
      PatientsCrossTab := THashedStringList.Create;
      PatientsCrossTab.LoadFromFile( FNameR );
    end;

    ProvidersCrossTab := nil;
    FNameR := FName + 'Provider.txt';
    if FileExists( FNameR ) then
    begin
      ProvidersCrossTab := THashedStringList.Create;
      ProvidersCrossTab.LoadFromFile( FNameR );
    end;

    ErrSlidesIndsSL := TStringList.Create;

    VideoFExtList := TStringList.Create;
    VideoFExtList.CaseSensitive := false;
    VideoFExtList.CommaText := N_MemIniToString( 'CMS_Main', 'VideoFileExts', '.avi' );


    SavedCurSlidesList := TList.Create;
    SavedCurSlidesList.Assign(K_CMEDAccess.CurSlidesList); // Save CurSlidesList
    SavedVisSlidesArray := Copy( K_CMCurVisSlidesArray );
    K_CMEDAccess.CurSlidesList.Clear;
//    K_CMEDAccess.EDAClearCurSlidesSet();

    if CIState.CMIDBID = -1 then
    begin
      K_CMEDAccess.EDAAddImportHistory( CIState.CMIDBID );
      CIState.CMIDate := Now();
      LEdDate.Text := K_DateTimeToStr( CIState.CMIDate, 'dd"/"mm"/"yyyy' );
      LEdTime.Text := K_DateTimeToStr( CIState.CMIDate, 'hh":"nn AM/PM' );
      K_DeleteFile( ErrSlidesIndsFName );
    end;

    if FileExists( ErrSlidesIndsFName ) then
      ErrSlidesIndsSL.LoadFromFile( ErrSlidesIndsFName )
    else if ImportErrSlidesMode then
      K_CMShowMessageDlg1( //sysout
        'File with slides indexes ' + ErrSlidesIndsFName + ' is not found', mtWarning );

    FNameN := FName + 'Notes.xml';
//    if FALSE then // temporary code to skip notes loading
    if FileExists(FNameN) then
    begin
      ImportNotes := TK_CMSImportNotes.Create();
      ImportNotes.SINLoadNotesXML( FNameN );
      ImportNotes.SINImportDumpChanel := K_CMSImportLogChanInd;
    end
    else
      ImportNotes := nil;


//    GPCWrapper := TK_GPDIBCodecsWrapper.Create;
    SkipAbsID              := TRUE;
    SkipDTCrErr            := TRUE;
    SkipPatIDErr           := TRUE;
    SkipIMGFileFormatErr   := TRUE;
    SkipIMGFileAbsErr      := TRUE;
    SkipVideoFileFormatErr := TRUE;
    SkipVideoFileAbsErr    := TRUE;
    SkipWrongTagErr        := TRUE;

    CheckDiskSpaceInd := 0;
    CheckMemSpaceInd := 0;
    K_CMSCreateDeleteMode := 1;

    UseImageFolders   := FALSE;
    CheckImageFolders := FALSE;
    if ImportErrSlidesMode then
      for i := ErrSlidesIndsSL.Count - 1 downto 0 do
      begin
        ErrSlideInd := StrToIntDef( ErrSlidesIndsSL[i], -1 );
        if ErrSlideInd < 0 then Continue;
        ErrSlideImpCount := CIState.CMIImpCount;
        if not ImportOneSlide( ErrSlideInd ) then break;
        if ErrSlideImpCount < CIState.CMIImpCount then
        begin
        // Remove Loaded Slide
          ErrSlidesIndsSL.Delete( i );
          ErrSlidesIndsSL.SaveToFile( ErrSlidesIndsFName );
        end;
      end
    else // if not ImportErrSlidesMode then
      for i := CIState.CMIProcCount to CIState.CMIAllCount - 1 do
      begin
        if not ImportOneSlide( i ) then break;
      end; // for i := 0 to SCount - 1 do

    K_CMSCreateDeleteMode := 0;


    if CIState.CMIImpCount = 0 then
    begin
      K_CMEDAccess.EDADeleteImportHistory( CIState.CMIDBID );
      CIState.CMIDBID := -1;
    end;

    ShowProgress();
    Mes := format( K_CML1Form.LLLDBImport12.Caption,
//                   '%d of %d processed slides were imported from %s',
                   [ CIState.CMIImpCount, CIState.CMIProcCount, CIState.CMIXMLSlidesFName] );
    if CIState.CMIErrCount > 0 then
      Mes := Mes + #13#10 + format( K_CML1Form.LLLDBImport13.Caption,
//                  '%d errors were found.',
                                    [CIState.CMIErrCount] );
    N_LCAdd( K_CMSImportLogChanInd, '**** ' + Mes );
//    N_Dump1Str( Mes );
    K_CMShowMessageDlg1( Mes, mtInformation );

    if K_CMDemoModeFlag then
    begin
      K_CMEDAccess.EDAGetCurSlidesSet;
      N_CM_MainForm.CMMFRebuildVisSlides();
    end
    else
    begin
      K_CMCurVisSlidesArray := Copy(SavedVisSlidesArray);
      K_CMEDAccess.CurSlidesList.Assign(SavedCurSlidesList); // Restore CurSlidesList
    end;
    Result := TRUE;
//    GPCWrapper.Free;
//    K_RIObj.RIClear();
    K_RIObj.RIClose();

    PatientsCrossTab.Free;
    ProvidersCrossTab.Free;
    SavedCurSlidesList.Free;
    VideoFExtList.Free;
    ErrSlidesIndsSL.Free;
  end
  else
  begin
    Mes := format( K_CML1Form.LLLDBImport14.Caption, [CIState.CMIXMLSlidesFName] );
//      'File ' + CIState.CMIXMLSlidesFName + ' doesn''t contain proper data';
    N_LCAdd( K_CMSImportLogChanInd, Mes );
    K_CMShowMessageDlg1( Mes, mtWarning );
  end;

LExit0:
  TmpUDRoot.Free;
  TmpUDSlide.Free;
  ImportNotes.Free;

end; // procedure TK_FormCMImport.CMSImport

//***********************************  TK_FormCMImport.CurStateToMemIni  ***
//
procedure TK_FormCMImport.CurStateToMemIni();
begin
  inherited;
  N_ComboBoxToMemIni( 'CMSImportFilesHistory', FNameFrame.mbFileName );
end; // end of TK_FormCMImport.CurStateToMemIni

//***********************************  TK_FormCMImport.MemIniToCurState ***
//
procedure TK_FormCMImport.MemIniToCurState();
begin
  inherited;
  N_MemIniToComboBox( 'CMSImportFilesHistory', FNameFrame.mbFileName );
end; // end of TK_FormCMImport.MemIniToCurState

//***********************************  TK_FormCMImport.CloseTimerTimer ***
//
procedure TK_FormCMImport.CloseTimerTimer(Sender: TObject);
begin
  CloseTimer.Enabled := FALSE;
  Close();
  N_Dump2Str( 'TK_FormCMImport closed by Free Space Restrictions'  );
end;

end.
