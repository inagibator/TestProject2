inherited N_CMCaptDev21Form: TN_CMCaptDev21Form
  Left = 344
  Top = 195
  Width = 943
  Height = 617
  Caption = '_Schick devices'
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  DesignSize = (
    927
    578)
  PixelsPerInch = 96
  TextHeight = 13
  object CtrlsPanelParent: TPanel [0]
    Left = 0
    Top = 496
    Width = 852
    Height = 81
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    object CtrlsPanel: TPanel
      Left = 0
      Top = 0
      Width = 852
      Height = 81
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        852
        81)
      object StatusLabel: TLabel
        Left = 42
        Top = 14
        Width = 78
        Height = 16
        Caption = '_StatusLabel'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object StatusShape: TShape
        Left = 16
        Top = 14
        Width = 15
        Height = 15
        Shape = stCircle
      end
      object bnSetup: TButton
        Left = 16
        Top = 40
        Width = 75
        Height = 25
        Caption = 'Setup'
        TabOrder = 0
        OnClick = bnSetupClick
      end
      object cbRaw: TCheckBox
        Left = 101
        Top = 44
        Width = 72
        Height = 17
        Caption = 'Raw Image'
        TabOrder = 1
      end
      object PanelFilter: TPanel
        Left = 197
        Top = 6
        Width = 281
        Height = 63
        TabOrder = 2
        DesignSize = (
          281
          63)
        object lbSharp: TLabel
          Left = 164
          Top = 12
          Width = 69
          Height = 13
          Anchors = [akLeft, akBottom]
          Caption = 'Sharp/Smooth'
        end
        object rbModeA: TRadioButton
          Left = 14
          Top = 10
          Width = 57
          Height = 17
          Anchors = [akLeft, akBottom]
          Caption = 'Mode A'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rbModeAClick
        end
        object rbModeB: TRadioButton
          Left = 77
          Top = 10
          Width = 57
          Height = 17
          Anchors = [akLeft, akBottom]
          Caption = 'Mode B'
          TabOrder = 1
          OnClick = rbModeBClick
        end
        object TrackBar1: TTrackBar
          Left = 147
          Top = 29
          Width = 127
          Height = 28
          Anchors = [akLeft, akBottom]
          Max = 100
          Frequency = 50
          Position = 50
          TabOrder = 2
          OnChange = TrackBar1Change
        end
        object cbMapping: TComboBox
          Left = 14
          Top = 33
          Width = 127
          Height = 21
          Anchors = [akLeft, akBottom]
          ItemHeight = 13
          ItemIndex = 2
          TabOrder = 3
          Text = 'General Dentistry'
          OnChange = cbMappingChange
          Items.Strings = (
            'Endodontic'
            'Periodontic'
            'General Dentistry'
            'Caries'
            'Hygiene')
        end
      end
      object tbRotateImage: TToolBar
        Left = 488
        Top = 7
        Width = 204
        Height = 54
        Align = alNone
        Anchors = [akTop, akRight]
        AutoSize = True
        ButtonHeight = 50
        ButtonWidth = 51
        Caption = 'tbRotateImage'
        Ctl3D = False
        TabOrder = 3
        Wrapable = False
        object tbLeft90: TToolButton
          Left = 0
          Top = 2
          AllowAllUp = True
          ImageIndex = 20
          OnClick = tbLeft90Click
        end
        object tbRight90: TToolButton
          Left = 51
          Top = 2
          AllowAllUp = True
          ImageIndex = 21
          OnClick = tbRight90Click
        end
        object tb180: TToolButton
          Left = 102
          Top = 2
          AllowAllUp = True
          ImageIndex = 22
          OnClick = tb180Click
        end
        object tbFlipHor: TToolButton
          Left = 153
          Top = 2
          Caption = 'tbFlipHor'
          ImageIndex = 24
          OnClick = tbFlipHorClick
        end
      end
      object bnImport: TButton
        Left = 703
        Top = 8
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Import'
        TabOrder = 4
        Visible = False
        OnClick = bnImportClick
      end
      object cbAutoTake: TCheckBox
        Left = 702
        Top = 33
        Width = 74
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Auto Take'
        TabOrder = 5
        Visible = False
        OnClick = cbAutoTakeClick
      end
      object bnCapture: TButton
        Left = 782
        Top = 21
        Width = 65
        Height = 41
        Anchors = [akTop, akRight]
        Caption = 'Capture'
        TabOrder = 6
        OnClick = bnCaptureClick
      end
    end
  end
  inherited BFMinBRPanel: TPanel
    Left = 921
    Top = 573
    TabOrder = 2
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 927
    Height = 494
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 797
      Top = 1
      Width = 129
      Height = 492
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 490
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 474
        end
        inherited HScrollBar: TScrollBar
          Top = 474
          Width = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 474
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 796
      Height = 492
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 794
        Height = 490
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        inherited PaintBox: TPaintBox
          Width = 778
          Height = 477
        end
        inherited HScrollBar: TScrollBar
          Top = 477
          Width = 794
          Height = 13
        end
        inherited VScrollBar: TScrollBar
          Left = 778
          Height = 477
        end
      end
    end
  end
  object bnExit: TButton
    Left = 855
    Top = 518
    Width = 62
    Height = 40
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
  end
  object CheckTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = CheckTimerTimer
    Left = 147
    Top = 505
  end
end
