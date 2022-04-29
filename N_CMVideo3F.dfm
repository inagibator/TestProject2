inherited N_CMVideo3Form: TN_CMVideo3Form
  Left = 184
  Top = 54
  Caption = 'N_CMVideo3Form'
  ClientHeight = 541
  ClientWidth = 870
  KeyPreview = True
  OldCreateOrder = True
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 886
  ExplicitHeight = 580
  DesignSize = (
    870
    541)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel [0]
    Left = 8
    Top = 499
    Width = 27
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Mode'
  end
  object Label3: TLabel [1]
    Left = 118
    Top = 499
    Width = 20
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Size'
  end
  inherited BFMinBRPanel: TPanel
    Left = 887
    Top = 536
    Width = 11
    TabOrder = 10
    ExplicitLeft = 887
    ExplicitTop = 536
    ExplicitWidth = 11
  end
  object StillControlsPanel: TPanel
    Left = 439
    Top = 484
    Width = 311
    Height = 58
    Anchors = [akLeft, akBottom]
    TabOrder = 8
    object rgOneTwoClicks: TRadioGroup
      Left = 5
      Top = 3
      Width = 168
      Height = 51
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
          Top = 0
          Caption = 'tbnPM1'
          Grouped = True
          ImageIndex = 10
          Style = tbsCheck
          OnClick = tbnPMNClick
        end
        object tbnPM2: TToolButton
          Tag = 2
          Left = 25
          Top = 0
          Caption = 'tbnPM2'
          Grouped = True
          ImageIndex = 12
          Style = tbsCheck
          OnClick = tbnPMNClick
        end
        object tbnPM3: TToolButton
          Tag = 3
          Left = 50
          Top = 0
          Caption = 'tbnPM3'
          Grouped = True
          ImageIndex = 11
          Style = tbsCheck
          OnClick = tbnPMNClick
        end
        object tbnPM4: TToolButton
          Tag = 4
          Left = 75
          Top = 0
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
    Width = 870
    Height = 480
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 740
      Top = 1
      Width = 129
      Height = 478
      Align = alRight
      TabOrder = 0
      DesignSize = (
        129
        478)
      object ButtonsPanel: TPanel
        Left = 6
        Top = 344
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
        Height = 337
        HelpType = htKeyword
        Align = alTop
        Anchors = [akLeft, akTop, akRight, akBottom]
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 1
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 127
        ExplicitHeight = 337
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 319
          ExplicitWidth = 111
          ExplicitHeight = 319
        end
        inherited HScrollBar: TScrollBar
          Top = 319
          Width = 127
          Height = 18
          ExplicitTop = 319
          ExplicitWidth = 127
          ExplicitHeight = 18
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 319
          ExplicitLeft = 111
          ExplicitHeight = 319
        end
      end
      object VideoControlsPanel: TPanel
        Left = 6
        Top = 414
        Width = 120
        Height = 57
        Anchors = [akLeft, akBottom]
        TabOrder = 2
        DesignSize = (
          120
          57)
        object TimeLabel: TLabel
          Left = 37
          Top = 38
          Width = 53
          Height = 16
          Alignment = taCenter
          Anchors = [akRight, akBottom]
          Caption = '  999.2  s '
          Color = clRed
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object bnRecord: TButton
          Left = 6
          Top = 4
          Width = 52
          Height = 32
          Caption = 'Record'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = bnRecordClick
        end
        object bnStop: TButton
          Left = 62
          Top = 4
          Width = 52
          Height = 32
          Caption = 'Stop'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = bnStopClick
        end
      end
    end
    object LeftPanel: TPanel
      Left = 1
      Top = 1
      Width = 739
      Height = 478
      Align = alClient
      TabOrder = 1
      OnResize = LeftPanelResize
      object PleaseWaitLabel: TLabel
        Left = 106
        Top = 226
        Width = 557
        Height = 36
        Alignment = taCenter
        Caption = 'Video decoding in progress. Please wait...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGreen
        Font.Height = -30
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        Visible = False
      end
      object VideoPanel: TPanel
        Left = 5
        Top = 5
        Width = 124
        Height = 204
        BevelWidth = 2
        TabOrder = 0
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
          ExplicitLeft = 6
          ExplicitTop = 6
          ExplicitWidth = 213
          ExplicitHeight = 165
          inherited PaintBox: TPaintBox
            Width = 197
            Height = 149
            ExplicitWidth = 197
            ExplicitHeight = 149
          end
          inherited HScrollBar: TScrollBar
            Top = 149
            Width = 213
            ExplicitTop = 149
            ExplicitWidth = 213
          end
          inherited VScrollBar: TScrollBar
            Left = 197
            Height = 149
            ExplicitLeft = 197
            ExplicitHeight = 149
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
          ExplicitLeft = 6
          ExplicitTop = 6
          ExplicitWidth = 213
          ExplicitHeight = 165
          inherited PaintBox: TPaintBox
            Width = 197
            Height = 149
            ExplicitWidth = 197
            ExplicitHeight = 149
          end
          inherited HScrollBar: TScrollBar
            Top = 149
            Width = 213
            ExplicitTop = 149
            ExplicitWidth = 213
          end
          inherited VScrollBar: TScrollBar
            Left = 197
            Height = 149
            ExplicitLeft = 197
            ExplicitHeight = 149
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
          ExplicitLeft = 6
          ExplicitTop = 6
          ExplicitWidth = 213
          ExplicitHeight = 165
          inherited PaintBox: TPaintBox
            Width = 197
            Height = 149
            ExplicitWidth = 197
            ExplicitHeight = 149
          end
          inherited HScrollBar: TScrollBar
            Top = 149
            Width = 213
            ExplicitTop = 149
            ExplicitWidth = 213
          end
          inherited VScrollBar: TScrollBar
            Left = 197
            Height = 149
            ExplicitLeft = 197
            ExplicitHeight = 149
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
          ExplicitLeft = 6
          ExplicitTop = 6
          ExplicitWidth = 213
          ExplicitHeight = 165
          inherited PaintBox: TPaintBox
            Width = 197
            Height = 149
            ExplicitWidth = 197
            ExplicitHeight = 149
          end
          inherited HScrollBar: TScrollBar
            Top = 149
            Width = 213
            ExplicitTop = 149
            ExplicitWidth = 213
          end
          inherited VScrollBar: TScrollBar
            Left = 197
            Height = 149
            ExplicitLeft = 197
            ExplicitHeight = 149
          end
        end
      end
    end
  end
  object cbCaptMode: TComboBox
    Left = 8
    Top = 514
    Width = 106
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemIndex = 1
    TabOrder = 1
    Text = 'Video Recording'
    OnChange = cbCaptModeChange
    Items.Strings = (
      'Still Images'
      'Video Recording')
  end
  object bnFinish: TButton
    Left = 838
    Top = 510
    Width = 50
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Finish'
    ModalResult = 1
    TabOrder = 2
  end
  object bnCaptFilterSettings: TButton
    Left = 108
    Top = 482
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
    Top = 482
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
    Top = 509
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
      ExplicitWidth = 90
      ExplicitHeight = 13
    end
  end
  object cbCaptSize: TComboBox
    Left = 117
    Top = 514
    Width = 85
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemIndex = 0
    TabOrder = 6
    Text = '320 x 240'
    OnChange = cbCaptSizeChange
    Items.Strings = (
      '320 x 240')
  end
  object bnCameraSettings: TButton
    Left = 208
    Top = 518
    Width = 99
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Camera Settings'
    TabOrder = 7
    OnClick = bnCaptFilterSettingsClick
  end
  object bnCrossBarSettings: TButton
    Left = 208
    Top = 491
    Width = 99
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Crossbar Settings'
    TabOrder = 9
    OnClick = bnCrossBarSettingsClick
  end
  object cbFlipHor: TCheckBox
    Left = 317
    Top = 486
    Width = 116
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Flip Horizontally'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
    Visible = False
    OnClick = cbFlipHorClick
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
  object TimerError: TTimer
    Enabled = False
    OnTimer = TimerErrorTimer
    Left = 560
    Top = 32
  end
end
