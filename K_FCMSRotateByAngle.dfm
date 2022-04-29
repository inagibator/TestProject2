inherited K_FormCMSRotateByAngle: TK_FormCMSRotateByAngle
  Left = 52
  Top = 520
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '  Rotate by Angle'
  ClientHeight = 101
  ClientWidth = 312
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1_: TLabel [0]
    Left = 10
    Top = 47
    Width = 19
    Height = 13
    Caption = '-45'#176
  end
  object Label2_: TLabel [1]
    Left = 276
    Top = 47
    Width = 22
    Height = 13
    Caption = '+45'#176
  end
  object Label3_: TLabel [2]
    Left = 151
    Top = 47
    Width = 6
    Height = 13
    Caption = '0'
  end
  inherited BFMinBRPanel: TPanel
    Left = 302
    Top = 91
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 212
    Top = 70
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 124
    Top = 70
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object TBVal: TTrackBar
    Left = 12
    Top = 19
    Width = 285
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    LineSize = 5
    Max = 10000
    PageSize = 1000
    Frequency = 500
    TabOrder = 2
    ThumbLength = 16
    OnChange = TBValChange
  end
  object Timer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = TimerTimer
    Left = 104
    Top = 69
  end
end
