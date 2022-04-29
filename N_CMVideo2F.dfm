inherited N_CMVideo2Form: TN_CMVideo2Form
  Left = 434
  Top = 176
  Width = 807
  Height = 580
  Caption = 'N_CMVideo2Form'
  DefaultMonitor = dmDesktop
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  DesignSize = (
    791
    541)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel [0]
    Left = 10
    Top = 508
    Width = 27
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Mode'
  end
  object Label3: TLabel [1]
    Left = 119
    Top = 508
    Width = 20
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Size'
  end
  object TmpLabel: TLabel [2]
    Left = 376
    Top = 489
    Width = 47
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'TmpLabel'
    Visible = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 829
    Top = 541
    TabOrder = 11
  end
  object VideoControlsPanel: TPanel
    Left = 439
    Top = 487
    Width = 290
    Height = 58
    Anchors = [akLeft, akBottom]
    TabOrder = 8
    DesignSize = (
      290
      58)
    object TimeLabel: TLabel
      Left = 199
      Top = 19
      Width = 79
      Height = 24
      Alignment = taCenter
      Anchors = [akRight, akBottom]
      Caption = '  999.2  s '
      Color = clRed
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object bnRecord: TButton
      Left = 11
      Top = 15
      Width = 84
      Height = 32
      Caption = 'Record'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = bnRecordClick
    end
    object bnStop: TButton
      Left = 103
      Top = 15
      Width = 84
      Height = 32
      Caption = 'Stop'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = bnStopClick
    end
  end
  object StillControlsPanel: TPanel
    Left = 439
    Top = 487
    Width = 311
    Height = 58
    Anchors = [akLeft, akBottom]
    TabOrder = 9
    object rgOneTwoClicks: TRadioGroup
      Left = 5
      Top = 4
      Width = 168
      Height = 50
      Caption = 'Capture and Save'
      Columns = 2
      ItemIndex = 1
      Items.Strings = (
        'Two Clicks'
        'Single Click')
      TabOrder = 0
      OnClick = rgOneTwoClicksClick
    end
    object gbPreviewMode: TGroupBox
      Left = 179
      Top = 3
      Width = 127
      Height = 51
      Caption = 'Preview Mode'
      TabOrder = 1
      object tbarPreviwMode: TToolBar
        Left = 12
        Top = 19
        Width = 101
        Height = 27
        Align = alNone
        ButtonHeight = 24
        ButtonWidth = 25
        Caption = 'tbarPreviwMode'
        Ctl3D = False
        Images = N_CMResForm.MainIcons18
        TabOrder = 0
        object tbnPM1: TToolButton
          Tag = 1
          Left = 0
          Top = 2
          Caption = 'tbnPM1'
          Grouped = True
          ImageIndex = 10
          Style = tbsCheck
          OnClick = tbnPMNClick
        end
        object tbnPM2: TToolButton
          Tag = 2
          Left = 25
          Top = 2
          Caption = 'tbnPM2'
          Grouped = True
          ImageIndex = 12
          Style = tbsCheck
          OnClick = tbnPMNClick
        end
        object tbnPM3: TToolButton
          Tag = 3
          Left = 50
          Top = 2
          Caption = 'tbnPM3'
          Grouped = True
          ImageIndex = 11
          Style = tbsCheck
          OnClick = tbnPMNClick
        end
        object tbnPM4: TToolButton
          Tag = 4
          Left = 75
          Top = 2
          Caption = 'tbnPM4'
          Grouped = True
          ImageIndex = 13
          Style = tbsCheck
          OnClick = tbnPMNClick
        end
      end
    end
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 791
    Height = 475
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 661
      Top = 1
      Width = 129
      Height = 473
      Align = alRight
      TabOrder = 0
      DesignSize = (
        129
        473)
      object ButtonsPanel: TPanel
        Left = 4
        Top = 404
        Width = 120
        Height = 64
        Anchors = [akRight, akBottom]
        TabOrder = 0
        object bnCapture: TButton
          Left = 7
          Top = 14
          Width = 106
          Height = 37
          Caption = 'Capture'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -24
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnMouseDown = bnCaptureMouseDown
          OnMouseUp = bnCaptureMouseUp
        end
      end
      inline ThumbsRframe: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 381
        HelpType = htKeyword
        Align = alTop
        Anchors = [akLeft, akTop, akRight, akBottom]
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 1
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 365
        end
        inherited HScrollBar: TScrollBar
          Top = 365
          Width = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 365
        end
      end
    end
    object LeftPanel: TPanel
      Left = 1
      Top = 1
      Width = 660
      Height = 473
      Align = alClient
      Caption = 'LeftPanel'
      TabOrder = 1
      OnResize = LeftPanelResize
      object VideoPanel: TPanel
        Left = 5
        Top = 5
        Width = 124
        Height = 204
        BevelWidth = 2
        TabOrder = 0
        object PleaseWaitLabel: TLabel
          Left = 106
          Top = 226
          Width = 533
          Height = 36
          Alignment = taCenter
          Caption = 'Video decoding in progress Please wait.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGreen
          Font.Height = -30
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
      end
      object SlidePanel2: TPanel
        Left = 401
        Top = 48
        Width = 225
        Height = 177
        BevelWidth = 2
        Caption = 'SlidePanel2'
        TabOrder = 1
        Visible = False
        DesignSize = (
          225
          177)
        inline RFrame2: TN_Rast1Frame
          Left = 6
          Top = 6
          Width = 213
          Height = 165
          HelpType = htKeyword
          Anchors = [akLeft, akTop, akRight, akBottom]
          Constraints.MinHeight = 56
          Constraints.MinWidth = 56
          Color = clBtnFace
          ParentColor = False
          TabOrder = 0
          inherited PaintBox: TPaintBox
            Width = 197
            Height = 149
          end
          inherited HScrollBar: TScrollBar
            Top = 149
            Width = 213
          end
          inherited VScrollBar: TScrollBar
            Left = 197
            Height = 149
          end
        end
      end
      object SlidePanel3: TPanel
        Left = 20
        Top = 280
        Width = 225
        Height = 177
        BevelWidth = 2
        Caption = 'SlidePanel2'
        TabOrder = 2
        Visible = False
        DesignSize = (
          225
          177)
        inline RFrame3: TN_Rast1Frame
          Left = 6
          Top = 6
          Width = 213
          Height = 165
          HelpType = htKeyword
          Anchors = [akLeft, akTop, akRight, akBottom]
          Constraints.MinHeight = 56
          Constraints.MinWidth = 56
          Color = clBtnFace
          ParentColor = False
          TabOrder = 0
          inherited PaintBox: TPaintBox
            Width = 197
            Height = 149
          end
          inherited HScrollBar: TScrollBar
            Top = 149
            Width = 213
          end
          inherited VScrollBar: TScrollBar
            Left = 197
            Height = 149
          end
        end
      end
      object SlidePanel4: TPanel
        Left = 372
        Top = 279
        Width = 225
        Height = 177
        BevelWidth = 2
        Caption = 'SlidePanel2'
        TabOrder = 3
        Visible = False
        DesignSize = (
          225
          177)
        inline RFrame4: TN_Rast1Frame
          Left = 6
          Top = 6
          Width = 213
          Height = 165
          HelpType = htKeyword
          Anchors = [akLeft, akTop, akRight, akBottom]
          Constraints.MinHeight = 56
          Constraints.MinWidth = 56
          Color = clBtnFace
          ParentColor = False
          TabOrder = 0
          inherited PaintBox: TPaintBox
            Width = 197
            Height = 149
          end
          inherited HScrollBar: TScrollBar
            Top = 149
            Width = 213
          end
          inherited VScrollBar: TScrollBar
            Left = 197
            Height = 149
          end
        end
      end
      object SlidePanel1: TPanel
        Left = 145
        Top = 48
        Width = 225
        Height = 177
        BevelWidth = 2
        Caption = 'SlidePanel2'
        TabOrder = 4
        Visible = False
        DesignSize = (
          225
          177)
        inline RFrame1: TN_Rast1Frame
          Left = 6
          Top = 6
          Width = 213
          Height = 165
          HelpType = htKeyword
          Anchors = [akLeft, akTop, akRight, akBottom]
          Constraints.MinHeight = 56
          Constraints.MinWidth = 56
          Color = clBtnFace
          ParentColor = False
          TabOrder = 0
          inherited PaintBox: TPaintBox
            Width = 197
            Height = 149
          end
          inherited HScrollBar: TScrollBar
            Top = 149
            Width = 213
          end
          inherited VScrollBar: TScrollBar
            Left = 197
            Height = 149
          end
        end
      end
    end
  end
  object cbCaptMode: TComboBox
    Left = 8
    Top = 524
    Width = 106
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 1
    Text = 'Still Images'
    OnChange = cbCaptModeChange
    Items.Strings = (
      'Still Images'
      'Video Recording')
  end
  object bnFinish: TButton
    Left = 782
    Top = 519
    Width = 50
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Finish'
    ModalResult = 1
    TabOrder = 2
  end
  object bnCaptFilterSettings: TButton
    Left = 109
    Top = 485
    Width = 94
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Driver Settings2 ...'
    TabOrder = 3
    Visible = False
    OnClick = bnCaptFilterSettingsClick
  end
  object bnStreamSettings: TButton
    Left = 8
    Top = 485
    Width = 94
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Driver Settings1 ...'
    TabOrder = 4
    Visible = False
    OnClick = bnStreamSettingsClick
  end
  object gbCaptured: TGroupBox
    Left = 315
    Top = 512
    Width = 118
    Height = 34
    Anchors = [akLeft, akBottom]
    Caption = ' Captured '
    TabOrder = 5
    object NumCaptLabel: TLabel
      Left = 2
      Top = 15
      Width = 114
      Height = 17
      Align = alClient
      Alignment = taCenter
      Caption = 'Stills: 3    Video: 2  '
    end
  end
  object cbCaptSize: TComboBox
    Left = 117
    Top = 524
    Width = 85
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 6
    Text = '320 x 240'
    OnChange = cbCaptSizeChange
    Items.Strings = (
      '320 x 240')
  end
  object bnCameraSettings: TButton
    Left = 208
    Top = 523
    Width = 99
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Camera Settings'
    TabOrder = 7
    OnClick = bnCaptFilterSettingsClick
  end
  object bnCrossBarSettings: TButton
    Left = 208
    Top = 496
    Width = 99
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Crossbar Settings'
    TabOrder = 10
    OnClick = bnCrossBarSettingsClick
  end
  object RecordTimer: TTimer
    Interval = 200
    OnTimer = RecordTimerTimer
    Left = 474
    Top = 9
  end
  object ExtDLLTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ExtDLLTimerTimer
    Left = 513
    Top = 9
  end
end
