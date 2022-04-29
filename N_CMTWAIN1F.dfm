object N_CMTWAIN1Form: TN_CMTWAIN1Form
  Left = 41
  Top = 858
  BorderStyle = bsDialog
  Caption = 'N_CMTWAIN1Form'
  ClientHeight = 132
  ClientWidth = 314
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
  object Edit1: TEdit
    Left = 16
    Top = 8
    Width = 145
    Height = 21
    TabOrder = 0
    Text = 'Edit1'
  end
  object Timer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = OnTimer
    Left = 16
    Top = 40
  end
  object TimerSys: TTimer
    Enabled = False
    OnTimer = TimerSysTimer
    Left = 72
    Top = 56
  end
end
