inherited K_FormCMImgFilterProcAttrs: TK_FormCMImgFilterProcAttrs
  Left = 304
  Top = 47
  BorderStyle = bsSingle
  Caption = 'Automatic Image Processing'
  ClientHeight = 726
  ClientWidth = 335
  OldCreateOrder = True
  OnShow = FormShow
  DesignSize = (
    335
    726)
  PixelsPerInch = 96
  TextHeight = 13
  object PnAll: TPanel [0]
    Left = 0
    Top = 0
    Width = 338
    Height = 722
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      338
      722)
    object GBFilters: TGroupBox
      Left = 8
      Top = 8
      Width = 321
      Height = 319
      Caption = '  Filters  '
      TabOrder = 0
      DesignSize = (
        321
        319)
      object LbSmoothPower: TLabel
        Left = 102
        Top = 201
        Width = 30
        Height = 13
        Caption = 'Power'
      end
      object LbSmoothBound: TLabel
        Left = 102
        Top = 229
        Width = 31
        Height = 13
        Caption = 'Bound'
      end
      object LbSharpPower: TLabel
        Left = 102
        Top = 261
        Width = 30
        Height = 13
        Caption = 'Power'
      end
      object LbSharpBound: TLabel
        Left = 102
        Top = 289
        Width = 31
        Height = 13
        Caption = 'Bound'
      end
      object LbMedianBound: TLabel
        Left = 102
        Top = 105
        Width = 31
        Height = 13
        Caption = 'Bound'
      end
      object LbDespeckleBound: TLabel
        Left = 102
        Top = 137
        Width = 31
        Height = 13
        Caption = 'Bound'
      end
      object LbNoisePower: TLabel
        Left = 102
        Top = 169
        Width = 30
        Height = 13
        Caption = 'Power'
      end
      object LbEqualizePower: TLabel
        Left = 102
        Top = 73
        Width = 30
        Height = 13
        Caption = 'Power'
      end
      object ChBNoise: TCheckBox
        Left = 11
        Top = 168
        Width = 70
        Height = 17
        Caption = 'No&ise'
        TabOrder = 0
        OnClick = ChBNoiseClick
      end
      object ChBEqualize: TCheckBox
        Left = 11
        Top = 72
        Width = 70
        Height = 17
        Caption = '&Equalize'
        TabOrder = 1
        OnClick = ChBEqualizeClick
      end
      object ChBNegate: TCheckBox
        Left = 255
        Top = 16
        Width = 62
        Height = 17
        Caption = 'Nega&te'
        TabOrder = 2
        OnClick = ChBNegateClick
      end
      object ChBConvToGrey: TCheckBox
        Left = 11
        Top = 16
        Width = 120
        Height = 17
        Caption = 'Convert to gre&yscale'
        TabOrder = 3
      end
      object TBSmoothPower: TTrackBar
        Left = 136
        Top = 198
        Width = 130
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        LineSize = 100
        Max = 10000
        PageSize = 1000
        Frequency = 500
        TabOrder = 4
        ThumbLength = 13
        OnChange = TBSmoothPowerChange
      end
      object LbEdSmoothPower: TLabeledEdit
        Left = 270
        Top = 201
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
        OnEnter = EdBriValEnter
        OnExit = EdBriValExit
        OnKeyDown = LbEdSmoothPowerKeyDown
      end
      object TBSmoothBound: TTrackBar
        Left = 136
        Top = 226
        Width = 100
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Max = 8
        PageSize = 1
        Position = 8
        TabOrder = 6
        ThumbLength = 13
        OnChange = TBSmoothBoundChange
      end
      object LbEdSmoothBound: TLabeledEdit
        Left = 242
        Top = 229
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
      end
      object ChBSmoothAuto: TCheckBox
        Left = 270
        Top = 228
        Width = 46
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Auto'
        Color = clBtnFace
        ParentColor = False
        TabOrder = 8
        OnClick = ChBSmoothAutoClick
      end
      object ChBMedian: TCheckBox
        Left = 11
        Top = 104
        Width = 70
        Height = 17
        Caption = '&Median'
        TabOrder = 9
        OnClick = ChBMedianClick
      end
      object ChBDespeckle: TCheckBox
        Left = 11
        Top = 136
        Width = 78
        Height = 17
        Caption = '&Despeckle'
        TabOrder = 10
        OnClick = ChBDespeckleClick
      end
      object ChBSmooth: TCheckBox
        Left = 11
        Top = 200
        Width = 70
        Height = 17
        Caption = '&Smooth'
        TabOrder = 11
        OnClick = ChBSmoothClick
      end
      object ChBSharp: TCheckBox
        Left = 11
        Top = 260
        Width = 70
        Height = 17
        Caption = 'Sh&arp'
        TabOrder = 12
        OnClick = ChBSharpClick
      end
      object TBSharpPower: TTrackBar
        Left = 136
        Top = 258
        Width = 130
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        LineSize = 100
        Max = 10000
        PageSize = 1000
        Frequency = 500
        TabOrder = 13
        ThumbLength = 13
        OnChange = TBSharpPowerChange
      end
      object LbEdSharpPower: TLabeledEdit
        Left = 270
        Top = 261
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
        TabOrder = 14
        Text = '  0.0'
        OnEnter = EdBriValEnter
        OnExit = EdBriValExit
        OnKeyDown = LbEdSharpPowerKeyDown
      end
      object TBSharpBound: TTrackBar
        Left = 136
        Top = 286
        Width = 100
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Max = 8
        PageSize = 1
        Position = 8
        TabOrder = 15
        ThumbLength = 13
        OnChange = TBSharpBoundChange
      end
      object LbEdSharpBound: TLabeledEdit
        Left = 242
        Top = 289
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
        TabOrder = 16
        Text = '99'
      end
      object ChBSharpAuto: TCheckBox
        Left = 270
        Top = 288
        Width = 46
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Auto'
        Color = clBtnFace
        ParentColor = False
        TabOrder = 17
        OnClick = ChBSharpAutoClick
      end
      object TBMedianBound: TTrackBar
        Left = 136
        Top = 102
        Width = 100
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Max = 5
        PageSize = 1
        Position = 5
        TabOrder = 18
        ThumbLength = 13
        OnChange = TBMedianBoundChange
      end
      object LbEdMedianBound: TLabeledEdit
        Left = 242
        Top = 105
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
        TabOrder = 19
        Text = '99'
      end
      object ChBMedianAuto: TCheckBox
        Left = 270
        Top = 104
        Width = 46
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Auto'
        Color = clBtnFace
        ParentColor = False
        TabOrder = 20
        Visible = False
        OnClick = ChBMedianAutoClick
      end
      object TBDespeckleBound: TTrackBar
        Left = 136
        Top = 134
        Width = 100
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Max = 5
        PageSize = 1
        Position = 5
        TabOrder = 21
        ThumbLength = 13
        OnChange = TBDespeckleBoundChange
      end
      object LbEdDespeckleBound: TLabeledEdit
        Left = 242
        Top = 137
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
        TabOrder = 22
        Text = '99'
      end
      object ChBDespeckleAuto: TCheckBox
        Left = 270
        Top = 136
        Width = 46
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Auto'
        Color = clBtnFace
        ParentColor = False
        TabOrder = 23
        Visible = False
        OnClick = ChBDespeckleAutoClick
      end
      object TBNoisePower: TTrackBar
        Left = 136
        Top = 166
        Width = 130
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        LineSize = 100
        Max = 10000
        PageSize = 1000
        Frequency = 500
        TabOrder = 24
        ThumbLength = 13
        OnChange = TBNoisePowerChange
      end
      object LbEdNoisePower: TLabeledEdit
        Left = 270
        Top = 169
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
        TabOrder = 25
        Text = '  0.0'
        OnEnter = EdBriValEnter
        OnExit = EdBriValExit
        OnKeyDown = LbEdNoisePowerKeyDown
      end
      object ChBConvTo8: TCheckBox
        Left = 147
        Top = 16
        Width = 94
        Height = 17
        Caption = 'Convert to &8 bit'
        TabOrder = 26
      end
      object ChBAutoContrast: TCheckBox
        Left = 11
        Top = 40
        Width = 98
        Height = 17
        Caption = 'Auto &Contrast'
        TabOrder = 27
      end
      object TBEqualizePower: TTrackBar
        Left = 136
        Top = 70
        Width = 130
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        LineSize = 100
        Max = 10000
        PageSize = 1000
        Frequency = 500
        Position = 11
        TabOrder = 28
        ThumbLength = 13
        OnChange = TBEqualizePowerChange
      end
      object LbEdEqualizePower: TLabeledEdit
        Left = 270
        Top = 73
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
        TabOrder = 29
        Text = '  0.0'
        OnEnter = EdBriValEnter
        OnExit = EdBriValExit
        OnKeyDown = LbEdEqualizePowerKeyDown
      end
    end
    object GBBriCoGam: TGroupBox
      Left = 8
      Top = 334
      Width = 321
      Height = 209
      Anchors = [akTop, akRight]
      TabOrder = 1
      DesignSize = (
        321
        209)
      object Label3: TLabel
        Left = 30
        Top = 23
        Width = 49
        Height = 13
        Caption = '&Brightness'
        FocusControl = BrightnessTrackBar
      end
      object Label4: TLabel
        Left = 30
        Top = 79
        Width = 36
        Height = 13
        Caption = '&Gamma'
        FocusControl = GammaTrackBar
      end
      object Label5: TLabel
        Left = 30
        Top = 51
        Width = 39
        Height = 13
        Caption = 'Co&ntrast'
        FocusControl = ContrastTrackBar
      end
      object LbLL: TLabel
        Left = 80
        Top = 115
        Width = 12
        Height = 13
        Caption = '&LL'
        FocusControl = TBLL
      end
      object LbLU: TLabel
        Left = 80
        Top = 143
        Width = 14
        Height = 13
        Caption = '&UL'
        FocusControl = TBLU
      end
      object LbAutoLLULPower: TLabel
        Left = 102
        Top = 181
        Width = 30
        Height = 13
        Caption = 'Power'
      end
      object BrightnessTrackBar: TTrackBar
        Left = 96
        Top = 20
        Width = 172
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        LineSize = 7
        Max = 10000
        ParentCtl3D = False
        PageSize = 70
        Frequency = 1000
        Position = 5000
        TabOrder = 0
        ThumbLength = 13
        OnChange = BrightnessTrackBarChange
      end
      object GammaTrackBar: TTrackBar
        Left = 96
        Top = 76
        Width = 172
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        LineSize = 7
        Max = 10000
        PageSize = 70
        Frequency = 1000
        Position = 5000
        TabOrder = 1
        ThumbLength = 13
        OnChange = BrightnessTrackBarChange
      end
      object ContrastTrackBar: TTrackBar
        Left = 96
        Top = 48
        Width = 172
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        LineSize = 7
        Max = 10000
        PageSize = 70
        Frequency = 1000
        Position = 5000
        TabOrder = 2
        ThumbLength = 13
        OnChange = BrightnessTrackBarChange
      end
      object EdBriVal: TEdit
        Left = 270
        Top = 23
        Width = 40
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 3
        Text = '  -99.5'
        OnEnter = EdBriValEnter
        OnExit = EdBriValExit
        OnKeyDown = EdBriValKeyDown
      end
      object EdCoVal: TEdit
        Left = 270
        Top = 51
        Width = 40
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 4
        Text = '  -99.5'
        OnEnter = EdBriValEnter
        OnExit = EdBriValExit
        OnKeyDown = EdBriValKeyDown
      end
      object EdGamVal: TEdit
        Left = 270
        Top = 79
        Width = 40
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 5
        Text = '  -99.5'
        OnEnter = EdBriValEnter
        OnExit = EdBriValExit
        OnKeyDown = EdBriValKeyDown
      end
      object ChBBri: TCheckBox
        Left = 10
        Top = 22
        Width = 15
        Height = 17
        TabOrder = 6
        OnClick = ChBBriClick
      end
      object ChBCo: TCheckBox
        Left = 10
        Top = 50
        Width = 15
        Height = 17
        TabOrder = 7
        OnClick = ChBCoClick
      end
      object ChBGam: TCheckBox
        Left = 10
        Top = 78
        Width = 15
        Height = 17
        TabOrder = 8
        OnClick = ChBGamClick
      end
      object TBLL: TTrackBar
        Left = 96
        Top = 112
        Width = 172
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        LineSize = 7
        Max = 1000
        PageSize = 70
        Frequency = 100
        Position = 500
        TabOrder = 9
        ThumbLength = 13
        OnChange = BrightnessTrackBarChange
      end
      object EdLLVal: TEdit
        Left = 269
        Top = 115
        Width = 40
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 10
        Text = '  -99.5'
        OnEnter = EdBriValEnter
        OnExit = EdBriValExit
        OnKeyDown = EdBriValKeyDown
      end
      object TBLU: TTrackBar
        Left = 96
        Top = 140
        Width = 172
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        LineSize = 7
        Max = 1000
        PageSize = 70
        Frequency = 100
        Position = 500
        TabOrder = 11
        ThumbLength = 13
        OnChange = BrightnessTrackBarChange
      end
      object EdLUVal: TEdit
        Left = 269
        Top = 143
        Width = 40
        Height = 17
        Anchors = [akTop, akRight]
        AutoSize = False
        Color = 10682367
        TabOrder = 12
        Text = '  -99.5'
        OnEnter = EdBriValEnter
        OnExit = EdBriValExit
        OnKeyDown = EdBriValKeyDown
      end
      object ChBAutoLLLU: TCheckBox
        Left = 16
        Top = 162
        Width = 81
        Height = 17
        Caption = 'Auto LL/UL'
        TabOrder = 13
        OnClick = ChBLLLUClick
      end
      object ChBLLLU: TCheckBox
        Left = 9
        Top = 114
        Width = 49
        Height = 17
        Caption = 'LL/UL'
        TabOrder = 14
        OnClick = ChBLLLUClick
      end
      object ChBAutoLLLUPower: TCheckBox
        Left = 16
        Top = 179
        Width = 75
        Height = 17
        Caption = 'Use Power'
        TabOrder = 15
        OnClick = ChBLLLUClick
      end
      object TBAutoLLULPower: TTrackBar
        Left = 136
        Top = 178
        Width = 130
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        LineSize = 100
        Max = 10000
        PageSize = 1000
        Frequency = 500
        Position = 11
        TabOrder = 16
        ThumbLength = 13
        OnChange = TBAutoLLULPowerChange
      end
      object LbEdAutoLLULPower: TLabeledEdit
        Left = 270
        Top = 181
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
        TabOrder = 17
        Text = '  0.0'
        OnEnter = EdBriValEnter
        OnExit = EdBriValExit
        OnKeyDown = LbEdAutoLLULPowerKeyDown
      end
    end
    object GBFlipRotate: TGroupBox
      Left = 8
      Top = 550
      Width = 321
      Height = 97
      Anchors = [akTop, akRight]
      Caption = '  Orientation  '
      TabOrder = 2
      DesignSize = (
        321
        97)
      object RGRotate_4: TRadioGroup
        Left = 10
        Top = 15
        Width = 299
        Height = 45
        Anchors = [akLeft, akTop, akRight]
        Caption = '  Rotate  '
        Columns = 4
        ItemIndex = 0
        Items.Strings = (
          '&0'#176' '
          '&90'#176' '
          '&180'#176
          '&270'#176)
        TabOrder = 0
      end
      object ChBHor: TCheckBox
        Left = 19
        Top = 68
        Width = 109
        Height = 17
        Caption = 'Flip &Horizontally'
        TabOrder = 1
      end
      object ChBVert: TCheckBox
        Left = 163
        Top = 68
        Width = 143
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Flip &Vertically'
        TabOrder = 2
      end
    end
    object BtReset: TButton
      Left = 8
      Top = 659
      Width = 80
      Height = 23
      Hint = 'Reset processing attributes'
      Anchors = [akTop, akRight]
      Caption = '&Reset'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = BtResetClick
    end
    object BtTest: TButton
      Left = 128
      Top = 659
      Width = 80
      Height = 23
      Hint = 'Apply processing attributes to active image  '
      Anchors = [akTop, akRight]
      Caption = 'Test'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = BtTestClick
    end
    object BtTestUndo: TButton
      Left = 248
      Top = 659
      Width = 80
      Height = 23
      Hint = 'Undo changes done to image by previouse Test button click'
      Anchors = [akTop, akRight]
      Caption = 'Reset Test'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = BtTestUndoClick
    end
    object BtOK: TButton
      Left = 128
      Top = 690
      Width = 80
      Height = 23
      Anchors = [akTop, akRight]
      Caption = '&OK'
      ModalResult = 1
      TabOrder = 6
      OnClick = BtOKClick
    end
    object BtCancel: TButton
      Left = 248
      Top = 690
      Width = 80
      Height = 23
      Anchors = [akTop, akRight]
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 7
      OnClick = BtCancelClick
    end
  end
  inherited BFMinBRPanel: TPanel
    Left = 323
    Top = 714
  end
end
