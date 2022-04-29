inherited K_FormCMSEmboss: TK_FormCMSEmboss
  Left = 446
  Top = 399
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '  Emboss Attributes'
  ClientHeight = 226
  ClientWidth = 297
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbBri: TLabel [0]
    Left = 12
    Top = 152
    Width = 49
    Height = 13
    Caption = 'Brightness'
    FocusControl = TBBri
  end
  object LbRFactor: TLabel [1]
    Left = 12
    Top = 106
    Width = 39
    Height = 13
    Caption = 'Contrast'
    FocusControl = TBRFactor
  end
  object LbDepth: TLabel [2]
    Left = 12
    Top = 15
    Width = 29
    Height = 13
    Caption = 'Depth'
    FocusControl = TBDepth
  end
  object LbDir: TLabel [3]
    Left = 12
    Top = 61
    Width = 42
    Height = 13
    Caption = 'Direction'
    FocusControl = TBDir
  end
  object LbB0_: TLabel [4]
    Left = 74
    Top = 176
    Width = 6
    Height = 13
    Caption = '0'
  end
  object LbB50_: TLabel [5]
    Left = 168
    Top = 176
    Width = 20
    Height = 13
    Caption = '50%'
  end
  object LbB100_: TLabel [6]
    Left = 261
    Top = 176
    Width = 26
    Height = 13
    Anchors = [akTop, akRight]
    Caption = '100%'
  end
  object LbL0_: TLabel [7]
    Left = 74
    Top = 130
    Width = 6
    Height = 13
    Caption = '0'
  end
  object LbL50_: TLabel [8]
    Left = 168
    Top = 130
    Width = 20
    Height = 13
    Caption = '50%'
  end
  object LbL100_: TLabel [9]
    Left = 261
    Top = 130
    Width = 26
    Height = 13
    Anchors = [akTop, akRight]
    Caption = '100%'
  end
  object LbD0_: TLabel [10]
    Left = 74
    Top = 84
    Width = 6
    Height = 13
    Caption = '0'
  end
  object LbD50_: TLabel [11]
    Left = 166
    Top = 84
    Width = 18
    Height = 13
    Caption = '180'
  end
  object LbD100_: TLabel [12]
    Left = 263
    Top = 84
    Width = 18
    Height = 13
    Anchors = [akTop, akRight]
    Caption = '360'
  end
  object LbE0_: TLabel [13]
    Left = 74
    Top = 38
    Width = 6
    Height = 13
    Caption = '1'
  end
  object LbE50_: TLabel [14]
    Left = 170
    Top = 38
    Width = 12
    Height = 13
    Caption = '10'
  end
  object LbE100_: TLabel [15]
    Left = 267
    Top = 38
    Width = 12
    Height = 13
    Anchors = [akTop, akRight]
    Caption = '20'
  end
  inherited BFMinBRPanel: TPanel
    Left = 287
    Top = 216
    TabOrder = 7
  end
  object BtCancel: TButton
    Left = 197
    Top = 195
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 115
    Top = 195
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object TBBri: TTrackBar
    Left = 68
    Top = 150
    Width = 215
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    LineSize = 7
    Max = 1000
    ParentCtl3D = False
    PageSize = 70
    Frequency = 100
    Position = 500
    TabOrder = 2
    ThumbLength = 16
    OnChange = TBValChange
  end
  object TBRFactor: TTrackBar
    Left = 68
    Top = 104
    Width = 215
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    LineSize = 5
    Max = 1000
    PageSize = 50
    Frequency = 100
    Position = 500
    TabOrder = 3
    ThumbLength = 16
    OnChange = TBValChange
  end
  object TBDepth: TTrackBar
    Left = 68
    Top = 12
    Width = 215
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    LineSize = 5
    Max = 100
    PageSize = 20
    Frequency = 10
    Position = 50
    TabOrder = 4
    ThumbLength = 16
    OnChange = TBValChange
  end
  object bnReset: TButton
    Left = 18
    Top = 195
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Reset'
    TabOrder = 5
    OnClick = bnResetClick
  end
  object TBDir: TTrackBar
    Left = 68
    Top = 58
    Width = 215
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    LineSize = 25
    Max = 1000
    PageSize = 125
    Frequency = 100
    TabOrder = 6
    ThumbLength = 16
    OnChange = TBValChange
  end
end
