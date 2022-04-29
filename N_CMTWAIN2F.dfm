object N_CMTWAIN2Form: TN_CMTWAIN2Form
  Left = 108
  Top = 855
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'TWAIN Capture'
  ClientHeight = 49
  ClientWidth = 249
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object bnClose: TButton
    Left = 8
    Top = 8
    Width = 121
    Height = 25
    Caption = 'Close TWAIN Capture'
    ModalResult = 1
    TabOrder = 0
  end
  object Timer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = OnTimer
    Left = 136
    Top = 8
  end
  object TimerSys: TTimer
    Enabled = False
    OnTimer = TimerSysTimer
    Left = 168
    Top = 8
  end
end
