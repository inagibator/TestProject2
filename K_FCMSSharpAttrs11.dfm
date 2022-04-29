inherited K_FormCMSSharpAttrs11: TK_FormCMSSharpAttrs11
  Left = 296
  Top = 507
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '  Sharp / Smooth'
  ClientHeight = 190
  ClientWidth = 367
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
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
    Top = 54
    Width = 29
    Height = 13
    Caption = '-100%'
  end
  object Label2: TLabel [3]
    Left = 276
    Top = 54
    Width = 26
    Height = 13
    Caption = '100%'
  end
  object Label3: TLabel [4]
    Left = 151
    Top = 54
    Width = 6
    Height = 13
    Caption = '0'
  end
  object LbRadius: TLabel [5]
    Left = 138
    Top = 76
    Width = 33
    Height = 13
    Caption = 'Radius'
  end
  object LbSVal1: TLabel [6]
    Left = 21
    Top = 128
    Width = 6
    Height = 13
    Caption = '1'
  end
  object LbSVal3: TLabel [7]
    Left = 149
    Top = 128
    Width = 12
    Height = 13
    Caption = '16'
  end
  object LbSVal5: TLabel [8]
    Left = 277
    Top = 128
    Width = 18
    Height = 13
    Caption = '266'
  end
  object LbSVal4: TLabel [9]
    Left = 215
    Top = 128
    Width = 12
    Height = 13
    Caption = '66'
  end
  object LbSVal2: TLabel [10]
    Left = 86
    Top = 128
    Width = 6
    Height = 13
    Caption = '6'
  end
  object LbTimeInfo: TLabel [11]
    Left = 49
    Top = 164
    Width = 128
    Height = 13
    Anchors = [akLeft, akBottom]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 357
    Top = 180
    TabOrder = 4
  end
  object BtCancel: TButton
    Left = 190
    Top = 159
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 278
    Top = 159
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
    Anchors = [akLeft, akTop, akRight]
    LineSize = 100
    Max = 10000
    PageSize = 1000
    Frequency = 500
    TabOrder = 2
    OnChange = TBValChange
  end
  object BtApply: TButton
    Left = 20
    Top = 159
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Apply'
    TabOrder = 3
    Visible = False
    OnClick = BtApplyClick
  end
  object LbEdConvFactor: TLabeledEdit
    Left = 310
    Top = 25
    Width = 40
    Height = 21
    Anchors = [akTop, akRight]
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
  object TBRadius: TTrackBar
    Left = 12
    Top = 94
    Width = 285
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    LineSize = 500
    Max = 10000
    PageSize = 1000
    Frequency = 500
    TabOrder = 6
    OnChange = TBRadiusChange
  end
  object EdRadiusVal: TEdit
    Left = 311
    Top = 97
    Width = 38
    Height = 21
    Anchors = [akTop, akRight]
    AutoSize = False
    Color = 10682367
    TabOrder = 7
    Text = '  -99.5'
    OnKeyPress = EdRadiusValKeyPress
  end
  object Timer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = TimerTimer
    Left = 144
  end
end
