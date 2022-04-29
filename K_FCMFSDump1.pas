unit K_FCMFSDump1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, IniFiles,
  N_BaseF, N_Types,
  K_CLib0;

type
  TK_FormCMFSDump1 = class(TN_BaseForm)
    LbEDFilesCount: TLabeledEdit;
    LbEDDBCount: TLabeledEdit;
    LbEDProcCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    StatusBar: TStatusBar;
    SaveDialog: TSaveDialog;
    ChBFileNamesOnly: TCheckBox;
    RGContent: TRadioGroup;
//    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
  private
    { Private declarations }
    SavedCursor: TCursor;
    ExistFilesList : TStringList;
    ImgFilesList : TStringList;
    VideoFilesList : TStringList;
    Img3DFilesList : TStringList;
    AImgFilesList : TStringList;
    AVideoFilesList : TStringList;
    AImg3DFilesList : TStringList;
    ExistedImgFilesCount : Integer;
    ExistedVideoFilesCount : Integer;
    ExistedImg3DFilesCount : Integer;

    FSAnalysisFinishFlag : Boolean;

    AllCount, FProcCount : Integer;

  public
    { Public declarations }
    procedure ShowProgress( AllCount, CurCount : Integer );
  end;

var
  K_FormCMFSDump1: TK_FormCMFSDump1;

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
procedure TK_FormCMFSDump1.FormShow(Sender: TObject);
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

  ExistFilesList := TStringList.Create;
  ImgFilesList   := TStringList.Create;
  VideoFilesList := TStringList.Create;
  Img3DFilesList := TStringList.Create;

  AImgFilesList   := TStringList.Create;
  AVideoFilesList := TStringList.Create;
  AImg3DFilesList := TStringList.Create;

  ExistedImgFilesCount   := 0;
  ExistedVideoFilesCount := 0;
  ExistedImg3DFilesCount := 0;

  SavedCursor := Screen.Cursor;

end; // TK_FormCMFStorageClear1.FormShow

//***************************************** TK_FormCMFStorageClear1.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMFSDump1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);

begin
  ExistFilesList.Free;
  ImgFilesList.Free;
  VideoFilesList.Free;
  Img3DFilesList.Free;

  AImgFilesList.Free;
  AVideoFilesList.Free;
  AImg3DFilesList.Free;

end; // TK_FormCMFStorageClear1.FormCloseQuery

//***************************************** TK_FormCMFStorageClear1.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMFSDump1.BtStartClick(Sender: TObject);
var
  BuildFlags : TK_CMFSBuildFilesListFlags;
  FName : string;

begin

// Process Slides Loop
  N_Dump1Str( 'FSD>> ' + BtStart.Caption );
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      Screen.Cursor := crHourglass;
      FProcCount := 0;

      //////////////////////////////////////
      // Build Media Objects Files List
      //
      ExistFilesList.Clear;

      BuildFlags := [K_fsbflUseRelFName];
      if ChBFileNamesOnly.Checked then
        BuildFlags := BuildFlags + [K_fsbflUseExtrFName];

      if RGContent.ItemIndex < 2 then
      begin

        StatusBar.SimpleText := ' Build files list ...';
        K_CMFSBuildExistedFLists( ImgFilesList, VideoFilesList, Img3DFilesList, BuildFlags );

        ExistedImgFilesCount := ImgFilesList.Count;
        ExistFilesList.Add( format( 'Img Root=%s Count=%d', [SlidesImgRootFolder,ExistedImgFilesCount] ) );
        ExistFilesList.AddStrings( ImgFilesList );
        ImgFilesList.Clear;

        ExistedVideoFilesCount := VideoFilesList.Count;
        ExistFilesList.Add( format( 'Video Root=%s Count=%d', [SlidesMediaRootFolder,ExistedVideoFilesCount] ) );
        ExistFilesList.AddStrings( VideoFilesList );
        VideoFilesList.Clear;

        ExistedVideoFilesCount := Img3DFilesList.Count;
        ExistFilesList.Add( format( 'Img3D Root=%s Count=%d', [SlidesImg3DRootFolder,ExistedImg3DFilesCount] ) );
        ExistFilesList.AddStrings( Img3DFilesList );
        Img3DFilesList.Clear;
        StatusBar.SimpleText := '';
      end;

      LbEDFilesCount.Text := IntToStr( ExistFilesList.Count - 3);
      N_Dump1Str( format( 'FSD>> FilesCount=%d MediaCount=%d',
                            [ExistFilesList.Count, AllCount] ) );

      ///////////////////////////////
      // Select Existing Slides
      //

      if (RGContent.ItemIndex = 0) or (RGContent.ItemIndex = 2) then
      begin
        Connection := LANDBConnection;
        K_CMFSBuildNeededFLists( ImgFilesList, VideoFilesList, Img3DFilesList,
                                 AImgFilesList, AVideoFilesList, AImg3DFilesList,
                                    BuildFlags, CurDSet2, ShowProgress );
      end;

      Screen.Cursor := SavedCursor;

      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      BtStart.Enabled := FALSE;
      StatusBar.SimpleText := '';
      FSAnalysisFinishFlag := TRUE;

      if mrYes = K_CMShowMessageDlg( format('%d Img files, %d Video files, %d Img3D folders were found'#10#13+
                                 '%d Img files, %d Video files, %d Img3D folders are needed'#10#13+
                                 '%d Img files, %d Video files, %d Img3D folders are archived'#10#13+
                                 'Select Yes if you want to save details',
                                 [ExistedImgFilesCount,ExistedVideoFilesCount,ExistedImg3DFilesCount,
                                  ImgFilesList.Count,VideoFilesList.Count,Img3DFilesList.Count,
                                  AImgFilesList.Count,AVideoFilesList.Count,AImg3DFilesList.Count]), mtConfirmation ) then
      begin // Save Files List

        with SaveDialog do
        begin
          InitialDir := K_ExpandFileName(N_MemIniToString('CMS_Main','LastExportDir', ''));

          Filter := 'File storage analysis results (*.txt)|*.txt|All files (*.*)|*.*';
          FilterIndex := 1;
//          Options := Options + [ofEnableSizing];
          Title := 'Save File Storage Dump results';

          FileName := 'CMFSDump.txt';


          if Execute then
          begin
            N_Dump1Str( format( 'FSD>> Files List Dump Base Name>> %s', [FileName] ) );

            FName := ChangeFileExt( FileName, 'Existed.txt' );
            if RGContent.ItemIndex < 2 then
            begin
              ExistFilesList.SaveToFile( FName );
              ExistFilesList.Clear;
            end
            else
            if FileExists( FName ) then
              DeleteFile( FName );

            FName := ChangeFileExt( FileName, 'Needed.txt' );
            if (RGContent.ItemIndex = 0) or (RGContent.ItemIndex = 2) then
            begin
              ImgFilesList.Sort;
              ImgFilesList.Sorted := FALSE;
              ImgFilesList.Insert( 0, format( 'Img Root=%s Count=%d', [SlidesImgRootFolder,ImgFilesList.Count] ) );

              ImgFilesList.Add( format( 'Video Root=%s Count=%d', [SlidesMediaRootFolder, VideoFilesList.Count] ) );
              VideoFilesList.Sort;
              ImgFilesList.AddStrings(VideoFilesList);
              ImgFilesList.Add( format( 'Img3D Root=%s Count=%d', [SlidesImg3DRootFolder,Img3DFilesList.Count] ) );

              Img3DFilesList.Sort;
              ImgFilesList.AddStrings(Img3DFilesList);
              ImgFilesList.SaveToFile( FName );
            end
            else
            if FileExists( FName ) then
              DeleteFile( FName );

            FName := ChangeFileExt( FileName, 'Archived.txt' );
            if (RGContent.ItemIndex = 0) or (RGContent.ItemIndex = 2) then
            begin
              AImgFilesList.Sort;
              AImgFilesList.Sorted := FALSE;
              AImgFilesList.Insert( 0, format( 'Img Root=%s Count=%d', [SlidesImgRootFolder,ImgFilesList.Count] ) );

              AImgFilesList.Add( format( 'Video Root=%s Count=%d', [SlidesMediaRootFolder, VideoFilesList.Count] ) );
              AVideoFilesList.Sort;
              AImgFilesList.AddStrings(AVideoFilesList);
              AImgFilesList.Add( format( 'Img3D Root=%s Count=%d', [SlidesImg3DRootFolder,Img3DFilesList.Count] ) );

              AImg3DFilesList.Sort;
              AImgFilesList.AddStrings(AImg3DFilesList);
              AImgFilesList.SaveToFile( FName );
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
        ExtDataErrorString := 'FSD>> Restore Slides by File Exception >> ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end; // try
  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMFStorageClear1.BtStartClick


procedure TK_FormCMFSDump1.ShowProgress( AllCount, CurCount: Integer);
begin
  if AllCount > 0 then
    PBProgress.Position := Round(1000 * FProcCount / AllCount);
  LbEDProcCount.Text := IntToStr( FProcCount );
  LbEDProcCount.Refresh();
//  Application.ProcessMessages;
end; // procedure TK_FormCMFSDump1.ShowProgress

end.
