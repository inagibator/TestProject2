unit K_FCMImportExpToDCM;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  K_CM0,
  N_BaseF, N_Types, K_FPathNameFr;

type
  TK_FormCMImportExpToDCM = class(TN_BaseForm)
    BtCancel: TButton;
    BtStart: TButton;
    Label2: TLabel;
    LbIDate: TLabel;
    Label5: TLabel;
    LbITime: TLabel;
    Bevel3: TBevel;
    Label3: TLabel;
    LbICount: TLabel;
    Bevel2: TBevel;
    Bevel1: TBevel;
    LbExpCount: TLabel;
    FPathNameFrame: TK_FPathNameFrame;
    procedure FormShow(Sender: TObject);
    procedure BtStartClick(Sender: TObject);
  private
    { Private declarations }
//    ImportID : Integer;
//    ImportCount : Integer;
    SlidesID : TN_IArray;
    CMIState : TK_CMImportState;
    procedure OnPathChange();
  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMImportExpToDCM: TK_FormCMImportExpToDCM;

  function  K_CMImportExpToDCMDlg( ) : Boolean;

implementation

{$R *.dfm}
uses Math,
  N_Lib1, N_CM1, N_CMMain5F,
  K_FCMSIsodensity, K_CLib0, K_CML1F, K_CMDCM;

function  K_CMImportExpToDCMDlg( ) : Boolean;
begin

  with TK_FormCMImportExpToDCM.Create(Application) do
  begin
//    BaseFormInit ( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    Result := FALSE;
    K_CMEDAccess.EDAGetLastImportHistory1( @CMIState, @SlidesID );

    if CMIState.CMIDBID = -1 then begin
      K_CMShowMessageDlg( K_CML1Form.LLLNothingToDo.Caption,
//         'Nothing to do!',
                          mtInformation );
      Exit;
    end;
    Result := ShowModal = mrOK;
  end;


end; // function  K_CMImportExpToDCMDlg( )

procedure TK_FormCMImportExpToDCM.FormShow(Sender: TObject);
begin
//
  LbIDate.Caption := K_DateTimeToStr( CMIState.CMIDate, 'dd"/"mm"/"yyyy' );
  LbITime.Caption := K_DateTimeToStr( CMIState.CMIDate, 'hh":"nn AM/PM' );
  LbICount.Caption := IntToStr( CMIState.CMIImpCount );
  LbExpCount.Caption := '';
  FPathNameFrame.OnChange := OnPathChange;
  OnPathChange();
end; // procedure TK_FormCMImportExpToDCM.FormShow

{}
procedure TK_FormCMImportExpToDCM.BtStartClick(Sender: TObject);
const
  ExpStep = 10;
var
  IDInd, k, n, i, m : Integer;
  Slides : TN_UDCMSArray;
  CCount, WereExpCount,
  Skip3DCount, SkipMediaCount : Integer;
  SavedCursor : TCursor;
  WStr : string;
  AlreadyExistsCount, OutOfMemoryCount, ErrCount,
  AlreadyInPAQSCount, AlreadyExpCount, TotalExported  : Integer;
  FOutOfMemoryCount, FErrCount  : Integer;

label SkipSlideExport;

begin
// Prepare slides list
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  BtCancel.Enabled := FALSE;
  BtStart.Enabled     := FALSE;

  N_Dump1Str( 'Export to DICOM import after conversion Slides Count=' + IntToStr(CMIState.CMIImpCount) );
  with K_CMEDAccess do
  begin
    CCount         := 0;
    IDInd          := 0;
    WereExpCount   := 0;
    AlreadyExpCount:= 0;
    SkipMediaCount := 0;
    Skip3DCount    := 0;
    AlreadyInPAQSCount:= 0;
    FOutOfMemoryCount := 0;
    FErrCount         := 0;

    GUISilentFlag  := TRUE;
    LbICount.Caption := IntToStr( CMIState.CMIImpCount );
    LbICount.Refresh();
    K_CMSCreateDeleteMode := 1;
    while IDInd < CMIState.CMIImpCount do
    begin
      k := Min( CMIState.CMIImpCount - IDInd, ExpStep );
      K_CMEDAccess.EDAGetUDCMSlidesByID( @SlidesID[IDInd], k, Slides );
      n := Length(Slides);
      WereExpCount := WereExpCount + k - n;
      if n > 0 then
      begin
      ////////////////////////////////////////////////////////////
      // skip not 2D images and slides which already are in PACS
      //
        m := 0;
        for i := 0 to n - 1 do
        begin
          if (K_CMEDDBVersion >= 44) and (K_bsdcmsStore in Slides[i].CMSDCMFSet) then
          begin
            Inc(AlreadyInPAQSCount);
SkipSlideExport: //*****
            if Slides[i].p^.CMSPatID <> CurPatID then
              Slides[i].UDDelete();
            Continue;
          end;
          if cmsfIsMediaObj in Slides[i].p^.CMSDB.SFlags then
          begin
            Inc( SkipMediaCount );
            goto SkipSlideExport;
          end;
          if cmsfIsImg3DObj in Slides[i].p^.CMSDB.SFlags then
          begin
            Inc( Skip3DCount );
            goto SkipSlideExport;
          end;
          Slides[m] := Slides[i];
          Inc(m);
        end; // for i := 0 to n - 1 do
        SetLength( Slides, m);

        if m > 0 then
        begin
//          N_CM_MainForm.CMMFShowString( '' );
          WereExpCount := WereExpCount +
            K_DCMStoreExport( @Slides[0], m, FPathNameFrame.mbPathName.Text,
                              AlreadyExistsCount, OutOfMemoryCount, ErrCount );
          AlreadyExpCount := AlreadyExpCount + AlreadyExistsCount;
          FOutOfMemoryCount := FOutOfMemoryCount + OutOfMemoryCount;
          FErrCount := FErrCount + ErrCount;
          Inc( CCount, m );

          // Delete all created UDSlides
          for i := 0 to m - 1 do
            if Slides[i].p^.CMSPatID <> CurPatID then
              Slides[i].UDDelete();
        end; // if m > 0 then
      end; // if n > 0 then
      Inc(IDInd, k);
      LbExpCount.Caption := format( '%5d object(s) were processed',
                                      [IDInd] );
      Application.ProcessMessages();
    end; // while IDInd < CMIState.CMIImpCount do

    K_CMSCreateDeleteMode := 0;
    TotalExported := AlreadyExpCount + WereExpCount;
    LbExpCount.Caption := format( 'In total %5d were exported',
                                      [TotalExported] );

    WStr := format( ' %d object(s) were processed',
                             [IDInd] );
    if SkipMediaCount > 0 then
    begin
      WStr := WStr + #13#10 + format(
          ' %d Video object(s) were skiped',
                      [SkipMediaCount] );
    end;

    if Skip3DCount > 0 then
    begin
      WStr := WStr + #13#10 + format( ' %d 3D object(s) were skiped',
                             [Skip3DCount] );
    end;

    if AlreadyInPAQSCount > 0 then
    begin
      WStr := WStr + #13#10 + format( ' %d image(s) were already in PAQS',
                             [AlreadyInPAQSCount] );
    end; // if AlreadyInPAQSCount > 0 then

    WStr := WStr + #13#10 + format( 'Try to export %d image(s)',
                                   [CCount] );

    if FOutOfMemoryCount > 0 then
    begin
      WStr := WStr + #13#10 + format( ' %d image(s) were out memory (relaunch CMSupport and try again!!!)',
                             [FOutOfMemoryCount] );
    end;

    if FErrCount > 0 then
    begin
      WStr := WStr + #13#10 + format( ' export errors detected in %d image(s)',
                             [FErrCount] );
    end;


    WStr := WStr + #13#10 + format(
        ' %d image(s) were really exported',
                      [WereExpCount] );
    WStr := WStr + #13#10 + format( ' %d image(s) were exported earlier',
                        [AlreadyExpCount] );

//    N_Dump1Str( 'Export to DICOM import after conversion >> '#13#10 + WStr );

    K_CMShowMessageDlg( WStr, mtInformation );
  end; // with K_CMEDAccess do

//  if WereExpCount + AlreadyExpCount > 0 then
//  begin
  // Update Current Context
  with N_CM_MainForm do
  begin
//      CMMFRebuildVisSlides();
//        CMMFDisableActions( nil );
      CMMFShowStringByTimer( format( 'Totaly %d  were exported',
                             [TotalExported] ) );
//    end;
  end;
  ModalResult := mrOK;

  Screen.Cursor := SavedCursor;

end; // procedure TK_FormCMImportExpToDCM.BtOKClick
{}
//***************************** TK_FormCMImportExpToDCM.CurStateToMemIni ***
//
procedure TK_FormCMImportExpToDCM.CurStateToMemIni();
begin
  inherited;
  N_ComboBoxToMemIni( 'CMSImportExpToDCMFilesHistory', FPathNameFrame.mbPathName );
end; // end of TK_FormCMImportExpToDCM.CurStateToMemIni

//***************************** TK_FormCMImportExpToDCM.MemIniToCurState ***
//
procedure TK_FormCMImportExpToDCM.MemIniToCurState();
begin
  inherited;
  N_MemIniToComboBox( 'CMSImportExpToDCMFilesHistory', FPathNameFrame.mbPathName );
  FPathNameFrame.AddNameToTop( FPathNameFrame.mbPathName.Text );
end; // end of TK_FormCMImportExpToDCM.MemIniToCurState

procedure TK_FormCMImportExpToDCM.OnPathChange;
begin
  BtStart.Enabled := FPathNameFrame.mbPathName.Text <> '';
end; // procedure TK_FormCMImportExpToDCM.OnPathChange

end.
