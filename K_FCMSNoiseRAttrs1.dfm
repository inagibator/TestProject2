inherited K_FormCMSNoiseRAttrs1: TK_FormCMSNoiseRAttrs1
  Left = 317
  Top = 132
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Filters test '
  ClientHeight = 584
  ClientWidth = 680
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbTimeInfo: TLabel [0]
    Left = 248
    Top = 544
    Width = 177
    Height = 35
    Anchors = [akLeft, akBottom]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 670
    Top = 574
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 588
    Top = 553
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
    OnClick = BtCancelClick
  end
  object BtOK: TButton
    Left = 498
    Top = 553
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = BtOKClick
  end
  object GBNR: TGroupBox
    Left = 8
    Top = 8
    Width = 329
    Height = 529
    Caption = '  Noise Reduction  '
    TabOrder = 3
    object GB1: TGroupBox
      Left = 16
      Top = 24
      Width = 297
      Height = 47
      Caption = '  Median  '
      TabOrder = 0
      object LbAperture: TLabel
        Left = 75
        Top = 19
        Width = 43
        Height = 13
        Caption = 'Aperture:'
      end
      object ChBMedianUse: TCheckBox
        Left = 15
        Top = 17
        Width = 14
        Height = 17
        Hint = 'Use filter flag'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = ChBMedianUseClick
      end
      object CmBMedianAperture: TComboBox
        Left = 133
        Top = 16
        Width = 56
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = CmBMedianApertureChange
        Items.Strings = (
          '  3x3'
          '  5x5 '
          '  7x7'
          '  9x9'
          '11x11'
          '13x13'
          '17x17'
          '21x21'
          '29x29'
          '37x37'
          '51x51')
      end
    end
    object GroupBox5: TGroupBox
      Left = 16
      Top = 76
      Width = 297
      Height = 84
      Caption = '  Noise Reduction (New 1)  '
      TabOrder = 1
      DesignSize = (
        297
        84)
      object Label6: TLabel
        Left = 75
        Top = 18
        Width = 43
        Height = 13
        Caption = 'Aperture:'
      end
      object Label8: TLabel
        Left = 13
        Top = 45
        Width = 50
        Height = 13
        Caption = 'Threshold:'
      end
      object ChBNR1Use: TCheckBox
        Left = 15
        Top = 16
        Width = 14
        Height = 17
        Hint = 'Use filter flag'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = ChBMedianUseClick
      end
      object CmBNR1Aperture: TComboBox
        Left = 133
        Top = 15
        Width = 56
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = CmBMedianApertureChange
        Items.Strings = (
          '  3x3'
          '  5x5 '
          '  7x7'
          '  9x9'
          '11x11'
          '13x13'
          '17x17'
          '21x21'
          '29x29'
          '37x37'
          '51x51')
      end
      object TBNR1TS1: TTrackBar
        Left = 68
        Top = 42
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 1000
        ParentCtl3D = False
        PageSize = 50
        Frequency = 50
        Position = 499
        TabOrder = 2
        ThumbLength = 18
        OnChange = TBNR0TS1Change
      end
      object EdNR1TS1: TEdit
        Left = 252
        Top = 45
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 3
        Text = '  -99.5'
        OnKeyPress = EdNR0TS1KeyPress
      end
    end
    object GB2: TGroupBox
      Left = 16
      Top = 165
      Width = 297
      Height = 113
      Caption = '  Noise Reduction (New 2)  '
      TabOrder = 2
      DesignSize = (
        297
        113)
      object Label3: TLabel
        Left = 75
        Top = 18
        Width = 43
        Height = 13
        Caption = 'Aperture:'
      end
      object Label7: TLabel
        Left = 13
        Top = 45
        Width = 50
        Height = 13
        Caption = 'Threshold:'
      end
      object Label9: TLabel
        Left = 13
        Top = 77
        Width = 32
        Height = 13
        Caption = 'Sigma:'
      end
      object ChBNR2Use: TCheckBox
        Left = 15
        Top = 16
        Width = 14
        Height = 17
        Hint = 'Use filter flag'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = ChBMedianUseClick
      end
      object CmBNR2Aperture: TComboBox
        Left = 133
        Top = 15
        Width = 56
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = CmBMedianApertureChange
        Items.Strings = (
          '  3x3'
          '  5x5 '
          '  7x7'
          '  9x9'
          '11x11'
          '13x13'
          '17x17'
          '21x21'
          '29x29'
          '37x37'
          '51x51')
      end
      object TBNR2TS1: TTrackBar
        Left = 68
        Top = 42
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 1000
        ParentCtl3D = False
        PageSize = 50
        Frequency = 50
        Position = 499
        TabOrder = 2
        ThumbLength = 18
        OnChange = TBNR0TS1Change
      end
      object EdNR2TS1: TEdit
        Left = 252
        Top = 45
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 3
        Text = '  -99.5'
        OnKeyPress = EdNR0TS1KeyPress
      end
      object TBNR2Sigma: TTrackBar
        Left = 68
        Top = 74
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 10000
        ParentCtl3D = False
        PageSize = 1000
        Frequency = 500
        Position = 4999
        TabOrder = 4
        ThumbLength = 18
        OnChange = TBNR0SigmaChange
      end
      object EdNR2Sigma: TEdit
        Left = 252
        Top = 77
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 5
        Text = '  -99.5'
        OnKeyPress = EdNR0TS1KeyPress
      end
    end
    object GB3: TGroupBox
      Left = 16
      Top = 283
      Width = 297
      Height = 82
      Caption = '  Noise Reduction (New 3)  '
      TabOrder = 3
      DesignSize = (
        297
        82)
      object Label10: TLabel
        Left = 75
        Top = 18
        Width = 43
        Height = 13
        Caption = 'Aperture:'
      end
      object Label12: TLabel
        Left = 13
        Top = 45
        Width = 50
        Height = 13
        Caption = 'Threshold:'
      end
      object ChBNR3Use: TCheckBox
        Left = 15
        Top = 16
        Width = 14
        Height = 17
        Hint = 'Use filter flag'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = ChBMedianUseClick
      end
      object CmBNR3Aperture: TComboBox
        Left = 133
        Top = 15
        Width = 56
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = CmBMedianApertureChange
        Items.Strings = (
          '  3x3'
          '  5x5 '
          '  7x7'
          '  9x9'
          '11x11'
          '13x13'
          '17x17'
          '21x21'
          '29x29'
          '37x37'
          '51x51')
      end
      object TBNR3TS1: TTrackBar
        Left = 68
        Top = 42
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 1000
        ParentCtl3D = False
        PageSize = 50
        Frequency = 50
        Position = 499
        TabOrder = 2
        ThumbLength = 18
        OnChange = TBNR0TS1Change
      end
      object EdNR3TS1: TEdit
        Left = 252
        Top = 45
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 3
        Text = '  -99.5'
        OnKeyPress = EdNR0TS1KeyPress
      end
    end
    object GroupBox4: TGroupBox
      Left = 16
      Top = 370
      Width = 297
      Height = 140
      Caption = '  Noise Reduction (Old)  '
      TabOrder = 4
      DesignSize = (
        297
        140)
      object Label2: TLabel
        Left = 46
        Top = 18
        Width = 49
        Height = 13
        Caption = 'Aperture1:'
      end
      object Label22: TLabel
        Left = 13
        Top = 45
        Width = 56
        Height = 13
        Caption = 'Threshold1:'
      end
      object Label27: TLabel
        Left = 13
        Top = 73
        Width = 56
        Height = 13
        Caption = 'Threshold2:'
      end
      object Label32: TLabel
        Left = 13
        Top = 101
        Width = 32
        Height = 13
        Caption = 'Sigma:'
      end
      object Label11: TLabel
        Left = 166
        Top = 18
        Width = 49
        Height = 13
        Caption = 'Aperture2:'
      end
      object ChBNR0Use: TCheckBox
        Left = 15
        Top = 16
        Width = 14
        Height = 17
        Hint = 'Use filter flag'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = ChBMedianUseClick
      end
      object CmBNR0Aperture1: TComboBox
        Left = 98
        Top = 15
        Width = 56
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = CmBMedianApertureChange
        Items.Strings = (
          '  3x3'
          '  5x5 '
          '  7x7'
          '  9x9'
          '11x11'
          '13x13'
          '17x17'
          '21x21'
          '29x29'
          '37x37'
          '51x51')
      end
      object TBNR0TS1: TTrackBar
        Left = 68
        Top = 42
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 100
        Max = 10000
        ParentCtl3D = False
        PageSize = 1000
        Frequency = 500
        Position = 4999
        TabOrder = 2
        ThumbLength = 18
        OnChange = TBNR0TS1Change
      end
      object EdNR0TS1: TEdit
        Left = 252
        Top = 45
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 3
        Text = '  -99.5'
        OnKeyPress = EdNR0TS1KeyPress
      end
      object TBNR0TS2: TTrackBar
        Left = 68
        Top = 70
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 100
        Max = 10000
        ParentCtl3D = False
        PageSize = 1000
        Frequency = 500
        Position = 4999
        TabOrder = 4
        ThumbLength = 18
        OnChange = TBNR0TS1Change
      end
      object EdNR0TS2: TEdit
        Left = 252
        Top = 73
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 5
        Text = '  -99.5'
        OnKeyPress = EdNR0TS1KeyPress
      end
      object TBNR0Sigma: TTrackBar
        Left = 68
        Top = 98
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 10000
        ParentCtl3D = False
        PageSize = 1000
        Frequency = 500
        Position = 4999
        TabOrder = 6
        ThumbLength = 18
        OnChange = TBNR0SigmaChange
      end
      object EdNR0Sigma: TEdit
        Left = 252
        Top = 101
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 7
        Text = '  -99.5'
        OnKeyPress = EdNR0TS1KeyPress
      end
      object CmBNR0Aperture2: TComboBox
        Left = 219
        Top = 15
        Width = 56
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 8
        OnChange = CmBMedianApertureChange
        Items.Strings = (
          '  3x3'
          '  5x5 '
          '  7x7'
          '  9x9'
          '11x11'
          '13x13'
          '17x17'
          '21x21'
          '29x29'
          '37x37'
          '51x51')
      end
    end
  end
  object GBSharpening: TGroupBox
    Left = 344
    Top = 8
    Width = 329
    Height = 529
    Caption = '  Sharpening  '
    TabOrder = 4
    object GBSharpen1: TGroupBox
      Left = 16
      Top = 24
      Width = 297
      Height = 113
      Caption = '  Sharpening 1  '
      TabOrder = 0
      DesignSize = (
        297
        113)
      object Label15: TLabel
        Left = 179
        Top = 18
        Width = 43
        Height = 13
        Caption = 'Aperture:'
      end
      object LbSH0Sigma: TLabel
        Left = 13
        Top = 73
        Width = 32
        Height = 13
        Caption = 'Sigma:'
      end
      object Label16: TLabel
        Left = 13
        Top = 45
        Width = 33
        Height = 13
        Caption = 'Power:'
      end
      object ChBSH0Use: TCheckBox
        Left = 15
        Top = 16
        Width = 14
        Height = 17
        Hint = 'Use filter flag'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = ChBMedianUseClick
      end
      object CmBSH0Method: TComboBox
        Left = 44
        Top = 15
        Width = 114
        Height = 21
        Hint = 'Smoothing method'
        Style = csDropDownList
        ItemHeight = 13
        ItemIndex = 2
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Text = 'Median'
        OnChange = CmBSH0MethodChange
        Items.Strings = (
          'Gaussian'
          'Average'
          'Median')
      end
      object CmBSH0Aperture: TComboBox
        Left = 234
        Top = 15
        Width = 56
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
        OnChange = CmBMedianApertureChange
        Items.Strings = (
          '  3x3'
          '  5x5 '
          '  7x7'
          '  9x9'
          '11x11'
          '13x13'
          '17x17'
          '21x21'
          '29x29'
          '37x37'
          '51x51')
      end
      object TBSH0Sigma: TTrackBar
        Left = 68
        Top = 70
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 10000
        ParentCtl3D = False
        PageSize = 100
        Frequency = 500
        Position = 4999
        TabOrder = 3
        ThumbLength = 18
        OnChange = TBNR0SigmaChange
      end
      object EdSH0Sigma: TEdit
        Left = 252
        Top = 73
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 4
        Text = '   1.4'
        OnKeyPress = EdNR0TS1KeyPress
      end
      object TBSH0TS1: TTrackBar
        Left = 68
        Top = 42
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 1000
        ParentCtl3D = False
        PageSize = 50
        Frequency = 50
        Position = 499
        TabOrder = 5
        ThumbLength = 18
        OnChange = TBNR0TS1Change
      end
      object EdSH0TS1: TEdit
        Left = 252
        Top = 45
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 6
        Text = '100.0'
        OnKeyPress = EdNR0TS1KeyPress
      end
    end
    object GBSharpen2: TGroupBox
      Left = 16
      Top = 144
      Width = 297
      Height = 137
      Caption = '  Sharpening 2  '
      TabOrder = 1
      Visible = False
      DesignSize = (
        297
        137)
      object Label1: TLabel
        Left = 75
        Top = 18
        Width = 43
        Height = 13
        Caption = 'Aperture:'
      end
      object Label4: TLabel
        Left = 13
        Top = 101
        Width = 32
        Height = 13
        Caption = 'Sigma:'
      end
      object Label5: TLabel
        Left = 13
        Top = 45
        Width = 26
        Height = 13
        Caption = 'Form:'
      end
      object Label13: TLabel
        Left = 15
        Top = 73
        Width = 24
        Height = 13
        Caption = 'Shift:'
      end
      object ChBSH1Use: TCheckBox
        Left = 15
        Top = 16
        Width = 14
        Height = 17
        Hint = 'Use filter flag'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = ChBMedianUseClick
      end
      object CmBSH1Aperture: TComboBox
        Left = 133
        Top = 15
        Width = 56
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = CmBMedianApertureChange
        Items.Strings = (
          '  3x3'
          '  5x5 '
          '  7x7'
          '  9x9'
          '11x11'
          '13x13'
          '17x17'
          '21x21'
          '29x29'
          '37x37'
          '51x51')
      end
      object TBSH1Sigma: TTrackBar
        Left = 68
        Top = 98
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 10000
        ParentCtl3D = False
        PageSize = 100
        Frequency = 500
        Position = 4999
        TabOrder = 2
        ThumbLength = 18
        OnChange = TBNR0SigmaChange
      end
      object EdSH1Sigma: TEdit
        Left = 252
        Top = 101
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 3
        Text = '   1.4'
        OnKeyPress = EdNR0TS1KeyPress
      end
      object TBSH1TS1: TTrackBar
        Left = 68
        Top = 42
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 1000
        ParentCtl3D = False
        PageSize = 50
        Frequency = 50
        Position = 499
        TabOrder = 4
        ThumbLength = 18
        OnChange = TBNR0TS1Change
      end
      object EdSH1TS1: TEdit
        Left = 252
        Top = 45
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 5
        Text = '100.0'
        OnKeyPress = EdNR0TS1KeyPress
      end
      object TBSH1TS2: TTrackBar
        Left = 68
        Top = 70
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 1000
        ParentCtl3D = False
        PageSize = 50
        Frequency = 50
        Position = 500
        TabOrder = 6
        ThumbLength = 18
        OnChange = TBNR0TS1Change
      end
      object EdSH1TS2: TEdit
        Left = 252
        Top = 73
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 7
        Text = '100.0'
        OnKeyPress = EdNR0TS1KeyPress
      end
    end
    object GBSharpen3: TGroupBox
      Left = 16
      Top = 288
      Width = 297
      Height = 113
      Caption = '  Sharpening 3  '
      TabOrder = 2
      Visible = False
      DesignSize = (
        297
        113)
      object Label14: TLabel
        Left = 13
        Top = 45
        Width = 26
        Height = 13
        Caption = 'Form:'
      end
      object Label17: TLabel
        Left = 15
        Top = 73
        Width = 24
        Height = 13
        Caption = 'Shift:'
      end
      object ChBSH2Use: TCheckBox
        Left = 15
        Top = 16
        Width = 14
        Height = 17
        Hint = 'Use filter flag'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = ChBMedianUseClick
      end
      object TBSH2TS1: TTrackBar
        Left = 68
        Top = 42
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 1000
        ParentCtl3D = False
        PageSize = 50
        Frequency = 50
        Position = 499
        TabOrder = 1
        ThumbLength = 18
        OnChange = TBNR0TS1Change
      end
      object EdSH2TS1: TEdit
        Left = 252
        Top = 45
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 2
        Text = '100.0'
        OnKeyPress = EdNR0TS1KeyPress
      end
      object TBSH2TS2: TTrackBar
        Left = 68
        Top = 70
        Width = 185
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 1000
        ParentCtl3D = False
        PageSize = 50
        Frequency = 50
        Position = 500
        TabOrder = 3
        ThumbLength = 18
        OnChange = TBNR0TS1Change
      end
      object EdSH2TS2: TEdit
        Left = 252
        Top = 73
        Width = 38
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 4
        Text = '100.0'
        OnKeyPress = EdNR0TS1KeyPress
      end
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 32
    Top = 552
  end
end
