unit A_fConvertFromD4W;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, N_GRA2, K_CM0, N_Types, System.IOUtils, System.Types;

type
  TConvertFromD4W = class(TForm)
    odFolder: TFileOpenDialog;
    ilMain: TImageList;
    pcMain: TPageControl;
    tsConvertParams: TTabSheet;
    tsConvertProgress: TTabSheet;
    edtSourceFolder: TButtonedEdit;
    lblSourceFolder: TLabel;
    edtFileNameMask: TLabeledEdit;
    btnConvert: TButton;
    btnCancel: TButton;
    btnFinish: TButton;
    ProgressBar1: TProgressBar;
    lblConvertStep: TLabel;
    lblConvertCount: TLabel;
    edtMappingFile: TButtonedEdit;
    cbUseMapping: TCheckBox;
    edtMappingSeparatorChar: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnConvertClick(Sender: TObject);
    procedure edtSourceFolderRightButtonClick(Sender: TObject);
    procedure edtMappingFileRightButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConvertFromD4W: TConvertFromD4W;

implementation

{$R *.dfm}

procedure TConvertFromD4W.btnConvertClick(Sender: TObject);
  procedure ProgressStepIt;
  begin
    ProgressBar1.StepBy(1);
    ProgressBar1.StepBy(-1);
    ProgressBar1.StepBy(1);
  end;
var
  SrcFolder: string;

  DirList: TStringDynArray;
  Dir: string;

  FileListPNG,
  FileListJPG: TStringDynArray;
  FileName: string;
  FileCount: integer;

  PatID: integer;

  IDIB: TN_DIBObj;
  UDCMSlide: TN_UDCMSlide;
  CurImgIndex: integer;

  SavedToDB, SavedToFS: TK_CMEDResult;

  MappingFileStrings: TStringList;
  MappingValue: string;
begin
  SrcFolder := edtSourceFolder.Text;

  if not DirectoryExists(SrcFolder) then
  begin
    MessageDlg('Invalid path!', mtError, [mbOK], 0);
    edtSourceFolder.SetFocus;
    edtSourceFolder.SelectAll;

    Exit;
  end
  else
    pcMain.ActivePage := tsConvertProgress;

  lblConvertStep.Caption := 'Getting folder list...';

  DirList := TDirectory.GetDirectories(SrcFolder);

  if cbUseMapping.Checked AND
     TFile.Exists(edtMappingFile.Text) AND
     (TPath.GetExtension(edtMappingFile.Text).ToUpper.Equals('.TXT') OR
      TPath.GetExtension(edtMappingFile.Text).ToUpper.Equals('.CSV')) then
  begin
    MappingFileStrings := TStringList.Create;
    MappingFileStrings.NameValueSeparator := edtMappingSeparatorChar.Text[1];
    MappingFileStrings.LoadFromFile(edtMappingFile.Text);
  end;

  try
    for Dir in DirList do
    begin
      ProgressBar1.Position := 0;
      ProgressBar1.Min := 0;
      ProgressBar1.Max := 0;

      lblConvertCount.Visible := False;

      if cbUseMapping.Checked AND
         Assigned(MappingFileStrings) then
      begin
        MappingValue := Dir.Substring(Dir.IndexOf('[')+1, Dir.IndexOf(']') - Dir.IndexOf('[')-1);
        PatID := StrToIntDef(MappingFileStrings.Values[MappingValue], -1);
      end
      else
        PatID := StrToIntDef(Dir.Substring(Dir.IndexOf('[')+1, Dir.IndexOf(']') - Dir.IndexOf('[')-1), -1);

      if (PatID = -1) then
        Continue;

      lblConvertStep.Caption := Format('Processing: "%s"', [TPath.GetFileName(Dir)]);
      lblConvertStep.ShowHint := True;
      lblConvertStep.Hint := Dir;

      Application.ProcessMessages;

      FileListPNG := TDirectory.GetFiles(Dir, Trim(edtFileNameMask.Text) + '*.png');
      FileListJPG := TDirectory.GetFiles(Dir, Trim(edtFileNameMask.Text) + '*.jpeg');
      FileCount := Length(FileListPNG) + Length(FileListJPG);

      if (FileCount > 0) then
      begin
        ProgressBar1.Max := FileCount;

        CurImgIndex := 0;

        lblConvertCount.Caption := Format('%d/%d', [CurImgIndex, FileCount]);
        lblConvertCount.Visible := True;

        Application.ProcessMessages;

        for FileName in FileListPNG do
        begin
          Inc(CurImgIndex);
          lblConvertCount.Caption := Format('%d/%d', [CurImgIndex, FileCount]);
          ProgressStepIt;
          Application.ProcessMessages;

          try
            try
              IDIB := TN_DIBObj.Create;
              N_LoadDIBFromFileByImLib(IDIB, FileName);
              UDCMSlide := K_CMSlideCreateFromDIBObj(IDIB, nil, nil, uddfNotDef);
              K_CMSlideSetAttrsByDIB(UDCMSlide.P, IDIB, False);
              UDCMSlide.P()^.CMSPatID := PatID;
              UDCMSlide.P()^.CMSSourceDescr := ExtractFileName(FileName);

              SavedToDB := K_CMEDAccess.EDASaveSlidesArray(@UDCMSlide, 1);
              SavedToFS := K_CMEDAccess.EDASlideDIBToFile(UDCMSlide, True);

              if (SavedToDB = K_edOK) AND
                 (SavedToFS = K_edOK) then
                N_Dump1Str(FileName + ' converted successfully!')
              else
              if (SavedToDB <> K_edOK) then
                N_Dump1Str(FileName + ' failed to save to DB')
              else
              if (SavedToFS <> K_edOK) then
                N_Dump1Str(FileName + ' failed to save to filesystem');
            except
              on E: Exception do
                N_Dump1Str('CONVERT ERROR >> ' + FileName + '!' + #13#10 + E.Message);
            end;
          finally
            UDCMSlide.Free;
            UDCMSlide := nil;
          end;
        end;

        for FileName in FileListJPG do
        begin
          Inc(CurImgIndex);
          lblConvertCount.Caption := Format('%d/%d', [CurImgIndex, FileCount]);
          ProgressStepIt;
          Application.ProcessMessages;

          try
            try
              IDIB := TN_DIBObj.Create;
              N_LoadDIBFromFileByImLib(IDIB, FileName);

              UDCMSlide := K_CMSlideCreateFromDIBObj(IDIB, nil, nil, uddfNotDef);
              K_CMSlideSetAttrsByDIB(UDCMSlide.P, IDIB, False);
              UDCMSlide.P()^.CMSPatID := PatID;
              UDCMSlide.P()^.CMSSourceDescr := ExtractFileName(FileName);

              SavedToDB := K_CMEDAccess.EDASaveSlidesArray(@UDCMSlide, 1);
              SavedToFS := K_CMEDAccess.EDASlideDIBToFile(UDCMSlide, True);

              if (SavedToDB = K_edOK) AND
                 (SavedToFS = K_edOK) then
                N_Dump1Str(FileName + ' converted successfully!')
              else
              if (SavedToDB <> K_edOK) then
                N_Dump1Str(FileName + ' failed to save to DB')
              else
              if (SavedToFS <> K_edOK) then
                N_Dump1Str(FileName + ' failed to save to filesystem');
            except
              on E: Exception do
                N_Dump1Str('CONVERT ERROR >> ' + FileName + '!' + #13#10 + E.Message);
            end;
          finally
            UDCMSlide.Free;
            UDCMSlide := nil;
          end;
        end;

        ProgressStepIt;
      end;
    end;
  finally
    FreeAndNil(MappingFileStrings);

    ProgressBar1.Position := ProgressBar1.Max;
    lblConvertStep.Caption := 'Convert process completed';
    lblConvertStep.Hint := lblConvertStep.Caption;
    lblConvertCount.Visible := False;
    btnFinish.Enabled := True;
  end;
end;

procedure TConvertFromD4W.edtMappingFileRightButtonClick(Sender: TObject);
begin
  odFolder.Options := [];

  if odFolder.Execute then
    edtMappingFile.Text := odFolder.FileName;
end;

procedure TConvertFromD4W.edtSourceFolderRightButtonClick(Sender: TObject);
begin
  odFolder.Options := [fdoPickFolders];

  if odFolder.Execute then
    edtSourceFolder.Text := odFolder.FileName;
end;

procedure TConvertFromD4W.FormCreate(Sender: TObject);
var
  index: integer;
begin
  for index := 0 to pcMain.PageCount - 1 do
    pcMain.Pages[index].TabVisible := false;

  pcMain.ActivePageIndex := 0;
end;

end.
