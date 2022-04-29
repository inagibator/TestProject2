inherited K_FormCMSSharpAttrs12: TK_FormCMSSharpAttrs12
  Left = 129
  Top = 180
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '  Sharp / Smooth'
  ClientHeight = 385
  ClientWidth = 367
  FormStyle = fsStayOnTop
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
    Left = 312
    Top = 76
    Width = 33
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Radius'
  end
  object LbSigma: TLabel [6]
    Left = 138
    Top = 76
    Width = 29
    Height = 13
    Caption = 'Sigma'
  end
  object LbSVal1: TLabel [7]
    Left = 16
    Top = 128
    Width = 15
    Height = 13
    Caption = '0.1'
  end
  object LbSVal3: TLabel [8]
    Left = 123
    Top = 128
    Width = 15
    Height = 13
    Caption = '1.5'
  end
  object LbSVal5: TLabel [9]
    Left = 229
    Top = 128
    Width = 12
    Height = 13
    Caption = '20'
  end
  object LbSVal4: TLabel [10]
    Left = 177
    Top = 128
    Width = 15
    Height = 13
    Caption = '5.0'
  end
  object LbSVal2: TLabel [11]
    Left = 70
    Top = 128
    Width = 15
    Height = 13
    Caption = '0.5'
  end
  object lbSmoothType: TLabel [12]
    Left = 20
    Top = 155
    Width = 66
    Height = 13
    Caption = 'Smooth Type:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 357
    Top = 375
    TabOrder = 4
  end
  object BtCancel: TButton
    Left = 278
    Top = 336
    Width = 80
    Height = 24
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
    OnClick = BtCancelClick
  end
  object BtOK: TButton
    Left = 193
    Top = 336
    Width = 80
    Height = 24
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = BtOKClick
  end
  object TBVal: TTrackBar
    Left = 12
    Top = 22
    Width = 293
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
    Left = 24
    Top = 337
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Apply'
    TabOrder = 3
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
  object cbRadius: TComboBox
    Left = 302
    Top = 97
    Width = 51
    Height = 21
    Style = csDropDownList
    Anchors = [akTop, akRight]
    Color = 10682367
    DropDownCount = 20
    ItemHeight = 13
    TabOrder = 6
    OnChange = cbRadiusChange
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '10'
      '20'
      '30'
      '50'
      '100'
      '200')
  end
  object TBSigma: TTrackBar
    Left = 12
    Top = 94
    Width = 231
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    LineSize = 100
    Max = 10000
    PageSize = 1000
    Frequency = 500
    TabOrder = 7
    OnChange = TBSigmaChange
  end
  object EdSigmaVal: TEdit
    Left = 247
    Top = 97
    Width = 38
    Height = 21
    Anchors = [akTop, akRight]
    AutoSize = False
    Color = 10682367
    TabOrder = 8
    Text = '  -99.5'
    OnKeyPress = EdSigmaValKeyPress
  end
  object CmBSmoothType: TComboBox
    Left = 94
    Top = 152
    Width = 144
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    DropDownCount = 20
    ItemHeight = 13
    TabOrder = 9
    OnChange = cbRadiusChange
    Items.Strings = (
      'Old Gauss'
      'Median Huang'
      'Median CT'
      'Median Slow1'
      'Average Slow1'
      'Average Slow2'
      'Empty Slow1'
      'Average FastV'
      'Average FastN'
      'Copy1'
      'Copy2'
      'FastGauss')
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 366
    Width = 367
    Height = 19
    Panels = <>
  end
  object bnSave: TButton
    Left = 108
    Top = 336
    Width = 80
    Height = 24
    Anchors = [akRight, akBottom]
    Caption = '&Save'
    TabOrder = 11
    OnClick = bnSaveClick
  end
  object TBSV1: TTrackBar
    Left = 12
    Top = 190
    Width = 293
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    Max = 255
    PageSize = 10
    Frequency = 10
    TabOrder = 12
    OnChange = TBValChange
  end
  object LbEdSV1: TLabeledEdit
    Left = 310
    Top = 193
    Width = 40
    Height = 21
    Anchors = [akTop, akRight]
    AutoSize = False
    Color = 10682367
    EditLabel.Width = 45
    EditLabel.Height = 13
    EditLabel.Caption = 'LbEdSV1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelPosition = lpRight
    ParentFont = False
    TabOrder = 13
    OnKeyPress = LbEdConvFactorKeyPress
  end
  object TBSV2: TTrackBar
    Left = 12
    Top = 223
    Width = 293
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    Max = 255
    PageSize = 10
    Frequency = 10
    Position = 255
    TabOrder = 14
    OnChange = TBValChange
  end
  object LbEdSV2: TLabeledEdit
    Left = 310
    Top = 226
    Width = 40
    Height = 21
    Anchors = [akTop, akRight]
    AutoSize = False
    Color = 10682367
    EditLabel.Width = 45
    EditLabel.Height = 13
    EditLabel.Caption = 'LbEdSV2'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelPosition = lpRight
    ParentFont = False
    TabOrder = 15
    OnKeyPress = LbEdConvFactorKeyPress
  end
  object TBSD1: TTrackBar
    Left = 12
    Top = 262
    Width = 293
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    Max = 255
    PageSize = 10
    Frequency = 10
    TabOrder = 16
    OnChange = TBValChange
  end
  object LbEdSD1: TLabeledEdit
    Left = 310
    Top = 265
    Width = 40
    Height = 21
    Anchors = [akTop, akRight]
    AutoSize = False
    Color = 10682367
    EditLabel.Width = 46
    EditLabel.Height = 13
    EditLabel.Caption = 'LbEdSD1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelPosition = lpRight
    ParentFont = False
    TabOrder = 17
    OnKeyPress = LbEdConvFactorKeyPress
  end
  object TBSD2: TTrackBar
    Left = 12
    Top = 295
    Width = 293
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    Max = 255
    PageSize = 10
    Frequency = 10
    Position = 255
    TabOrder = 18
    OnChange = TBValChange
  end
  object LbEdSD2: TLabeledEdit
    Left = 310
    Top = 298
    Width = 40
    Height = 21
    Anchors = [akTop, akRight]
    AutoSize = False
    Color = 10682367
    EditLabel.Width = 46
    EditLabel.Height = 13
    EditLabel.Caption = 'LbEdSD2'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelPosition = lpRight
    ParentFont = False
    TabOrder = 19
    OnKeyPress = LbEdConvFactorKeyPress
  end
  object Timer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = TimerTimer
    Left = 144
  end
end
