inherited K_FormCMSBriCoGam1: TK_FormCMSBriCoGam1
  Left = 412
  Top = 404
  Width = 342
  Height = 501
  BorderIcons = [biSystemMenu]
  Caption = '  Brightness / Contrast / Gamma'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnResize = nil
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel [0]
    Left = 12
    Top = 12
    Width = 49
    Height = 13
    Caption = '&Brightness'
    FocusControl = TBBrightness
  end
  object Label4: TLabel [1]
    Left = 12
    Top = 84
    Width = 36
    Height = 13
    Caption = '&Gamma'
    FocusControl = TBGamma
  end
  object Label5: TLabel [2]
    Left = 12
    Top = 49
    Width = 39
    Height = 13
    Caption = 'Co&ntrast'
    FocusControl = TBContrast
  end
  object LbLL: TLabel [3]
    Left = 12
    Top = 296
    Width = 12
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '&LL'
    FocusControl = TBLL
  end
  object LbLU: TLabel [4]
    Left = 12
    Top = 332
    Width = 14
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '&UL'
    FocusControl = TBLU
  end
  object LbAutoLLULPower: TLabel [5]
    Left = 114
    Top = 398
    Width = 30
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Power'
  end
  inherited BFMinBRPanel: TPanel
    Left = 324
    Top = 457
    TabOrder = 9
  end
  object BtCancel: TButton
    Left = 244
    Top = 436
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 157
    Top = 436
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object TBBrightness: TTrackBar
    Left = 68
    Top = 10
    Width = 208
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    LineSize = 7
    Max = 10000
    ParentCtl3D = False
    PageSize = 70
    Frequency = 1000
    Position = 5000
    TabOrder = 2
    OnChange = TBValChange
  end
  object TBGamma: TTrackBar
    Left = 68
    Top = 82
    Width = 208
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    LineSize = 7
    Max = 10000
    PageSize = 70
    Frequency = 1000
    Position = 5000
    TabOrder = 3
    OnChange = TBValChange
  end
  object TBContrast: TTrackBar
    Left = 68
    Top = 46
    Width = 208
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    LineSize = 7
    Max = 10000
    PageSize = 70
    Frequency = 1000
    Position = 5000
    TabOrder = 4
    OnChange = TBValChange
  end
  object bnReset: TButton
    Left = 75
    Top = 436
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '&Reset'
    TabOrder = 5
    OnClick = bnResetClick
  end
  object EdBriVal: TEdit
    Left = 282
    Top = 13
    Width = 38
    Height = 17
    Anchors = [akTop, akRight]
    AutoSize = False
    Color = 10682367
    TabOrder = 6
    Text = '  -99.5'
    OnEnter = EdBriValEnter
    OnKeyDown = EdBriValKeyDown
  end
  object EdCoVal: TEdit
    Left = 282
    Top = 49
    Width = 38
    Height = 17
    Anchors = [akTop, akRight]
    AutoSize = False
    Color = 10682367
    TabOrder = 7
    Text = '  -99.5'
    OnEnter = EdBriValEnter
    OnKeyDown = EdBriValKeyDown
  end
  object EdGamVal: TEdit
    Left = 282
    Top = 85
    Width = 38
    Height = 17
    Anchors = [akTop, akRight]
    AutoSize = False
    Color = 10682367
    TabOrder = 8
    Text = '  -99.5'
    OnEnter = EdBriValEnter
    OnKeyDown = EdBriValKeyDown
  end
  object TBLL: TTrackBar
    Left = 68
    Top = 293
    Width = 208
    Height = 33
    Anchors = [akLeft, akRight, akBottom]
    LineSize = 7
    Max = 1000
    PageSize = 70
    Frequency = 100
    Position = 500
    TabOrder = 10
    OnChange = TBValChange
  end
  object EdLLVal: TEdit
    Left = 282
    Top = 297
    Width = 38
    Height = 17
    Anchors = [akRight, akBottom]
    AutoSize = False
    Color = 10682367
    TabOrder = 11
    Text = '  -99.5'
    OnEnter = EdBriValEnter
    OnKeyDown = EdBriValKeyDown
  end
  object TBLU: TTrackBar
    Left = 68
    Top = 328
    Width = 208
    Height = 33
    Anchors = [akLeft, akRight, akBottom]
    LineSize = 7
    Max = 1000
    PageSize = 70
    Frequency = 100
    Position = 500
    TabOrder = 12
    OnChange = TBValChange
  end
  object EdLUVal: TEdit
    Left = 282
    Top = 333
    Width = 38
    Height = 17
    Anchors = [akRight, akBottom]
    AutoSize = False
    Color = 10682367
    TabOrder = 13
    Text = '  -99.5'
    OnEnter = EdBriValEnter
    OnKeyDown = EdBriValKeyDown
  end
  object ChBSyncLLUL: TCheckBox
    Left = 155
    Top = 365
    Width = 158
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Syncronize LL/UL changing'
    TabOrder = 14
  end
  inline BCGHistFrame: TN_BrigHistFrame
    Left = 75
    Top = 119
    Width = 193
    Height = 161
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 15
    OnResize = HistFrameResize
    inherited RFrame: TN_Rast1Frame
      Width = 193
      Height = 161
      inherited PaintBox: TPaintBox
        Width = 177
        Height = 145
      end
      inherited HScrollBar: TScrollBar
        Top = 145
        Width = 193
      end
      inherited VScrollBar: TScrollBar
        Left = 177
        Height = 145
      end
    end
  end
  object ChBAutoLLLU: TCheckBox
    Left = 26
    Top = 365
    Width = 81
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Auto LL/UL'
    TabOrder = 16
    OnClick = ChBAutoLLLUClick
  end
  object ChBAutoLLLUPower: TCheckBox
    Left = 26
    Top = 396
    Width = 75
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Use Power'
    TabOrder = 17
    OnClick = ChBAutoLLLUClick
  end
  object TBAutoLLULPower: TTrackBar
    Left = 144
    Top = 395
    Width = 129
    Height = 33
    Anchors = [akLeft, akRight, akBottom]
    LineSize = 100
    Max = 10000
    PageSize = 1000
    Frequency = 1000
    Position = 11
    TabOrder = 18
    OnChange = ChBAutoLLLUClick
  end
  object LbEdAutoLLULPower: TLabeledEdit
    Left = 282
    Top = 398
    Width = 38
    Height = 17
    Anchors = [akRight, akBottom]
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
    TabOrder = 19
    Text = '  0.0'
    OnEnter = EdBriValEnter
    OnKeyDown = EdBriValKeyDown
  end
end
