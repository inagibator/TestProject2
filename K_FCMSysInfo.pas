unit K_FCMSysInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, StdCtrls, ComCtrls;

type
  TK_FormCMSysInfo = class(TN_BaseForm)
    LbCapt: TLabel;
    LbEDBFile: TLabeledEdit;
    LbEDBLogFile: TLabeledEdit;
    LbEImgFiles: TLabeledEdit;
    LbEVideoFiles: TLabeledEdit;
    LbETotal: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    LbProcessphase: TLabel;
    Timer: TTimer;
    LbEImg3DFiles: TLabeledEdit;
    LbLicenseInfo: TLabel;
    LbComment: TLabel;
    BtCancel: TButton;
    procedure TimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ProcessState : Integer;
  end;

var
  K_FormCMSysInfo: TK_FormCMSysInfo;

implementation

{$R *.dfm}

uses DB,
  K_CM0, K_CM1,
  N_Types, N_Lib0, K_CML1F;

//***************************************** TK_FormCMSysInfo.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMSysInfo.FormShow(Sender: TObject);
begin
  inherited;
  Timer.Enabled := TRUE;
  BtClose.Enabled := FALSE;
end; // TK_FormCMSysInfo.FormShow

//***************************************** TK_FormCMSysInfo.TimerTimer ***
//  OnTimer Handler
//
procedure TK_FormCMSysInfo.TimerTimer(Sender: TObject);
var
  PageSize : Integer;
  RCount : Integer;
  CMSDB  : TN_CMSlideSDBF;   // Slide Fields stored as single DB field
  ProcCount : Integer;
  Path1, SlideID: string;
  CTotal, Total, VideoTotal, ImgTotal, Img3DTotal : Double;
  CurFSize  : Double;
  ImgSize : Integer;
  VideoFCount, ImgCount, ImgFCount, Img3DFCount : Integer;
  SQLText : string;
  UNCSlidesImgRootFolder, UNCSlidesVideoRootFolder, UNCSlidesImg3DRootFolder : string;
  SlideFileName : string;

//RCode, Size: LongWord;
//RemoteNameInfo: array[0..1023] of Byte;
label CancelExit;

begin
  Timer.Enabled := FALSE;
// Prepare Resulting Data
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
      with CurDSet2 do
      begin

        ExtDataErrorCode := K_eeDBSelect;
        Connection := LANDBConnection;
     //////////////////////////////////////
     // Get DB Files Info
     //
        N_Dump2Str('SysInfo>> Get DB Files Common Info');
        ExtDataErrorCode := K_eeDBSelect;
        if not K_CMEDAMSSQL then
        begin // Sybase
          SQL.Text := 'select ' +
            'DB_PROPERTY(''File''),'+
            'cast(DB_PROPERTY(''FileSize'') as integer),'+
            'cast(DB_PROPERTY(''PageSize'') as integer),'+
            'DB_PROPERTY(''LogName''),'+
            'cast(DB_EXTENDED_PROPERTY(''FileSize'',''translog'') as integer);';

          Filtered := false;
          Open;
          PageSize := FieldList.Fields[2].AsInteger;

          CTotal := FieldList.Fields[1].AsInteger; // Integer to Double
          CTotal := CTotal * PageSize;
          Total := CTotal;
          LbEDBFile.Text := format( '%s (%.2n MB)',
             [ExpandUNCFileName(K_CMEDAGetDBStringValue(Fields[0])), CTotal / 1024 / 1024] );
    //         [ExpandUNCFileName(N_AnsiToString(Fields[0].AsString)), CTotal / 1024 / 1024] );
    //           EDAGetStringFieldValue(FieldList.Fields[0])), CTotal / 1024 / 1024] );
          LbEDBFile.Refresh();

          CTotal := FieldList.Fields[4].AsInteger; // Integer to Double
          CTotal := CTotal * PageSize;
          Total := Total + CTotal;
          LbEDBLogFile.Text := format( '%s (%.2n MB)',
             [ExpandUNCFileName(K_CMEDAGetDBStringValue(Fields[3])), CTotal / 1024 / 1024] );
    //           [ExpandUNCFileName(N_AnsiToString(Fields[3].AsString)), CTotal / 1024 / 1024] );
    //           EDAGetStringFieldValue(FieldList.Fields[3])), CTotal / 1024 / 1024] );
          LbEDBLogFile.Refresh();
//        Size := SizeOf(RemoteNameInfo);
//        RCode := WNetGetUniversalName(PChar(SlidesImgRootFolder), UNIVERSAL_NAME_INFO_LEVEL,
//                      @RemoteNameInfo, Size);
//        UNCSlidesImgRootFolder := PRemoteNameInfo(@RemoteNameInfo).lpUniversalName;
//        N_s := SysErrorMessage( GetLastError() );

        end
        else
        begin // MSSQL
          SQL.Text := 'select File_id, Physical_Name, Size ' +
                      ' from [sys].[database_files] ' +
                      ' ORDER BY File_id;';

          Filtered := false;
          Open;
          PageSize := 8 * 1024;
          CTotal := FieldList.Fields[2].AsInteger; // Integer to Double
          CTotal := CTotal * PageSize;
          Total := CTotal;
          LbEDBFile.Text := format( '%s (%.2n MB)',
             [ExpandUNCFileName(K_CMEDAGetDBStringValue(Fields[1])), CTotal / 1024 / 1024] );
          LbEDBFile.Refresh();

          Next();

          CTotal := FieldList.Fields[2].AsInteger; // Integer to Double
          CTotal := CTotal * PageSize;
          Total := Total + CTotal;
          LbEDBLogFile.Text := format( '%s (%.2n MB)',
             [ExpandUNCFileName(K_CMEDAGetDBStringValue(Fields[1])), CTotal / 1024 / 1024] );
          LbEDBLogFile.Refresh();
        end;
        Close;
     //
     // Get DB Files Info
     //////////////////////////////////////

     //////////////////////////////////////
     // Show License Info
     //
        if K_CMSLiRegState = K_lrsOK then
        begin
          LbLicenseInfo.Caption := format( K_CML1Form.LLLSysInfo6.Caption,
                               // '%d of %d registered licenses in use.',
                               [K_CMGetRunCount(), K_CMGetSecadmLicount()] );
          LbLicenseInfo.Visible := TRUE;
          LbLicenseInfo.Refresh();
        end;
     //
     // Show License Info
     //////////////////////////////////////

     //////////////////////////////////////
     // Show File Storage Path Info
     //
        UNCSlidesImgRootFolder   := ExpandUNCFileName(SlidesImgRootFolder);
        UNCSlidesVideoRootFolder := ExpandUNCFileName(SlidesMediaRootFolder);
        UNCSlidesImg3DRootFolder := ExpandUNCFileName(SlidesImg3DRootFolder);

        LbEImgFiles.Text := UNCSlidesImgRootFolder;
        LbEImgFiles.Refresh();

        if K_CMMediaFilesStoringMode <> 0 then
        begin
          LbEVideoFiles.Text := UNCSlidesVideoRootFolder;
          LbEVideoFiles.Refresh();
        end;

        LbEImg3DFiles.Text := UNCSlidesImg3DRootFolder;
        LbEImg3DFiles.Refresh();

        LbETotal.Text :=  format( '%.2n MB',[Total / 1024 / 1024] );
        LbETotal.Refresh();
     //
     // Show File Storage Path Info
     //////////////////////////////////////

     //////////////////////////////////////
     // Prepare DB Fields
     //
        if K_CMEDDBVersion >= 12 then
        begin
          N_Dump2Str('SysInfo>> Prepare DB Files Info Fields');

          SQLText := 'select ' +
    K_CMENDBSTFSlideID       + ',' + K_CMENDBSTFPatID + ',' +          //0,1
    K_CMENDBSTFSlideDTCr     + ',' + K_CMENDBSTFSlideSysInfo + ',' +   //2,3
    K_CMENDBSTFSlideCurFSize + ',' + K_CMENDBSTFSlideSrcFSize;         //4,5

          if K_CMEDDBVersion >= 16 then
            SQLText := SQLText + ',' +  K_CMENDBSTFSlideVideoFSize; // 6                                       //6

          if K_CMEDDBVersion >= 24 then
            SQLText := SQLText + ',' + K_CMENDBSTFSlideStudyID;     // 7

          SQLText := SQLText +
    ' from ' + K_CMENDBSlidesTable +
    ' where ' +
    K_CMENDBSTFSlideCurFSize   + ' IS NULL and ' +
    K_CMENDBSTFSlideSrcFSize   + ' IS NULL';

          if K_CMEDDBVersion >= 16 then
            SQLText := SQLText + ' and ' + K_CMENDBSTFSlideVideoFSize + ' IS NULL';

          if K_CMEnterpriseModeFlag then
            SQLText := SQLText + ' and ' +  K_CMENDBSTFSlideLocIDHost + '=' + IntToStr(CurLocID);

          SQL.Text := SQLText;
          Filtered := false;
          Open;
          RCount := RecordCount;
          if RCount > 0 then
          begin
            if not SlidesImgRootFDA then
            begin
              Close;
              K_CMShowMessageDlg( //sysout
                 'Image files size couldn''t be get from file system', mtError );
              BtClose.Enabled := TRUE;
              Exit;
            end;

            LbProcessphase.Caption := K_CML1Form.LLLSysInfoProgress.Items[0]; // 'Preparing DB';
            LbProcessphase.Visible := TRUE;
            LbProcessphase.Refresh();
            
            PBProgress.Max := 1000;
            PBProgress.Position := 0;
            PBProgress.Visible := TRUE;

            First();
            ProcCount := 0;
            ProcessState := 1;
            N_Dump2Str('SysInfo>> Prepare DB Files Info Fields Loop');
            while not EOF do
            begin
            // Prepare Files Size Fields
              K_CMEDAGetSlideSysFieldsData( K_CMEDAGetDBStringValue(Fields[3]), @CMSDB);
              Edit;
              if cmsfIsMediaObj in CMSDB.SFlags then
              begin  // Video
                if K_CMEDDBVersion >= 16 then
                  FieldList.Fields[6].AsFloat := CMSDB.BytesSize;
              end
              else
              if (cmsfIsImg3DObj in CMSDB.SFlags) or
                 ((K_CMEDDBVersion >= 24) and
                  (FieldList.Fields[7].AsInteger < 0)) then
              begin // Study or Img3D
// 2020-07-28 add Capt3DDevObjName <> ''  if CMSDB.Capt3DDevObjName = '' then
// 2020-09-25 add new condition for Dev3D objs
                if (CMSDB.Capt3DDevObjName = '') or (CMSDB.MediaFExt = '') then
                begin // in Study or self Img3D Capt3DDevObjName= ''
                  FieldList.Fields[4].AsInteger := -1;
                  N_Dump2Str( format( 'New Study or Img3D ID=%s of patient ID=%s is processed ',
                    [FieldList.Fields[0].AsString,FieldList.Fields[1].AsString] ) );
                end
              end
              else
              begin // Image
                Path1 := SlidesImgRootFolder +
                  K_CMSlideGetPatientFilesPathSegm( FieldList.Fields[1].AsInteger ) +
                  K_CMSlideGetFileDatePathSegm(TDateTimeField(FieldList.Fields[2]).Value);
                SlideID := FieldList.Fields[0].AsString;
                SlideFileName := Path1 + K_CMSlideGetCurImgFileName(SlideID);
                ImgSize := N_GetFileSize( SlideFileName );
//var my
//                if ImgSize = -1 then
//                  ImgSize := CMSDB.BytesSize;
//                FieldList.Fields[4].AsInteger := ImgSize;

                 if ImgSize <> -1 then
                  FieldList.Fields[4].AsInteger := ImgSize
                else
                  N_Dump1Str( format( 'File is absent >> %s', [SlideFileName] ) );
                if cmsfHasSrcImg in CMSDB.SFlags then
                begin
                  SlideFileName := Path1 + K_CMSlideGetSrcImgFileName(SlideID);
                  ImgSize := N_GetFileSize( SlideFileName );
//var my
//                  if ImgSize = -1 then
//                    ImgSize := CMSDB.BytesSize;
//                  FieldList.Fields[5].AsInteger := ImgSize;

                  if ImgSize <> -1 then
                    FieldList.Fields[5].AsInteger := ImgSize
                  else
                    N_Dump1Str( format( 'File is absent >> %s', [SlideFileName] ) );
                end;
              end;
              Inc(ProcCount);
              PBProgress.Position := Round(1000 * ProcCount / RCount);
//              sleep(3000); // Debug
              Application.ProcessMessages();
              if ProcessState = -1 then Break;
              Next();
            end;
            UpdateBatch();
          end; // if RCount > 0 then
          Close;
        end; // if K_CMEDDBVersion >= 12 then

        if ProcessState = -1 then goto CancelExit;

     //
     // Prepare DB Fields
     //////////////////////////////////////

        sleep(100);

     //////////////////////////////////////
     // Calculate Files Size
     //
        if K_CMEDDBVersion >= 16 then
        begin
          N_Dump2Str('SysInfo>> Calculate Files Size');
          ProcessState := 2;
          SQLText := 'select ' +
    K_CMENDBSTFSlideID       + ',' + K_CMENDBSTFPatID + ',' +           //0,1
    K_CMENDBSTFSlideDTCr     + ',' + K_CMENDBSTFSlideCurFSize + ',' +   //2,3
    K_CMENDBSTFSlideSrcFSize + ',' + K_CMENDBSTFSlideVideoFSize + ',' + //4,5
    K_CMENDBSTFSlideSysInfo;                                           //6

          if K_CMEDDBVersion >= 24 then
            SQLText := SQLText + ',' + K_CMENDBSTFSlideStudyID;

          SQLText := SQLText + ' from ' + K_CMENDBSlidesTable; // not study

          if K_CMEnterpriseModeFlag then
            SQLText := SQLText + ' where ' +  K_CMENDBSTFSlideLocIDHost + '=' + IntToStr(CurLocID);

          SQLText := SQLText + ' order by ' + K_CMENDBSTFSlideVideoFSize + ' asc';

          SQL.Text := SQLText;
          Filtered := false;
          Open;
          RCount := RecordCount;

          VideoTotal := 0;
          ImgTotal := 0;
          VideoFCount := 0;
          ImgFCount := 0;
          ImgCount := 0;
          Img3DTotal := 0;
          Img3DFCount := 0;


          if RCount > 0 then
          begin
            LbProcessphase.Caption := K_CML1Form.LLLSysInfoProgress.Items[1]; //'Calculating';
            LbProcessphase.Visible := TRUE;
            LbProcessphase.Refresh();

            PBProgress.Max := 1000;
            PBProgress.Position := 0;
            PBProgress.Visible := TRUE;
            PBProgress.Refresh();

            First();
            ProcCount := 0;
            N_Dump2Str('SysInfo>> Calculate Files Size Loop');

            while not EOF do
            begin
            // Prepare Files Size Fields
              SlideID := FieldList.Fields[0].AsString;
//              PatID := FieldList.Fields[1].AsInteger;
//              Path1 := K_CMSlideGetPatientFilesGroupPathSegm(PatID);
//              Path2 := K_CMSlideGetPatientFilesPathSegm(PatID);
//              Path3 := Path2 + K_CMSlideGetFileDatePathSegm(TDateTimeField(FieldList.Fields[2]).Value);

              CurFSize := FieldList.Fields[5].AsFloat; // VideoFileSize
              if CurFSize <> 0 then
              begin  // Video
                VideoTotal := VideoTotal + CurFSize;
                Inc(VideoFCount);
              end
              else
              begin // Image  Study Img3D
                CurFSize := FieldList.Fields[3].AsFloat;
                if CurFSize = -1 then
                begin
                  if (K_CMEDDBVersion >= 24) and
                     (FieldList.Fields[7].AsInteger < 0) then
                  begin // Study - only add to files count
                    Inc(ImgFCount);
                  end
                  else
                  begin // 3D Image
                    K_CMEDAGetSlideSysFieldsData( K_CMEDAGetDBStringValue(Fields[6]), @CMSDB);
                    Img3DTotal := Img3DTotal + CMSDB.BytesSize;
                    Inc(Img3DFCount);
                  end;
                end
                else
                begin // Image
                  if CurFSize > 0 then
                  begin
                    ImgTotal := ImgTotal + CurFSize; // CurFSize
                    Inc(ImgFCount);
                  end;
                  CurFSize := FieldList.Fields[4].AsFloat; // SrcFSize
                  if CurFSize > 0 then
                  begin
                    ImgTotal := ImgTotal + CurFSize;
                    Inc(ImgFCount);
                  end;
                  Inc(ImgCount);
                end;
              end;
              Inc(ProcCount);
              PBProgress.Position := Round(1000 * ProcCount / RCount);
//              sleep(3000); // debug
              Application.ProcessMessages();
              if ProcessState = -1 then break;
              Next();
            end; // while not EOF do
          end; // if RCount > 0 then
          Close;

          if ProcessState = -1 then goto CancelExit;

          LbEImgFiles.Text := format( K_CML1Form.LLLSysInfo1.Caption,
             // '%s (%.2n MB) [%.0n files]',
             [UNCSlidesImgRootFolder, ImgTotal / 1024 / 1024, ImgFCount + 0.1] );
          LbEImgFiles.Refresh();

          if K_CMMediaFilesStoringMode <> 0 then
          begin
            LbEVideoFiles.Text := format( K_CML1Form.LLLSysInfo1.Caption,
             //  '%s (%.2n MB) [%.0n files]',
               [UNCSlidesVideoRootFolder, VideoTotal / 1024 / 1024, VideoFCount + 0.1] );
            LbEVideoFiles.Refresh();
          end;

          LbEImg3DFiles.Text := format( K_CML1Form.LLLSysInfo5.Caption,
             // '%s (%.2n MB) [%.0n objects]',
             [UNCSlidesImg3DRootFolder, Img3DTotal / 1024 / 1024, Img3DFCount + 0.1] );
          LbEImgFiles.Refresh();

          LbETotal.Text :=  format( K_CML1Form.LLLSysInfo2.Caption,
           //  '%s (%.2n MB) [%.0n objects]',
            [(Total + VideoTotal + ImgTotal + Img3DTotal)/ 1024 / 1024,
             ImgCount + VideoFCount + Img3DFCount + 0.1] );
          LbETotal.Refresh();
        end; // if K_CMEDDBVersion >= 16 then

      end; // with CurDSet2 do

CancelExit: //******
      ProcessState := 0;
      PBProgress.Visible := FALSE;
      LbProcessphase.Visible := FALSE;
      BtCancel.Visible := FALSE;
      BtClose.Enabled := TRUE;

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMSysInfo.TimerTimer ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end;  // with TK_CMEDDBAccess(K_CMEDAccess) do

end; // TK_FormCMSysInfo.TimerTimer

//***************************************** TK_FormCMSysInfo.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMSysInfo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Mes : string;
begin
  Mes := '';
  if ProcessState = 1 then
    Mes := K_CML1Form.LLLSysInfo3.Caption
//    'Do you really want to break database fields preparing?'
  else if ProcessState = 2 then
    Mes := K_CML1Form.LLLSysInfo4.Caption;
//    'Do you really want to break files size calculation?';

  if Mes <> '' then
  begin
    if mrYes = K_CMShowMessageDlg( Mes, mtConfirmation ) then
      BtCancelClick( BtCancel );
    CanClose :=FALSE;
  end;
end; // TK_FormCMSysInfo.FormCloseQuery

procedure TK_FormCMSysInfo.BtCancelClick(Sender: TObject);
begin
  ProcessState := -1;
  BtCancel.Visible := FALSE;
end;

end.
