unit K_FCMReportShow;

{$R-}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls, Grids,
  N_FNameFr, N_Types,
  K_FrRaEdit, K_Script1;

type
  TK_FormCMReportShow = class(TN_BaseForm)
    BtExport: TButton;
    Button1: TButton;
    FrRAEdit: TK_FrameRAEdit;
    BtWC: TButton;
    GBExport: TGroupBox;
    RGFormats: TRadioGroup;
    ChBOpen: TCheckBox;
    LbReportDetails: TLabel;
    SaveDialog: TSaveDialog;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure BtWCClick(Sender: TObject);
    procedure BtExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FRAData : TK_FRAData;
    ReportDataRAMatrix: TK_RArray;
    CurExpFilePath, ExpFilePath : string;
    function SelectFileName() : string;
  public
    { Public declarations }
    ReportDataSMatr: TN_ASArray;
    procedure PrepareRAFrameByDataSMatr( const AReportDetails : string = '' );
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
  end;

var
  K_FormCMReportShow: TK_FormCMReportShow;

implementation

uses ShlObj, Math,
 K_CM0, K_CLib0,
 N_Lib0, N_Lib1, N_CMExpRep, K_CML1F;

{$R *.dfm}
const
  K_FNDOC = 0;
  K_FNXLS = 1;
  K_FNHTM = 2;
  K_FNCSV = 3;
  K_FNTAB = 4;
  K_FNTXT = 5;
  K_IndToFName : array [0..3] of integer = (K_FNHTM,K_FNCSV,K_FNTAB,K_FNTXT);

procedure TK_FormCMReportShow.CurStateToMemIni;
begin
  inherited;
  N_IntToMemIni( BFSelfName, 'RGFormatsInd', RGFormats.ItemIndex );
  N_BoolToMemIni( BFSelfName, 'ExpFileOpen', ChBOpen.Checked );
  N_StringToMemIni( BFSelfName, 'ExpFilePath', ExpFilePath );
end;

procedure TK_FormCMReportShow.MemIniToCurState;
begin
  inherited;
  RGFormats.ItemIndex := N_MemIniToInt( BFSelfName, 'RGFormatsInd', 2 );
  ChBOpen.Checked := N_MemIniToBool( BFSelfName, 'ExpFileOpen', TRUE );

  ExpFilePath := K_GetWinUserDocumentsPath( 'CMS Reports\' );

//  ExpFilePath := GetEnvironmentVariable( 'USERPROFILE' ) + '\My documents\';
  ExpFilePath := N_MemIniToString( BFSelfName, 'ExpFilePath', ExpFilePath );
//  RGFormatsClick( nil );
end;

procedure TK_FormCMReportShow.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  FRAData.Free;
  ReportDataRAMatrix.ARelease();

end;

procedure TK_FormCMReportShow.FormCreate(Sender: TObject);
begin
  inherited;
  ReportDataRAMatrix := K_RCreateByTypeCode( Ord(nptString), 0 );

  FRAData := TK_FRAData.Create( FrRAEdit );
  FRAData.SkipDataBuf := true;
  FRAData.SkipClearEmptyRArrays := true;
  FRAData.SkipAddToEmpty := true;

end;

procedure TK_FormCMReportShow.PrepareRAFrameByDataSMatr( const AReportDetails : string = '' );
var
  RCount, CCount, i, j : Integer;
  PS : PString;
begin
  if Length(ReportDataSMatr) = 0 then
    Exit;

  LbReportDetails.Caption := AReportDetails;
  if AReportDetails = '' then
  begin
    i := FrRAEdit.Top - LbReportDetails.Top;
    FrRAEdit.Top := LbReportDetails.Top;
    FrRAEdit.Height := FrRAEdit.Height + i;
  end;
  RCount := Length( ReportDataSMatr ) - 1;
  CCount := Length( ReportDataSMatr[0] );

// Create Show Buffer
  ReportDataRAMatrix.ASetLength( CCount, RCount );
//  ReportDataRAMatrix.HCol := CCount -1;
  PS := ReportDataRAMatrix.P();
  for i := 1 to RCount do
    for j := 0 to CCount - 1 do
    begin
      PS^ := ReportDataSMatr[i][j];
      Inc(PS);
    end;

  FRAData.PColNames := @ReportDataSMatr[0][0];
  FRAData.PrepMatrixFrame1( [],
    [K_ramReadOnly,K_ramColVertical,K_ramSkipInfoCol,
    K_ramFillFrameWidth,K_ramSkipDataPaste,K_ramSkipColMoving,
    K_ramSkipResizeHeight,K_ramSkipResizeWidth],
    ReportDataRAMatrix, ReportDataRAMatrix.ElemType, '' );
end;

procedure TK_FormCMReportShow.BtWCClick(Sender: TObject);
var
  GR : TGridRect;
  i,j : Integer;
  buf : string;
  BufList : TStringList;
begin
  inherited;
  GR := FrRAEdit.SGrid.Selection;
  GR.Left   := Max( GR.Left, 1 );
  GR.Right  := Max( GR.Left, GR.Right );
  GR.Bottom := Min( GR.Bottom, High(ReportDataSMatr) );
  BufList := TStringList.Create();

// Add Selection
  for j := GR.Top to GR.Bottom do
  begin
    buf := '';
    for i := GR.Left - 1 to GR.Right - 2 do
      buf := buf + ReportDataSMatr[j][i] + #9;
    BufList.Add(buf + ReportDataSMatr[j][GR.Right-1] );
  end;
  K_PutTextToClipboard( BufList.Text );
  BufList.Free;
end;

procedure TK_FormCMReportShow.BtExportClick(Sender: TObject);
var
  SL : TStringList;
  SMFormat: TN_StrMatrFormat;
  RCount, CCount, i, j : Integer;
  Buf, Align, Value : string;
//  CMExpSMFlags : TN_CMExpSMFlags;
  FName : string;
  FInd : Integer;
  FParams: TN_CFPArray;

label SelectFilePath;

begin
SelectFilePath:

  FName := SelectFileName();
  if FName = '' then Exit;
  SL := nil;

  FInd := K_IndToFName[RGFormats.ItemIndex];
  case FInd of
{
  0 : K_CMShowMessageDlg( ' Is not implemented now ', mtInformation ); // XLS
  1 : begin // DOC
    CMExpSMFlags := [];
    if ChBOpen.Checked then
      CMExpSMFlags := CMExpSMFlags + [esmfShowResFile];
    N_CMExpStrMatrToWord ( ReportDataSMatr, FName, CMExpSMFlags );
  end;
}
  K_FNHTM, K_FNCSV, K_FNTAB, K_FNTXT :
    begin // HTML CSV TAB
      SL := TStringList.Create;
      CCount := Length( ReportDataSMatr[0] );
      if FInd = K_FNHTM then
      begin // HTML
        RCount := Length( ReportDataSMatr ) - 1;
        SL.Add('<html><body><table border=1 cellpadding=5 width=100%>');
        Buf := '';
        for j := 0 to CCount - 1 do
          Buf := Buf + '<th>' + ReportDataSMatr[0][j] + '</th>';
        SL.Add('<tr>' + Buf + '</tr>');
        for i := 1 to RCount do
        begin
          Buf := '';
          for j := 0 to CCount - 1 do
          begin
            Align := '';
            case (FrRAEdit.RAFCArray[j].TextPos and $F) of
            Ord(K_ppCenter)   : Align := 'align=center';
            Ord(K_ppDownRight): Align := 'align=right';
            end;
            Value := ReportDataSMatr[i][j];
            if Value = '' then Value := '&nbsp;';
            Buf := Buf + '<td '+ Align +'>' + Value + '</td>';
          end;
          SL.Add('<tr>' + Buf + '</tr>');
        end;
        SL.Add('</table></body></html>')
      end // if FInd = K_FNHTM then
      else
      if FInd = K_FNTXT then
      begin
        SetLength( FParams, CCount );
        for j := 0 to CCount - 1 do
        begin
          case (FrRAEdit.RAFCArray[j].TextPos and $F) of
          Ord(K_ppCenter)   : FParams[j].CFPFlags := [cffHorAlignCenter];
          Ord(K_ppDownRight): FParams[j].CFPFlags := [cffHorAlignRight];
          end;
        end;
        N_AlignStrMatr( ReportDataSMatr, FParams );
        N_StrMatrToStrings( ReportDataSMatr, SL, ' ' );
      end // if FInd = K_FNTXT then
      else
      begin // CSV or TAB
        SMFormat := smfCSV;
        if FInd = K_FNTAB then
          SMFormat := smfTab;
        N_SaveSMatrToStrings2( ReportDataSMatr, SL, SMFormat );
      end;
    end; // end of case: K_FNHTM, K_FNCSV, K_FNTAB, K_FNTXT
  end; // case FInd of

  if SL <> nil then
  begin
{
    if not K_ForceDirPath( CurExpFilePath ) then
    begin
      K_CMShowMessageDlg1( format( K_CML1Form.LLLReport1.Caption,
      // 'Selected file path\# %s\#Couldn''t be created. Please select proper file path.'
        [CurExpFilePath] ), mtWarning, [mbOK] );
    end
    else
}

    if not K_CMVUIMode then
    begin // CMSuite
      if not K_ForceDirPath( CurExpFilePath ) then
      begin
        CurExpFilePath := K_GetWinUserDocumentsPath( 'CMS Reports\' );
        K_ForceDirPath( CurExpFilePath );
      end;
    end
    else
    begin // CMSuiteWEB
      CurExpFilePath := ExtractFilePath( FName );
    end;

    try
      N_Dump1Str( 'Save Report to file ' + FName );
      SL.SaveToFile( FName );
      ExpFilePath := CurExpFilePath;
      if ChBOpen.Checked then
        K_ShellExecute( 'Open', FName );
      ModalResult := mrOK;
    except
      K_CMShowMessageDlg1( format( K_CML1Form.LLLReport1.Caption,
      // 'Selected full file name\# %s\#Couldn''t be created. Please select proper full file name.'
        [FName] ), mtWarning, [mbOK] );
{
        'Selected full file name'#13#10 +
        FName + #13#10 +
        'Couldn''t be created. Please select proper full file name.',
         mtWarning, [mbOK] )
}
    end;
  end;

  if K_CMVUIMode and
     Assigned(K_CMVUIDownloadFileProc) then
    K_CMVUIDownloadFileProc( FName ); // CMSuiteWEB

  SL.Free;
  if ModalResult <> mrOK then goto SelectFilePath;
end;

function TK_FormCMReportShow.SelectFileName: string;
var
  SFilter : string;
  SFExt, FExt : string;


Label SelectFile;

begin

  SFilter := 'All files (*.*)|*.*';

  case K_IndToFName[RGFormats.ItemIndex] of
  K_FNDOC : begin
    SFilter := 'Excel files (*.xls)|*.xls|' + SFilter;
    FExt := '.xls';
  end;
  K_FNXLS : begin
    SFilter := 'Word files (*.doc)|*.doc|' + SFilter;
    FExt := '.doc';
  end;
  K_FNHTM : begin
    SFilter := 'HTML files (*.html)|*.htm;*.html|' + SFilter;
    FExt := '.htm';
  end;
  K_FNCSV : begin
    SFilter := 'Excel CSV files (*.csv)|*.csv|' + SFilter;
    FExt := '.csv';
  end;
  K_FNTAB : begin
    SFilter := 'Text files (with TAB delimiter)(*.txt)|*.txt|' + SFilter;
    FExt := '.txt';
  end;
  K_FNTXT : begin
    SFilter := 'Text files (*.txt)|*.txt|' + SFilter;
    FExt := '.txt';
  end;
  end;

  if K_CMVUIMode then
  begin // CMSuiteWEB
    Result := K_ExpandFileName( '(#TmpFiles#)' + K_DateTimeToStr( Now(), '"CMSRep_"yyyy.mm.dd"_"hh-nn-ss' ) ) + FExt;
    Exit;
  end;

  Result := '';
  SaveDialog.Filter := SFilter;
  CurExpFilePath := ExpFilePath;

SelectFile:

  if not K_ForceDirPath( CurExpFilePath ) then
  begin
    K_CMShowMessageDlg1( format( K_CML1Form.LLLReport1.Caption,
    // 'Selected file path\# %s\#Couldn''t be created. Please select proper file path.'
      [CurExpFilePath] ), mtWarning, [mbOK] );
{
    K_CMShowMessageDlg1(
      'Selected file path'#13#10 +
      CurExpFilePath + #13#10 +
      'Couldn''t be created. Please select proper file path.',
       mtWarning, [mbOK] );
}
    Exit;
  end;
  SaveDialog.InitialDir := CurExpFilePath;
  SaveDialog.FileName := K_DateTimeToStr( Now(), '"CMSRep_"yyyy.mm.dd"_"hh-nn-ss' ) + FExt;
  if not SaveDialog.Execute then Exit;

  // Corret File Extension
  SFExt := ExtractFileExt( SaveDialog.FileName );
  if not SameText( SFExt, FExt ) and
     ( (FExt <> '.htm') or (LowerCase(SFExt) <> '.html') ) then
    SFExt := '';
  if SFExt = '' then
    SaveDialog.FileName := SaveDialog.FileName + FExt;

  if FileExists( SaveDialog.FileName ) then
  begin
    K_CMShowMessageDlg1( format( K_CML1Form.LLLReport3.Caption,
    // 'File %s already exists.\#Please select another report file name.'
      [ExtractFileName(SaveDialog.FileName)] ), mtWarning, [mbOK] );
{
    K_CMShowMessageDlg( 'File ' + ExtractFileName(SaveDialog.FileName) + ' already exists.'#13#10 +
                        'Please select another report file name.', mtWarning );
}
    goto SelectFile;
  end;
  CurExpFilePath := ExtractFilePath( SaveDialog.FileName );
  Result := SaveDialog.FileName;

end;

procedure TK_FormCMReportShow.FormShow(Sender: TObject);
begin
  inherited;
  ChBOpen.Enabled := not K_CMVUIMode; // CMSuite (not CMSuiteWEB)
  ChBOpen.Checked := FALSE;
end;

end.
