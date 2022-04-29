unit K_FCMFSAnalysis1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, IniFiles,
  N_BaseF, N_Types,
  K_CLib0;

type
  TK_FormCMFSAnalysis1 = class(TN_BaseForm)
    LbEDFilesCount: TLabeledEdit;
    LbEDDBCount: TLabeledEdit;
    LbEDProcCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    StatusBar: TStatusBar;
    SaveDialog: TSaveDialog;
    ChBUsePrevious: TCheckBox;
//    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
  private
    { Private declarations }
    SavedCursor: TCursor;
    AllFilesList : THashedStringList;
    AbsentFilesList, ArchivedFilesList : TStringList;

    AllCount : Integer;

  public
    { Public declarations }
    procedure ShowProgress( AllCount, CurCount : Integer );
  end;

var
  K_FormCMFSAnalysis1: TK_FormCMFSAnalysis1;

implementation

{$R *.dfm}

uses DB, GDIPAPI, Math,
  K_UDT1, K_UDC, K_UDConst, K_SBuf, K_CM0, K_CM1, K_FCMReportShow, K_Script1, {K_FEText,}
  K_STBuf,
  N_CompBase, N_Comp1, N_Lib1, N_Lib2, N_Video, N_ClassRef, N_CMMain5F, K_CML1F;

const K_BadImg   = 'Bad images';
const K_BadVideo = 'Bad video';
const K_BadImg3D = 'Bad 3D images';


//***************************************** TK_FormCMFStorageClear1.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMFSAnalysis1.FormShow(Sender: TObject);
begin
  inherited;

  SavedCursor := Screen.Cursor;

  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';

    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;
     //////////////////////////////////////
     // Get DB Slides Count
     //
      Filtered := FALSE;
      SQL.Text := 'select Count(*) from ' + K_CMENDBSlidesTable;
      Open();
      AllCount := FieldList[0].AsInteger;
      Close();
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMDBRecovery.FormShow ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

    LbEDDBCount.Text := IntToStr( AllCount );
    LbEDProcCount.Text := '0';
    LbEDFilesCount.Text := '0';
    PBProgress.Max := 1000;
    PBProgress.Position := 0;
  end;

  SavedCursor := Screen.Cursor;

end; // TK_FormCMFStorageClear1.FormShow

//***************************************** TK_FormCMFStorageClear1.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMFSAnalysis1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);

begin

  AllFilesList.Free;
  AbsentFilesList.Free;
  ArchivedFilesList.Free;


end; // TK_FormCMFStorageClear1.FormCloseQuery

//***************************************** TK_FormCMFStorageClear1.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMFSAnalysis1.BtStartClick(Sender: TObject);
var
  FName : string;
begin

// Process Slides Loop
  N_Dump1Str( 'FSA>> ' + BtStart.Caption );
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      if AbsentFilesList = nil then
      begin
        AbsentFilesList   := TStringList.Create;
        ArchivedFilesList := TStringList.Create;
      end;
      Screen.Cursor := crHourglass;

      //////////////////////////////////////
      // Build Media Objects Files List
      //

      StatusBar.SimpleText := ' Build existed files list ...';

      AllFilesList := THashedStringList.Create;
      K_CMFSBuildExistedFLists( AllFilesList, AllFilesList, AllFilesList, [] );
      AllFilesList.Sort();


      StatusBar.SimpleText := '';

      LbEDFilesCount.Text := IntToStr( AllFilesList.Count);
      N_Dump1Str( format( 'FSA>> FilesCount=%d MediaCount=%d ',
                            [AllFilesList.Count, AllCount] ) );


      ///////////////////////////////
      // Select Existing Slides
      //
      Connection := LANDBConnection;

      StatusBar.SimpleText := ' Build needed list ...';
      K_CMFSBuildNeededFLists( AbsentFilesList, AbsentFilesList, AbsentFilesList,
                               ArchivedFilesList, ArchivedFilesList, ArchivedFilesList,
                                  [], CurDSet2, ShowProgress );

      StatusBar.SimpleText := ' Compare file lists ...';
      K_CMFSCompNeededExistedFLists( AllFilesList, AbsentFilesList, ShowProgress );

      Screen.Cursor := SavedCursor;

      StatusBar.SimpleText := '';

      if mrYes = K_CMShowMessageDlg( format('%d extra files and 3D folders were found'#10#13+
                                    '%d absent files and 3D folders were found'#10#13+
                                    '%d archived files and 3D folders were found'#10#13+
                                    'Select Yes if you want to save details',
                                    [AllFilesList.Count,AbsentFilesList.Count,
                                     ArchivedFilesList.Count]), mtConfirmation ) then
//      if (AllFilesList.Count > 0) or (AbsentFilesList.Count > 0) then
      begin // Save Files List

        with SaveDialog do
        begin
          InitialDir := K_ExpandFileName(N_MemIniToString('CMS_Main',
                                         'LastExportDir', ''));

          Filter := 'File storage analysis results (*.txt)|*.txt|All files (*.*)|*.*';
          FilterIndex := 1;
//          Options := Options + [ofEnableSizing];
          Title := 'Save File Storage analysis results';

          FileName := 'CMFSAnalResults.txt';
          if Execute then
          begin
            N_Dump1Str( format( 'FSA>> Files List Analysis Base Name>> %s', [FileName] ) );
            FName := ChangeFileExt( FileName, 'Extra.txt' );
            if AllFilesList.Count > 0 then
            begin
              AllFilesList.Sort;
              AllFilesList.SaveToFile( FName );
            end
            else
            if FileExists( FName ) then
              DeleteFile( FName );

            FName := ChangeFileExt( FileName, 'Absent.txt' );
            if AbsentFilesList.Count > 0 then
            begin
              AbsentFilesList.Sort;
              AbsentFilesList.SaveToFile( FName );
            end
            else
            if FileExists( FName ) then
              DeleteFile( FName );

            FName := ChangeFileExt( FileName, 'Archived.txt' );
            if ArchivedFilesList.Count > 0 then
            begin
              ArchivedFilesList.Sort;
              ArchivedFilesList.SaveToFile( FName );
            end
            else
            if FileExists( FName ) then
              DeleteFile( FName );
        end; // if Execute then

          Free;
        end; // with SaveDialog do
      end;

      // Close Form
      ModalResult := mrOK;

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'FSA>> Restore Slides by File Exception >> ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end; // try
  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMFStorageClear1.BtStartClick


procedure TK_FormCMFSAnalysis1.ShowProgress(AllCount, CurCount: Integer);
begin
  if AllCount > 0 then
    PBProgress.Position := Round(1000 * CurCount / AllCount);
  LbEDProcCount.Text := IntToStr( CurCount );
  LbEDProcCount.Refresh();
//          Sleep(1000);

end; // procedure TK_FormCMFSAnalysis1.ShowProgress

end.
