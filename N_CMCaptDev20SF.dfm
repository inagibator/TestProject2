inherited N_CMCaptDev20Form: TN_CMCaptDev20Form
  Left = 390
  Top = 186
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 546
  ClientWidth = 772
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 788
  ExplicitHeight = 585
  DesignSize = (
    772
    546)
  PixelsPerInch = 96
  TextHeight = 13
  object CtrlsPanelParent: TPanel [0]
    Left = 1
    Top = 449
    Width = 696
    Height = 89
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
    object CtrlsPanel: TPanel
      Left = 0
      Top = 0
      Width = 696
      Height = 89
      Align = alClient
      Anchors = [akTop, akRight, akBottom]
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        696
        89)
      object LbSerialID: TLabel
        Left = 57
        Top = 40
        Width = 26
        Height = 13
        Caption = 'None'
      end
      object LbSerialText: TLabel
        Left = 8
        Top = 40
        Width = 43
        Height = 13
        Caption = 'Serial ID:'
      end
      object StatusLabel: TLabel
        Left = 29
        Top = 13
        Width = 127
        Height = 16
        Caption = 'Sensor disconnected'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object StatusShape: TShape
        Left = 9
        Top = 14
        Width = 15
        Height = 15
        Brush.Color = clRed
        Shape = stCircle
      end
      object bnCapture: TButton
        Left = 636
        Top = 8
        Width = 57
        Height = 46
        Anchors = [akTop, akRight]
        Caption = 'Capture'
        TabOrder = 0
        Visible = False
        OnClick = bnCaptureClick
      end
      object bnSetup: TButton
        Left = 8
        Top = 63
        Width = 75
        Height = 25
        Caption = 'Setup'
        TabOrder = 1
        Visible = False
        OnClick = bnSetupClick
      end
      object cbAutoTake: TCheckBox
        Left = 89
        Top = 67
        Width = 80
        Height = 17
        Caption = 'Auto Take'
        Checked = True
        State = cbChecked
        TabOrder = 2
        Visible = False
        OnClick = cbAutoTakeClick
      end
      object cbRawImage: TCheckBox
        Left = 175
        Top = 38
        Width = 97
        Height = 17
        Caption = 'Raw image'
        TabOrder = 3
        OnClick = cbRawImageClick
      end
      object CmBIPPMode: TComboBox
        Left = 176
        Top = 12
        Width = 145
        Height = 21
        TabOrder = 4
        Text = 'Select IPP mode...'
        Visible = False
        OnChange = CmBIPPModeChange
      end
      object cmbNew: TComboBox
        Left = 176
        Top = 12
        Width = 145
        Height = 21
        ItemIndex = 3
        TabOrder = 5
        Text = 'Contrast 4'
        Visible = False
        OnChange = cmbNewChange
        Items.Strings = (
          'Contrast 1'
          'Contrast 2'
          'Contrast 3'
          'Contrast 4'
          'Contrast 5'
          'Contrast 6'
          'Contrast 7')
      end
      object tbRotateImage: TToolBar
        Left = 415
        Top = 6
        Width = 204
        Height = 50
        Align = alNone
        Anchors = [akTop, akRight]
        AutoSize = True
        ButtonHeight = 50
        ButtonWidth = 51
        Caption = 'tbRotateImage'
        Ctl3D = False
        TabOrder = 6
        Wrapable = False
        object tbLeft90: TToolButton
          Left = 0
          Top = 0
          AllowAllUp = True
          Caption = '``'
          ImageIndex = 20
          OnClick = tbLeft90Click
        end
        object tbRight90: TToolButton
          Left = 51
          Top = 0
          AllowAllUp = True
          ImageIndex = 21
          OnClick = tbRight90Click
        end
        object tb180: TToolButton
          Left = 102
          Top = 0
          AllowAllUp = True
          ImageIndex = 22
          OnClick = tb180Click
        end
        object tbFlipHor: TToolButton
          Left = 153
          Top = 0
          Caption = 'tbFlipHor'
          ImageIndex = 24
          OnClick = tbFlipHorClick
        end
      end
    end
  end
  inherited BFMinBRPanel: TPanel
    Left = 766
    Top = 540
    ExplicitLeft = 766
    ExplicitTop = 540
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 772
    Height = 441
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object RightPanel: TPanel
      Left = 642
      Top = 1
      Width = 129
      Height = 439
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 437
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 127
        ExplicitHeight = 437
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 421
          ExplicitWidth = 111
          ExplicitHeight = 421
        end
        inherited HScrollBar: TScrollBar
          Top = 421
          Width = 127
          ExplicitTop = 421
          ExplicitWidth = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 421
          ExplicitLeft = 111
          ExplicitHeight = 421
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 641
      Height = 439
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 639
        Height = 437
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 639
        ExplicitHeight = 437
        inherited PaintBox: TPaintBox
          Width = 623
          Height = 420
          ExplicitWidth = 623
          ExplicitHeight = 420
        end
        inherited HScrollBar: TScrollBar
          Top = 420
          Width = 639
          Height = 17
          ExplicitTop = 420
          ExplicitWidth = 639
          ExplicitHeight = 17
        end
        inherited VScrollBar: TScrollBar
          Left = 623
          Height = 420
          ExplicitLeft = 623
          ExplicitHeight = 420
        end
      end
    end
  end
  object bnExit: TButton
    Left = 703
    Top = 457
    Width = 62
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 3
    OnClick = bnExitClick
  end
  object TimerCheck: TTimer
    Enabled = False
    Interval = 200
    OnTimer = TimerCheckTimer
    Left = 376
    Top = 584
  end
end
