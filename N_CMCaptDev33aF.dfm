inherited N_CMCaptDev33aForm: TN_CMCaptDev33aForm
  Left = 160
  Top = 539
  Width = 314
  Height = 206
  Caption = 'E2V Device Settings'
  OldCreateOrder = True
  DesignSize = (
    306
    179)
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
    Left = 320
    Top = 122
  end
  object bnCancel: TButton
    Left = 239
    Top = 98
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    TabStop = False
  end
  object bnOK: TButton
    Left = 141
    Top = 98
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
  object bnConfigure: TButton
    Left = 18
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Configure'
    TabOrder = 4
    Visible = False
    OnClick = bnConfigureClick
  end
end
