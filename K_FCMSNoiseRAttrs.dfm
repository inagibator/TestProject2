inherited K_FormCMSNoiseRAttrs: TK_FormCMSNoiseRAttrs
  Left = 145
  Top = 224
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Noise reduction '
  ClientHeight = 207
  ClientWidth = 423
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbThresh1: TLabel [0]
    Left = 14
    Top = 80
    Width = 53
    Height = 13
    Caption = 'Threshold1'
  end
  object LbThresh2: TLabel [1]
    Left = 14
    Top = 112
    Width = 53
    Height = 13
    Caption = 'Threshold2'
  end
  object Label1: TLabel [2]
    Left = 16
    Top = 16
    Width = 29
    Height = 13
    Caption = 'Depth'
  end
  object LbSigma: TLabel [3]
    Left = 16
    Top = 48
    Width = 29
    Height = 13
    Caption = 'Sigma'
  end
  object LbTimeInfo: TLabel [4]
    Left = 105
    Top = 183
    Width = 128
    Height = 13
    Anchors = [akLeft, akBottom]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 413
    Top = 197
    TabOrder = 6
  end
  object BtCancel: TButton
    Left = 331
    Top = 176
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 241
    Top = 176
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = BtOKClick
  end
  object BtApply: TButton
    Left = 19
    Top = 176
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '&Apply'
    TabOrder = 2
    Visible = False
    OnClick = BtApplyClick
  end
  object TBThresh1: TTrackBar
    Left = 80
    Top = 78
    Width = 276
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    LineSize = 100
    Max = 10000
    PageSize = 500
    Frequency = 500
    Position = 10000
    TabOrder = 3
    ThumbLength = 16
    OnChange = TBThresh1Change
  end
  object TBThresh2: TTrackBar
    Left = 80
    Top = 110
    Width = 276
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    LineSize = 100
    Max = 10000
    PageSize = 500
    Frequency = 500
    Position = 10000
    TabOrder = 4
    ThumbLength = 16
    OnChange = TBThresh1Change
  end
  object bnTest: TButton
    Left = 112
    Top = 176
    Width = 41
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Test'
    TabOrder = 5
    Visible = False
    OnClick = bnTestClick
  end
  object CmBDepth: TComboBox
    Left = 86
    Top = 13
    Width = 42
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    ItemIndex = 5
    TabOrder = 7
    Text = '13'
    OnChange = CmBDepthChange
    Items.Strings = (
      '3'
      '5'
      '7'
      '9'
      '11'
      '13'
      '15'
      '17'
      '19'
      '21'
      '23'
      '25'
      '27'
      '29')
  end
  object EdSigmaVal: TEdit
    Left = 367
    Top = 45
    Width = 38
    Height = 21
    AutoSize = False
    Color = 10682367
    TabOrder = 8
    Text = '  -99.5'
    OnKeyPress = EdSigmaValKeyPress
  end
  object TBSigma: TTrackBar
    Left = 80
    Top = 43
    Width = 276
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    LineSize = 100
    Max = 10000
    PageSize = 1000
    Frequency = 500
    Position = 10000
    TabOrder = 9
    OnChange = TBSigmaChange
  end
  object EdThreshold1Val: TEdit
    Left = 367
    Top = 77
    Width = 38
    Height = 21
    AutoSize = False
    Color = 10682367
    TabOrder = 10
    Text = '  -99.5'
    OnKeyPress = EdThreshold1ValKeyPress
  end
  object EdThreshold2Val: TEdit
    Left = 367
    Top = 109
    Width = 38
    Height = 21
    AutoSize = False
    Color = 10682367
    TabOrder = 11
    Text = '  -99.5'
    OnKeyPress = EdSigmaValKeyPress
  end
  object CmBFilterType: TComboBox
    Left = 128
    Top = 144
    Width = 148
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 12
    OnChange = CmBDepthChange
    Items.Strings = (
      'Filter1'
      '2D Cleaner'
      '2D Cleaner+'
      'Spatial Smoother')
  end
  object Timer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerTimer
    Left = 200
    Top = 40
  end
end
