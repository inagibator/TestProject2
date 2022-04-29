inherited N_BrigHist2Form: TN_BrigHist2Form
  Left = 222
  Top = 474
  Width = 518
  Height = 326
  BorderStyle = bsSizeToolWin
  Caption = '_Brightness Histogramm'
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnResize = nil
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 500
    Top = 278
  end
  object rgYAxis: TRadioGroup
    Left = 8
    Top = 223
    Width = 93
    Height = 56
    Anchors = [akLeft, akBottom]
    Caption = ' Vertical axis  '
    ItemIndex = 0
    Items.Strings = (
      'Pixels'
      'Percentage')
    TabOrder = 1
    OnClick = rgYAxisClick
  end
  object edYValue: TLabeledEdit
    Left = 152
    Top = 229
    Width = 76
    Height = 21
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 33
    EditLabel.Height = 13
    EditLabel.Caption = 'Pixels  '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
    Text = '9000000000'
  end
  object edBriValue: TLabeledEdit
    Left = 153
    Top = 256
    Width = 76
    Height = 21
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 38
    EditLabel.Height = 13
    EditLabel.Caption = 'Density '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 3
  end
  object bnClose: TButton
    Left = 423
    Top = 241
    Width = 75
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 4
    OnClick = bnCloseClick
  end
  inline BHFrame: TN_BrigHistFrame
    Left = 0
    Top = 0
    Width = 510
    Height = 222
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 5
    OnResize = RFrameResize
    inherited RFrame: TN_Rast1Frame
      Width = 510
      Height = 222
      inherited PaintBox: TPaintBox
        Width = 494
        Height = 206
      end
      inherited HScrollBar: TScrollBar
        Top = 206
        Width = 510
      end
      inherited VScrollBar: TScrollBar
        Left = 494
        Height = 206
      end
    end
  end
  object gbScale: TGroupBox
    Left = 252
    Top = 223
    Width = 157
    Height = 56
    Anchors = [akLeft, akBottom]
    Caption = ' Scale '
    TabOrder = 6
    object tbYScale: TTrackBar
      Left = 2
      Top = 17
      Width = 100
      Height = 29
      Max = 995
      PageSize = 200
      Frequency = 50
      Position = 990
      TabOrder = 0
      OnChange = tbYScaleChange
    end
    object cbAuto: TCheckBox
      Left = 107
      Top = 20
      Width = 47
      Height = 17
      Caption = 'Auto'
      TabOrder = 1
      OnClick = cbAutoClick
    end
  end
end
