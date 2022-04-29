inherited K_FormCMSharpSmooth: TK_FormCMSharpSmooth
  Left = 449
  Top = 372
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'K_FormCMSharpSmooth'
  ClientHeight = 115
  ClientWidth = 279
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbPower: TLabel [0]
    Left = 16
    Top = 11
    Width = 30
    Height = 13
    Caption = 'Power'
  end
  object LbBound: TLabel [1]
    Left = 16
    Top = 43
    Width = 31
    Height = 13
    Caption = 'Bound'
  end
  object LbSharp: TLabel [2]
    Left = 92
    Top = 65
    Width = 28
    Height = 13
    Caption = 'Sharp'
    Visible = False
  end
  object LbSmooth: TLabel [3]
    Left = 145
    Top = 66
    Width = 36
    Height = 13
    Caption = 'Smooth'
    Visible = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 269
    Top = 105
    TabOrder = 4
  end
  object BtCancel: TButton
    Left = 192
    Top = 82
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 104
    Top = 82
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = BtOKClick
  end
  object TBPower: TTrackBar
    Left = 64
    Top = 8
    Width = 154
    Height = 20
    Anchors = [akLeft, akTop, akRight]
    LineSize = 100
    Max = 10000
    PageSize = 1000
    Frequency = 500
    TabOrder = 2
    ThumbLength = 13
    OnChange = TBPowerChange
  end
  object BtReset: TButton
    Left = 16
    Top = 82
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '&Reset'
    TabOrder = 3
    OnClick = BtResetClick
  end
  object LbEdConvFactor: TLabeledEdit
    Left = 222
    Top = 11
    Width = 40
    Height = 17
    Anchors = [akTop, akRight]
    AutoSize = False
    Color = 10682367
    EditLabel.Width = 3
    EditLabel.Height = 13
    EditLabel.Caption = ' '
    EditLabel.Transparent = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelPosition = lpRight
    ParentFont = False
    TabOrder = 5
    Text = '   0,0'
    OnKeyPress = LbEdConvFactorKeyPress
  end
  object TBBound: TTrackBar
    Left = 64
    Top = 40
    Width = 117
    Height = 20
    Anchors = [akLeft, akTop, akRight]
    Max = 8
    PageSize = 1
    Position = 8
    TabOrder = 6
    ThumbLength = 13
    OnChange = TBBoundChange
  end
  object LbEdBound: TLabeledEdit
    Left = 190
    Top = 43
    Width = 19
    Height = 17
    Anchors = [akTop, akRight]
    AutoSize = False
    EditLabel.Width = 3
    EditLabel.Height = 13
    EditLabel.Caption = ' '
    EditLabel.Transparent = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelPosition = lpRight
    ParentFont = False
    ReadOnly = True
    TabOrder = 7
    Text = '99'
    OnKeyPress = LbEdConvFactorKeyPress
  end
  object ChBAuto: TCheckBox
    Left = 220
    Top = 42
    Width = 46
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Auto'
    Color = clBtnFace
    ParentColor = False
    TabOrder = 8
    OnClick = ChBAutoClick
  end
  object Timer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = TimerTimer
    Top = 43
  end
end
