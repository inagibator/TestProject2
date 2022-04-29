inherited N_PMTDiagr2Form: TN_PMTDiagr2Form
  Left = 498
  Top = 35
  Width = 902
  Height = 901
  TransparentColorValue = clBtnFace
  Constraints.MinHeight = 536
  Constraints.MinWidth = 600
  DefaultMonitor = dmPrimary
  Font.Name = 'MS Sans Serif'
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poDefault
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 700
    Top = 770
    TabOrder = 1
  end
  inline RFrame1: TN_Rast1Frame
    Left = 0
    Top = 0
    Width = 894
    Height = 874
    HelpType = htKeyword
    Align = alClient
    Constraints.MinHeight = 56
    Constraints.MinWidth = 56
    Color = clBtnFace
    ParentColor = False
    TabOrder = 0
    inherited PaintBox: TPaintBox
      Width = 878
      Height = 858
    end
    inherited HScrollBar: TScrollBar
      Top = 858
      Width = 894
    end
    inherited VScrollBar: TScrollBar
      Left = 878
      Height = 858
    end
  end
end
