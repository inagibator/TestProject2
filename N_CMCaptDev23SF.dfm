inherited N_CMCaptDev23Form: TN_CMCaptDev23Form
  Left = 360
  Top = 186
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 645
  ClientWidth = 808
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 824
  ExplicitHeight = 684
  DesignSize = (
    808
    645)
  PixelsPerInch = 96
  TextHeight = 13
  object CtrlsPanelParent: TPanel [0]
    Left = 0
    Top = 552
    Width = 731
    Height = 93
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    object CtrlsPanel: TPanel
      Left = 0
      Top = 0
      Width = 731
      Height = 93
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        731
        93)
      object lbExpoLevel: TLabel
        Left = 237
        Top = 14
        Width = 6
        Height = 13
        Caption = '0'
        Visible = False
      end
      object lbExpoLevelPrev: TLabel
        Left = 184
        Top = 14
        Width = 47
        Height = 13
        Caption = 'Exposure:'
        Visible = False
      end
      object LbSerialID: TLabel
        Left = 57
        Top = 39
        Width = 26
        Height = 13
        Caption = 'None'
        Visible = False
      end
      object LbSerialText: TLabel
        Left = 8
        Top = 39
        Width = 43
        Height = 13
        Caption = 'Serial ID:'
        Visible = False
      end
      object StatusShape: TShape
        Left = 8
        Top = 13
        Width = 15
        Height = 15
        Brush.Color = clRed
        Shape = stCircle
      end
      object StatusLabel: TLabel
        Left = 29
        Top = 12
        Width = 83
        Height = 16
        Caption = 'Disconnected'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object tbRotateImage: TToolBar
        Left = 454
        Top = 9
        Width = 204
        Height = 50
        Align = alNone
        Anchors = [akTop, akRight]
        AutoSize = True
        ButtonHeight = 50
        ButtonWidth = 51
        Caption = 'tbRotateImage'
        Ctl3D = False
        TabOrder = 0
        Wrapable = False
        object tbLeft90: TToolButton
          Left = 0
          Top = 0
          AllowAllUp = True
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
      object cbAutoTake: TCheckBox
        Left = 89
        Top = 66
        Width = 80
        Height = 17
        Caption = 'Auto Take'
        Checked = True
        State = cbChecked
        TabOrder = 1
        Visible = False
        OnClick = cbAutoTakeClick
      end
      object bnSetup: TButton
        Left = 8
        Top = 35
        Width = 75
        Height = 25
        Caption = 'Setup'
        TabOrder = 2
        OnClick = bnSetupClick
      end
      object bnCapture: TButton
        Left = 673
        Top = 13
        Width = 57
        Height = 46
        Anchors = [akTop, akRight]
        Caption = 'Capture'
        TabOrder = 3
        Visible = False
        OnClick = bnCaptureClick
      end
    end
  end
  inherited BFMinBRPanel: TPanel
    Left = 804
    Top = 641
    Width = 7
    Height = 7
    TabOrder = 2
    ExplicitLeft = 804
    ExplicitTop = 641
    ExplicitWidth = 7
    ExplicitHeight = 7
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 808
    Height = 553
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 678
      Top = 1
      Width = 129
      Height = 551
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 549
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
        ExplicitHeight = 549
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 533
          ExplicitWidth = 111
          ExplicitHeight = 533
        end
        inherited HScrollBar: TScrollBar
          Top = 533
          Width = 127
          ExplicitTop = 533
          ExplicitWidth = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 533
          ExplicitLeft = 111
          ExplicitHeight = 533
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 677
      Height = 551
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 675
        Height = 549
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 675
        ExplicitHeight = 549
        inherited PaintBox: TPaintBox
          Width = 659
          Height = 533
          ExplicitWidth = 659
          ExplicitHeight = 533
        end
        inherited HScrollBar: TScrollBar
          Top = 533
          Width = 675
          ExplicitTop = 533
          ExplicitWidth = 675
        end
        inherited VScrollBar: TScrollBar
          Left = 659
          Height = 533
          ExplicitLeft = 659
          ExplicitHeight = 533
        end
      end
    end
  end
  object bnExit: TButton
    Left = 736
    Top = 565
    Width = 62
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
    OnClick = bnExitClick
  end
  object TimerCheck: TTimer
    Enabled = False
    Interval = 200
    OnTimer = TimerCheckTimer
    Left = 408
    Top = 576
  end
end
