inherited K_FormCMSSharpAttrsN: TK_FormCMSSharpAttrsN
  Left = 114
  Top = 518
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '  Sharp / Smooth'
  ClientHeight = 135
  ClientWidth = 312
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object LbSharpen: TLabel [0]
    Left = 20
    Top = 6
    Width = 28
    Height = 13
    Caption = 'Sharp'
  end
  object LbSmoothen: TLabel [1]
    Left = 254
    Top = 6
    Width = 36
    Height = 13
    Caption = 'Smooth'
  end
  object Label1: TLabel [2]
    Left = 10
    Top = 50
    Width = 29
    Height = 13
    Caption = '-100%'
  end
  object Label2: TLabel [3]
    Left = 276
    Top = 50
    Width = 26
    Height = 13
    Caption = '100%'
  end
  object Label3: TLabel [4]
    Left = 151
    Top = 50
    Width = 6
    Height = 13
    Caption = '0'
  end
  inherited BFMinBRPanel: TPanel
    Left = 302
    Top = 125
    TabOrder = 4
  end
  object BtCancel: TButton
    Left = 214
    Top = 104
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 126
    Top = 104
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = BtOKClick
  end
  object TBVal: TTrackBar
    Left = 12
    Top = 22
    Width = 285
    Height = 26
    LineSize = 100
    Max = 10000
    PageSize = 1000
    Frequency = 500
    TabOrder = 2
    ThumbLength = 16
    OnChange = TBValChange
  end
  object BtApply: TButton
    Left = 28
    Top = 104
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '&Apply'
    TabOrder = 3
    Visible = False
    OnClick = BtApplyClick
  end
  object LbEdConvFactor: TLabeledEdit
    Left = 135
    Top = 72
    Width = 40
    Height = 21
    AutoSize = False
    Color = 10682367
    EditLabel.Width = 8
    EditLabel.Height = 13
    EditLabel.Caption = '%'
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
  object Timer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = TimerTimer
    Left = 144
  end
end
