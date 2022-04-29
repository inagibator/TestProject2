inherited N_CMCaptDev12Form: TN_CMCaptDev12Form
  Left = 740
  Top = 245
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 667
  ClientWidth = 774
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 790
  ExplicitHeight = 706
  DesignSize = (
    774
    667)
  PixelsPerInch = 96
  TextHeight = 13
  object StatusShape: TShape [0]
    Left = 8
    Top = 565
    Width = 15
    Height = 15
    Anchors = [akLeft, akBottom]
    Brush.Color = clRed
    Shape = stCircle
  end
  object StatusLabel: TLabel [1]
    Left = 29
    Top = 564
    Width = 127
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Sensor disconnected'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object LbSerialText: TLabel [2]
    Left = 8
    Top = 591
    Width = 43
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Serial ID:'
  end
  object LbSerialID: TLabel [3]
    Left = 57
    Top = 591
    Width = 26
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'None'
  end
  inherited BFMinBRPanel: TPanel
    Left = 796
    Top = 614
    TabOrder = 2
    ExplicitLeft = 796
    ExplicitTop = 614
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 774
    Height = 553
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 644
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
      Width = 643
      Height = 551
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 641
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
        ExplicitWidth = 641
        ExplicitHeight = 549
        inherited PaintBox: TPaintBox
          Width = 625
          Height = 533
          ExplicitWidth = 625
          ExplicitHeight = 533
        end
        inherited HScrollBar: TScrollBar
          Top = 533
          Width = 641
          ExplicitTop = 533
          ExplicitWidth = 641
        end
        inherited VScrollBar: TScrollBar
          Left = 625
          Height = 533
          ExplicitLeft = 625
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
  object bnCapture: TButton
    Left = 673
    Top = 565
    Width = 57
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Capture'
    TabOrder = 3
    Visible = False
    OnClick = bnCaptureClick
  end
  object tbRotateImage: TToolBar
    Left = 455
    Top = 562
    Width = 204
    Height = 54
    Align = alNone
    Anchors = [akRight, akBottom]
    AutoSize = True
    ButtonHeight = 50
    ButtonWidth = 51
    Caption = 'tbRotateImage'
    Ctl3D = False
    TabOrder = 4
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
  object cbAutoTake: TCheckBox
    Left = 89
    Top = 618
    Width = 80
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Auto Take'
    Checked = True
    State = cbChecked
    TabOrder = 5
    Visible = False
    OnClick = cbAutoTakeClick
  end
  object bnSetup: TButton
    Left = 8
    Top = 614
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Setup'
    TabOrder = 6
    Visible = False
    OnClick = bnSetupClick
  end
  object CmBIPPMode: TComboBox
    Left = 215
    Top = 563
    Width = 145
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 7
    Text = 'Select IPP mode...'
    OnChange = CmBIPPModeChange
    Items.Strings = (
      'High constast New'
      'Middle constast New'
      'Normal image'
      'Low constrast New'
      'High contrast'
      'Middle contrast'
      'Low contrast')
  end
  object cbRawImage: TCheckBox
    Left = 215
    Top = 590
    Width = 97
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Raw image'
    TabOrder = 8
    OnClick = cbRawImageClick
  end
  object TimerCheck: TTimer
    Enabled = False
    Interval = 200
    OnTimer = TimerCheckTimer
    Left = 408
    Top = 576
  end
end
