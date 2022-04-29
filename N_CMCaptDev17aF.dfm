inherited N_CMCaptDev17aForm: TN_CMCaptDev17aForm
  Left = 387
  Top = 538
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Progeny Device Settings'
  ClientHeight = 242
  ClientWidth = 339
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 355
  ExplicitHeight = 281
  DesignSize = (
    339
    242)
  PixelsPerInch = 96
  TextHeight = 13
  object StatusShape: TShape [0]
    Left = 16
    Top = 92
    Width = 15
    Height = 15
    Brush.Color = clRed
    Shape = stCircle
  end
  object StatusLabel: TLabel [1]
    Left = 37
    Top = 91
    Width = 127
    Height = 16
    Caption = 'Sensor disconnected'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 329
    Top = 144
    ExplicitLeft = 329
    ExplicitTop = 144
  end
  object bnOK: TButton
    Left = 129
    Top = 113
    Width = 75
    Height = 26
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    TabStop = False
    OnClick = bnOKClick
  end
  object bnSetup: TButton
    Left = 16
    Top = 20
    Width = 75
    Height = 25
    Caption = 'Driver Setup'
    TabOrder = 2
    OnClick = bnSetupClick
  end
end
