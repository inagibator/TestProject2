inherited N_CMCaptDev16aForm: TN_CMCaptDev16aForm
  Left = 160
  Top = 539
  Caption = 'E2V Device Settings'
  ClientHeight = 166
  ClientWidth = 320
  OldCreateOrder = True
  ExplicitWidth = 336
  ExplicitHeight = 205
  DesignSize = (
    320
    166)
  PixelsPerInch = 96
  TextHeight = 13
  object lbSensor: TLabel [0]
    Left = 18
    Top = 16
    Width = 67
    Height = 16
    Caption = 'Sensor Info'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 334
    Top = 109
    ExplicitLeft = 334
    ExplicitTop = 109
  end
  object bnCancel: TButton
    Left = 253
    Top = 85
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    TabStop = False
  end
  object bnOK: TButton
    Left = 155
    Top = 85
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
    TabStop = False
    OnClick = bnOKClick
  end
  object cbRaw: TCheckBox
    Left = 18
    Top = 56
    Width = 97
    Height = 17
    Caption = 'Raw image data'
    TabOrder = 3
  end
end
