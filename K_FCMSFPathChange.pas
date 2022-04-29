unit K_FCMSFPathChange;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls, ActnList;

type
  TK_FormCMSFPathChange = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    BtApply: TButton;

    ActionList1: TActionList;
      MoveFiles: TAction;
      CancelMoving: TAction;
      ApplyPath: TAction;

    Timer1: TTimer;

    GBCurLocation: TGroupBox;
      LEdCurFPath: TLabeledEdit;
      LbCurFilesAttrs: TLabel;

    GBNewLocation: TGroupBox;
      LEdNewPath: TLabeledEdit;
      LbNewFilesAttrs: TLabel;
    BtPathSelect_1: TButton;
    BtPause: TButton;

    procedure FormShow(Sender: TObject);
    procedure MoveFilesExecute(Sender: TObject);
    procedure CancelMovingExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure ApplyPathExecute(Sender: TObject);
    procedure ChBNewDAFlagClick(Sender: TObject);
//    procedure ChBNewSplitFlagClick(Sender: TObject);
    procedure BtPathSelect_1Click(Sender: TObject);
  private
    { Private declarations }
    CurFilesPath  : string;
    CurFilesCount : Integer;
    CurFilesSize  : Int64;
    MovingFilesMode : Boolean;
    ApplyPathMode : Boolean;
    ContinueFilesMovingMode : Boolean;
    NewSplitFlag: Boolean;
    CurSplitFlag: Boolean;
    SaveCursor : TCursor;
    CurDAFlag : Boolean;
    NewDAFlag : Boolean;

    procedure DisableControls();
    function  DoCancelMoving() : Boolean;
    procedure DoMoveFiles();
    procedure DoApplyPath();
    procedure ClearCurCMSContext();
  public
    { Public declarations }
  end;

var
  K_FormCMSFPathChange: TK_FormCMSFPathChange;

implementation

{$R *.dfm}
{$WARN UNIT_PLATFORM	 OFF}
uses FileCtrl,
     N_CMMain5F, N_Types,
     K_CM0, K_CLib0, K_CML1F;
{$WARN UNIT_PLATFORM	 ON}

//************************************ TK_FormCMSFPathChange.FormShow ***
// Self initialization
//
//     Parameters
// Sender    - Event Sender
//
// OnShow Self handler
//
procedure TK_FormCMSFPathChange.FormShow(Sender: TObject);
begin
//
  with TK_CMEDDBAccess(K_CMEDAccess) do begin
    if EDAGetSlidesFilesInfo( CurFilesPath, CurFilesCount, CurFilesSize, CurDAFlag ) <> K_edOK then Exit;
//    if CurFilesCount = 0 then BtOK.Caption := 'Change &path';
    LEdCurFPath.Text := CurFilesPath;
    LbCurFilesAttrs.Caption := format( K_CML1Form.LLLPathChange36.Caption,
//      'Total number of files: %3d        Whole size: %.1f MB',
                 [CurFilesCount, CurFilesSize/1024/1024] );
{ !!! Remove Direct Access Controls
    ChBCurDAFlag.Checked := CurFilesDA;
}
//    ChBCurSplitFlag.Checked := SlidesCRFC.MediaFCopy and
//                               (SlidesMediaFSplit and ((SlidesCRFC.MovingFSDDescr and 1) = 0));
    CurSplitFlag := SlidesCRFC.MediaFCopy and
                               (SlidesMediaFSplit and ((SlidesCRFC.MovingFSDDescr and 1) = 0));

    ContinueFilesMovingMode := SlidesCRFC.RootFolder <> '';
    if ContinueFilesMovingMode then
    begin
      LEdNewPath.Text := SlidesCRFC.RootFolder;
      LbNewFilesAttrs.Caption := format( K_CML1Form.LLLPathChange37.Caption,
//      'Total number of moved files: %3d        Whole size: %.1f MB',
      [SlidesCRFC.CopiedFNum, SlidesCRFC.CopiedFSize/1024/1024] );
    end
    else
    begin
      LEdNewPath.Text := CurFilesPath;
      LbNewFilesAttrs.Caption := K_CML1Form.LLLPathChange38.Caption; //'Total number of files:    0';
    end;

    NewDAFlag := CurDAFlag;
    ChBNewDAFlagClick(Sender);    // MoveFiles.Enabled and SplitState recalc


    CancelMoving.Enabled := ContinueFilesMovingMode;

    if not SlidesCRFC.MediaFCopy then
    begin
      CurSplitFlag := FALSE;
      NewSplitFlag := FALSE;
    end;

    DisableControls();

  end;
  K_FormCMSFPathChange := Self;
  SaveCursor := Screen.Cursor;
end; // procedure TK_FormCMSFPathChange.FormShow

//************************************ TK_FormCMSFPathChange.FormCloseQuery ***
// Form Close Query event handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMSFPathChange.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
    if (SlidesCRFC.RootFolder <> '') then
      CanClose := mrYes = K_CMShowMessageDlg( K_CML1Form.LLLPathChange1.Caption,
//            '              Are you sure you want to break the operation?'#13#10 +
//            '(Working with Images and Video will be impossible until this operation is properly finished)',
            mtConfirmation );
  CancelMoving.Enabled := not CanClose;
  if not CanClose then Exit;
  K_FormCMSFPathChange := nil;
  ClearCurCMSContext();
end; // procedure TK_FormCMSFPathChange.FormCloseQuery

//************************************ TK_FormCMSFPathChange.MoveFilesExecute ***
// Image Files Start or Continue Moving Action
//
//     Parameters
// Sender    - Event Sender
//
// MoveFiles Action handler
//
procedure TK_FormCMSFPathChange.MoveFilesExecute(Sender: TObject);
var
  FreeSpace : Int64;
begin
//
  if LEdNewPath.Text = '' then begin
    K_CMShowMessageDlg( K_CML1Form.LLLPathChange2.Caption,
//                        'New folder is not set!',
                        mtWarning );
    Exit;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess) do begin
//    if (ChBNewSplitFlag.Checked = ChBCurSplitFlag.Checked) and
    if (NewSplitFlag = CurSplitFlag) and
       (NewDAFlag = CurDAFlag) and
//       (ChBNewDAFlag.Checked = ChBCurDAFlag.Checked) and
       SameText( IncludeTrailingPathDelimiter(LEdNewPath.Text), CurFilesPath ) then begin
      K_CMShowMessageDlg( K_CML1Form.LLLPathChange3.Caption,
//                          'New folder is the same as current folder!',
                           mtWarning );
      Exit;
    end;


//    if EDAGetDirFreeSpace( LEdNewPath.Text, ChBNewDAFlag.Checked, FreeSpace ) = K_edOK then begin
    if EDAGetDirFreeSpace( LEdNewPath.Text, NewDAFlag, FreeSpace ) = K_edOK then begin
      if CurFilesSize >= FreeSpace then begin
        K_CMShowMessageDlg( K_CML1Form.LLLPathChange4.Caption,
//                            'New folder has not enough space!',
                            mtWarning );
        Exit;
      end;
    end;

  end;
  MovingFilesMode := TRUE;
  Timer1.Enabled := TRUE;
end; // procedure TK_FormCMSFPathChange.MoveFilesExecute

//************************************ TK_FormCMSFPathChange.CancelMovingExecute ***
// Cancel Image Files Moving Action
//
//     Parameters
// Sender    - Event Sender
//
// CancelMoving Action handler
//
procedure TK_FormCMSFPathChange.CancelMovingExecute(Sender: TObject);
begin
//
  if MovingFilesMode then
  begin
    MovingFilesMode := FALSE;
    BtCancel.Caption := CancelMoving.Caption;
    BtCancel.Hint := CancelMoving.Hint;
    Exit;
  end;
  if DoCancelMoving() then
    Close();
end; // procedure TK_FormCMSFPathChange.CancelMovingExecute

//************************************ TK_FormCMSFPathChange.ApplyPathExecute ***
// Apply Files New Location Path Action
//
//     Parameters
// Sender    - Event Sender
//
// CancelMoving Action handler
//
procedure TK_FormCMSFPathChange.ApplyPathExecute(Sender: TObject);
begin
  if LEdNewPath.Text = '' then begin
    K_CMShowMessageDlg( K_CML1Form.LLLPathChange2.Caption,
//                        'New folder is not set!',
                        mtWarning );
    Exit;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess) do begin


//    if (ChBNewDAFlag.Checked = ChBCurDAFlag.Checked)       and
//       (ChBNewSplitFlag.Checked = ChBCurSplitFlag.Checked) and
    if (NewDAFlag = CurDAFlag)       and
       (NewSplitFlag = CurSplitFlag) and
       SameText( IncludeTrailingPathDelimiter(LEdNewPath.Text), CurFilesPath ) then
    begin
      if mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLPathChange3.Caption + #13#10 +
                                      '                   ' + K_CML1Form.LLLProceed.Caption,
//                      'New folder is the same as current folder!'#13#10 +
//                                      '                   Continue?',
                                      mtConfirmation ) then
        Exit;

    end;
{
    if K_edFails = EDASetFilesPathInfo( LEdNewPath.Text, ChBNewDAFlag.Checked, ChBNewSplitFlag.Checked ) then
      K_CMShowMessageDlg( 'New folder does not exist or does not contain proper files!', mtWarning )
    else
      Close();
}
  end;
  ApplyPathMode := TRUE;
  Timer1.Enabled := TRUE;

end; // procedure TK_FormCMSFPathChange.ApplyPathExecute

//************************************ TK_FormCMSFPathChange.Timer1Timer ***
// Timer event handler
//
//     Parameters
// Sender    - Event Sender
//
// OnTimer handler
//
procedure TK_FormCMSFPathChange.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := FALSE;
  if MovingFilesMode then
    DoMoveFiles()
  else if ApplyPathMode then
    DoApplyPath();
end; // procedure TK_FormCMSFPathChange.Timer1Timer

//************************************ TK_FormCMSFPathChange.ChBNewDAFlagClick ***
// Direct Access Checkbox Click event handler
//
//     Parameters
// Sender    - Event Sender
//
// OnClick handler
//
procedure TK_FormCMSFPathChange.ChBNewDAFlagClick(Sender: TObject);
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do begin
    NewSplitFlag := SlidesCRFC.MediaFCopy           and
                    ( (ContinueFilesMovingMode and
                       SlidesCRFC.MediaFSplit)
                                 or
                      ( (SlidesCRFC.MovingFSDDescr <= 1) and  // to Server
                         not NewDAFlag ) ); // Select New Root without DA

    MoveFiles.Enabled := (CurFilesPath <> '') and   // Sourece Files Exist
                         (CurFilesCount > 0)  and   // Sourece Files Exist
                         (not K_CMEnterpriseModeFlag or (SlidesCRFC.MovingFSDDescr = 3));
    // Skip Files Mooving in Enterprise Mode - Can be done only for Slides that are "Green" in Current Location

    BtPathSelect_1.Enabled := NewDAFlag;
  end;
  DisableControls();
end; // procedure TK_FormCMSFPathChange.ChBNewDAFlagClick
{
//************************************ TK_FormCMSFPathChange.ChBNewSplitFlagClick ***
// Split Files Checkbox Click event handler
//
//     Parameters
// Sender    - Event Sender
//
// OnClick handler
//
procedure TK_FormCMSFPathChange.ChBNewSplitFlagClick(Sender: TObject);
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do begin

    ApplyPath.Enabled := not ContinueFilesMovingMode and
//                        ((ChBNewSplitFlag.Checked = ChBCurSplitFlag.Checked)
                         ((NewSplitFlag = CurSplitFlag)
                                    or
                         (CurFilesCount = 0));  // Files are absent
  end;

end; // procedure TK_FormCMSFPathChange.ChBNewSplitFlagClick
}
//************************************ TK_FormCMSFPathChange.DisableControls ***
// Disable Controls
//
procedure TK_FormCMSFPathChange.DisableControls();
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do begin

    ApplyPath.Enabled := not ContinueFilesMovingMode and
//                        ((ChBNewSplitFlag.Checked = ChBCurSplitFlag.Checked)
                         ( (CurFilesCount = 0)           // Files are absent
                                    or
                           (NewSplitFlag = CurSplitFlag) // Equal Split Mode
                                    or
                           (CurSplitFlag and NewDAFlag) ); // Spread Split Mode to Folder with DA Mode
//                           (CurSplitFlag and ChBNewDAFlag.Checked) ); // Spread Split Mode to Folder with DA Mode
  end;

end; // procedure TK_FormCMSFPathChange.DisableControls

//************************************ TK_FormCMSFPathChange.DoCancelMoving ***
// Image Files Moving Cancel Loop
//
//     Parameters
// Result - Returns TRUE if Dialog Form should be closed
//
function TK_FormCMSFPathChange.DoCancelMoving() : Boolean;
var
  Mes : string;
begin
//
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    Result := (SlidesCRFC.RootFolder = '');
    if Result then Exit;
    Result := (SlidesCRFC.CopiedFNum > 0);
    if Result then
    begin
      Result := mrYes = K_CMShowMessageDlg( K_CML1Form.LLLPathChange5.Caption,
//                  'Are you sure you want to cancel operation?',
                                            mtConfirmation );
      if not Result then
      begin
        ClearCurCMSContext();
        Exit;
      end;
    end;

    EDAPrepClearFilesMoving( SlidesCRFC.RootFolder, NewDAFlag, NewSplitFlag );
//    EDAPrepClearFilesMoving( SlidesCRFC.RootFolder, ChBNewDAFlag.Checked, ChBNewSplitFlag.Checked );
    Mes := '';
    if Result then
    begin
      Screen.Cursor := crHourglass;
    // Delete Copied Files and Clear MoveFiles DB Context
      while EDADelNextSlideFiles() <> K_edFails do
      begin
        LbNewFilesAttrs.Caption := format( K_CML1Form.LLLPathChange39.Caption,
//         'Deleting files in new folder. Remaining number of files %8d',
                                          [SlidesCRFC.CopiedFNum] );
        LbNewFilesAttrs.Update();
      end;
      Screen.Cursor := SaveCursor;
    end;

//    EDARestoreFilesContext( CurFilesPath, ChBCurDAFlag.Checked, ChBCurSplitFlag.Checked ); // for clearing SlidesCRFC.RootFolder even if  SlidesCRFC.CopiedFNum = 0
    EDARestoreFilesContext( CurFilesPath, CurDAFlag, CurSplitFlag ); // for clearing SlidesCRFC.RootFolder even if  SlidesCRFC.CopiedFNum = 0
    if Result then
    begin
      Mes := K_CML1Form.LLLPathChange7.Caption;  // 'Files in new folder are deleted.';
      if ContinueFilesMovingMode then
        Mes := Mes + ' ' + K_CML1Form.LLLPathChange6.Caption;
//        Mes := Mes + 'Restart Media Suite if you want to use it in ordinary mode.';
      K_CMShowMessageDlg( Mes, mtInformation );
    end;
    Result := TRUE;
    CancelMoving.Enabled := FALSE;
   end;
end; // procedure TK_FormCMSFPathChange.DoCancelMoving`

//************************************ TK_FormCMSFPathChange.DoMoveFiles ***
// Image Files Moving Loop
//
procedure TK_FormCMSFPathChange.DoMoveFiles();
var
  Mes : string;
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    N_Dump1Str( format( 'DB>> FormCMSFPathChange.DoMoveFiles start copy from %s'#13#10'to %s',
                        [LEdCurFPath.Text,LEdNewPath.Text] ) );
    MovingFilesMode := FALSE;
//    if K_edFails = EDAPrepSlidesFilesMoving( LEdNewPath.Text, ChBNewDAFlag.Checked, ChBNewSplitFlag.Checked ) then begin
    if K_edFails = EDAPrepSlidesFilesMoving( LEdNewPath.Text, NewDAFlag, NewSplitFlag, FALSE ) then begin
      K_CMShowMessageDlg( K_CML1Form.LLLPathChange8.Caption + #13#10 +
//                          '    Moving files to new folder is not possible.'#13#10 +
//                          'Other Media Suite instance(s) are launched on computers:'#13#10 +
                          ExtDataErrorString, mtWarning );
      CancelMoving.Enabled := TRUE;
      Exit;
    end;

    if SlidesCRFC.SameFolder and
       ( not SlidesCRFC.MediaFCopy
                   or
         (SlidesCRFC.MediaFSplit = SlidesMediaFSplit) ) then
    begin
      K_CMShowMessageDlg( K_CML1Form.LLLPathChange3.Caption,
//                          'New folder is the same as current folder!',
                          mtWarning );
      Exit;
    end;

  // Copy Files to new location
    CancelMoving.Enabled := TRUE;
    BtCancel.Caption := BtPause.Caption;//'Pause';
    BtCancel.Hint := BtPause.Hint;//'Pause files moving operation';
    MovingFilesMode := TRUE;
    ApplyPath.Enabled := FALSE;

  // Check if Source and Destination Folders are equal
  //  SlidesCRFC.SameFolder

    Screen.Cursor := crHourglass;
    while TRUE do
    begin
      case EDACopyNextSlideFiles() of
        K_edOK: begin
          LbNewFilesAttrs.Caption := format( K_CML1Form.LLLPathChange13.Caption,
//               'Total number of moved files: %3d        Whole size: %.1f MB',
               [SlidesCRFC.CopiedFNum, SlidesCRFC.CopiedFSize/1024/1024] );
          LbNewFilesAttrs.Refresh();
//          Application.ProcessMessages();
          if MovingFilesMode then Continue;
          Screen.Cursor := SaveCursor;
          if mrYes = K_CMShowMessageDlg( K_CML1Form.LLLPathChange9.Caption,
//               'Are you realy want to stop moving files to new folder?',
               mtConfirmation ) then Exit;
          Screen.Cursor := crHourglass;
          MovingFilesMode := TRUE;
          Continue;
        end;
        K_edFails: Mes := '';
        K_edImageFilesMoving: Mes := K_CML1Form.LLLPathChange10.Caption +
//                    'Couldn''t copy files ' +
                    ExtDataErrorString + '.';
      else
        Mes := 'Error: ' + ExtDataErrorString;
      end;
      break;
    end;
    Screen.Cursor := SaveCursor;

    MovingFilesMode := FALSE;
    if Mes <> '' then
    begin
      K_CMShowMessageDlg( Mes + ' ' + K_CML1Form.LLLPathChange11.Caption,
//              ' Files moving is stopped.',
              mtWarning );
      DisableControls();
//      ChBNewSplitFlagClick(nil); // For Files Apply
      ApplyPath.Enabled := (SlidesCRFC.CopiedFNum = 0);
    end
    else
    begin
    // Delete Files at previous location
      N_Dump1Str( format( 'DB>> FormCMSFPathChange.DoMoveFiles delete start from %s',
                        [LEdCurFPath.Text] ) );
      EDAPrepClearFilesMoving( '', FALSE, FALSE );
      Screen.Cursor := crHourglass;
      while EDADelNextSlideFiles() <> K_edFails do
      begin
        LbNewFilesAttrs.Caption := format( K_CML1Form.LLLPathChange14.Caption,
//           'Deleting files in previous folder. Remaining number of files %8d',
                                           [SlidesCRFC.CopiedFNum] );
        LbNewFilesAttrs.Update();
      end;
      Screen.Cursor := SaveCursor;
//      EDARestoreFilesContext( SlidesCRFC.RootFolder, ChBNewDAFlag.Checked, ChBNewSplitFlag.Checked );
      EDARestoreFilesContext( SlidesCRFC.RootFolder, NewDAFlag, NewSplitFlag );
      Mes := K_CML1Form.LLLPathChange12.Caption; // 'Files are moved to new folder.';
      if ContinueFilesMovingMode then
        Mes := Mes +  ' ' + K_CML1Form.LLLPathChange6.Caption;
//          + 'Restart Media Suite if you want to use it in ordinary mode.';
      K_CMShowMessageDlg( Mes, mtInformation );
      Close();
    end;
  end;
end; // procedure TK_FormCMSFPathChange.DoMoveFiles

//************************************ TK_FormCMSFPathChange.DoApplyPath ***
// Image Files Path Apply
//
procedure TK_FormCMSFPathChange.DoApplyPath();
var
  Mes : string;
  ErrCount : Integer;
  OKtoAll : Boolean;
  Res : word;
  WImg3DFCopy     : Boolean; // 3D Img Files Move to New Root Folder Flag
  WMediaFCopy     : Boolean; // Media Files Move to New Root Folder Flag
  WMovingFSDDescr : Integer; // Moving Files Source and Destination description
Label FinPathApply;
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    N_Dump1Str( format( 'DB>> FormCMSFPathChange.DoApplyPath start new %s',
                        [LEdNewPath.Text] ) );
    ApplyPathMode := FALSE;
//    if K_edFails = EDAPrepSetFilesPathInfo( LEdNewPath.Text, ChBNewDAFlag.Checked,
//                                            ChBNewSplitFlag.Checked, CurFilesCount = 0 ) then begin
    if K_edFails = EDAPrepSetFilesPathInfo( LEdNewPath.Text, NewDAFlag,
                                            CurSplitFlag, CurFilesCount = 0 ) then
    begin

      if ExtDataErrorString = '*' then
        K_CMShowMessageDlg( K_CML1Form.LLLPathChange15.Caption,
//           'Couldn''t create new folder!',
                            mtWarning )
      else if ExtDataErrorString = '' then
        K_CMShowMessageDlg( K_CML1Form.LLLPathChange16.Caption,
//           'New folder is absent!',
                            mtWarning )
      else
      begin
        K_CMShowMessageDlg( K_CML1Form.LLLPathChange17.Caption + #13#10 +
//                     '     The setting of a new folder is not possible.'#13#10 +
//                     'Other Media Suite instances are launched on the computers:'#13#10 +
                                     ExtDataErrorString,
                            mtWarning );
        CancelMoving.Enabled := TRUE;
      end;
      Exit;
    end;

    // Skip Files check in Enterprise Mode - Can be done only for Slides that are "Green" in Current Location
    if K_CMEnterpriseModeFlag and (SlidesCRFC.MovingFSDDescr <> 3) then goto FinPathApply;

  // Check Files at new location
    MoveFiles.Enabled := FALSE;
    CancelMoving.Enabled := FALSE;
    OKtoAll := FALSE;
    Mes := '';
    ErrCount := 0;

    Screen.Cursor := crHourglass;
    while TRUE do
    begin
      case EDACheckNextSlideFiles() of
        K_edOK: begin
          LbNewFilesAttrs.Caption := format( K_CML1Form.LLLPathChange18.Caption,
//                'Total number of checked files: %3d',
                [SlidesCRFC.CopiedFNum] );
          LbNewFilesAttrs.Update();
        end;
        K_edFails: begin
          if ExtDataErrorString = '' then
            break
          else
          begin
            Inc(ErrCount);
            if not OKtoAll then
            begin
              Res := K_CMShowMessageDlg( format( K_CML1Form.LLLPathChange19.Caption,
//                       'File "%s" is not found!'#13#10 +
//                       'Continue files checking?',
                       [ExtDataErrorString] ), mtConfirmation, [mbYes, mbNo, mbYesToAll] );
              if Res = mrYesToAll then
                OKtoAll := TRUE
              else if mrYes <> Res then
              begin
                if SlidesCRFC.SameFolder then
                  Mes := K_CML1Form.LLLPathChange20.Caption
//                  'Some files are not found in current folder.'
                else
                  Mes := K_CML1Form.LLLPathChange21.Caption;
//                    'Some files are not found in new folder.';
                break;
              end;
            end // if not OKtoAll then
            else
              N_Dump1Str( format( 'DB>> FormCMSFPathChange.DoApplyPath file not found %s',
                        [ExtDataErrorString] ) );

          end;
        end;
      end;
      Continue;
    end;
    Screen.Cursor := SaveCursor;
    if (Mes = '') and (ErrCount > 0) then
    begin
      if SlidesCRFC.SameFolder then
        Mes := format( K_CML1Form.LLLPathChange22.Caption,
//            '%d files are not found in current folder.',
                       [ErrCount] )
      else
      begin
        Mes := format( K_CML1Form.LLLPathChange23.Caption,
//            '%d files are not found in new folder.',
                       [ErrCount] );
        if mrYes = K_CMShowMessageDlg( Mes + #13#10 + K_CML1Form.LLLPathChange24.Caption,
//               'Are you sure you want to change folder?',
                     mtConfirmation ) then
          Mes := '';
      end;
    end;

    if Mes <> '' then
    begin
      if not SlidesCRFC.SameFolder  then
        Mes := Mes + ' ' + K_CML1Form.LLLPathChange25.Caption; // ' New folder is not set.';
      K_CMShowMessageDlg( Mes, mtWarning );
      with SlidesCRFC do
      begin
        WMediaFCopy := MediaFCopy;
        WMovingFSDDescr := MovingFSDDescr;
        WImg3DFCopy := Img3DFCopy;
        EDAClearFilesMovingInfo();
        MediaFCopy := WMediaFCopy;
        MovingFSDDescr := WMovingFSDDescr;
        Img3DFCopy := WImg3DFCopy;
      end;
      ChBNewDAFlagClick( nil ); // set MoveFiles.Enabled state
    end
    else
    begin
    // Apply Files Path
FinPathApply:
      EDASetFilesPathInfo( );
      if SlidesCRFC.SameFolder then
        Mes := K_CML1Form.LLLPathChange26.Caption // 'Files were checked.'
      else
        Mes := K_CML1Form.LLLPathChange27.Caption; // 'New folder is set.';
      if ContinueFilesMovingMode then
        Mes := Mes + ' ' + K_CML1Form.LLLPathChange6.Caption;
//                + 'Restart Media Suite if you want to use it in ordinary mode.';
      K_CMShowMessageDlg( Mes, mtInformation );
      Close();
    end;
  end;
end; // procedure TK_FormCMSFPathChange.DoApplyPath

//************************************ TK_FormCMSFPathChange.ClearCurCMSContext ***
// Clear current CMS Show/Edit context
//
// Should be used if dialog is closed and Image Files moving process is not finished
//
procedure TK_FormCMSFPathChange.ClearCurCMSContext();
begin
//
  with TK_CMEDDBAccess(K_CMEDAccess) do begin
    if (SlidesCRFC.RootFolder = '') or ContinueFilesMovingMode then Exit;
    N_CM_MainForm.CMMFFreeEdFrObjects();
    EDASaveSlidesList( nil );  // Save Slides
    EDAClearCurSlidesSet(); // Clear All Opend
    N_CM_MainForm.CMMFRebuildVisSlides();
    N_CM_MainForm.CMMFDisableActions( nil );
  end;
end; // procedure TK_FormCMSFPathChange.ClearCurCMSContext

procedure TK_FormCMSFPathChange.BtPathSelect_1Click(Sender: TObject);
var
  RPath : string;
begin
  RPath := LEdNewPath.Text;
//  if SelectDirectory( 'Select Folder', '', RPath ) then
  if K_SelectFolder( 'Select Folder', '', RPath ) then
    LEdNewPath.Text := IncludeTrailingPathDelimiter(RPath);
end;

end.
