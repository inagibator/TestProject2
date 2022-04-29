unit K_FCMTwainASettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, StdCtrls;

type
  TK_FormCMTwainASettings = class(TN_BaseForm)
    RGDataTransferMode: TRadioGroup;
    RGCMSMode: TRadioGroup;
    RGGeneralMode: TRadioGroup;
    BtOK: TButton;
    BtCancel: TButton;
    procedure RGGeneralModeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    DefaultDataTransferInd, DefaultCMSMethodInd : Integer;
  public
    { Public declarations }
  end;

var
  K_FormCMTwainASettings: TK_FormCMTwainASettings;

function  K_CMProfileTwainASettingsDlg( var ASettingsText : string ) : Boolean;

implementation

{$R *.dfm}

uses N_Types;

procedure TK_FormCMTwainASettings.RGGeneralModeClick(Sender: TObject);
begin
  inherited;
  case RGGeneralMode.ItemIndex of
  0 : begin
    RGDataTransferMode.Enabled := FALSE;
    if RGDataTransferMode.ItemIndex <> -1 then
      DefaultDataTransferInd := RGDataTransferMode.ItemIndex;
    RGDataTransferMode.ItemIndex := 0;

    RGCMSMode.Enabled := FALSE;
    if RGCMSMode.ItemIndex <> -1 then
      DefaultCMSMethodInd := RGCMSMode.ItemIndex;
    RGCMSMode.ItemIndex := 0;
  end;
  1 : begin
    RGDataTransferMode.Enabled := FALSE;
    if RGDataTransferMode.ItemIndex <> -1 then
      DefaultDataTransferInd := RGDataTransferMode.ItemIndex;
    RGDataTransferMode.ItemIndex := 0;

    RGCMSMode.Enabled := FALSE;
    if RGCMSMode.ItemIndex <> -1 then
      DefaultCMSMethodInd := RGCMSMode.ItemIndex;
    RGCMSMode.ItemIndex := 1;
  end;
  2 : begin
    RGDataTransferMode.Enabled := TRUE;
    if DefaultDataTransferInd <> - 1 then
      RGDataTransferMode.ItemIndex := DefaultDataTransferInd;
    if RGDataTransferMode.ItemIndex = -1 then
      RGDataTransferMode.ItemIndex := 0;

    RGCMSMode.Enabled := FALSE;
    if RGCMSMode.ItemIndex <> -1 then
      DefaultCMSMethodInd := RGCMSMode.ItemIndex;
    RGCMSMode.ItemIndex := -1;
  end;
  3 : begin
    RGDataTransferMode.Enabled := TRUE;
    if DefaultDataTransferInd <> - 1 then
      RGDataTransferMode.ItemIndex := DefaultDataTransferInd;
    if RGDataTransferMode.ItemIndex = -1 then
      RGDataTransferMode.ItemIndex := 0;

    RGCMSMode.Enabled := TRUE;
    if DefaultCMSMethodInd <> - 1 then
      RGCMSMode.ItemIndex := DefaultCMSMethodInd;
    if RGCMSMode.ItemIndex = -1 then
      RGCMSMode.ItemIndex := 0;
  end;
  end;
end;

procedure TK_FormCMTwainASettings.FormShow(Sender: TObject);
begin
  RGGeneralModeClick(Sender);
end;

function  K_CMProfileTwainASettingsDlg( var ASettingsText : string ) : Boolean;

  procedure GetTwainDataTransfereResult();
  begin
    case K_FormCMTwainASettings.RGDataTransferMode.ItemIndex of
      0: ASettingsText[2] := '1';
      1: ASettingsText[2] := '2';
      2: ASettingsText[2] := '3';
    end; // case K_FormCMTwainASettings.RGDataTransferMode.ItemIndex of
  end;

  procedure SetTwainDataTransfereControl();
  begin
    K_FormCMTwainASettings.RGDataTransferMode.ItemIndex := 0;
    if Length(ASettingsText) > 1 then
    case ASettingsText[2] of
    '1': K_FormCMTwainASettings.RGDataTransferMode.ItemIndex := 0;
    '2': K_FormCMTwainASettings.RGDataTransferMode.ItemIndex := 1;
    '3': K_FormCMTwainASettings.RGDataTransferMode.ItemIndex := 2;
    end; // case ASettingsText[2] of
  end;

begin
  K_FormCMTwainASettings := TK_FormCMTwainASettings.Create( Application );
  with K_FormCMTwainASettings do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    case ASettingsText[1] of
      '1': RGGeneralMode.ItemIndex := 0;
      '2': RGGeneralMode.ItemIndex := 1;
      '3': begin
        RGGeneralMode.ItemIndex := 2;
        SetTwainDataTransfereControl();
      end;
      '4': begin
        RGGeneralMode.ItemIndex := 3;
        SetTwainDataTransfereControl();
        RGCMSMode.ItemIndex := 0;
        if Length(ASettingsText) > 2 then
        case ASettingsText[3] of
        '1': RGCMSMode.ItemIndex := 0;
        '2': RGCMSMode.ItemIndex := 1;
        '3': RGCMSMode.ItemIndex := 2;
        '4': RGCMSMode.ItemIndex := 3;
        end;
      end;
    end; // case ASettingsText[1] of
    DefaultDataTransferInd := -1;
    DefaultCMSMethodInd    := -1;

    Result := ShowModal() = mrOK;
    
    if Result then
    case RGGeneralMode.ItemIndex of
      0: ASettingsText := '1';
      1: ASettingsText := '2';
      2: begin
        SetLength( ASettingsText, 2 );
        ASettingsText[1] := '3';
        GetTwainDataTransfereResult();
      end; // 2:
      3: begin
        SetLength( ASettingsText, 3 );
        ASettingsText[1] := '4';
        GetTwainDataTransfereResult();
        case RGCMSMode.ItemIndex of
          0: ASettingsText[3] := '1';
          1: ASettingsText[3] := '2';
          2: ASettingsText[3] := '3';
          3: ASettingsText[3] := '4';
        end;
      end; // 3:
    end; // if Result then
    K_FormCMTwainASettings := nil;
  end; // with K_FormCMTwainASettings do

end; // function K_CMProfileTwainASettingsDlg

end.
