inherited N_CMCaptDev5Form: TN_CMCaptDev5Form
  Left = 300
  Top = 172
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 594
  ClientWidth = 774
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 790
  ExplicitHeight = 633
  DesignSize = (
    774
    594)
  PixelsPerInch = 96
  TextHeight = 13
  object StatusShape: TShape [0]
    Left = 12
    Top = 577
    Width = 15
    Height = 15
    Anchors = [akLeft, akBottom]
    Brush.Color = 1478391
    Shape = stCircle
  end
  object StatusLabel: TLabel [1]
    Left = 33
    Top = 576
    Width = 45
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Waiting'
    Color = 1478391
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 796
    Top = 602
    TabOrder = 2
    ExplicitLeft = 796
    ExplicitTop = 602
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 774
    Height = 557
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 644
      Top = 1
      Width = 129
      Height = 555
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 553
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
        ExplicitHeight = 553
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 537
          ExplicitWidth = 111
          ExplicitHeight = 537
        end
        inherited HScrollBar: TScrollBar
          Top = 537
          Width = 127
          ExplicitTop = 537
          ExplicitWidth = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 537
          ExplicitLeft = 111
          ExplicitHeight = 537
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 643
      Height = 555
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 641
        Height = 553
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
        ExplicitHeight = 553
        inherited PaintBox: TPaintBox
          Width = 625
          Height = 537
          ExplicitWidth = 633
          ExplicitHeight = 537
        end
        inherited HScrollBar: TScrollBar
          Top = 537
          Width = 641
          ExplicitTop = 537
          ExplicitWidth = 641
        end
        inherited VScrollBar: TScrollBar
          Left = 625
          Height = 537
          ExplicitLeft = 625
          ExplicitHeight = 537
        end
      end
    end
  end
  object bnExit: TButton
    Left = 715
    Top = 571
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
  end
  object tbRotateImage: TToolBar
    Left = 397
    Top = 559
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
  object ProgressBar1: TProgressBar
    Left = 240
    Top = 465
    Width = 150
    Height = 19
    Anchors = [akRight, akBottom]
    Smooth = True
    TabOrder = 4
    Visible = False
  end
  object CheckBox1: TCheckBox
    Left = 612
    Top = 600
    Width = 97
    Height = 17
    Caption = 'Force'
    TabOrder = 5
    Visible = False
  end
  object bnCapture: TButton
    Left = 634
    Top = 571
    Width = 75
    Height = 25
    Caption = 'Capture'
    TabOrder = 6
    Visible = False
    OnClick = bnCaptureClick
  end
  object cbCalibration: TCheckBox
    Left = 300
    Top = 582
    Width = 91
    Height = 17
    Caption = 'Use Calibration'
    Checked = True
    State = cbChecked
    TabOrder = 7
    OnClick = cbCalibrationClick
  end
  object RadioGroup1: TRadioGroup
    Left = 110
    Top = 570
    Width = 176
    Height = 34
    Caption = 'Resolution'
    Columns = 3
    ItemIndex = 0
    Items.Strings = (
      'High'
      'Medium'
      'Normal')
    TabOrder = 8
  end
  object CheckTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = CheckTimerTimer
    Left = 159
    Top = 407
  end
  object TimerImage: TTimer
    Enabled = False
    OnTimer = TimerImageTimer
    Left = 200
    Top = 408
  end
  object StatusTimer: TTimer
    Interval = 100
    OnTimer = StatusTimerTimer
    Left = 240
    Top = 408
  end
end
