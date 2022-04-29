inherited N_CMCaptDev17Form: TN_CMCaptDev17Form
  Left = 253
  Top = 107
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 664
  ClientWidth = 782
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnPaint = FormPaint
  OnShow = FormShow
  ExplicitWidth = 798
  ExplicitHeight = 703
  DesignSize = (
    782
    664)
  PixelsPerInch = 96
  TextHeight = 13
  object StatusShape: TShape [0]
    Left = 8
    Top = 561
    Width = 15
    Height = 15
    Anchors = [akLeft, akBottom]
    Brush.Color = clRed
    Shape = stCircle
  end
  object StatusLabel: TLabel [1]
    Left = 29
    Top = 560
    Width = 83
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Disconnected'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 796
    Top = 610
    TabOrder = 2
    ExplicitLeft = 796
    ExplicitTop = 610
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 782
    Height = 549
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 652
      Top = 1
      Width = 129
      Height = 547
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 545
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
        ExplicitHeight = 545
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 529
          ExplicitWidth = 111
          ExplicitHeight = 529
        end
        inherited HScrollBar: TScrollBar
          Top = 529
          Width = 127
          ExplicitTop = 529
          ExplicitWidth = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 529
          ExplicitLeft = 111
          ExplicitHeight = 529
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 651
      Height = 547
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 649
        Height = 545
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 649
        ExplicitHeight = 545
        inherited PaintBox: TPaintBox
          Width = 633
          Height = 529
          ExplicitWidth = 641
          ExplicitHeight = 529
        end
        inherited HScrollBar: TScrollBar
          Top = 529
          Width = 649
          ExplicitTop = 529
          ExplicitWidth = 649
        end
        inherited VScrollBar: TScrollBar
          Left = 633
          Height = 529
          ExplicitLeft = 633
          ExplicitHeight = 529
        end
      end
    end
  end
  object bnExit: TButton
    Left = 736
    Top = 561
    Width = 62
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
  end
  object tbRotateImage: TToolBar
    Left = 455
    Top = 558
    Width = 204
    Height = 50
    Align = alNone
    Anchors = [akRight, akBottom]
    AutoSize = True
    ButtonHeight = 50
    ButtonWidth = 51
    Caption = 'tbRotateImage'
    Ctl3D = False
    TabOrder = 3
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
  object bnSetup: TButton
    Left = 8
    Top = 582
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Setup'
    TabOrder = 4
    OnClick = bnSetupClick
  end
  object bnStopCapture: TButton
    Left = 360
    Top = 590
    Width = 75
    Height = 25
    Caption = 'Stop Capture'
    TabOrder = 5
    Visible = False
    OnClick = bnStopCaptureClick
  end
  object bnStartCapture: TButton
    Left = 360
    Top = 559
    Width = 75
    Height = 25
    Caption = 'bnStartCapture'
    TabOrder = 6
    Visible = False
    OnClick = bnStartCaptureClick
  end
end
